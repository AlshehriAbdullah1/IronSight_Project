import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iron_sight/APIs/api_client.dart';
import 'dart:convert';
import 'package:iron_sight/models/tournament.dart';
import 'package:iron_sight/models/user.dart';
import 'package:riverpod/riverpod.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';

//create api client Provider using riverpod
//create tournament Api client Provider using riverpod
final tournamentApiClientProvider = Provider<TournamentApiClient>((ref) {
  return TournamentApiClient();
});

class TournamentApiClient {
  final String baseUrl =
      ApiClient.baseUrl; //tournament backend connection

  TournamentApiClient();
  // get all tournaments
  Future<List<Tournament>> getTournaments() async {
    try {
      final response = await http.get(
      Uri.parse("$baseUrl/tournaments"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
       if(response.body=='No matching documents'){
        return [];
       }
      final result = jsonDecode(response.body);
     
      if(result is Map<String,dynamic> || result is List<dynamic>){
         Iterable list = result;
      return list.map((tournament) => Tournament.fromJson(tournament)).toList();
      }
      else{
 
        return [];
      }
     
    } else {
      throw Exception("Failed to load tournaments");
    }
    } catch (e) {
      rethrow ;
    }
    
  }

    Future<List<Tournament>> searchTournaments(String querySearch)async{
    try {
       final response= await http.get(Uri.parse('$baseUrl/search/tournaments/?SearchQuery=$querySearch'));
    if(response.statusCode==200||response.statusCode==201){
      final result = jsonDecode(response.body);
      Iterable list = result;
      return list.map((game) => Tournament.fromJson(game)).toList();
    }
    throw 'Error in loading games';
    } catch (e) {
      rethrow;
    }
   
  }

  Future<Matches> startTournament(String tourId)async{
    
    try {
      final response= await http.put(Uri.parse('$baseUrl/tournaments/$tourId/startTournament'));
      if (response.statusCode==200|| response.statusCode==201){
        final result = jsonDecode(response.body);
        return Matches.fromJson(result);
      }
      else{
        throw 'Error in starting tournament';
      }
    } catch (e) {
      rethrow;
    }
  }
  

  
  // get all matches of a tournament
Future<Matches> getMatches(String tournamentId) async {
  try {
    final response = await http
        .get(Uri.parse('$baseUrl/tournaments/$tournamentId/matches'))
        .catchError((error) {
      throw 'Failed to load matches';
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> result = jsonDecode(response.body);
      //remove all matches that has player which has id of "Pending"
      return Matches.fromJson(result);
    } else {
      throw 'Failed to load matches';
    }
  } catch (e) {
    rethrow;
  }
}

  // get tournament by id
 // get tournament by id
Future<Tournament> getTournament(String tournamentId) async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/tournaments?Tour_Id=$tournamentId"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      if(result is Map<String,dynamic> && result['error'] == null){
        Tournament tournament = Tournament.fromJson(result);
List<Participant> updatedParticipants = (await Future.wait((result['Participants'] as List).map((item) async {
  final user = await getParticipantsInfo(item['Participant_Id']);
  if (user != null) {
    return Participant(
      participantId: item['Participant_Id'],
      participantImage: user.profilepic,
      participantName: user.displayName,
      participantUserName: user.username,
      record: Record.fromJson(item['Record']),
    );
  }
  // Return null if user data couldn't be fetched
  return null;
}).toList())).whereType<Participant>().toList();

        // Update the tournament with the updated participants
        tournament = tournament.copyWith(participants: updatedParticipants);

  
        return tournament;
      } else {
        throw "Failed to load tournament";
      }
    } else {
      throw "Failed to load tournament";
    }
  } catch (e) {
    rethrow;
  }
}

  // create tournament
  Future<Tournament> createTournament(Map<String, dynamic> tournamentData,String organazierId) async {
    try {

    Map<String, dynamic> reqBody = {...tournamentData, 'Tournament_Org': organazierId};
    final response = await http.post(
      Uri.parse("$baseUrl/tournaments"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reqBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      
      final result = jsonDecode(response.body);
      if(result['message']==null || result['error']==null) {
         return Tournament.fromJson(result);
      }
      else{
        throw result['error']? result['error']: result['message'];
      }

     
    } else {
      throw 'Server Error, could not create tournament ';
    }
    } catch (e) {
      rethrow;
    }
   
  }


      Future<Tournament> uploadCommunityBanner(File imageFile, String id) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));

    final mimeType = lookupMimeType(imageFile.path); // Get the MIME type based on file extension

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: 'Banner/$id',
      contentType: MediaType('image', mimeType?.split('/').last ?? 'jpeg'), // Use the correct MIME type
    ));

    request.fields['from_micro'] = 'Tournament';
    request.fields['image_name'] = 'Banner';
    request.fields['id'] = id;
    request.fields['collection'] = 'Tournaments';


    var response = await request.send();

    if (response.statusCode == 200) {
      // Image uploaded successfully
      var responseData = await response.stream.bytesToString();
      Map<String,dynamic> jsonResponse = json.decode(responseData);
      
      return Tournament.fromJson(jsonResponse);
    } else {
      // Failed to upload image
      throw 'Failed to upload image. Error: ${response.statusCode}' ;
    }
  } catch (e) {
    // Handle exceptions
   rethrow;
  }
}


     Future<Tournament> uploadCommunityThumbnail(File imageFile, String id) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));

    final mimeType = lookupMimeType(imageFile.path); // Get the MIME type based on file extension

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: 'Thumbnail/$id',
      contentType: MediaType('image', mimeType?.split('/').last ?? 'jpeg'), // Use the correct MIME type
    ));

    request.fields['from_micro'] = 'Tournament';
    request.fields['image_name'] = 'Thumbnail';
    request.fields['id'] = id;
    request.fields['collection'] = 'Tournaments';


    var response = await request.send();

    if (response.statusCode == 200) {
      // Image uploaded successfully
      var responseData = await response.stream.bytesToString();
      Map<String,dynamic> jsonResponse = json.decode(responseData);
      
      return Tournament.fromJson(jsonResponse);
    } else {
      // Failed to upload image
      throw 'Failed to upload image. Error: ${response.statusCode}';
    }
  } catch (e) {
    // Handle exceptions
    rethrow ;
  }
}


  // delete tournament
  Future<Tournament> deleteTournament(String tournamentId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/tournaments/$tournamentId"),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Tournament.fromJson(result);
    } else {
      throw Exception("Failed to Delete tournament");
    }
  }

  // edit tournament
  Future<Tournament?> editTournament(
      String tournamentId, Map<String, dynamic> tournamentData) async {
    Map<String, dynamic> reqBody = {
      'Description':
          tournamentData['Description'] ?? "Unknown", //if null then 'Unknown
      'Country': tournamentData['Country'] ?? "Unknown",
      'City': tournamentData['City'] ?? "Unknown",
      'Max_Participants': tournamentData['Max_Participants'] ?? "Unknown",
      'Prize_Pool': tournamentData['Prize_Pool'] ?? "Unknown",
      'Registration_Link': tournamentData['Registration_Link'] ?? "Unknown",
      'Streaming_Link': tournamentData['Streaming_Link'] ?? "Unknown",
      'Time': tournamentData['Time'].toString(),
      'Date': tournamentData['Date'].toString(),
      'Tournament_Name': tournamentData['Tournament_Name'] ?? "Unknown",
      'Tournament_Org': tournamentData['Tournament_Org'] ?? "Unknown",
      'Game_Name': tournamentData['Game_Name'] ?? "Unknown",
      'Type': tournamentData['Type'] ?? "Unknown",
      // if the tournament is inhouse (true) or third party (false)
      'In_House': tournamentData['In_House'] ?? true,
    };
    final response = await http.put(
      Uri.parse("$baseUrl/tournaments/$tournamentId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reqBody),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Tournament.fromJson(result);
    } else {
      throw Exception("Failed to Edit tournament");
    }
  }


  // for turki 
  //test these 
  // Register participant
  Future<List<Participant>?> registerParticipant(
      String tournamentId, String participantId,) async {
    final response = await http.post(
      Uri.parse("$baseUrl/tournaments/$tournamentId/registerParticipant"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "Participant_Id": participantId
      }),
    );

    if (response.statusCode == 200 || response.statusCode==201) {
      List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody
          .map((participant) => Participant.fromJson(participant))
          .toList();
    } else {
      return null;
    }
  }
    Future<List<Participant>?> removeParticipant(
      String tournamentId, String participantId) async {
    final response = await http.delete(
      Uri.parse(
          "$baseUrl/tournaments/$tournamentId/removeParticipant/?Participant_Id=$participantId"),
    );
   
    if (response.statusCode == 200|| response.statusCode==201) {
      List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody
          .map((participant) => Participant.fromJson(participant))
          .toList();
    } else {
      throw Exception("Failed to remove participant from tournament ${jsonDecode(response.body)} ");
    }
  }


  Future<UserModel?> getParticipantsInfo(String participantId)async{
    final response= await http.get(Uri.parse("${baseUrl}/users/?User_Id=${participantId}"));
    if(response.statusCode==200|| response.statusCode==201){
      final result=jsonDecode(response.body);
      return UserModel.fromJson(result);
    }
    else{
      return null;
    }
  }

  // Abdullah check this (this is better than getting each participant info separately)
  // This function is used to get the participants of a tournament
  Future<List<Participant>?> getParticipants(String tournamentId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/tournaments/$tournamentId/participants"),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody
          .map((participant) => Participant.fromJson(participant))
          .toList();
    } else {
      return null;
    }
  }



// for turki 
// test these 
  Future<Matches?> matchWinner(String tournamentId, String winnerId) async {
    //Check this
    // "PUT /tournaments/:Tour_Id/matchWin/:Winner_Id"
    final response = await http.put(
      Uri.parse("$baseUrl/tournaments/$tournamentId/matchWin/$winnerId"),
    );
    if (response.statusCode == 200 && !response.body.contains("Error")) {

      return Matches.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

//create map string dynamic function



  // Get the list of tournaments that are related to the game by using the game name
  Future<List<Tournament>> getTournamentsGameName(String gameName) async {
    final response = await http.get(
      Uri.parse("$baseUrl/tournaments/game/$gameName"),
    );
    try{
      if (response.statusCode == 200 || response.statusCode == 201) {
        if(response.body==null || response.body.isEmpty){
          return [];
        }
        
        final result = jsonDecode(response.body);
        if(result is Map<String,dynamic> || result is List<dynamic>){
          Iterable list = result;
          return list.map((tournament) => Tournament.fromJson(tournament)).toList();
        }
        else{
          return [];
        }
      } 
      else {
        throw Exception("Failed to load games");
      }
    } 
    catch (e) {
      rethrow;
    }
  }
  



}
