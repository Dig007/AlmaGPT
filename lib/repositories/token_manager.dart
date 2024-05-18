import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String tokenUrl = 'https://securetoken.googleapis.com/v1/token';
  static const String apiKey = 'AIzaSyBkanDK4DjniXPjw7TWA1dp9bUeOyHov6c';

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expirationDate = prefs.getInt('token_expiration_date') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime < expirationDate) {
      return prefs.getString('access_token') ?? '';
    } else {
      return await refreshToken(prefs);
    }
  }

  static Future<String> refreshToken(SharedPreferences prefs) async {
    try {
      var refreshToken = prefs.getString('refresh_token') ??
          'AMf-vBxztAkcjH5-szemDJOy1l2cJJda4-Gfyl3J05wMDKGyy4WVs-ItlHEqhVPEMMoKii8LLYKV-z27l153-pbxZ6znyqEENOECofAs9QWXSaRUj3MUnUoWADI1YkPCgdSuumil-POoQqlBd4KaSxV4XsskgcRMwx2kFlyS0_HeBHO94AACOEM';
      var response = await http.post(
        Uri.parse('$tokenUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'User-Agent':
              'Dalvik/2.1.0 (Linux; U; Android 11; Redmi Note 5 Build/RQ3A.211001.001)',
          'X-Client-Version': 'Android/Fallback/X22001002/FirebaseCore-Android',
          'X-Android-Cert': '43D7F272E99AD8C847D911AA565AE3BCD74188CD',
          'Accept-Language': 'in-ID, en-US',
          'Accept-Encoding': 'gzip',
          'X-Android-Package': 'co.appnation.geniechat',
          'X-Firebase-Client':
              'H4sIAAAAAAAAAKtWykhNLCpJSk0sKVayio7VUSpLLSrOzM9TslIyUqoFAFyivEQfAAAA',
          'X-Firebase-Gmpid': '1:467270152911:android:9e21622fbcb4a9cc673dba',
        },
        body: jsonEncode(
            {"grantType": "refresh_token", "refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        await prefs.setInt(
            'token_expiration_date',
            DateTime.now().millisecondsSinceEpoch +
                int.parse(data['expires_in']) * 1000);
        return data['access_token'];
      } else {
        throw Exception(
            'Failed to refresh token with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error refreshing token: $e');
    }
  }
}
