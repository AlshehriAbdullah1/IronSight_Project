import 'package:flutter/material.dart';
import 'package:iron_sight/APIs/community_api_client.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/models/community.dart';
import 'package:iron_sight/models/member.dart';
import 'package:riverpod/riverpod.dart';

final membersStateProvider =
    StateNotifierProvider.autoDispose<MembersState, AsyncValue<List<Member>>>(
        (ref) {
  final communityProvider = ref.read(singleCommunityStateProvider);
  final communityApiClient = ref.read(communityRepoProvider);

  return MembersState(communityProvider, communityApiClient);
});

class MembersState extends StateNotifier<AsyncValue<List<Member>>> {
  MembersState(this._communityState, this._communityApiClient)
      : super(const AsyncValue<List<Member>>.loading());
  final AsyncValue<Community> _communityState;
  final CommunityApiClient _communityApiClient;

  Future<void> getMembers() async {
    try {
      state = const AsyncValue.loading();

      if (_communityState.hasValue) {
        final community = _communityState.value!;
        var results = await Future.wait([
            _communityApiClient.getCommunityOwners(community.id),
  _communityApiClient.getCommunityModerators(community.id),
  _communityApiClient.getCommunityMembers(community.id),
        ]);
        final owner =results[0];
        final moderators = results[1];
        final members =  results[2];
        // print("members are ${members.toString()}");
        
        state = AsyncValue.data([...owner!,...moderators!,...members!]);
      } else if (_communityState.hasError) {
      } else {
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }

  Future<bool> removeMember(String memberId, BuildContext context)async{
    if(_communityState.value !=null){
          final removeResponse= await _communityApiClient.removeCommunityMember(_communityState.value!.id, memberId);
          if(removeResponse){
              //show snack bar 
              
              if(mounted){
                getMembers();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Member removed successfully")));
                  return true;
              }
              
          }
          else{
              //show snack bar 
              if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Failed to remove member")));
              }
              return false;
            }

          
    }
    else{
      // show the error message
      if(mounted){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("community is undefined")));
                            }
                          
    }
    return false;
  }

 Future<bool> setModerator(String memberId, BuildContext context)async{
    if(_communityState.value !=null){
          final setModeratorResponse= await _communityApiClient.addCommunityModerator(_communityState.value!.id, memberId);
          if(setModeratorResponse){
              //show snack bar 
              
              if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Moderator set successfully")));
                  return true;
              }
              

          }
          else{
                //show snack bar 
                if(mounted){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Failed to set moderator")));
                }
                return false;
              }

          
    }
    else{
      // show the error message
      if(mounted){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("community is undefined")));
                            }
                          
    }
    return false;
  }

Future<bool> removeModerator(String memberId, BuildContext context)async{
    if(_communityState.value !=null){
          // update the state first 
          
          final removeModeratorResponse= await _communityApiClient.removeCommunityModerator(_communityState.value!.id, memberId);
          if(removeModeratorResponse){
            //show snack bar 
            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Moderator removed successfully")));
                return true;
                }
                }
                
                else{
             //show snack bar 
             if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Failed to remove moderator")));
                }
                return false;
                }

          
    }
    else{
      // show the error message
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("community is undefined")));
          }
          }
          return false;
          }


  Future<void> getMoreMembers() async {
    try {
      if (_communityState.hasValue) {
        final community = _communityState.value!;

        final members =
            await _communityApiClient.getCommunityMembers(community.id);


        state = AsyncValue.data(members);
      } else if (_communityState.hasError) {
      } else {
      }
    } catch (e, stackTrace) {}
  }

  // Future<void> removeMember (String communityId, Member member) async {
  //   try {
  //     final response = await _communityState.removeMember(communityId, member.id);
  //     if (response) {
  //       state = AsyncValue.data(state.data!.value..remove(member));
  //     }
  //   } catch (e, stackTrace) {
  //     print("Error in removing member: $e");
  //   }
  // }
}



final blockedMembersStateProvider =
    StateNotifierProvider.autoDispose<BlockedMembersNotifier, AsyncValue<List<BlockedMember>>>((ref) {
  final communityProvider = ref.read(singleCommunityStateProvider);
  final communityApiClient = ref.read(communityRepoProvider);
  return BlockedMembersNotifier(communityProvider, communityApiClient);
});

class BlockedMembersNotifier extends StateNotifier<AsyncValue<List<BlockedMember>>> {
  final AsyncValue<Community> _communityProvider;
  final CommunityApiClient _communityApiClient;
   bool _mounted = false;


  BlockedMembersNotifier(this._communityProvider, this._communityApiClient)
      : super(const AsyncValue.loading()) {
    _mounted = true;
    loadBlockedMembers();
  }
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadBlockedMembers() async {
    if (!_mounted) return;
    
    final community = _communityProvider.value;
    if (community != null) {
      final blockedMembers =
          await _communityApiClient.getCommunityBlockedMembers(community.id);
     if (_mounted) state = AsyncValue.data(blockedMembers);
    } else {
      if (_mounted) state = AsyncValue.data([]);
    }
  }

 Future<bool> blockMember (  String memberID,BuildContext context) async {
    try {
      if(_communityProvider.value !=null){
              final blockedMember = await _communityApiClient.blockMember( memberID,_communityProvider.value!.id);
        if(blockedMember!=null && blockedMember){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Member blocked successfully")));
            return true;
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("failed to block")));
          
          return false;}
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Community is undefined")));
        
        return false;}
    
    //     if (unblockedMember != null && unblockedMember is List<Member>) {
    //   state =  AsyncValue.data(_communityState.value!.members!..add(unblockedMember.first));
    // }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Unknown error ")));
        return false;
     

    }


    
  }

   Future<bool?> unblockMember (  String memberID,String communityId ) async {
    try {
      final unblockedMember = await _communityApiClient.unblockMember( memberID,communityId);
    //     if (unblockedMember != null && unblockedMember is List<Member>) {
    //   state =  AsyncValue.data(_communityState.value!.members!..add(unblockedMember.first));
    // }
    if(unblockedMember != null && unblockedMember){
        return true;
      }
      else{
          return false;
      }
    //     if (unblockedMember != null && unblockedMember is List<Member>) {
    //   state =  AsyncValue.data(_communityState.value!.members!..add(unblockedMember.first));
    // }
      } catch (e) {
        throw e;
    }
  }
}
