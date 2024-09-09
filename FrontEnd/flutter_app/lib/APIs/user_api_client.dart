import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iron_sight/APIs/api_client.dart';
import 'package:iron_sight/models/tournament.dart';
import 'dart:convert';
import 'package:iron_sight/models/user.dart';
import 'package:riverpod/riverpod.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
final userApiClientProvider = Provider<UserApiClient>((ref) {
  return UserApiClient();
});

class UserApiClient {
  final String baseUrl =
      ApiClient.baseUrl; //user backend connection

  UserApiClient();

  Future<List<UserModel>> getUsers() async {
    final response = await http.get(
      Uri.parse("$baseUrl/users"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      Iterable list = result;
      return list.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  // get user by id
  Future<UserModel> getUser(String userId) async {
    try {
      final response = await http.get(
      Uri.parse("$baseUrl/users?User_Id=$userId"),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if(result['error'] == null){
         return UserModel.fromJson(result);
      }
      else{
        throw Exception(result['error']);
      }

    } else {
      throw Exception("Failed to load specific user");
    }
    } catch (e) {
      rethrow;
    }
    
  }

      Future<List<UserModel>> searchUsers(String querySearch)async{
    try {
       final response= await http.get(Uri.parse('$baseUrl/search/users/?SearchQuery=$querySearch'));
    if(response.statusCode==200||response.statusCode==201){
      final result = jsonDecode(response.body);
      Iterable list = result;
      return list.map((game) => UserModel.fromJson(game)).toList();
    }
    throw 'Error in loading games';
    } catch (e) {
      rethrow;
    }
   
  }

  Future<UserModel?> signUpUser(String email, String uid)async{
    
     final response = await http.post(
          Uri.parse('${baseUrl}/users/$uid/signup'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
           
          }),
        );
        if(response.statusCode==200|| response.statusCode==201){
          try {
              final user = jsonDecode(response.body);
            if(user['error']==null ){
            return UserModel.fromJson(user);
            }
            else{
              throw Exception(user['error']);
            }
          } catch (e) {
            rethrow ;
          }
          
        }
  }


// turki
//  complete this, return list of followed tournament if success, also for unfollowTournament the same
  Future<List<Tournament>> followTournament(String uid, String tournamentId) async{
    try {
      final response = await http.post(
          Uri.parse('${baseUrl}/users/$uid/addParticipatedTournaments'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },body: jsonEncode(<String, String>{
            'Tour_Id': tournamentId,
            'Tour_Type': 'Followed'
          }));
    if(response.statusCode==200 || response.statusCode==201){
        final result = jsonDecode(response.body);
      
      
       if (result is List) {
          return result.map((tournament) => Tournament.fromJson(tournament)).toList();
        } else {
          throw 'in else1 Unexpected result type: ${result.runtimeType}';
        }
        
     
    }
    else{
      throw 'in else3 Error following tournament , server error (${response.statusCode})';
    }

    } catch (e) {
      rethrow;
    }
   
  }

    Future<List<Tournament>> unfollowTournament(String uid, String tournamentId) async{
      try {
      final response = await http.delete(
          Uri.parse('${baseUrl}/users/$uid/removeParticipatedTournaments?Tour_Id=$tournamentId&Tour_Type=Followed'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          });

    if(response.statusCode==200 || response.statusCode==201){
        final result = jsonDecode(response.body);
     
          if (result is List) {
          return result.map((tournament) => Tournament.fromJson(tournament)).toList();
        } else {
          throw 'in else1 Unexpected result type: ${result.runtimeType}';
        }     
       
    }
    else{
      throw 'Error following tournament , server error (${response.statusCode})';
    }

    } catch (e) {
      rethrow;
    }
   
  }

    Future<Map<String,dynamic>?> uploadUserPicture(File imageFile, String id,String imageName) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));

    final mimeType = lookupMimeType(imageFile.path); // Get the MIME type based on file extension

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: '$imageName/$id',
      contentType: MediaType('image', mimeType?.split('/').last ?? 'jpeg'), // Use the correct MIME type
    ));

    request.fields['from_micro'] = 'User';
    request.fields['image_name'] = imageName;
    request.fields['id'] = id;
    request.fields['collection'] = 'Users';


    var response = await request.send();

    if (response.statusCode == 200) {
      // Image uploaded successfully
      var responseData = await response.stream.bytesToString();
      Map<String,dynamic> jsonResponse = json.decode(responseData);
      
      return jsonResponse;
    } else {
      // Failed to upload image
      return null;
    }
  } catch (e) {
    // Handle exceptions
    return null;
  }
}

  // get participated tournaments of a user
  Future<List<Tournament>> getParticipatedTournaments(
      String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId/participatedTournaments"),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['message']==null) {
        //complete 
        return [];
        // throw 'Invalid';
        // return result['Previous'].map((tournament) => Tournament.fromJson(tournament)).toList();
        //##########################################################//
      
      } else {
        throw Exception('Result is empty');
      }

      // return ParticipatedTournaments.fromJson(result);
    } else {
      throw Exception("Failed to load specific user");
    }
  }

  // get participated tournament of a user based on the given type
  Future<List<Tournament>> getParticipatedTournamentsByType(
      String userId, String type) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId/participatedTournaments/?Tour_Type=$type"),
    );

    try{
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if(result==null){
          return [];
        } 
        else {
          Iterable list = result;
          return list.map((user) => Tournament.fromJson(user)).toList();
        }
      }
      else{
        throw 'Server error, cannot fetch tournament information';
      }
    } 
    catch(e){
      rethrow;
    }
  }
      


  // create user
  // Future<User> createUser(Map<String, dynamic> userData) async {
  //   print('create user called in client');
  //   Map<String, dynamic> reqBody = userData;
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/users"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8'
  //     },
  //     body: jsonEncode(reqBody),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final result = jsonDecode(response.body);
  //     return result;
  //   } else {
  //     throw Exception("Failed to create user");
  //   }
  // }

  // edit user
  Future<UserModel?> editUser(String userId, Map<String, dynamic> userData) async {
    try {
       Map<String, dynamic> reqBody = userData;
    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reqBody),
    );

    if (response.statusCode == 200) {
      
      final result = jsonDecode(response.body);
      if(result['error']!=null){
        throw Exception(result['error']);
      }
      return UserModel.fromJson(result);
    } else {
      throw Exception("Failed to Edit user");
    }
    } catch (e) {
      rethrow;
    }
   
  }

  // delete tournament
  // Future<User> deleteUser(String tournamentId) async {
  //   final response = await http.delete(
  //     Uri.parse("$baseUrl/users/?Tour_Id=$tournamentId"),
  //   );

  //   if (response.statusCode == 200) {
  //     final result = jsonDecode(response.body);
  //     return User.fromJson(result);
  //   } else {
  //     throw Exception("Failed to Delete tournament");
  //   }
  // }

  // Add other methods as needed
}
