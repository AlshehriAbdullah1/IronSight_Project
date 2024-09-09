import 'package:iron_sight/models/tournament.dart';

class Game {
  final String id;
  final String mainPicture;
  final String bannerPicture;
  final String gameName;
  final String description;
  final String releaseDate;
  final String developer;
  final List<String> genre; // Change the type to List<String>

  Game({
    required this.id,
    required this.mainPicture,
    required this.bannerPicture,
    required this.gameName,
    required this.description,
    required this.releaseDate,
    required this.developer,
    required this.genre,
  });

  Map<String, dynamic> GameToJson(Game Game) {
    return {
      "id": Game.id,
      "mainPicture": Game.mainPicture,
      "bannerPicture": Game.bannerPicture,
      "gameName": Game.gameName,
      "description": Game.description,
      "releaseDate": Game.releaseDate,
      "developer": Game.developer,
      "genre": Game.genre, // Convert genre to a JSON array
    };
  }

  Game copyWith({
    String? id,
    String? mainPicture,
    String? bannerPicture,
    String? gameName,
    String? description,
    String? releaseDate,
    String? developer,
    List<String>? genre, // Change the type to List<String>
  }) {
    return Game(
      id: id ?? this.id,
      mainPicture: mainPicture ?? this.mainPicture,
      bannerPicture: bannerPicture ?? this.bannerPicture,
      gameName: gameName ?? this.gameName,
      description: description ?? this.description,
      releaseDate: releaseDate ?? this.releaseDate,
      developer: developer ?? this.developer,
      genre: genre ?? this.genre, // Use the new genre
    );
  }

  @override
  String toString() {
    return '''Game{
      id: $id,
      mainPicture: $mainPicture,
      bannerPicture: $bannerPicture,
      gameName: $gameName,
      description: $description,
      releaseDate: $releaseDate,
      developer: $developer,
      genre: $genre
    }''';
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['Game_Id'],
      mainPicture: json['Game_Img_Main'],
      bannerPicture: json['Game_Img_Banner'],
      gameName: json['Game_Name'],
      description: json['Game_Description'],
      releaseDate: json['Release_Date'],
      developer: json['Developer'] ?? 'Unknown',
      genre: List<String>.from(
          json['Game_Genre'] ?? []), // Parse genre from a JSON array
    );
  }
}
