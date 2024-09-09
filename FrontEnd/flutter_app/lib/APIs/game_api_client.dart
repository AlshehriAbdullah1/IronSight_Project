import 'dart:convert';

import 'package:iron_sight/APIs/api_client.dart';
import 'package:iron_sight/models/game.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;

final gameApiClientProvider = Provider<GameApiClient>((ref) {
  return GameApiClient();
});

class GameApiClient {
  final String baseUrl = ApiClient.baseUrl;

  GameApiClient();

  Future<List<Game>> getGames() async {
    final response = await http.get(
      Uri.parse("$baseUrl/games"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      Iterable list = result;
      return list.map((game) => Game.fromJson(game)).toList();
    } else {
      throw Exception("Failed to load games");
    }
  }

  Future<List<Game>> searchGames(String querySearch) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/search/games/?SearchQuery=$querySearch'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        Iterable list = result;
        return list.map((game) => Game.fromJson(game)).toList();
      }
      throw 'Error in loading games';
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Game>> getUserGames(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId/gamePreferences"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      Iterable list = result;
      return list.map((game) => Game.fromJson(game)).toList();
    } else {
      throw Exception("Failed to load games");
    }
  }

  Future<Game> getGame(String gameId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/games?Game_Id=$gameId"),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Game.fromJson(result);
    } else {
      throw Exception("Failed to load specific game");
    }
  }

  Future<Game> suggestGame() async {
    final response = await http.get(
      Uri.parse("$baseUrl/games/suggest"),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Game.fromJson(result);
    } else {
      throw Exception("Failed to suggest a game");
    }
  }

  Future<Game> deleteGame(String gameId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/games/$gameId"),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Game.fromJson(result);
    } else {
      throw Exception("Failed to Delete game");
    }
  }

  Future<List<Game>?> submitPreferences(
      List<String> prefferedGamesList, userId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/users/$userId/addGamePreferences"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'Game_Ids': prefferedGamesList, 'User_Id': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        // return the list of games
        if (result.length > 0) {
          final userGames = await getUserGames(userId);
          return userGames;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Game>?> removePreferences(String gameId, userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/users/$userId/removeGamePreferences/?Game_Id=$gameId"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        // return the list of games
        if (result.length > 0) {
          final userGames = await getUserGames(userId);
          return userGames;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }


}
