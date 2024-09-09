import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/auth_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:iron_sight/APIs/user_api_client.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  waitingCompletingInfo,
}

enum AuthOperation { signUp, signIn, none }

T authStateWhen<T>({
  required AuthState state,
  required T Function() initial,
  required T Function() authenticated,
  required T Function() unauthenticated,
  required T Function() loading,
  required T Function() waitingCompletingInfo,
}) {
  switch (state) {
    case AuthState.initial:
      return initial();
    case AuthState.authenticated:
      return authenticated();
    case AuthState.unauthenticated:
      return unauthenticated();
    case AuthState.loading:
      return loading();
    case AuthState.waitingCompletingInfo:

      return waitingCompletingInfo();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final userApiClient = ref.read(userApiClientProvider);

  return AuthController(ref, userApiClient);
});

final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});


class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserApiClient _userCredential;
  AuthOperation lastOperation = AuthOperation.none;

  AuthController(this._ref, this._userCredential) : super(AuthState.initial) {
    // _firebaseAuthabdullah  .signOut();
    _ref.listen(firebaseAuthProvider, (_, user) async {
      if (user != null && user is AsyncData<User?> && user.value != null) {
        try {
        
         
          // lastOperation = AuthOperation.none;
          
        } catch (e) {

          // state = AuthState.unauthenticated;
        }
      } else {

        // state = AuthState.unauthenticated;
      }
    });
  }

  void _changeState(AuthState newState) {
    // state = newState;
  }

  // create a method that gets the current state
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  //return state
  AuthState getAuthState() {
    return state;
  }

  Future<void> signIn(String email, String password) async {

    try {
    final userCredits=await  _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
           final userNeedToCompleteInfo =
              await _ref.read(userProvider.notifier).loadUser(userCredits.user!.uid);
                         
      
    if (userNeedToCompleteInfo) {
            // print('changing the state to waitingCompletingInfo');
            // _changeState(AuthState.waitingCompletingInfo);
            ;
          } else {
            // print('changing the state to authenticated');
            // _changeState(AuthState.authenticated);
            // state = AuthState.authenticated;
          }
    } catch (e) { 
  if (e is FirebaseAuthException && e.code == 'invalid-credential') {
    throw Exception('Email or password is invalid, try again');
  } else {
    rethrow;
  }
    
    }

    // try {
    //   await _firebaseAuth.signInWithEmailAndPassword(
    //       email: email, password: password);
    //   // state = AuthState.authenticated;
    //   print('success signing $email');

    // } catch (e) {
    //   // state = AuthState.unauthenticated;

    //   // return null;
    //   rethrow;
    // }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // state = AuthState.unauthenticated;
  }

  Future<bool> signInUsingThirdParty(String token) async {
   
    try {
      final userCredential = await _firebaseAuth.signInWithCustomToken(token);
      // state = AuthState.authenticated;
      if(userCredential.user ==null){
        throw Exception("failed to sign in,try again or use diffrenet sign in method");
      }
      else{
     final userNeedToCompleteInfo= await _ref.read(userProvider.notifier).loadUser(userCredential.user!.uid);
        return userNeedToCompleteInfo;
      }
      
    } catch (e) {
      // state = AuthState.unauthenticated;
      rethrow;
    }
  }

  Future<bool> signUp(String email, String password) async {
    lastOperation = AuthOperation.signUp;
    try {
     final userCredits = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
        await _userCredential.signUpUser(
                userCredits.user!.email!, userCredits.user!.uid);
       final userNeedToCompleteInfo =
              await _ref.read(userProvider.notifier).loadUser(userCredits.user!.uid);
                          
                          
  
    if (userNeedToCompleteInfo) {
            // print('changing the state to waitingCompletingInfo');
            
            // _changeState(AuthState.waitingCompletingInfo);
            return true;
            ;
          } else {
            // print('changing the state to authenticated');
            // _changeState(AuthState.authenticated);
            // state = AuthState.authenticated;
                   return false;
          }
    } catch (e) {
      if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'email-already-in-use':
        throw ('The email is already in use. Please use a different email.');
      case 'invalid-email':
        throw Exception('The email is invalid. Please enter a valid email.');
      case 'operation-not-allowed':
        throw Exception('Sign up is not allowed. Please contact support.');
      case 'weak-password':
        throw Exception('The password is too weak. Please enter a stronger password.');
      default:
        throw Exception('An unknown error occurred. Please try again.');
    }
  } else {
    rethrow;
  }
    }
    //   if (userCredential.user != null) {
    //     // Go to the backend
    //     try {
    //       final user = await _userCredential.signUpUser(
    //        email, userCredential.user!.uid);
    //        if(user != null) {
    //                      await _ref.read(userProvider.notifier).loadUser(user.id);
    //          state = AuthState.waitingCompletingInfo;
    //        }
    //        else{
    //           state= AuthState.unauthenticated;
    //             // _firebaseAuth.signOut();
    //           print("error in signing up user is null : ");
    //        }
    //     } catch (e) {
    //       //print the error
    //       print("excetpion in signing up : ${e}");
    //       // _firebaseAuth.signOut();
    //       state= AuthState.unauthenticated;
    //     }

    //     return userCredential;
    //   }
    // } catch (e) {
    //   state = AuthState.unauthenticated;
    //   throw e;
    // }
  }
}
