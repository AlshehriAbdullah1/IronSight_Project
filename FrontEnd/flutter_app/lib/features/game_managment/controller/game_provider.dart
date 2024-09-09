import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/game_api_client.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/models/game.dart';
import 'package:iron_sight/models/tournament.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

final gamesProvider = FutureProvider.autoDispose<List<Game>>((ref) async {
  final _gameApiClient = ref.watch(gameApiClientProvider);
  return await _gameApiClient.getGames();
});

final gameListStateProvider =
    StateNotifierProvider<GameListState, AsyncValue<List<Game>>>((ref) {
  final gameApiClient = ref.watch(gameApiClientProvider);
  final authController = ref.watch(authControllerProvider);
  return GameListState(gameApiClient, ref);
});

class GameListState extends StateNotifier<AsyncValue<List<Game>>> {
  final GameApiClient _gameApiClient;
  Ref _ref;
  GameListState(this._gameApiClient, this._ref)
      : super(const AsyncValue<List<Game>>.loading());

  Future<void> loadGames({bool isHomeView = false}) async {
    try {
      state = const AsyncValue.loading();
      final games = await _gameApiClient.getGames();
      String? userId =
          _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if (userId != null && games != null) {
        if (isHomeView) {
          final userGames = await _gameApiClient.getUserGames(userId);
          
          if (userGames != null) {
            final userGamesIds = userGames.map((game) => game.id).toList();
            final filteredGames = games
                .where((game) => !userGamesIds.contains(game.id))
                .toList();
            state = AsyncValue.data(filteredGames);
          } else {
            state = AsyncValue.data(games);
          }
        } else {
          state = AsyncValue.data(games);
        }
      } else {
        throw 'User is not logged in';
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

final singleGameStateProvider =
    StateNotifierProvider<SingleGameState, AsyncValue<Game>>((ref) {
  final gameApiClient = ref.read(gameApiClientProvider);
  return SingleGameState(gameApiClient, ref);
});

class SingleGameState extends StateNotifier<AsyncValue<Game>> {
  final GameApiClient _gameApiClient;
  Ref _ref;
  SingleGameState(this._gameApiClient, this._ref)
      : super(const AsyncValue<Game>.loading());

  Future<void> getGame(String id) async {
    // print('trying to get game with id ' + id);
    try {
      state = const AsyncValue.loading();
      final game = await _gameApiClient.getGame(id);
      if (game != null) {
        // print('got game with info : ${game.toJson()}');
        state = AsyncValue.data(game);
      } else {
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error('An err', stackTrace);
    }
  }
}

final userGamesProvider = FutureProvider.autoDispose<List<Game>>((ref) async {
  final userId = ref.read(authControllerProvider.notifier).getCurrentUserId();
  if (userId != null) {
    final _gameApiClient = ref.watch(gameApiClientProvider);
    return await _gameApiClient.getUserGames(userId);
  } else {
    throw Exception("User Id is null, or not defined");
  }
});




class PreferencesNotifier extends StateNotifier<List<String>> {
  final Ref _ref;
  PreferencesNotifier(this._gameApiClient, this._ref) : super([]);

  final GameApiClient _gameApiClient;


  Future<void> followGame(String game) async {
    print('trying to follow the game ' + game);
    final userId = _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (userId != null) {
      try{
        final returnedPrefrences =
              await _gameApiClient.submitPreferences([game], userId);
          _ref.read(loadingProvider.notifier).state = false;
          if (returnedPrefrences != null) {
            _ref
                .read(userProvider.notifier)
                .updateUserPreferences(returnedPrefrences, userId);
          }
          else {
            _ref.read(loadingProvider.notifier).state = false;
            throw Exception("the response from backend is not success");
          }
      } 
      catch (e) {
          _ref.read(loadingProvider.notifier).state = false;
          rethrow;
        }
      }
    else {
      throw Exception("User Id is null, or not defined");
    }
  }

  Future<void> Unfollowgame(String game) async {
    print('trying to unfollow the game ' + game);
    final userId = _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (userId != null) {
      try{
        // Using the removePreferences function in game api to remove the game from the user's preferences
        final returnedPrefrences =
              await _gameApiClient.removePreferences(game, userId);
          _ref.read(loadingProvider.notifier).state = false;
          if (returnedPrefrences != null) {
            
            _ref
                .read(userProvider.notifier)
                .updateUserPreferences(returnedPrefrences, userId);
          }
          else {
            _ref.read(loadingProvider.notifier).state = false;
            throw Exception("the response from backend is not success");
          }
      }
      catch (e) {
        _ref.read(loadingProvider.notifier).state = false;
        rethrow;
      }
    }
    else {
      throw Exception("User Id is null, or not defined");
    }
  }


  void addPreference(String preference) {
    print('adding preference ' + preference);
    state = [...state, preference];
  }

  void removePreference(String preference) {
    state = state.where((game) => game != preference).toList();
  }

  Future<void> submitPreferences() async {
    _ref.read(loadingProvider.notifier).state = true;

    final userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (userId != null) {
      try {
        final returnedPrefrences =
            await _gameApiClient.submitPreferences(state, userId);
        _ref.read(loadingProvider.notifier).state = false;
        if (returnedPrefrences != null) {
          _ref
              .read(userProvider.notifier)
              .updateUserPreferences(returnedPrefrences, userId);
        } else {
          _ref.read(loadingProvider.notifier).state = false;
          throw Exception("the response from backend is not success");
        }
      } catch (e) {
        _ref.read(loadingProvider.notifier).state = false;
        rethrow;
      }
    } else {
      _ref.read(loadingProvider.notifier).state = false;
      throw Exception("User Id is null, or not defined");
    }
    _ref.read(loadingProvider.notifier).state = false;
  }

  bool isSelectedPreference(String preference) {
    return state.contains(preference);
  }

  // get games
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, List<String>>((ref) {
  final _gameApiClient = ref.watch(gameApiClientProvider);

  return PreferencesNotifier(_gameApiClient, ref);
});
