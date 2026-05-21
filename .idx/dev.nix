# Firebase Studio (Project IDX) environment configuration for Flutter
# This file tells Firebase Studio which tools to install in the workspace

{ pkgs, ... }: {

  channel = "stable-24.05";

  packages = [
    pkgs.curl
    pkgs.unzip
    pkgs.xz
    pkgs.git
  ];

  idx = {
    extensions = [
      # Flutter + Dart
      "Dart-Code.flutter"
      "Dart-Code.dart-code"

      # Useful extras
      "usernamehw.errorlens"
      "bradlc.vscode-tailwindcss"
    ];

    workspace = {
      onCreate = {
        flutter-pub-get = "flutter pub get";
      };
      onStart = {
        run-flutter = "flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000";
      };
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d"
            "web-server"
            "--web-hostname"
            "0.0.0.0"
            "--web-port"
            "$PORT"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
