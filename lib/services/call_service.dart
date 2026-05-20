import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'api.dart';

/// State of a single call
class CallState {
  bool outgoing = false;    // we placed the call
  bool ringing = false;     // incoming, not yet answered
  bool inCall = false;      // connected
  bool loudspeaker = false;
  int duration = 0;         // seconds
  Map<String, dynamic>? incomingOffer; // SDP from remote peer

  RTCPeerConnection? pc;
  MediaStream? localStream;
  MediaStream? remoteStream;
  List<RTCIceCandidate> iceBuf = []; // buffered ICE before remoteDescription set
  int lastSigId = 0;
  Timer? durTimer;

  bool get active => inCall || outgoing || ringing;
}

/// Port of the WebRTC system from app.js
/// Uses chat.send with signal_type for signalling (same as original)
class CallService {
  static final CallState state = CallState();
  static Function()? onStateChanged; // call setState in UI

  static const _iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
    {'urls': 'stun:stun.cloudflare.com:3478'},
  ];

  static final _pcConfig = {
    'iceServers': _iceServers,
    'iceCandidatePoolSize': 10,
    'iceTransportPolicy': 'all',
    'bundlePolicy': 'max-bundle',
    'sdpSemantics': 'unified-plan',
  };

  // ── Create peer connection ──────────────────────────────────────────────────
  // Port of makePeerConn()
  static Future<RTCPeerConnection> _makePc(int threadId) async {
    final pc = await createPeerConnection(_pcConfig);

    pc.onIceCandidate = (candidate) async {
      try {
        await _sendSignal(threadId, 'call_ice', {
          'candidate': candidate.toMap(),
        });
      } catch (_) {}
    };

    pc.onIceConnectionState = (state_) async {
      if (state_ == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state_ == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        if (!state.inCall && (state.outgoing || state.ringing)) {
          state.inCall = true;
          state.outgoing = false;
          state.ringing = false;
          state.durTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            state.duration++;
            onStateChanged?.call();
          });
          onStateChanged?.call();
        }
      }
      if (state_ == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        teardown();
        onStateChanged?.call();
      }
    };

    pc.onConnectionState = (s) {
      if (s == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        teardown();
        onStateChanged?.call();
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        state.remoteStream = event.streams[0];
      } else {
        state.remoteStream ??= event.track.kind == 'audio'
            ? MediaStream('remote', 'remote')
            : null;
        state.remoteStream?.addTrack(event.track);
      }
      onStateChanged?.call();
    };

    return pc;
  }

  // ── Start an outgoing call ─────────────────────────────────────────────────
  // Port of startCall()
  static Future<String?> startCall(int threadId) async {
    if (state.inCall || state.outgoing) return null;
    try {
      final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      state.localStream = stream;
      final pc = await _makePc(threadId);
      state.pc = pc;

      for (final track in stream.getTracks()) {
        await pc.addTrack(track, stream);
      }

      final offer = await pc.createOffer({'offerToReceiveAudio': true});
      await pc.setLocalDescription(offer);

      await _sendSignal(threadId, 'call_offer', {
        'sdp': {'type': offer.type, 'sdp': offer.sdp},
      });

      state.outgoing = true;
      onStateChanged?.call();
      return null;
    } catch (e) {
      state.outgoing = false;
      teardown();
      return e.toString();
    }
  }

  // ── Answer an incoming call ────────────────────────────────────────────────
  // Port of answerCall()
  static Future<String?> answerCall(int threadId) async {
    if (state.incomingOffer == null) return 'No incoming offer';
    try {
      final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      state.localStream = stream;
      final pc = await _makePc(threadId);
      state.pc = pc;

      for (final track in stream.getTracks()) {
        await pc.addTrack(track, stream);
      }

      final offerSdp = RTCSessionDescription(
        state.incomingOffer!['sdp'],
        state.incomingOffer!['type'],
      );
      await pc.setRemoteDescription(offerSdp);

      // Flush buffered ICE
      for (final c in state.iceBuf) {
        try { await pc.addCandidate(c); } catch (_) {}
      }
      state.iceBuf.clear();

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _sendSignal(threadId, 'call_answer', {
        'sdp': {'type': answer.type, 'sdp': answer.sdp},
      });

      state.ringing = false;
      state.inCall = true;
      state.durTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        state.duration++;
        onStateChanged?.call();
      });
      onStateChanged?.call();
      return null;
    } catch (e) {
      teardown();
      try { await _sendSignal(threadId, 'call_end', {'reason': 'failed'}); } catch (_) {}
      return e.toString();
    }
  }

  // ── End call ───────────────────────────────────────────────────────────────
  // Port of endCall()
  static Future<void> endCall(int threadId) async {
    final dur = state.duration;
    try {
      await _sendSignal(threadId, 'call_end', {'reason': 'hangup', 'duration': dur});
    } catch (_) {}
    if (dur > 0) {
      try {
        await ApiService.call('chat.send', {
          'thread_id': threadId,
          'message': jsonEncode({'sys': 'call_ended', 'duration': dur}),
          'signal_type': 'call_summary',
        });
      } catch (_) {}
    }
    teardown();
    onStateChanged?.call();
  }

  // ── Reject incoming call ───────────────────────────────────────────────────
  static Future<void> rejectCall(int threadId) async {
    try { await _sendSignal(threadId, 'call_end', {'reason': 'rejected'}); } catch (_) {}
    teardown();
    onStateChanged?.call();
  }

  // ── Toggle speaker (iOS/Android) ───────────────────────────────────────────
  // Port of toggleSpeaker()
  static Future<void> toggleSpeaker() async {
    state.loudspeaker = !state.loudspeaker;
    // flutter_webrtc exposes this via Helper on mobile
    try {
      await Helper.setSpeakerphoneOn(state.loudspeaker);
    } catch (_) {}
    onStateChanged?.call();
  }

  // ── Handle incoming signals (from chat polling) ────────────────────────────
  // Port of handleSignals(msgs)
  static Future<void> handleSignals(List<Map<String, dynamic>> msgs, int threadId, int myUserId) async {
    for (final m in msgs) {
      final sid = int.tryParse(m['id']?.toString() ?? '0') ?? 0;
      if (sid <= state.lastSigId) continue;
      state.lastSigId = sid;

      Map<String, dynamic> o;
      try { o = jsonDecode(m['body'] ?? '{}'); } catch (_) { continue; }

      final type = o['t'] ?? o['type'];
      final p = (o['p'] ?? {}) as Map<String, dynamic>;
      if (type == null) continue;

      // Ignore my own messages
      if (m['sender_id']?.toString() == myUserId.toString()) continue;

      switch (type) {
        case 'call_offer':
          if (state.inCall || state.outgoing) continue;
          // Ignore stale (> 90s old)
          if (o['at'] != null && DateTime.now().millisecondsSinceEpoch - (o['at'] as int) > 90000) continue;
          state.incomingOffer = p['sdp'];
          state.ringing = true;
          onStateChanged?.call();
          break;

        case 'call_answer':
          if (state.pc == null || state.inCall) continue;
          if (o['at'] != null && DateTime.now().millisecondsSinceEpoch - (o['at'] as int) > 90000) continue;
          try {
            final sdp = RTCSessionDescription(p['sdp']['sdp'], p['sdp']['type']);
            await state.pc!.setRemoteDescription(sdp);
            for (final c in state.iceBuf) {
              try { await state.pc!.addCandidate(c); } catch (_) {}
            }
            state.iceBuf.clear();
            state.inCall = true;
            state.outgoing = false;
            state.durTimer = Timer.periodic(const Duration(seconds: 1), (_) {
              state.duration++;
              onStateChanged?.call();
            });
            onStateChanged?.call();
          } catch (_) {}
          break;

        case 'call_ice':
          if (p['candidate'] == null) continue;
          final candidate = RTCIceCandidate(
            p['candidate']['candidate'],
            p['candidate']['sdpMid'],
            p['candidate']['sdpMLineIndex'],
          );
          final rd = await state.pc?.getRemoteDescription();
          if (rd?.type != null) {
            try { await state.pc!.addCandidate(candidate); } catch (_) {}
          } else {
            state.iceBuf.add(candidate);
          }
          break;

        case 'call_end':
          if (state.active) {
            teardown();
            onStateChanged?.call();
          }
          break;
      }
    }
  }

  // ── Teardown ───────────────────────────────────────────────────────────────
  // Port of teardownCall()
  static void teardown() {
    try {
      state.pc?.onIceCandidate = null;
      state.pc?.onTrack = null;
      state.pc?.close();
    } catch (_) {}
    try { state.localStream?.getTracks().forEach((t) => t.stop()); } catch (_) {}
    state.durTimer?.cancel();
    state.pc = null;
    state.localStream = null;
    state.remoteStream = null;
    state.inCall = false;
    state.outgoing = false;
    state.ringing = false;
    state.incomingOffer = null;
    state.iceBuf.clear();
    state.duration = 0;
    state.durTimer = null;
    state.loudspeaker = false;
  }

  // ── Format call duration ───────────────────────────────────────────────────
  // Port of fmtCallDur(s)
  static String fmtDur(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m > 0 ? m : 0}:${r.toString().padLeft(2, '0')}';
  }

  // ── Send a signal message via chat.send ────────────────────────────────────
  // Port of sendSignalMsg(type, payload)
  static Future<void> _sendSignal(int threadId, String type, Map<String, dynamic> payload) async {
    await ApiService.call('chat.send', {
      'thread_id': threadId,
      'message': jsonEncode({'t': type, 'p': payload, 'at': DateTime.now().millisecondsSinceEpoch}),
      'signal_type': type,
    });
  }
}
