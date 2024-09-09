import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

// DateTime dateTime;
class Tournament {
  final String id;
  final String results;
  final String registrationLink;
  final String date;
  final String description;
  final String prizePool;
  final String type;
  final String streamingLink;
  final String tournamentName;
  final String time;
  final String location;
  final bool In_House;
  final String tournamentOrg;
  final String tournamentOrgId; //the id of the owner of the tournament
  final int maxParticipants;
  final String tournamentGame;
  final List<Participant>? participants;
  final List<String> participantIds;
  final Matches matches;
  final bool isStarted;
  final String banner;
  final String thumbnail;

  Tournament(
      {required this.id,
      required this.results,
      required this.registrationLink,
      required this.date,
      required this.description,
      required this.prizePool,
      required this.streamingLink,
      required this.tournamentName,
      required this.location,
      required this.time,
      required this.isStarted,
      required this.tournamentOrg,
      required this.type,
      required this.In_House,
      required this.tournamentGame,
      required this.maxParticipants,
      required this.tournamentOrgId,
      required this.participantIds,
       this.participants,
      required this.matches,
      required this.banner,
      required this.thumbnail});

  // Map<String, dynamic> tournamentToJson(Tournament tournament) {
  //   return {
  //     //id
  //     'id': tournament.id,
  //     'Results': tournament.results,
  //     'Registration_Link': tournament.registrationLink,
  //     'date': tournament.date,
  //     'Description': tournament.description,
  //     'Prize_Pool': tournament.prizePool,
  //     'Streaming_Link': tournament.streamingLink,
  //     'Tournament_Name': tournament.tournamentName,
  //     'Time': tournament.time,
  //     'In_House': In_House,
  //     "Type": "Tournament",
  //     'Tournament_Game': tournament.tournamentGame,
  //     'Tournament_Org': tournament.tournamentOrg,
  //     'Max_Participants': tournament.maxParticipants,
  //     'Participants':
  //         List<dynamic>.from(tournament.participants.map((x) => x.toJson())),
  //     'Matches': tournament.matches.toJson(),
  //     'Location': tournament.location,
  //     'Banner': tournament.banner,
  //     'Thumbnail': tournament.thumbnail,
  //   };
  // }

  Tournament copyWith({
    String? id,
    String? results,
    String? registrationLink,
    String? date,
    String? description,
    String? prizePool,
    String? streamingLink,
    String? tournamentName,
    String? time,
    bool? In_House,
    String? type,
    String? tournamentGame,
    String? tournamentOrg,
    int? maxParticipants,
    String? location,
    List<Participant>? participants,
    Matches? matches,
    String? tournamentOrgId,
    String? banner,
    String? thumbnail,
    bool? isStarted,
    List<String>? participantIds,
    }) {
    return Tournament(
      id: id ?? this.id,
      results: results ?? this.results,
      registrationLink: registrationLink ?? this.registrationLink,
      date: date ?? this.date,
      description: description ?? this.description,
      prizePool: prizePool ?? this.prizePool,
      streamingLink: streamingLink ?? this.streamingLink,
      tournamentName: tournamentName ?? this.tournamentName,
      type: type ?? this.type,
      time: time ?? this.time,
      tournamentOrgId: tournamentOrgId ?? this.tournamentOrgId,
      tournamentGame: tournamentGame ?? this.tournamentGame,
      tournamentOrg: tournamentOrg ?? this.tournamentOrg,
      location: location??this.location,
      In_House: In_House ?? this.In_House,
      isStarted: isStarted ?? this.isStarted,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      matches: matches ?? this.matches,
      banner: banner ?? this.banner,
      thumbnail: thumbnail ?? this.thumbnail,
      participantIds: participantIds?? this.participantIds
    );
  }

  @override
  String toString() {
    return 'Tournament {results: $results, registrationLink: $registrationLink, date: $date, description: $description, prizePool: $prizePool, streamingLink: $streamingLink, tournamentName: $tournamentName, time: $time, tournamentOrg: $tournamentOrg,  maxParticipants: $maxParticipants, participants: $participants, matches: $matches, location: $location, banner: $banner, thumbnail: $thumbnail}';
  }











  factory Tournament.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> timestamp = json['Date_Time'];
    int seconds = timestamp['_seconds'];
    int nanoseconds = timestamp['_nanoseconds'];

    DateTime dateTimeUtcPlus3 = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000);
        DateTime dateTime = dateTimeUtcPlus3.subtract(const Duration(hours: 3));
    String date = DateFormat('yyyy-MM-dd').format(dateTime);
    String time =
        DateFormat('HH:mm').format(dateTime); 
      
    return Tournament(
      //id
      id: json['Tour_Id'],
      results: json['Results'],
      registrationLink: json['Registration_Link'],
      date: date,
      tournamentOrgId: json['Tournament_Org_Id'],
      type: json['Type'],
      In_House: json['In_House'] ?? true,
      description: json['Description'],
      prizePool: json['Prize_Pool'],
      streamingLink: json['Streaming_Link'],
      tournamentName: json['Tournament_Name'],
      time: time,
      isStarted: json['isStarted']??false,
      location: json['Location'],
      tournamentGame: json['Tournament_Game'] ?? json['Game_Name'],
      tournamentOrg: json['Tournament_Org'],
      maxParticipants: json['Max_Participants'],
      participantIds: (json['Participants'] as List).map((item) => item['Participant_Id'] as String).toList(),
      matches: Matches.fromJson(json['Matches'])?? Matches(active: [], ended: []),
      banner: json['Banner'],
      thumbnail: json['Thumbnail'],
    );
  }
}

class Participant {
  String participantUserName;
  String participantName;
  Record record;
  String participantId;
  String? participantImage;

  Participant(
      {
        required this.participantName,
    required  this.record ,
     required this.participantId ,
      this.participantImage,
     required this.participantUserName });
  Map<String, dynamic> toJson() {
    return {
      'participant_name': participantName,
      'record': record.toJson(),
      'participant_id': participantId,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantName: json['participant_name'] ?? json['Participant_Name']??json['Participant_Display_Name'],
      record: Record.fromJson(json['record'] ?? json['Record']),
      participantId: json['participant_id'] ?? json['Participant_Id'],
      participantUserName: json['Participant_User_Name']??'',
      participantImage: json['Participant_Profile']?? json['participant_profile']??null,
    );
  }

  // Participant fromJson(Map<String, dynamic> json) {
  //   return Participant(
  //     participantName: json['participant_display_name'] ?? json['Participant_Display_Name'],
  //     record: Record.fromJson(json['Record'] ?? json['record']),
  //     participantId: json['participant_id'] ?? json['Participant_Id'],
  //     // Abdullah check this
  //     participantUserName:json['Participant_User_Name']?? json['participant_user_name'],
  //     participantImage: json['Participant_Profile']?? json['participant_profile'],
  //   );
  // }
  // Abdullah check this 
  //Here is the resopnse from the server
  // {
  //       "Participant_Id": "pFZibr4pVOhpIcytthCKsrx8uAl1",
  //       "Record": {
  //           "Losses": 0,
  //           "Wins": 0
  //       },
  //       "Participant_User_Name": "@aprilusername",
  //       "Participant_Profile": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2FpFZibr4pVOhpIcytthCKsrx8uAl1%2FProfile_Picture?generation=1713761301248438&alt=media",
  //       "Participant_Display_Name": "april name"
  //   }

  Participant copyWith({
    String? participantName,
    Record? record,
    String? participantId,
    String? participantImage,
    String? participantUserName
  }) {
    return Participant(
      participantName: participantName ?? this.participantName,
      record: record ?? this.record,
      participantId: participantId ?? this.participantId,
      participantImage: participantImage ?? this.participantImage,
      participantUserName: participantUserName?? this.participantUserName,
    );
  }
}

class Record {
  final int wins;
  final int losses;

  const Record({
    required this.wins,
    required this.losses,
  });
  Record fromJson(Map<String, dynamic> json) {
    return Record(
      wins: json['wins'] ?? json['Wins'],
      losses: json['losses'] ?? json['Losses'],
    );
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      wins: json['Wins'] ?? json['wins'],
      losses: json['Losses'] ?? json['losses'],
    );
  }

  // create factory method to convert the response to the model
  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
    };
  }
}

class Matches {
  final List<Active> active;
  final List<Ended> ended;

  const Matches({
    required this.active,
    required this.ended,
  });

  // create toString
  @override
  String toString() {
    return 'Matches {active: $active, ended: $ended}';
  }

factory Matches.fromJson(Map<String, dynamic> json) {
  return Matches(
    active: (json['Active'] as List)
        .map((x) => Active.fromJson(x as Map<String, dynamic>))
        .where((match) => match.player1.id != 'Pending' && match.player2.id != 'Pending')
        .toList() ?? [],
    ended: (json['Ended'] as List)
        .map((x) => Ended.fromJson(x as Map<String, dynamic>))
        .where((match) => match.player1.id != 'Pending' && match.player2.id != 'Pending')
        .toList() ?? [],
  );
}
  Map<String, dynamic> toJson() {
    return {
      'Active': active.map((x) => x.toJson()).toList(),
      // Abdullah
      'Ended': ended,// Think this needs to be changed to x.toJson()
    };
  }
}

class Active {
  final Player player1;
  final Player player2;

  Active({
    required this.player1,
    required this.player2,
  });

  //create toString
  @override
  String toString() {
    return 'Active {player1: $player1, player2: $player2}';
  }

  Map<String, dynamic> toJson() {
    return {
      'Player1': player1.toJson(),
      'Player2': player2.toJson(),
    };
  }

  factory Active.fromJson(Map<String, dynamic> json) {
    return Active(
      player1: Player.fromJson(json['Player1'])?? Player(status: "", id: "", name: "",profileImage: "",userName: ""),
      player2: Player.fromJson(json['Player2'])?? Player(status: "", id: "", name: "",profileImage: "",userName: ""),
    );
  }
}

//create Ended class
class Ended {
  final Player player1;
  final Player player2;

  Ended({
    required this.player1,
    required this.player2,
  });

  //create toString
  @override
  String toString() {
    return 'Ended {player1: $player1, player2: $player2}';
  }

  factory Ended.fromJson(Map<String, dynamic> json) {
    return Ended(
      player1: json['Player1'] is Map<String, dynamic>
          ? Player.fromJson(json['Player1'])
          : Player(status: "", id: "", name: "",profileImage: "",userName: ""),
      player2: json['Player2'] is Map<String, dynamic>
          ? Player.fromJson(json['Player2'])
          : Player(status: "", id: "", name: "",profileImage: "",userName: ""),
    );
  }
}

// Abdullah check this
// this is the response from the server
// "Player1": {
//                 "Status": "Pending",
//                 "Id": "otWWAMxB67cn0XyKp0aNAEloRBm2",
//                 "User_Name": "@apriluuser",
//                 "Profile_Picture": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2FotWWAMxB67cn0XyKp0aNAEloRBm2%2FProfile_Picture?generation=1714113679473351&alt=media",
//                 "Display_Name": "april name"
//             }

class Player {
  final String status;
  final String id;
  final String name;
  final String userName;
  final String profileImage;

  Player({
    required this.status,
    required this.id,
    required this.name,
    required this.userName,
    required this.profileImage,
  });

  //create toString
  @override
  String toString() {
    return 'Player {status: $status, id: $id, name: $name}';
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      status: json['Status']?? json['status']?? "",
      id: json['ID'] ?? json['Id']?? "",
      // Abdullah check this
      name: json['Display_Name']?? json['display_name']?? "",
      profileImage: json['Profile_Picture'] ?? json['profile_picture']?? "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/1200px-Default_pfp.svg.png",
      userName: json['User_Name'] ?? json['user_name']?? "",
    );
  }

  // Player fromJson(Map<String, dynamic> json) {
  //   return Player(
  //     status: json['Status'],
  //     id: json['ID'] ?? json['Id'],
  //     name: json['Name'],
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      // Changed these to match the json response
      'Status': status ?? "",
      'Id': id ?? "",
      'Display_Name': name ?? "",
      'User_Name': userName ?? "",
      'Profile_Picture': profileImage ?? "",
    };
  }
}
// Abdullah remove uncessary comments فضايح

// create a factory method to parse the response from the server

// create a factory method to convert the model to a map

// Map<String, dynamic> activeToJson(Active active) {
//   return {
//     'Player1': active.player1.playerToJson(),
//     'Player2': active.player2.playerToJson(),
//   };
// }

// Map<String, dynamic> playerToJson(Player player) {
//   return {
//     'Status': player.status,
//     'ID': player.id,
//     'Name': player.name,
//   };
// }

// create a factory method to convert the response to the model

// create a factory method to convert the model to a map

// create for me Tournament Model for this response

//  "Results": "Pending",
//     "Registration_Link": "test.com",
//     "date": "10/2/5555",
//     "Description": "Tour",
//     "Prize_Pool": "1000SAR",
//     "Streaming_Link": "Twitter.com",
//     "Tournament_Name": "Streetfighter",
//     "Time": "20:00",
//     "Tournament_Org": "P4444",
//     "Location": "Riyadh",
//     "Max_Participants": "108",
//     "Participants": [
//         {
//             "participant_name": "Turki",
//             "record": {
//                 "wins": 4,
//                 "losses": 2
//             },
//             "participant_id": "P1"
//         },
//         {
//             "participant_name": "Ahmed",
//             "record": {
//                 "wins": 11,
//                 "losses": 53
//             },
//             "participant_id": "P2"
//         },
//         {
//             "participant_name": "Zyiad",
//             "participant_id": "P3",
//             "record": {
//                 "wins": 41,
//                 "losses": 55
//             }
//         },
//         {
//             "participant_name": "Khaled",
//             "participant_id": "P4",
//             "record": {
//                 "wins": 4441,
//                 "losses": 565
//             }
//         },
//         {
//             "participant_name": "ali",
//             "participant_id": "P5",
//             "record": {
//                 "wins": 11,
//                 "losses": 5625
//             }
//         },
//         {
//             "participant_name": "sss",
//             "participant_id": "P6",
//             "record": {
//                 "wins": 11,
//                 "losses": 5625
//             }
//         },
//         {
//             "participant_name": "assd",
//             "participant_id": "P7",
//             "record": {
//                 "wins": 11,
//                 "losses": 5625
//             }
//         },
//         {
//             "participant_name": "cvwq",
//             "participant_id": "P8",
//             "record": {
//                 "wins": 11,
//                 "losses": 5625
//             }
//         }
//     ],
//     "Matches": {
//         "Active": [
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "P2",
//                     "Name": "Ahmed"
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "P1",
//                     "Name": "Turki"
//                 }
//             },
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "P4",
//                     "Name": "Khaled"
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "P3",
//                     "Name": "Zyiad"
//                 }
//             },
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "P6",
//                     "Name": "sss"
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "P5",
//                     "Name": "ali"
//                 }
//             },
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "P8",
//                     "Name": "cvwq"
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "P7",
//                     "Name": "assd"
//                 }
//             },
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "",
//                     "Name": ""
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "",
//                     "Name": ""
//                 }
//             },
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "",
//                     "Name": ""
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "",
//                     "Name": ""
//                 }
//             },
//             {
//                 "Player2": {
//                     "Status": "Pending",
//                     "ID": "",
//                     "Name": ""
//                 },
//                 "Player1": {
//                     "Status": "Pending",
//                     "ID": "",
//                     "Name": ""
//                 }
//             }
//         ],
//         "Ended": []
//     }
