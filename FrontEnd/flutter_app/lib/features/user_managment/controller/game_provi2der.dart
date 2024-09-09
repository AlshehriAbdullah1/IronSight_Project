
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/game_api_client.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/models/game.dart';

final gamesProvider = FutureProvider.autoDispose<List<Game>>((ref) async {
  final _gameApiClient = ref.watch(gameApiClientProvider);
  return await _gameApiClient.getGames();
});

// I want to make a provider to submit the prefrences to the backend
class PreferencesNotifier extends StateNotifier<List<String>> {
   final Ref _ref;

  PreferencesNotifier(this._gameApiClient,this._ref) : super([]);

  final GameApiClient _gameApiClient;

  void addPreference(String preference) {
    state = [...state, preference];
  }

  void removePreference(String preference) {
    state = state.where((game) => game != preference).toList();
  }

  Future<void> submitPreferences() async {
    final userId= _ref.read(authControllerProvider.notifier).getCurrentUserId();
    await _gameApiClient.submitPreferences(state,userId);
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, List<String>>((ref) {
  final _gameApiClient = ref.watch(gameApiClientProvider);
  
  return PreferencesNotifier(_gameApiClient,ref);
});