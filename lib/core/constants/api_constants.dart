/// Oxford Dictionary API Constants
class ApiConstants {
  ApiConstants._();

  // Oxford Dictionaries API
  // Register at: https://developer.oxforddictionaries.com/
  // Free tier: 1000 requests/month
  static const String oxfordBaseUrl = 'https://od-api-sandbox.oxforddictionaries.com/api/v2';
  
  // TODO: Replace with your actual API credentials
  static const String oxfordAppId = 'YOUR_APP_ID';
  static const String oxfordAppKey = 'YOUR_APP_KEY';
  
  // Endpoints
  static String entriesEndpoint(String word) => '$oxfordBaseUrl/entries/en-us/$word';
  static String lemmasEndpoint(String word) => '$oxfordBaseUrl/lemmas/en/$word';
  
  // Headers for API requests
  static Map<String, String> get oxfordHeaders => {
    'app_id': oxfordAppId,
    'app_key': oxfordAppKey,
    'Accept': 'application/json',
  };
}
