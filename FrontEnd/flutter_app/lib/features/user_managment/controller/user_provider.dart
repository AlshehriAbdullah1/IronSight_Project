import 'dart:ffi';
import 'dart:io';

import 'package:iron_sight/APIs/game_api_client.dart';
import 'package:iron_sight/APIs/tournament_api_client.dart';
import 'package:iron_sight/APIs/user_api_client.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/models/game.dart';
import 'package:iron_sight/models/tournament.dart';
import 'package:iron_sight/models/user.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// // final userStateProvider = StateNotifierProvider<UserState, User?>((ref) {
// //   final userApiClient = ref.read(userApiClientProvider);
// //   return UserState(userApiClient);
// // });

// final usersProvider = FutureProvider<List<User>>((ref) async {
//   final userApiClient = ref.read(userApiClientProvider);
//   return userApiClient.getUsers();
// });

// final userStateProvider = StateNotifierProvider<UserState, User?>((ref) {
//   final userApiClient = ref.read(userApiClientProvider);
//   return UserState(userApiClient);
// });

// final ParticipatedTournamentsProvider = StateNotifierProvider<
//     ParticipatedTournamentsState, List<ParticipatedTournaments?>>((ref) {
//   final tournamentApiClient = ref.read(userApiClientProvider);
//   return ParticipatedTournamentsState(tournamentApiClient);
// });

// class ParticipatedTournamentsState
//     extends StateNotifier<List<ParticipatedTournaments?>> {
//   final UserApiClient _userApiClient;
//   ParticipatedTournamentsState(this._userApiClient) : super([]);

//   Future<List<ParticipatedTournaments>> getParticipatedTournaments(
//       String id, String tourType) async {
//     final participatedTournaments =
//         await _userApiClient.getParticipatedTournaments(id, tourType);
//     state = participatedTournaments;
//     print('returning participated tournaments from state notifier');
//     return participatedTournaments;
//   }
// }

// class UserState extends StateNotifier<AppUser?> {
//   final UserApiClient _userApiClient;
//   UserState(this._userApiClient) : super(null);

//   Future<AppUser> getUser(String id) async {
//     final user = await _userApiClient.getUser(id);
//     state = user;
//     print('returning user from state notifier');
//     return user;
//   }

//   Future<String?> editUser(String id, Map<String, dynamic> userData) async {
//     final user = await _userApiClient.editUser(id, userData);
//     if (user != null) {
//       //make the state equal to the returned tournament
//       state = user;
//       return 'User has been updated successfully';
//     } else {
//       return 'Error in updating the user';
//     }
//   }

//   Future<String> createUser(Map<String, dynamic> userData) async {
//     print('create user called in notifoer');
//     String? response =
//         await _userApiClient.createUser(userData).toString(); //check this
//     final user = await _userApiClient.createUser(userData);
//     if (response != null) {
//       return 'User has been created successfully';
//     } else {
//       return 'Error in creating the user';
//     }
//   }

//   // Future<void> _launchGoogleSignIn() async {
//   //   try {
//   //     String googleSignInUrl = getGoogleAuthUrl();
//   //     // if (await canLaunchUrl(Uri.parse(googleSignInUrl))) {
//   //     //   await launchUrl(Uri.parse(googleSignInUrl),
//   //     //       mode: LaunchMode.inAppBrowserView);
//   //     // } else {
//   //     //   throw 'Could not launch $googleSignInUrl';
//   //     // }
//   //   } catch (error) {
//   //     print('An error occurred during sign-in: $error');
//   //   }
//   // }

// // also add this (we will change it later)
//   String getGoogleAuthUrl() {
//     const String googleClientId =
//         '300450977778-p1m3rflk0ah5cgml70i7i35updj8e07s.apps.googleusercontent.com';
//     const String googleOauthRedirectUrl =
//         'https://redesigned-space-meme-6q7qxr45xpxf54jq-3001.app.github.dev/api/sessions/oauth/google';
//     const rootUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
//     final options = {
//       'redirect_uri': googleOauthRedirectUrl,
//       'client_id': googleClientId,
//       'access_type': 'offline',
//       'response_type': 'code',
//       'prompt': 'consent',
//       'scope': [
//         'https://www.googleapis.com/auth/userinfo.profile',
//         'https://www.googleapis.com/auth/userinfo.email'
//       ].join(" "),
//     };
// // print(options);
//     Uri uri = Uri(queryParameters: options);
//     String queryString = uri.query;
// // print(uri.toString());

// // print('\n\n\n${rootUrl}?${queryString.toString()}');
//     return '${rootUrl.toString()}?${queryString.toString()}';
//   }

//   Future<void> _launchStartGgSignIn() async {
//     try {
//       String startGgSignInUrl = getStartGgAuthUrl();
//       // if (await canLaunchUrl(Uri.parse(startGgSignInUrl))) {
//       //   await launchUrl(Uri.parse(startGgSignInUrl),
//       //       mode: LaunchMode.inAppBrowserView);
//       // } else {
//       //   throw 'Could not launch $startGgSignInUrl';
//       // }
//     } catch (error) {
//       print('An error occurred during sign-in: $error');
//     }
//   }

//   String getStartGgAuthUrl() {
//     const String startGgClientId = "104";
//     const String startGgRedirectUrl =
//         "https://redesigned-space-meme-6q7qxr45xpxf54jq-3001.app.github.dev/api/sessions/oauth/startgg";
//     String rootUrl = 'https://start.gg/oauth/authorize';

//     final options = {
//       'response_type': 'code',
//       'client_id': startGgClientId,
//       'scope': 'user.identity user.email',
//       'redirect_uri': startGgRedirectUrl,
//     };

//     Uri uri = Uri(queryParameters: options);

//     String queryString = uri.query;

//     return "$rootUrl?$queryString".replaceAll('+', "%20");
//   }
// }
//function to get pariticpated tournaments by type
// "Followed" ""
final getParticpatedTournaments = FutureProvider.family
    .autoDispose<List<Tournament>?, String>((ref, type) async {
  final _userApiClient = ref.read(userApiClientProvider);
  final userId = ref.read(userProvider.notifier).state.user;
  if (userId == null) {
    return [];
  }
  return _userApiClient.getParticipatedTournamentsByType(userId.id, type);
});

final UserSuggestionProvider =
    FutureProvider.family<List<UserModel>, String>((ref, query) async {
  try {
    final userApiClient = ref.read(userApiClientProvider);
    final users = await userApiClient.searchUsers(query);
    return users;
  } catch (e) {
    rethrow;
  }
});

//new work
final isNewUserProvider = FutureProvider.family<bool, String>((ref, uid) async {
  final userApiClient = ref.read(userApiClientProvider);
  final user = await userApiClient.getUser(uid);
  return user.banner == "";
});
final userProvider = StateNotifierProvider<UserController, UserState>((ref) {
  final _authState = ref.watch(authControllerProvider.notifier);
  final _userApiClient = ref.read(userApiClientProvider);

  return UserController(_authState, _userApiClient, ref);
});

class UserController extends StateNotifier<UserState> {
  final AuthController _authState;
  Ref _ref;
  final UserApiClient _userApiClient;

  UserController(this._authState, this._userApiClient, this._ref)
      : super(UserState.initial());
//returns true if the user is new and false if the user is not new
  Future<bool> loadUser(String userId) async {
    state = UserState.loading();
    try {
      final user = await _userApiClient.getUser(userId);
      state = UserState.loaded(user);
      _loadParticipatedTournaments();
      return user.banner == "" ? true : false;
    } catch (e) {
      state = UserState.error(e.toString());
      rethrow;
    }
  }

  _loadParticipatedTournaments() async {
    if (state.user != null) {
      await _userApiClient.getParticipatedTournaments(state.user!.id);
    }
  }

  bool get isOwner {
    return _authState.getCurrentUserId() == state.user?.id;
  }

  Future<bool> loadIsFollowingTournament(String tournamentId) async {
    if (state.user == null && _authState.getCurrentUserId() != null) {
      await loadUser(_authState.getCurrentUserId()!);
    }
    final followedTournaments =
        await _ref.read(getParticpatedTournaments('Followed').future);
    if (state.user != null && followedTournaments != null) {
      updateUserStateWithFollowedTournaments(followedTournaments);
    } else {
      return false;
    }

    return state.user!.participatedTournaments['Followed']!.any((element) {
      return element.id == tournamentId;
    });
  }

  void updateUserStateWithFollowedTournaments(
      List<Tournament> followedTournaments) {
    // Update the state with the new followed tournaments.
    // This is highly dependent on how your state management is set up.
    var updatedUser = state.user!.copyWith(participatedTournaments: {
      'Followed': followedTournaments,
      ...state.user!.participatedTournaments
    });
    state = UserState.loaded(
        updatedUser); // Assuming UserState.loaded is a valid way to update the state.
  }

  bool isFollowingTournament(String tournamentId) {
    if (state.user != null) {
      if (state.user!.participatedTournaments['Followed'] != null) {
        return state.user!.participatedTournaments['Followed']!.any((element) {
          return element.id == tournamentId;
        });
      }
    }
    return false;
  }

// optimistically follow a tournament, if failed then throw an exception
  Future<void> followTournament(Tournament tournament) async {
    List<Tournament>? optimisticFollowedTournaments =
        state.user?.participatedTournaments['Followed'];
    bool wasAddedOptimistically = false;
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (state.user != null) {
      if (optimisticFollowedTournaments != null) {
        optimisticFollowedTournaments.add(tournament);
        wasAddedOptimistically = true;
      } else {
        optimisticFollowedTournaments = [tournament];
        state.user!.participatedTournaments['Followed'] =
            optimisticFollowedTournaments;
        wasAddedOptimistically = true;
      }
      updateUserState(state.user!);
    }

    try {
      if (userId != null) {
        final apiFollowedTournaments =
            await _userApiClient.followTournament(userId, tournament.id);
        // Assuming the API call returns the updated list of followed tournaments
        state.user!.participatedTournaments['Followed'] =
            apiFollowedTournaments;
        updateUserState(state
            .user!); // Ensure this method properly updates the state and notifies listeners
      } else {
        throw 'User is not logged in';
      }
    } catch (e) {
      if (wasAddedOptimistically && optimisticFollowedTournaments != null) {
        optimisticFollowedTournaments.removeWhere((t) => t.id == tournament.id);
        updateUserState(state.user!); // Revert optimistic update
      }
      rethrow; // Consider handling this error more gracefully
    }
  }

  void updateUserState(UserModel user) {
    // Update the state with the new user data
    // This is highly dependent on how your state management is set up
    // For example, if using a state notifier, you might simply assign a new state
    state = state.copyWith(user: user);
  }

  Future<void> unfollowTournament(Tournament tournament) async {
    List<Tournament>? optimisticFollowedTournaments =
        state.user?.participatedTournaments['Followed'];
    bool wasRemovedOptimistically = false;
    int tournamentIndex = -1; // Declare tournamentIndex here
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (state.user != null && optimisticFollowedTournaments != null) {
      tournamentIndex = optimisticFollowedTournaments
          .indexWhere((t) => t.id == tournament.id);
      if (tournamentIndex != -1) {
        optimisticFollowedTournaments.removeAt(tournamentIndex);
        wasRemovedOptimistically = true;
        updateUserState(state.user!);
      }
    }

    try {
      if (userId != null) {
        final apiFollowedTournaments =
            await _userApiClient.unfollowTournament(userId, tournament.id);
        // Assuming the API call returns the updated list of followed tournaments
        state.user!.participatedTournaments['Followed'] =
            apiFollowedTournaments;
        updateUserState(state
            .user!); // Ensure this method properly updates the state and notifies listeners
      } else {
        throw 'User is not logged in';
      }
    } catch (e) {
      if (wasRemovedOptimistically && tournamentIndex != -1) {
        // If the tournament was removed optimistically, add it back
        optimisticFollowedTournaments?.insert(tournamentIndex, tournament);
        updateUserState(state.user!); // Undo optimistic update
      }
      rethrow; // Consider handling this error more gracefully
    }
  }

  String get getUsername {
    return _authState.getCurrentUserId() == state.user?.id
        ? state.user!.username
        : 'Unknown';
  }

  String get getProfileImage {
    return _authState.getCurrentUserId() == state.user?.id
        ? state.user!.profilepic
        : 'https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2F1JlUF0P2ehTollmpjwppvgiU1Sk2%2FBanner?generation=1713840325862859&alt=media';
  }

  Future<String?> editUser(Map<String, dynamic> userData) async {
    if (_authState.getCurrentUserId() == state.user?.id) {
      if (userData == {} || userData.isEmpty) {
        return null;
      }
      try {
        final user = await _userApiClient.editUser(state.user!.id, userData);
        if (user != null) {
          //make the state equal to the returned tournament
          state = UserState.loaded(user);
          return null;
        } else {
          return 'Error in updating the user';
        }
      } catch (e) {
        return e.toString();
      }
    } else {
      return 'You are not the owner of this user';
    }
  }

  bool isFollowingGame(Game game) {
    if (state.user != null) {
      return state.user!.preferences.contains(game);
    }
    return false;
  }

  
  bool isFollowingGameUsingGameId(String gameId) {
  if (state.user != null) {
    return state.user!.preferences.any((game) => game.id == gameId);
  }
  return false;
}

  Future<void> loadUserGames() async {
    final userId= _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (state.user != null && userId !=null) {
      final myGames =
          await _ref.read(gameApiClientProvider).getUserGames(userId);
      print('updating the state games of the user');
      state = state.copyWith(user: state.user!.copyWith(preferences: myGames));
    }
 
  }

  Future<bool> uploadImages(File image, String field) async {
    try {
      if (state.user != null) {
        final response = await _userApiClient.uploadUserPicture(
            image, state.user!.id, field);
        if (response != null) {
          state = state.copyWith(user: state.user!.copyWithMap(response));
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  String getUserProfileImage(){
    return _authState.getCurrentUserId() == state.user?.id
       ? state.user!.profilepic
        : 'https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2F1JlUF0P2ehTollmpjwppvgiU1Sk2%2FBanner?generation=1713840325862859&alt=media';
  }

  void updateUserPreferences(List<Game> gamesList, String userId) {
    if (_authState.getCurrentUserId() == userId) {
      state =
          state.copyWith(user: state.user!.copyWith(preferences: gamesList));
    }
  }
}

class UserState {
  final UserModel? user;
  final String? error;
  final bool isLoading;
  UserState({
    this.user,
    this.error,
    this.isLoading = false,
  });

  factory UserState.initial() => UserState();

  factory UserState.loading() => UserState(isLoading: true);

  factory UserState.loaded(UserModel user) => UserState(user: user);

  factory UserState.error(String error) => UserState(error: error);

  //create method that update the state
  UserState copyWith({UserModel? user, String? error, bool? isLoading}) {
    return UserState(
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
