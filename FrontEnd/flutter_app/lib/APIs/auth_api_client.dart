// this file is for authentication purposes only 
// such as sign in , up and preparing headers (for future use). 
// use it when you want to to sign in or sign up

import 'package:iron_sight/APIs/api_client.dart';
import 'package:riverpod/riverpod.dart';

final authApiClientProvider =Provider<AuthApiClient>((ref) {
  return AuthApiClient();
},); 
class AuthApiClient {
    static String authUrl=ApiClient.baseUrl;
     AuthApiClient();


  //   Future<UserCredential?> signInUsingThirdParty(String customToken)async {
  //  return await  _auth.signInWithCustomToken(customToken);
   
  //   }
}