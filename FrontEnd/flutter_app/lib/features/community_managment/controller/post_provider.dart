import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/community_api_client.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/models/post.dart';
import 'package:iron_sight/models/reply.dart';
import 'package:iron_sight/util/utils.dart';
import 'package:riverpod/riverpod.dart';

final communityPostsProvider = StateNotifierProvider.autoDispose<
    CommunityPostListState, AsyncValue<List<Post>>>((ref) {
  final communityApiClient = ref.watch(communityRepoProvider);
  return CommunityPostListState(communityApiClient, ref);
});

// final communityRepliesProvider = FutureProvider<
//      List<Reply>?((ref) {
//   final communityApiClient = ref.watch(communityRepoProvider);
//   return CommunityReplyListState(communityApiClient);
// });
// final communityRepliesProvider =
//     FutureProvider.family<List<Reply>?, String>((ref, postId) {
//   final communityApiClient = ref.watch(communityRepoProvider);
//   return communityApiClient.getPostReplies(postId);
// });
final communityRepliesProvider =
    StateNotifierProvider.autoDispose<ReplyNotifier, AsyncValue<List<Reply>>>(
        (ref) {
  final communityApiClient = ref.watch(communityRepoProvider);
  return ReplyNotifier(communityApiClient, ref);
});

class ReplyNotifier extends StateNotifier<AsyncValue<List<Reply>>> {
  Ref _ref;
  final CommunityApiClient communityApiClient;

  ReplyNotifier(this.communityApiClient, this._ref)
      : super(const AsyncValue.loading()) {}

  Future<void> loadReplies(String postId) async {
    try {
      List<Reply>? replies = await communityApiClient.getPostReplies(postId);
      if (replies == null) {
        state = AsyncValue.data([]);
      } else {
        state = AsyncValue.data(replies);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> likeReply(String replyId, String postId) async {
    // Find the reply in the local state
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (userId == null) {
      throw Exception('Like failed, user is not logged in');
    }
    var replyIndex = state.value!.indexWhere((r) => r.id == replyId);

    if (replyIndex != -1 &&
        !state.value![replyIndex].replyLikesIds.contains(userId)) {
      // Create a new Reply object with the updated fields
      var newReply = state.value![replyIndex].copyWith(
        replyLikesIds: [...state.value![replyIndex].replyLikesIds, userId],
        replyLikeCount: state.value![replyIndex].replyLikeCount + 1,
      );

      // Replace the old Reply object in the state with the new one
      state = AsyncValue.data(state.value!..[replyIndex] = newReply);

      // Make the API call
      bool? success =
          await communityApiClient.likeReply(postId, newReply.id, userId);

      if (success == null || !success) {
        // If the API call fails, revert the changes in the local state
        newReply = newReply.copyWith(
          replyLikesIds:
              newReply.replyLikesIds.where((id) => id != userId).toList(),
          replyLikeCount:
              newReply.replyLikeCount - 1 < 0 ? 0 : newReply.replyLikeCount - 1,
        );
        state = AsyncValue.data(state.value!..[replyIndex] = newReply);
      }
    }
  }

  Future<void> unlikeReply(String replyId, String postId) async {
    // Find the reply in the local state
    String? userId =
        _ref.read(authControllerProvider.notifier).getCurrentUserId();
    if (userId == null) {
      throw Exception('unlike failed, user is not logged in');
    }
    var replyIndex = state.value!.indexWhere((r) => r.id == replyId);

    if (replyIndex != -1 &&
        state.value![replyIndex].replyLikesIds.contains(userId)) {
      // Create a new Reply object with the updated fields
      var newReply = state.value![replyIndex].copyWith(
        replyLikesIds: state.value![replyIndex].replyLikesIds
            .where((id) => id != userId)
            .toList(),
        replyLikeCount: state.value![replyIndex].replyLikeCount - 1 < 0
            ? 0
            : state.value![replyIndex].replyLikeCount - 1,
      );

      // Replace the old Reply object in the state with the new one
      state = AsyncValue.data(state.value!..[replyIndex] = newReply);

      // Make the API call
      bool? success =
          await communityApiClient.unLikeReply(postId, replyId, userId);

      if (success == null || !success) {
        // If the API call fails, revert the changes in the local state
        newReply = newReply.copyWith(
          replyLikesIds: [...newReply.replyLikesIds, userId],
          replyLikeCount: newReply.replyLikeCount + 1,
        );
        state = AsyncValue.data(state.value!..[replyIndex] = newReply);
      }
    }
  }
}
// to be completed

class CommunityPostListState extends StateNotifier<AsyncValue<List<Post>>> {
  Ref _ref;
  CommunityPostListState(this._communityApiClient, this._ref)
      : super(const AsyncValue<List<Post>>.loading());
  final CommunityApiClient _communityApiClient;

  Future<void> getPosts(String communityId) async {
    try {
      if (!mounted) return;
      state = const AsyncValue.loading();

      final posts = await _communityApiClient.getCommunityPosts(communityId);
      if (!mounted) return;
      if (posts != null || posts != []) {
        // print('posts are returned as ${posts.toString()}');
        state = AsyncValue.data(posts!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error('An err', stackTrace);
    }
  }

  Future<void> getMostPopularPosts(String communityId) async {
    try {
      state = const AsyncValue.loading();

      final posts = await _communityApiClient.getCommunityTopPosts(communityId);
      if (posts != null || posts != []) {
        // print('posts are returned as ${posts.toString()}');
        state = AsyncValue.data(posts!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error('An err', stackTrace);
    }
  }

  Future<void> likePost(String postId, String userId) async {
    List<Post> updatedPostsList = List.from(state.value!);
    int postIndex =
        updatedPostsList.indexWhere((element) => element.id == postId);

    if (postIndex != -1) {
      Post updatedPost = updatedPostsList[postIndex];
      updatedPost.postLikesIds.add(userId);
      updatedPost = updatedPost.copyWith(
          postLikesIds: List.from(updatedPost.postLikesIds),
          postLikeCount: updatedPost.postLikeCount + 1);
      updatedPostsList[postIndex] = updatedPost;
      state = AsyncValue.data(updatedPostsList);

      final likePostRequest =
          await _communityApiClient.likePost(postId, userId);
      // if (likePostRequest == null || !likePostRequest) {
      //   // Rollback the changes if the request failed
      //   updatedPost.postLikesIds.remove(userId);
      //   updatedPost = updatedPost.copyWith(
      //       postLikesIds: List.from(updatedPost.postLikesIds),
      //       postLikeCount: updatedPost.postLikeCount - 1);
      //   updatedPostsList[postIndex] = updatedPost;
      //   state = AsyncValue.data(updatedPostsList);
      //   print('Failed to like post, rolled back changes');
      // }
    } else {
    }
  }

  Future<void> unLikePost(String postId, userId) async {
    List<Post> updatedPostsList = List.from(state.value!);
    int postIndex =
        updatedPostsList.indexWhere((element) => element.id == postId);

    if (postIndex != -1) {
      Post updatedPost = updatedPostsList[postIndex];
      updatedPost.postLikesIds.remove(userId);
      updatedPost = updatedPost.copyWith(
          postLikesIds: List.from(updatedPost.postLikesIds),
          postLikeCount: updatedPost.postLikeCount - 1 < 0
              ? 0
              : updatedPost.postLikeCount - 1);
      updatedPostsList[postIndex] = updatedPost;
      state = AsyncValue.data(updatedPostsList);
      print('Optimistically updated post likes(undlike)');

      final unLikePostRequest =
          await _communityApiClient.unLikePost(postId, userId);
      // if (unLikePostRequest == null || !unLikePostRequest) {
      //   // Rollback the changes if the request failed
      //   updatedPost.postLikesIds.add(userId);
      //   updatedPost = updatedPost.copyWith(
      //       postLikesIds: List.from(updatedPost.postLikesIds),
      //       postLikeCount: updatedPost.postLikeCount + 1);
      //   updatedPostsList[postIndex] = updatedPost;
      //   state = AsyncValue.data(updatedPostsList);
      //   print('Failed to unlike post, rolled back changes');
      // }
    } else {
    }
  }

  // Future<void> addPostReply(
  //     String postId, String userId, String replyContent) async {
  //   state = const AsyncValue.loading();

  //   try {
  //     // Call the API to add the reply to the post
  //     final Reply? newReply = await _communityApiClient.addPostReply(
  //       postId,
  //       {'userId': userId, 'replyContent': replyContent},
  //     );

  //     if (newReply != null) {
  //       // If the reply is successfully added, update the local state
  //       state.whenData((replies) =>
  //           state = AsyncValue.data([...replies!, newReply as Post]));
  //     } else {
  //       // If the reply is not added, keep the state as it is
  //       state = AsyncValue.error('Failed to add the reply', StackTrace.current);
  //     }
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //   }
  // }

  Future<void> removePost(String communityId, String postId) async {
    try {
      state = const AsyncValue.loading();
      final posts =
          await _communityApiClient.removeCommunityPost(communityId, postId);
      if (posts != null || posts != []) {
        // print('posts are returned as ${posts.toString()}');
        state = AsyncValue.data(posts!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error('An err', stackTrace);
    }
  }

  void addPost(Post post) {
    if (state.value != null) {
      final updatedList = [...state.value!, post];
      // state = AsyncValue.data([...state.data!, post]);
      state =
          state.copyWithPrevious(isRefresh: true, AsyncValue.data(updatedList));
      // state = AsyncValue.data(updatedList);
    }
  }

  Future<void> sharePost({
    required String postContent,
    required List<File> images,
    required BuildContext context,
    required String communityId,
  }) async {
    try {
      if (postContent.isEmpty) {
        showSnackBar(context, "Please enter text");
      }
      // print('images are ${images} ${images.isNotEmpty}');

      if (images.isNotEmpty) {
        // share post with images
        Post? post = await _shareImagePost(
            postContent: postContent,
            images: images,
            context: context,
            communityId: communityId);

        if (post != null) {
          showSnackBar(context, "post with upload has been created");

          // Add the new post to the list
          addPost(post);

          // Update the state with the new list
          if (state.value != null) {
            state = AsyncValue.data(state.value!);
          }
        } else {
          showSnackBar(context, "Failed to share post With upload");
        }
      } else {
        // share post with no images
        String? userId =
            _ref.read(authControllerProvider.notifier).getCurrentUserId();
        if (userId != null) {

          final post = await _communityApiClient.shareTextPost(
            communityId: communityId,
            postContent: postContent,
            userId: userId,
          );
          if (post != null) {
            showSnackBar(context, "post has been created");

            // Add the new post to the list
            addPost(post);

            // Update the state with the new list
            if (state.value != null) {
              state = AsyncValue.data(state.value!);
            }
          } else {
            showSnackBar(context, "Failed to share post");
            throw Exception("Failed to share post");

          }
        } else {
          
          showSnackBar(context, "You need to be logged in to share a post");
          throw Exception("Failed to share post");
        }
      }
    } catch (e, stackTrace) {
      rethrow;
      // state = AsyncValue.error('An error occurred', stackTrace);
    }
  }

  Future<Post?> _shareImagePost({
    required String postContent,
    required List<File> images,
    required BuildContext context,
    required communityId,
  }) async {
    try {
      // first add the user id
      String? userId =
            _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if(userId == null){
        showSnackBar(context, "You need to be logged in to share a post");
        throw Exception("You need to be logged in to share a post");
      }
      final post = await _communityApiClient.shareTextPost(
        communityId: communityId,
        postContent: postContent,
        userId: userId,
      );
      if (post != null) {
      }
      List<Future<Post?>> uploadReplyFeaturs = [];
      for (int i = 0; i < images.length; i++) {
        // share post image
        uploadReplyFeaturs.add(_communityApiClient.shareImagePost(
          imageFile: images[i],
          imageName: 'Photo_${i + 1}',
          postId: post!.id,
        ));
      }

      List<Post?> uploadPosts = await Future.wait(uploadReplyFeaturs);

      // Filter out null values
      uploadPosts = uploadPosts.where((post) => post != null).toList();

      if (uploadPosts.isNotEmpty) {
        return uploadPosts.last;
      } else {
        return null;
      }
    } catch (e) {
      showSnackBar(context, "error occured during sharing post image 212");
    }
  }


  Future<Reply?> _shareImageReply({
    required String replyContent,
    required List<File> images,
    required BuildContext context,
    required postId,
  }) async {
    try {
      String? userId =
            _ref.read(authControllerProvider.notifier).getCurrentUserId();
      if(userId == null){
        showSnackBar(context, "You need to be logged in to share a post");
        throw Exception("You need to be logged in to share a post");
      }
      //
      final post = await _communityApiClient.shareReply(
        replyContent: replyContent,
        postId: postId,
        imageUrls: [],
        userId: userId,);

      if (post != null) {
      }
      List<Future<Reply?>> uploadReplyFeaturs = [];
      for (int i = 0; i < images.length; i++) {
        // share post image
        uploadReplyFeaturs.add(_communityApiClient.shareImageReply(
          imageFile: images[i],
          imageName: 'Photo_${i + 1}',
          postId: post!.id,
          replyId: userId,
        ));
      }

      List<Reply?> uploadPosts = await Future.wait(uploadReplyFeaturs);

      // Filter out null values
      uploadPosts = uploadPosts.where((post) => post != null).toList();

      if (uploadPosts.isNotEmpty) {
        return uploadPosts.last;
      } else {
        return null;
      }
    } catch (e) {
      showSnackBar(context, "error occured during sharing post image 212");
    }
  }

  Future<Reply?> shareReply({
  required String postId,
  required String replyContent,
  required List<File> images,
  required BuildContext context,
}) async {
  // Check if the user is logged in and has a valid ID
  String? userId = _ref.read(authControllerProvider.notifier).getCurrentUserId();
  if (userId == null) {
    showSnackBar(context, "You need to be logged in to reply to a post");
    return null;
  }

  // Check for empty content
  if (replyContent.isEmpty) {
    showSnackBar(context, "Please enter text");
    return null;
  }

  try {
    // Upload images first if there are any
    List<String> imageUrls = [];
    if (images.isNotEmpty) {
      for (File image in images) {
        // Use your API client's method to upload the image.
        // The uploadImage method must return the URL of the uploaded image
        // or throw an error if something goes wrong.
        Reply? imageUrl = await _communityApiClient.shareImageReply(
          imageFile: image,
          imageName: 'Photo',
          postId: postId,
          replyId: userId,);
        imageUrls.add(imageUrl.toString());
      }
    }

    // Now, send the reply content with image URLs to the backend
    final Reply reply = await _communityApiClient.shareReply(
      replyContent: replyContent,
      postId: postId,
      userId: userId,
      imageUrls: imageUrls, // Pass image URLs to the API client method
    );

    // If the reply is successfully added, show success message
    showSnackBar(context, "Reply has been created");

    // Return the new reply
    return reply;
  } catch (e) {
    // Show error message
    // showSnackBar(context, "An error occurred during sharing the reply: $e");
    return null;
  }
}


// class CommunityReplyListState extends StateNotifier<AsyncValue<List<Reply>?>> {
//   CommunityReplyListState(this._communityApiClient)
//       : super(const AsyncValue<List<Reply>>.loading());
//   final CommunityApiClient _communityApiClient;

//   Future<void> getReplies(String postId) async {
//     print('trying to get replies for post'+postId);
//     try {
//       state = const AsyncValue.loading();
//       final replies = await _communityApiClient.getPostReplies(postId);
//       if (replies != null || replies != []) {
//         print('Replies are returned as ${replies.toString()}');
//         state = AsyncValue.data(replies!);
//       } else {
//         print('making replies empty');
//         state = const AsyncValue.data([]);
//       }
//     } catch (e, stackTrace) {
//       state = AsyncValue.error('An err $e', stackTrace);
//     }
//   }

  // Future<void> removeReply (String postId,String replyId) async {
  //   try {
  //     state = const AsyncValue.loading();
  //     final replies = await _communityApiClient.removeCommunityPost(postId,replyId);
  //     if (replies != null || replies != []) {
  //       print('Replies are returned as ${replies.toString()}');
  //       state = AsyncValue.data(replies!);
  //     }
  //     else {
  //       print('making replies empty');
  //       state = const AsyncValue.data([]);
  //     }
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error('An err', stackTrace);
  //   }
  // }
// import 'dart:io';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iron_sight/APIs/community_api_client.dart';
// import 'package:iron_sight/models/post.dart';
// import 'package:iron_sight/util/utils.dart';

// final communityPostsProvider = FutureProvider.family<List<Post>, String>((ref, communityId) async {
//   final communityApiClient = ref.watch(communityRepoProvider);
//   final posts = await communityApiClient.getCommunityPosts(communityId);
//   if(posts is List<Post> ){
//     return posts;
//   }
//   return [];
// });

// class CommunityPostListNotifier extends StateNotifier<List<Post>> {
//   CommunityPostListNotifier(this._communityApiClient) : super([]);

//   final CommunityApiClient _communityApiClient;

//   Future<void> getPosts(String communityId) async {
//    final posts =  await _communityApiClient.getCommunityPosts(communityId);
//    if(posts is List<Post>){
//      state = posts;
//    }
//   }

//   Future<void> getMostPopularPosts(String communityId) async {
//     final posts = await _communityApiClient.getCommunityTopPosts(communityId);
//     if(posts is List<Post>){
//      state = posts;
//    }
//   }

//   Future<void> removePost(String communityId, String postId) async {
//     final posts = await _communityApiClient.removeCommunityPost(communityId, postId);
//   if(posts is List<Post>){
//         state = posts;

//   }
//   }

//   void addPost(Post post) {
//     state = [...state, post];
//   }

//   Future<void> sharePost({
//     required String postContent,
//     required List<File> images,
//     required BuildContext context,
//     required String communityId,
//   }) async {
//     try {
//       if (postContent.isEmpty) {
//         showSnackBar(context, "Please enter text");
//         return;
//       }

//       if (images.isNotEmpty) {
//         // share post with images
//       } else {
//         // share post with no images
//         final post = await _communityApiClient.shareTextPost(
//           communityId: communityId,
//           postContent: postContent,
//           userId: 'P1',
//         );

//         if (post != null) {
//           print('Post has been shared');
//           showSnackBar(context, "post has been created");
//           // Add the new post to the list
//           addPost(post);
//         } else {
//           print('Failed to share post');
//           showSnackBar(context, "Failed to share post");
//         }
//       }
//     } catch (e, stackTrace) {
//       print('An error occurred: $e');
//     }
//   }
// }

// final communityPostsNotifierProvider =
//     StateNotifierProvider<CommunityPostListNotifier, List<Post>>((ref) {
//   final communityApiClient = ref.watch(communityRepoProvider);
//   return CommunityPostListNotifier(communityApiClient);
// });

//   Future<void> sharePost(
//       {required String postContent,
//       required List<File> images,
//       required BuildContext context,
//       required communityId}) async {
//     try {
//       // state = const AsyncValue.loading();

//       if (postContent.isEmpty) {
//         showSnackBar(context, "Please eneter text");
//       }

//       if (images.isNotEmpty) {
//         // share post with  images
//       } else {
//         // share post with no images
//         final post = await _communityApiClient.shareTextPost(
//             communityId: communityId, postContent: postContent, userId: 'P1');
//         if (post != null) {
//            state = const AsyncValue.loading();
//           print('Post has been shared');
//                             showSnackBar(context, "post has been created ");

//          addPost(post);
//         } else {
//           print('Failed to share post');
//           // state = const AsyncValue.data(null);
//                   showSnackBar(context, "Failed to share post");

//         }
//       }
//     } catch (e, stackTrace) {
//       state = AsyncValue.error('An error occurred', stackTrace);
//     }
//   }

// final postProvider =
//     StateNotifierProvider<PostNotifier, Post?>((ref) {
//   final communityApiClient = ref.watch(communityRepoProvider);
//   // final  communityPostList = ref.watch(communityPostsProvider);
//   // return PostNotifier(communityApiClient,communityPostsProvider);
//     // final communityPostList = ref.watch(communityPostsProvider);
//     return PostNotifier(communityApiClient);

// });
// final postProvider = StateNotifierProvider<PostNotifier, Post?>((ref) {
//   final communityApiClient = ref.watch(communityRepoProvider);
//   final communityPostsProvider = ref.watch(communityPostsProvider);
//   return PostNotifier(communityApiClient, communityPostsProvider);
// });

// class PostNotifier extends StateNotifier<Post?> {
//   // PostNotifier( this._communityApiClient, this._communityPostListProvider) : super(null);
//     PostNotifier( this._communityApiClient) : super(null);
//   // final StateNotifierProvider<CommunityPostListState, AsyncValue<List<Post>>> _communityPostListProvider;
//   final CommunityApiClient _communityApiClient;
//   // final AutoDisposeStateNotifierProvider<CommunityPostListState, AsyncValue<List<Post>>>  _communityPostListProvider;
//   Future<void> sharePost(
//       {required String postContent,
//       required List<File> images,
//       required BuildContext context,
//       required communityId}) async {
//     try {
//       // state = const AsyncValue.loading();

//       if (postContent.isEmpty) {
//         showSnackBar(context, "Please eneter text");
//       }

//       if (images.isNotEmpty) {
//         // share post with  images
//       } else {
//         // share post with no images
//         final post = await _communityApiClient.shareTextPost(
//             communityId: communityId, postContent: postContent, userId: 'P1');
//         if (post != null) {
//           print('Post has been shared');
//                             showSnackBar(context, "post has been created ");

//           // _communityPostListProvider.addPost(post);
//         } else {
//           print('Failed to share post');
//           // state = const AsyncValue.data(null);
//                   showSnackBar(context, "Failed to share post");

//         }
//       }
//     } catch (e, stackTrace) {
//       // state = AsyncValue.error('An error occurred', stackTrace);
//     }
//   }
// }
}