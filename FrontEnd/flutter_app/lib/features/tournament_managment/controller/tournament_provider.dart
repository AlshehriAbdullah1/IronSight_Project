import 'dart:async';
import 'dart:io';

import 'package:iron_sight/APIs/user_api_client.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/models/game.dart';
import 'package:iron_sight/models/tournament.dart';
import 'package:iron_sight/APIs/tournament_api_client.dart';
import 'package:iron_sight/models/user.dart';
import 'package:riverpod/riverpod.dart';


final tournamentListStateProvider =
    StateNotifierProvider<TournamentListState, AsyncValue<List<Tournament>>>(
        (ref) {
  final tournaamentApiClient = ref.read(tournamentApiClientProvider);
  return TournamentListState(tournaamentApiClient, ref);
});

class TournamentListState extends StateNotifier<AsyncValue<List<Tournament>>> {
  final TournamentApiClient _tournamentApiClient;
  Ref _ref;

  TournamentListState(this._tournamentApiClient, this._ref)
      : super(const AsyncValue<List<Tournament>>.loading());

   Future<void> loadTournaments({bool isHomeView = false}) async {
    try {
      state = const AsyncValue.loading();
      final tournaments = await _tournamentApiClient.getTournaments();
      String? userId =
          _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if (userId != null && tournaments != null) {
        if (isHomeView) {
          var filteredTournaments = tournaments.where((tournament) {
          return tournament.participantIds.contains(userId) || tournament.tournamentOrgId == userId;
        }).toList();
        state = AsyncValue.data(filteredTournaments);
        } else {
          state = AsyncValue.data(tournaments);
        }
      } else {
        throw 'User is not logged in';
      }
    } catch (e,st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  

    bool isOwner(String tournamentId){
      final userId = _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if(userId!=null && state.value !=null){
        return state.value!.any((element) {
          return element.id == tournamentId && element.tournamentOrgId == userId;
        } );
      }
      return false;
      
    }
    bool isUserFollowingTournament(String tournamentId){
      final userId = _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if(userId!=null && state.value !=null){
        return state.value!.any((element) {
          return element.id == tournamentId && element.participantIds.any((parId){
            return parId==userId;
          });
        } );
      }
      return false;
    }


  Future<bool> isUserFollowing(String tournamentId)async{
     return await _ref.read(userProvider.notifier).isFollowingTournament(tournamentId);
  }

  Future<void> getTournamentsGameName(String gameName) async {
    try {
      
      state = const AsyncValue.loading();
      final tournaments = await _tournamentApiClient.getTournamentsGameName(gameName);
      if (tournaments != null) {
        state = AsyncValue.data(tournaments);
      } 
      else {
        throw Exception("Failed to get tournaments");
      }
    } 
    catch (e, stackTrace) {
      state = AsyncValue.error('An err', stackTrace);
    }
  }





}

final singleTournamentStateProvider =
    StateNotifierProvider<SingleTournamentState, AsyncValue<Tournament>>((ref) {
  final tournamentApiClient = ref.read(tournamentApiClientProvider);
  return SingleTournamentState(tournamentApiClient, ref);
});

class SingleTournamentState extends StateNotifier<AsyncValue<Tournament>> {
  final TournamentApiClient _tournamentApiClient;
  Ref _ref;
  SingleTournamentState(this._tournamentApiClient, this._ref)
      : super(const AsyncValue<Tournament>.loading());


    Future<void> getTournament(String id) async {
      try {
        state= const AsyncValue.loading();
        Tournament tournament = await _tournamentApiClient.getTournament(id);
        // final updatedParticipants = await updateParticipantsInfo(tournament);
        // print(updatedParticipants.first.participantUserName);
        // final UpdatedTournament=  tournament.copyWith(participants:updatedParticipants);
        state=AsyncValue.data(tournament);
      } catch (e) {
        rethrow;
      }
  }

 


  Future<void> loadParticipants()async{
    try {
      if(state.value !=null){
       final participant=   await  _tournamentApiClient.getParticipants(state.value!.id);

       if(participant !=null){
         state=AsyncValue.data(state.value!.copyWith(participants: participant));
       }
      }
    
    } catch (e) {
    }
  }

  

  
  bool isOwner(){{
      final userId=_ref.read(authControllerProvider.notifier).getCurrentUserId();
      if(userId!=null &&state.value!=null){
        return state.value!.tournamentOrgId==userId;
      }
      return false; 
  }}

  // to follow community
//success == "Success" will be returned from the followCommunity(CommunityId, userId)
//else will throw exception, handling it in the ui be rethrowing it
  Future<void> followTournament() async {
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    try {
      if (state.value != null && userId != null) {
      
      await _ref.read(userProvider.notifier).followTournament(state.value!);
        
      } else {
        
        throw Exception(
            'Error in following tournament: either user is not logged in or the tournament does not exists');
      }
    } catch (e) {
      rethrow;
    }
   
  }

  Future<UserModel?> getWinnerData()async{
    if (state.value != null){
      String result = state.value!.results;
      if(result.toLowerCase()=='pending'){
        return null;
      }
      else{
        UserModel user = await _ref.read(userApiClientProvider).getUser(result);
        return user;
      }
    }
  }

  

    Future<void> unFollowTournament() async {
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    try {
      if (state.value != null && userId != null) {
      
      await _ref.read(userProvider.notifier).unfollowTournament(state.value!);
        
      } else {
        
        throw Exception(
            'Error in following tournament: either user is not logged in or the tournament does not exists');
      }
    } catch (e) {
      rethrow;
    }
   
  }

 String getResult() {
    if (state.value != null) {
      return state.value!.results;
    }
    return 'pending';
  }

  

// create should navigate to community page after creating success
  Future<void> createTournament(Map<String, dynamic> tournamentData) async {
    try {
      String? userId =_ref.read(authControllerProvider.notifier).getCurrentUserId();
      if(userId !=null){
            Tournament response =
        await _tournamentApiClient.createTournament(tournamentData,userId);

    state= AsyncValue.data(response);
      }
      else{
        throw ('User is not logged in');
      }

    
    } catch (e) {
      rethrow;
    }
    
  }

  String getTournamentId(){
    if(state.value ==null ){
      throw 'No Tournament is selected';
    }
    return state.value!.id;
  }

  Future<void> uploadTournamentPictures(File banner, File thumbnail)async{

    try {
   await Future.wait([
        uploadTournamentBanner(banner),
        uploadTournamentThumbnail(thumbnail)
      ]);


    } catch (e) {
      
    }
  }

  Future<void> uploadTournamentBanner(File image)async{
    try {
      if(state.value ==null ){
        throw 'No Tournament is selected';
      }
      String tournamentId = state.value!.id;
      if(_ref.read(authControllerProvider.notifier).getCurrentUserId()== state.value!.tournamentOrgId){
        final response = await _tournamentApiClient.uploadCommunityBanner(image, tournamentId);
        state= AsyncValue.data(response);
      }
    } catch (e) {
      rethrow;
    }
  }
  
Future<void> uploadTournamentThumbnail(File image)async{
    try {
      if(state.value ==null ){
        throw 'No Tournament is selected';
      }
      String tournamentId = state.value!.id;
      if(_ref.read(authControllerProvider.notifier).getCurrentUserId()== state.value!.tournamentOrgId){
        final response = await _tournamentApiClient.uploadCommunityThumbnail(image, tournamentId);
        state= AsyncValue.data(response);
      }
    } catch (e) {
      rethrow;
    }
  }
// update should navigate to community page after updating success
  Future<void> getMatches() async {
    try {
      if(state.value!=null){
      String tournamentId = state.value!.id;
      final matches = await _tournamentApiClient.getMatches(tournamentId);
      if(matches != null && matches is Matches){
        state= AsyncValue.data(state.value!.copyWith(matches: matches));
      }
      else{
        throw 'Error in getting matches';
      }
      }
    } catch (e,stackTrace) {
      state= AsyncValue.error(e, stackTrace);
  
      rethrow;

    }
    
    
  }

//     final TournamentSuggestionProvider = FutureProvider.family<List<Tournament>, String>((ref,query ) async {
//   try {
//   final tournamentApiClient = ref.read(tournamentApiClientProvider);
//   final tournaments = await tournamentApiClient.searchTournaments(query);
//   return tournaments;
//   } catch (e) {
//     rethrow;
//   }
// });

 Future<void> startTournament()async{
  try {
     final userId= _ref.read(authControllerProvider.notifier).getCurrentUserId();
  String? tourId= state.value?.id;
  String? tourOrgId= state.value?.tournamentOrgId;

  if (tourId !=null && (tourOrgId == userId)){
    print('if is true');
    final matches = await _tournamentApiClient.startTournament(tourId);
    state= AsyncValue.data(state.value!.copyWith(matches: matches,isStarted: true));
  }
  else{
    print('if is not true');
    print('${tourId !=null}');
     print('${(tourOrgId == userId)}');
  }
  } catch (e) {
    rethrow;
  }
 

 }


  Future<void> removeParticipant(String participantId){
    //todo
return Future.value();
  }

//   Future<void> winMatch(String winnerId){
//     //todo
// return Future.value();
//   }

  Future<void> winMatch(String winnerId) async {
    try {
       if(state.value!=null){
      final matches =
        await _tournamentApiClient.matchWinner(state.value!.id, winnerId);
    if(matches != null && matches is Matches){
      state = AsyncValue.data(state.value!.copyWith(matches: matches));
    }
    else{
    }
   
    }
    } catch (e) {
      rethrow;
    }
   
  }

  void _updateParticipantInfoHelper(String participantId, UserModel user){
      if (state.value != null) {
    state = AsyncValue.data(
      state.value!.copyWith(
        participants: state.value!.participants!.map((participant) {
          if (participant.participantId == participantId) {
            // Assuming your Participant class has a copyWith method
            return participant.copyWith(participantImage: user.profilepic,participantName: user.displayName,participantUserName: user.username);
          }
          return participant;
        }).toList(),
      ),
    );
  }
  }

  // Future<void> updateParticipantsInfo()async{
  //   if (state.value != null) {
  //   await Future.wait(state.value!.participants.map((participant) async {
  //     UserModel? user = await _tournamentApiClient.getParticipantsInfo(participant.participantId);
  //     if(user!=null){
  //       _updateParticipantInfoHelper(participant.participantId, user);
  //     }
      
  //   }).toList());
  // }
  // }
  Future<List<Participant>> updateParticipantsInfo(Tournament tournament) async {
  // final currentState = state.value;
  if (tournament != null) {
    final updatedParticipants = await Future.wait(
      tournament.participants!.map((participant) async {
        final user =
            await _tournamentApiClient.getParticipantsInfo(participant.participantId);
        if (user != null) {
          return participant.copyWith(
            participantImage: user.profilepic,
            participantName: user.displayName,
            participantUserName: user.username,
          );
        }
        return participant;
      }).toList(),
    );
    

    return updatedParticipants;
  }
  else{
    return [];
  }
}
Future<void> updateParticipantInfo(String participantId) async {
  final currentState = state.value;
  if (currentState != null) {
    final participant = currentState.participants!.singleWhere((p) => p.participantId == participantId);
    final user = await _tournamentApiClient.getParticipantsInfo(participantId);
    Participant? updatedParticipant;

    if (user != null) {
      updatedParticipant = participant.copyWith(
        participantImage: user.profilepic,
        participantName: user.displayName,
        participantUserName: user.username,
      );
    }

    if (updatedParticipant != null) {
      final updatedParticipants = currentState.participants!.map((p) {
        return p.participantId == participantId ? updatedParticipant! : p;
      }).toList();

      state = AsyncValue.data(
        currentState.copyWith(participants: updatedParticipants),
      );
    }
  }
}
  Future<void> registerParticipant(String participantId)async{
    try {
      if(state.value !=null){
        final response = await _tournamentApiClient.registerParticipant(state.value!.id, participantId);
        if(response !=null){
             state= AsyncValue.data(state.value!.copyWith(participants: response));
        }
        else{
          throw 'Inavlid server response, failed to register participant';
        }
     
      }
    } catch (e) {
      rethrow;
    }
  }
   Future<void> unRegisterParticipant(String participantId)async{
    try {
      if(state.value !=null){
        final response = await _tournamentApiClient.removeParticipant(state.value!.id, participantId);
    
        if(response !=null){
       state = AsyncValue.data(state.value!.copyWith(participants: response));   
           }
        else{
          throw 'Inavlid server response, failed to remove participant';
        }
     
      }
    } catch (e) {
      rethrow;
    }
  }
  List<String> getParticipantsIds(){
    return state.value?.participantIds??[];
  }
  bool isUserRegsitered(){
    String? userId= _ref.read(authControllerProvider.notifier).getCurrentUserId();
    
      if(userId !=null && state.value !=null){
        print('participant ids are ${state.value!.participantIds}');
        return state.value!.participantIds.any((element) => element==userId);
    } 
    return false;
  }
   bool isTournamentStarted(){
    return state.value?.isStarted ?? false;
  }



  // Other methods specific to handling a single community
}




