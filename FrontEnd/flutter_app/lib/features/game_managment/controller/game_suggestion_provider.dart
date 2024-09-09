import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/game_api_client.dart';
import 'package:iron_sight/models/game.dart';




final gameSuggestionProvider = FutureProvider.family<List<Game>, String>((ref,query ) async {
  try {
    final gameApiClient = ref.read(gameApiClientProvider);
  final games= await gameApiClient.searchGames(query);
  return games;
  } catch (e) {
    rethrow;
  } 
});

