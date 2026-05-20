/// App-wide configuration constants.
/// The Google Maps API key is the same one from the original index.html:
///   window.GMAPS_KEY = 'AIzaSyBTtJz6qY4IaEvwGG01gM-BgaxH2oNmTzQ'
class AppConfig {
  /// Google Maps API key — used for:
  ///   - google_maps_flutter (delivery map)
  ///   - Places Autocomplete (voice route geocoding)
  static const googleMapsApiKey = 'AIzaSyBTtJz6qY4IaEvwGG01gM-BgaxH2oNmTzQ';

  /// Base URL for server.php — set this to your actual server
  static const serverUrl = 'https://your-domain.com/server.php';
}
