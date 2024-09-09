// this file is for state managment of community
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/models/community.dart';
import 'package:iron_sight/APIs/community_api_client.dart';
import 'package:riverpod/riverpod.dart';

final communityListStateProvider =
    StateNotifierProvider<CommunityListState, AsyncValue<List<Community>>>(
        (ref) {
  final communityApiClient = ref.watch(communityRepoProvider);
  final authController = ref.watch(authControllerProvider);
  return CommunityListState(communityApiClient, ref);
});

class CommunityListState extends StateNotifier<AsyncValue<List<Community>>> {
  final CommunityApiClient _communityApiClient;
  Ref _ref;

  CommunityListState(this._communityApiClient, this._ref)
      : super(const AsyncValue<List<Community>>.loading());

  Future<void> loadCommunities({bool isHomeView = false}) async {
    try {
      state = const AsyncValue.loading();
      final communities = await _communityApiClient.getCommunities();
      String? userId =
          _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if (userId != null && communities != null) {
        if (isHomeView) {
          state = AsyncValue.data(communities
              .where((community) =>
                  !community.blockedUsers.contains(userId) &&
                  (community.membersIds.contains(userId) ||
                      community.moderatorsIds.contains(userId) ||
                      community.owner == userId))
              .toList());
        } else {
          state = AsyncValue.data(communities);
        }
      } else {
        throw 'User is not logged in';
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
  
  bool isUserFollowing(String communityId) {
    return state.value?.any((community) =>
            community.id == communityId &&
            community.membersIds.contains(_ref
                .read(authControllerProvider.notifier)
                .getCurrentUserId())) ??
        false;
  }

  bool isOwnerOrModerator(String communityId) {
    return state.value?.any((community) =>
            community.id == communityId &&
            (community.moderatorsIds.contains(_ref
                    .read(authControllerProvider.notifier)
                    .getCurrentUserId()) ||
                community.owner ==
                    _ref
                        .read(authControllerProvider.notifier)
                        .getCurrentUserId())) ??
        false;
  }

  bool isOwner(String communityId) {
    return state.value?.any((community) =>
            community.id == communityId &&
            community.owner ==
                _ref
                    .read(authControllerProvider.notifier)
                    .getCurrentUserId()) ??
        false;
  }

  bool isModerator(String communityId) {
    return state.value?.any((community) =>
            community.id == communityId &&
            community.moderatorsIds.contains(_ref
                .read(authControllerProvider.notifier)
                .getCurrentUserId())) ??
        false;
  }

  // // to follow community
// //success == "Success" will be returned from the followCommunity(CommunityId, userId)
// //else will throw exception, handling it in the ui be rethrowing it
  Future<void> followCommunity(String communityId) async {
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    try {
      if (state.value != null && userId != null) {
        final response =
            await _communityApiClient.followCommunity(communityId, userId);
        if (response.toLowerCase() == "success") {
          state = AsyncValue.data(state.value!.map((community) {
            if (community.id == communityId) {
              return community
                  .copyWith(membersIds: [...community.membersIds, userId]);
            }
            return community;
          }).toList());
        } else {
          throw Exception(
              'Error in following community: API call was not successful');
        }
      } else {
        throw Exception(
            'Error in following community: either user is not logged in or the community does not exist');
      }
    } catch (e) {
      state = AsyncValue.data(state.value!.map((community) {
        if (community.id == communityId) {
          return community.copyWith(
              membersIds: community.membersIds
                  .where((element) => element != userId)
                  .toList());
        }
        return community;
      }).toList());
      rethrow;
    }
  }

  Future<void> unFollowCommunity(String communityId) async {
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    try {
      if (state.value != null && userId != null) {
        final response =
            await _communityApiClient.unFollowCommunity(communityId, userId);
        if (response == "Success") {
          state = AsyncValue.data(state.value!.map((community) {
            if (community.id == communityId) {
              return community.copyWith(
                  membersIds: community.membersIds
                      .where((element) => element != userId)
                      .toList());
            }
            return community;
          }).toList());
        } else {
          throw Exception(
              'Error in unfollowing community: API call was not successful');
        }
      } else {
        throw Exception(
            'Error in unfollowing community: either user is not logged in or the community does not exist');
      }
    } catch (e) {
      state = AsyncValue.data(state.value!.map((community) {
        if (community.id == communityId) {
          return community.copyWith(membersIds: [
            ...community.membersIds,
            if (userId != null) userId
          ]);
        }
        return community;
      }).toList());
      rethrow;
    }
  }
}

final singleCommunityStateProvider =
    StateNotifierProvider<SingleCommunityState, AsyncValue<Community>>((ref) {
  final communityApiClient = ref.read(communityRepoProvider);
  return SingleCommunityState(communityApiClient, ref);
});

class SingleCommunityState extends StateNotifier<AsyncValue<Community>> {
  final CommunityApiClient _communityApiClient;
  Ref _ref;
  SingleCommunityState(this._communityApiClient, this._ref)
      : super(const AsyncValue<Community>.loading());

  Future<void> getCommunity(String id) async {
    // print('trying to get community with id ' + id);
    try {
      state = const AsyncValue.loading();
      final community = await _communityApiClient.getCommunity(id);
      if (community != null) {
        // print('got community with info : ${community.toJson()}');
        state = AsyncValue.data(community);
      } else {
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error('An err', stackTrace);
    }
  }

  // to follow community
//success == "Success" will be returned from the followCommunity(CommunityId, userId)
//else will throw exception, handling it in the ui be rethrowing it
  Future<void> followCommunity() async {
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    try {
      if (state.value != null && userId != null) {
        state = AsyncValue.data(state.value!.copyWith(
            membersIds: [...state.value!.membersIds, userId],
            membersLength: state.value!.membersLength + 1));
        final response =
            await _communityApiClient.followCommunity(state.value!.id, userId);
        if (response == null) {
          // update the state
          //rollback the current state
          state = AsyncValue.data(state.value!.copyWith(
              membersIds: state.value!.membersIds
                  .where((element) => element != userId)
                  .toList()));
        }
      } else {
        state = AsyncValue.data(state.value!.copyWith(
            membersIds: state.value!.membersIds
                .where((element) => element != userId)
                .toList()));
        throw Exception(
            'Error in following community: either user is not logged in or the community does not exists');
      }
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
          membersIds: state.value!.membersIds
              .where((element) => element != userId)
              .toList()));
      rethrow;
    }
  }

  //UnFollowCommunity
  //success == "Success" will be returned from the unFollowCommunity(CommunityId, userId)
  //else will throw exception, handling it in the ui be rethrowing it
  Future<void> unFollowCommunity() async {
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    try {
      if (state.value != null && userId != null) {
        // First, update the state
        state = AsyncValue.data(state.value!.copyWith(
            membersIds: state.value!.membersIds
                .where((element) => element != userId)
                .toList(),
            membersLength: state.value!.membersLength - 1));

        // Then, call the API
        final response = await _communityApiClient.unFollowCommunity(
            state.value!.id, userId);

        // If the API call is not successful, rollback the state
        if (response == null) {
          state = AsyncValue.data(state.value!
              .copyWith(membersIds: [...state.value!.membersIds, userId]));
        }
      } else {
        throw Exception(
            'Error in unfollowing community: either user is not logged in or the community does not exist');
      }
    } catch (e) {
      // If there's an error, rollback the state
      state = AsyncValue.data(state.value!.copyWith(membersIds: [
        ...state.value!.membersIds,
        if (userId != null) userId
      ]));
      rethrow;
    }
  }

  bool isMember() {
    if (state.value != null) {
      return state.value!.membersIds.contains(
              _ref.read(authControllerProvider.notifier).getCurrentUserId())
          ? true
          : false;
    }
    return false;
  }

  bool isOwner() {
    if (state.value != null) {
      return state.value!.owner ==
              _ref.read(authControllerProvider.notifier).getCurrentUserId()
          ? true
          : false;
    }
    return false;
  }

  bool isModerator() {
    if (state.value != null) {
      return state.value!.moderatorsIds.contains(
              _ref.read(authControllerProvider.notifier).getCurrentUserId())
          ? true
          : false;
    }
    return false;
  }

  reduceMembersCount() {
    if (state.value != null) {
      state = AsyncValue.data(
          state.value!.copyWith(membersLength: state.value!.membersLength - 1));
    }
    // state= state.(membersCount: state.membersCount-1);
  }

// create should navigate to community page after creating success
  Future<String> createCommunity(Map<String, dynamic> communityInfo) async {
    try {
      // testing
      if (_ref.read(authControllerProvider.notifier).getCurrentUserId() !=
          null) {
      } else {
        throw Exception('User is not registered');
      }
      communityInfo['Owner'] =
          _ref.read(authControllerProvider.notifier).getCurrentUserId();
      final community =
          await _communityApiClient.createCommunity(communityInfo);
      if (community != null) {
        state = AsyncValue.data(community);
      }
      return 'Success';
    } catch (e, stackTrace) {
      state = AsyncValue.error('An err', stackTrace);
      return 'Error ${e.toString()}';
    }
  }

// update should navigate to community page after updating success
  Future<void> editCommunity(Map<String, dynamic> communityInfo) async {
    if (state.value != null &&
        state.value!.owner ==
            _ref.read(authControllerProvider.notifier).getCurrentUserId()) {
      try {
        String? userId =
            _ref.read(authControllerProvider.notifier).getCurrentUserId();
        if (userId != null) {
          var communityId = state.value!.id;
          final community = await _communityApiClient.editCommunity(
              communityId, communityInfo);
          if (community != null) {
            state = AsyncValue.data(community);
          }
        } else {
          throw 'User is not signed in';
        }
      } catch (e, stackTrace) {
        state = AsyncValue.error('An err', stackTrace);
      }
    } else {
    }
  }

  Future<void> getCommunityMembers() async {
    try {
      state = const AsyncValue.loading();
      final members =
          await _communityApiClient.getCommunityMembers(state.value!.id);
      state = AsyncValue.data(state.value!.copyWith(members: members));
      // state.value!.members= await _communityApiClient.getCommunityMembers(state.value!.id) ;
      // final communityMembers=
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }

    // else{
    //   print('state is null');
    // }
  }

  String? getCurrentCommunityId() {
    if (state.value != null) {
      return state.value!.id;
    }
    return null;
  }

  Future<bool> uploadCommunityPictures(File file) async {
    if (state.value != null) {
      try {
        final updateCommunity = await _communityApiClient
            .uploadCommunityPicture(file, state.value!.id, 'Community_Picture');

        // state= AsyncValue.data(null);
        if (updateCommunity != null) {
          state =
              AsyncValue.data(state.value!.copyWithFromMap(updateCommunity));
          return true;
        } else {
          return false;
        }
      } catch (e) {

        return false;
      }
    }
    return false;
  }

  Future<bool> uploadCommunityBanner(File file) async {
    if (state.value != null) {
      try {
        final updateCommunity = await _communityApiClient
            .uploadCommunityPicture(file, state.value!.id, 'Banner');


        // state= AsyncValue.data(null);
        if (updateCommunity != null) {
          state =
              AsyncValue.data(state.value!.copyWithFromMap(updateCommunity));
          return true;
        } else {
          return false;
        }
      } catch (e) {

        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> uploadCommunityThumbnail(File file) async {
    if (state.value != null) {
      try {
        final updateCommunity = await _communityApiClient
            .uploadCommunityPicture(file, state.value!.id, 'Thumbnail');

        // state= AsyncValue.data(null);
        if (updateCommunity != null) {
          state =
              AsyncValue.data(state.value!.copyWithFromMap(updateCommunity));
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  // Other methods specific to handling a single community
}
