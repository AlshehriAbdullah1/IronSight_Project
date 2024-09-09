
import 'package:intl/intl.dart';
import 'package:iron_sight/models/game.dart';
import 'package:iron_sight/models/tournament.dart';

class UserModel {
  final String id;
  final String email;
  final String profilepic;
  // final String phone;
  final String banner;
  final String username;
  final String displayName;
  final String bio;
  final Map<String, dynamic> Badges;
  final List<dynamic> Following;
  final List<dynamic> Followers;
  final Map<String, List<Tournament>> participatedTournaments;
  final List<Game> preferences;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.profilepic,
    required this.banner,
    required this.username,
    required this.isVerified,
    required this.displayName,
    required this.bio,
    required this.Badges,
    required this.participatedTournaments,
    required this.Following,
    required this.Followers,
    required this.preferences,
    // required this.phone,
  });

  Map<String, dynamic> userToJson(UserModel user) {
    return {
      "id": user.id,
      "email": user.email,
      "profilepic": user.profilepic,
      "banner": user.banner,
      "username": user.username,
      "displayName": user.displayName,
      "bio": user.bio,
      "Badges": user.Badges,
      "Tournaments": user.participatedTournaments,
      "Following": user.Following,
      "Followers": user.Followers,
      "preferences": user.preferences,
      // "Phone": user.phone,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? profilepic,
    String? banner,
    String? username,
    String? displayName,
    String? bio,
    Map<String, dynamic>? Badges,
    Map<String, List<Tournament>>? participatedTournaments,
    int? birthDate,
    List<dynamic>? Following,
    List<dynamic>? Followers,
    List<Game>? preferences,
    bool? isVerified,
    // String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      profilepic: profilepic ?? this.profilepic,
      banner: banner ?? this.banner,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      Badges: Badges ?? this.Badges,
      participatedTournaments: participatedTournaments ?? this.participatedTournaments,
      Following: Following ?? this.Following,
      Followers: Followers ?? this.Followers,
      preferences: preferences ?? this.preferences,
      isVerified: isVerified ?? this.isVerified,
      // phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, profilepic: $profilepic, banner: $banner, username: $username, accountname: $displayName, bio: $bio, Badges: $Badges, Tournaments: $participatedTournaments, Following: $Following, Followers: $Followers}';
  }

  // UserModel fromJson(Map<String, dynamic> json) {
  //   return UserModel(
  //     id: json['User_Id'],
  //     email: json['Email'],
  //     profilepic: json['Profile_Picture'],
  //     banner: json['Banner'],
  //     username: json['User_Name'],
  //     displayName: json['Display_Name'],
  //     bio: json['Bio'],
  //     Badges: json['Badges'],
  //     Tournaments: json['Tournaments'],
  //     Following: json['Following'],
  //     Followers: json['Followers'],
  //     // phone: json['Phone'],
  //   );
  // }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['User_Id'],
      email: json['Email'],
      profilepic: json['Profile_Picture'],
      banner: json['Banner'],
      username: json['User_Name'],
      displayName: json['Display_Name'],
      bio: json['Bio'],
      Badges: json['Badges'] ?? {},
      participatedTournaments: {},
      Following: json['Following'],
      Followers: json['Followers'],
      preferences: [],
      isVerified: json['isVerified']??false,
      // phone: json['Mobile_Number'] ?? 05050,
    );
  }

  UserModel copyWithMap(Map<String, dynamic> map) {
  return UserModel.fromJson({
    'User_Id': map['User_Id'] ?? id,
    'Email': map['Email'] ?? email,
    'Profile_Picture': map['Profile_Picture'] ?? profilepic,
    'Banner': map['Banner'] ?? banner,
    'User_Name': map['User_Name'] ?? username,
    'Display_Name': map['Display_Name'] ?? displayName,
    'Bio': map['Bio'] ?? bio,
    'Badges': map['Badges'] ?? Badges,
    'Tournaments': map['Tournaments'] ?? participatedTournaments,
    'Following': map['Following'] ?? Following,
    'Followers': map['Followers'] ?? Followers,
    'Preferences': map['Preferences'] ?? preferences,
    
    
  });
}
}

class ParticipatedTournaments {
  String id;
  String date;
  String type;
  String tournamentName;
  String time;
  String tournamentOrg;
  String country;
  String city;
  String tournamentGame;

  ParticipatedTournaments({
    required this.id,
    this.date = "",
    this.tournamentName = "",
    this.time = "",
    this.tournamentOrg = "",
    this.type = "",
    this.country = "",
    this.city = "",
    this.tournamentGame = "",
  });
  Map<String, dynamic> tournamentToJson(
      ParticipatedTournaments participatedTournaments) {
    return {
      //id
      'id': participatedTournaments.id,
      'date': participatedTournaments.date,
      'Tournament_Name': participatedTournaments.tournamentName,
      'Time': participatedTournaments.time,
      "Type": participatedTournaments.type,
      'Tournament_Game': participatedTournaments.tournamentGame,
      'Tournament_Org': participatedTournaments.tournamentOrg,
      'Country': participatedTournaments.country,
      "City": participatedTournaments.city,
    };
  }

  ParticipatedTournaments copyWith({
    String? id,
    String? date,
    String? tournamentName,
    String? time,
    String? country,
    String? city,
    String? type,
    String? tournamentGame,
    String? tournamentOrg,
  }) {
    return ParticipatedTournaments(
      id: id ?? this.id,
      date: date ?? this.date,
      tournamentName: tournamentName ?? this.tournamentName,
      type: type ?? this.type,
      time: time ?? this.time,
      tournamentGame: tournamentGame ?? this.tournamentGame,
      tournamentOrg: tournamentOrg ?? this.tournamentOrg,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }

  @override
  String toString() {
    return 'date: $date, tournamentName: $tournamentName, time: $time, tournamentOrg: $tournamentOrg, city: $city ,country: $country';
  }

  ParticipatedTournaments ParticipatedTournamentsFromJson(
      Map<String, dynamic> json) {
    // convert the date from GMT to local time
    final newDate = DateTime.parse(json['Date_Time']);
    final localDate = newDate.toLocal();
    // also the time
    final newTime = DateTime.parse(json['Time']);
    final localTime = newTime.toLocal();
    // make the date and time as follows , date yyyy-mm-dd time hh:mm
    final date = DateFormat('yyyy-MM-dd').format(localDate);
    final time = DateFormat('HH:mm').format(localTime);
    return ParticipatedTournaments(
      id: json['Tour_Id'],
      date: date,
      tournamentName: json['Tournament_Name'],
      time: time,
      tournamentGame: json['Tournament_Game'],
      tournamentOrg: json['Tournament_Org'],
      type: json['Type'],
      country: json['Country'].split(",")[0],
      city: json['City'].split(",")[1],
    );
  }

  factory ParticipatedTournaments.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> timestamp = json['Date_Time'];
    int seconds = timestamp['_seconds'];
    int nanoseconds = timestamp['_nanoseconds'];

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000);
    String date = DateFormat('yyyy-MM-dd').format(dateTime);
    String time =
        DateFormat('HH:mm').format(dateTime); // Format the time as "HH:mm".

    return ParticipatedTournaments(
      //id
      id: json['Tour_Id'],
      // date: json['Date_Time'].toString()+"  "+json['Time'].toString(),
      date: date,
      tournamentName: json['Tournament_Name'],
      time: time,
      type: json['Type'],
      tournamentGame: json['Tournament_Game'] ?? json['Game_Name'],
      tournamentOrg: json['Tournament_Org'],
      country: json['Country'] ?? json['Location'].split(",")[0],
      // get the city from the location
      // the location will look like this Country, City
      city: json['City'] ?? json['Location'].split(",")[1],
    );
  }
}
