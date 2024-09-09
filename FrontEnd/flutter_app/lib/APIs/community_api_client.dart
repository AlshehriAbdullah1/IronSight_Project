// create community api client
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:iron_sight/APIs/api_client.dart';
import 'package:iron_sight/models/community.dart';
import 'package:iron_sight/models/member.dart';
import 'package:iron_sight/models/post.dart';
import 'package:iron_sight/models/reply.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

final communityRepoProvider = Provider<CommunityApiClient>(
  (ref) {
    return const CommunityApiClient();
  },
);

//create a provider for the commuintiy api client
class CommunityApiClient {
  final String baseUrl = ApiClient.baseUrl;
  const CommunityApiClient();

  // all function that require network access is here

  // get all communities
  Future<List<Community>?> getFollowedCommunities(userId) async {
    //todo (get all communities that user follow )
  }

  Future<List<Community>?> getCommunities() async {
    final response = await http.get(
      Uri.parse("$baseUrl/communities"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      if(response.body=="No matching documents"){
        return [];
      }
      final result = jsonDecode(response.body);
      Iterable list = result;
      return list.map((community) => Community.fromJson(community)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<List<Community>> searchCommunities(String querySearch) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/search/Community/?SearchQuery=$querySearch'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        Iterable list = result;
        return list.map((game) => Community.fromJson(game)).toList();
      }
      throw 'Error in loading games';
    } catch (e) {
      rethrow;
    }
  }

  // get Community by id
  Future<Community?> getCommunity(String communityId) async {
    // print('get community with id is requested $communityId');
    final response = await http.get(
      Uri.parse("$baseUrl/communities?Community_Id=$communityId"),
    );
    try {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // print(result);
        return Community.fromJson(result);
      } else {
        throw Exception("Failed to load specific Community");
      }
    } catch (e) {
    }
  }

  Future<String> followCommunity(String communityId, String userId) async {
    try {
      final response =
          await http.put(Uri.parse("$baseUrl/users/$userId/followCommunity"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({'Community_Id': communityId}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.toLowerCase() == 'success') {
          return 'Success';
        }
        final result = jsonDecode(response.body);

        if (result['error'] != null) {
          throw result['error'];
        } else if (result == {}) {
          throw "Failed to follow community";
        } else {
          return 'Success';
        }
      } else {
        throw "Failed to follow community";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> unFollowCommunity(String communityId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            "$baseUrl/users/$userId/unfollowCommunity?Community_Id=$communityId"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.toLowerCase() == 'success') {
          return 'Success';
        }
        final result = jsonDecode(response.body);

        if (result['error'] != null) {
          throw result['error'];
        } else if (result == {}) {
          throw "Failed to unfollow community";
        }
      } else {
        throw "Failed to unfollow community";
      }
    } catch (e) {
      rethrow;
    }
  }

  // get Community with a spicfic option and answer
  //(e.g. get community using option "Community_Id" and answer "C1")
  Future<Community?> getCommunityOption(String option, String answer) async {
    // If the option is not part of the avaiable options, don't make the request
    if (option != "Community_Id" &&
        option != "Community_Name" &&
        option != "Community_Tag" &&
        option != "Description" &&
        option != "Owner" &&
        option != "isVerified") {
      throw Exception("Invalid option");
    }
    final response = await http.get(
      Uri.parse("$baseUrl/communities?$option=$answer"),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Community.fromJson(result);
    } else {
      throw Exception("Failed to load specific Community");
    }
  }

  Future<Community?> createCommunity(Map<String, dynamic> communityInfo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/communities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(communityInfo),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return Community.fromJson(result);
      } else {
        throw Exception("Failed to load specific Community");
      }
    } catch (e) {
    }
  }

  // Edit a community, use the community id and the new community info to edit
  Future<Community?> editCommunity(
      String communityId, Map<String, dynamic> communityInfo) async {

    final response = await http.put(
      Uri.parse('$baseUrl/communities/$communityId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(communityInfo),
    );
    try {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return Community.fromJson(result);
      } else {
        throw Exception("Failed to Edit Community");
      }
    } catch (e) {
    }
  }

  Future<Community?> updateCommunity(
      String userId, Map<String, dynamic> communityInfo) async {
    return null;
  }

  Future<Post?> shareTextPost({
    required String postContent,
    required String communityId,
    required String userId,
  }) async {
    try {
      Map<String, dynamic> postBody = {
        "Post_Content": postContent,
        "User_Id": userId,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/communities/$communityId/posts/addPost'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final post = json.decode(response.body);
        if (post['error'] == null) {
          return Post.fromJson(json.decode(response.body));
        } else {
          throw Exception(post['error']);
        }
      }
      throw Exception('Error in sharing post ( server error )');
    } catch (e, st) {
      rethrow;
    }
  }

  Future<Reply> shareReply({
    required String replyContent,
    required String postId,
    required String userId,
    required List<String> imageUrls,
  }) async {
    try {
      Map<String, dynamic> replyBody = {
        "Reply_Content": replyContent,
        "User_Id": userId,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/communities/posts/$postId/replies/addReply'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(replyBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final post = json.decode(response.body);
        if (post['error'] == null) {
          return Reply.fromJson(json.decode(response.body));
        } else {
          throw Exception(post['error']);
        }
      }
      throw Exception('Error in sharing reply ( server error )');
    } catch (e, st) {
      rethrow;
    }
  }

// MEMEBER FUNCTIONS //
  // Get all memebers of a community, using the community id
  // This function returns a list of members of a community
  Future<List<Member>> getCommunityMembers(String communityId) async {
    //sending request to get community members
    final response =
        await http.get(Uri.parse("$baseUrl/communities/$communityId/members"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final community_members = jsonDecode(response.body);
      Iterable list = community_members;
      return list.map((member) => Member.fromJson(member)).toList();
    } else {
      return [];
    }
  }

  Future<List<Member>> getCommunityOwners(String communityId) async {
    //sending request to get community members
    final response =
        await http.get(Uri.parse("$baseUrl/communities/$communityId/owner"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final community_members = jsonDecode(response.body);
      // Iterable list = community_members;
      community_members['Is_Owner'] = true;
      return [Member.fromJson(community_members)].toList();
      // return list.map((member) {
      //   member['Is_Owner']=true;
      //   return  Member.fromJson(member);
      // }).toList();
    } else {
      return [];
    }
  }

  Future<List<Member>> getCommunityModerators(String communityId) async {
    //sending request to get community members
    final response = await http
        .get(Uri.parse("$baseUrl/communities/$communityId/moderators"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final community_members = jsonDecode(response.body);
      Iterable list = community_members;
      return list.map((member) {
        member['Is_Moderator'] = true;
        return Member.fromJson(member);
      }).toList();
    } else {
      return [];
    }
  }
  // // Add a member to a community
  // Future<Member?> addCommunityMember(String communityId, String memberId) async {
  //   //sending request to add a member to a community
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/communities/$communityId/members"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode({"Member_Id": memberId}),
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final result = jsonDecode(response.body);
  //     return Member.fromJson(result);
  //   } else {
  //     return null;
  //   }
  // }

  // Remove a member from a community
  Future<bool> removeCommunityMember(
      String communityId, String memberId) async {
    //sending request to remove a member from a community
    try {
      final response = await http.delete(
        Uri.parse(
            "$baseUrl/users/$memberId/unfollowCommunity/?Community_Id=$communityId"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

// BLOCKED MEMEBERS and BLOCKING FUNCTIONS //
  Future<List<BlockedMember>> getCommunityBlockedMembers(
      String communityId) async {
    //sending request to get community blocked members
    final response = await http
        .get(Uri.parse("$baseUrl/communities/$communityId/blockedMembers"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final communityBlockedMembers = jsonDecode(response.body);
      Iterable list = communityBlockedMembers;
      return list
          .map((blockedMember) => BlockedMember.fromJson(blockedMember))
          .toList();
    }
    // If the response is not 200 or 201, return an empty list
    else {
      return [];
    }
  }

  // unBlock a member from a community
  Future<bool?> unblockMember(String memberId, String communityId) async {
    //sending request to unblock a member from a community
    // "/communities/:Community_Id/blockMember"
    final response = await http.put(
      Uri.parse("$baseUrl/communities/$communityId/unblockMember"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"User_Id": memberId}),
    );

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      // If the response is not 200 or 201, return an empty list
      else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> blockMember(String memberId, String communityId) async {
    //sending request to unblock a member from a community
    // "/communities/:Community_Id/blockMember"
    final response = await http.put(
      Uri.parse("$baseUrl/communities/$communityId/blockMember"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"User_Id": memberId}),
    );

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      // If the response is not 200 or 201, return an empty list
      else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

// Moderator FUNCTIONS //
  // Add a moderator to a community
  Future<bool> addCommunityModerator(
      String communityId, String moderatorId) async {
    // print('adding moderator to community: $communityId');
    //sending request to add a moderator to a community
    final response = await http.put(
      Uri.parse("$baseUrl/communities/$communityId/addModerator"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"User_Id": moderatorId}),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.body;
        return true;
      } else {
        return false;
      }
    } catch (e) {
    }
    return false;
  }

  // Remove a moderator from a community
  Future<bool> removeCommunityModerator(
      String communityId, String moderatorId) async {
    //sending request to remove a moderator from a community
    final response = await http.put(
      Uri.parse("$baseUrl/communities/$communityId/removeModerator"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"User_Id": moderatorId}),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('error in removeCommunityModerator: $e');
    }
    return false;
  }

// POST FUNCTIONS //
  // Get all posts of a community, using the community id
  // This function returns a list of posts of a community
  Future<List<Post>?> getCommunityPosts(String communityId) async {
    //sending request to get community posts
    final response =
        await http.get(Uri.parse("$baseUrl/communities/$communityId/posts"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final communityPosts = jsonDecode(response.body);
      // print('retuned posts are: $communityPosts');

      try {
        // List<Post> posts= [new Post(poster: Poster(userId: '4', displayName: 'displayName', profilePicture: 'profilePicture', userName: 'userName'), id: '3', postContent: 'postContent', postLikeCount: 0, userImage: 'userImage', userBio: 'userBio', displayName: 'displayName')];
        // Iterable list = communityPosts;
        // print('list is: $list');
        // handle the case where the post is empty list or empty
        if (communityPosts.isEmpty || communityPosts == []) {
          return [];
        } else {
          return communityPosts
              .map((post) => Post.fromJson(post))
              .toList()
              .cast<Post>();
        }
        // return communityPosts.map((post) => Post.fromJson(post)).toList().cast<Post>();
      } catch (e) {
        rethrow;
      }
    }
    // If the response is not 200 or 201, return an empty list
    else {
      return [];
    }
  }

  // Get a specific post of a community, using the community id and post id
  // This function returns a post of a community
  Future<Post?> getCommunityPost(String communityId, String postId) async {
    //sending request to get a specific post of a community
    final response = await http.get(
        Uri.parse("$baseUrl/communities/$communityId/posts?Post_Id=$postId"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final communityPost = jsonDecode(response.body);
      return Post.fromJson(communityPost);
    }
    // If the response is not 200 or 201, return null
    else {
      return null;
    }
  }

  // Get all top posts of a community, using the community id
  // This function returns a list of top posts of a community based on the likes
  Future<List<Post>?> getCommunityTopPosts(String communityId) async {
    //sending request to get top posts of a community
    final response = await http
        .get(Uri.parse("$baseUrl/communities/$communityId/posts/topPosts"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final communityTopPosts = jsonDecode(response.body);
      if (communityTopPosts.isEmpty || communityTopPosts == []) {
        return [];
      }
      return communityTopPosts
          .map((post) => Post.fromJson(post))
          .toList()
          .cast<Post>();
    }
    // If the response is not 200 or 201, return an empty list
    else {
      return [];
    }
  }

  // Remove a post from a community, using the community id and post id
  // This function returns a boolean value, true if the post is removed, false otherwise
  Future<List<Post>?> removeCommunityPost(
      String communityId, String postId) async {
    //sending request to remove a post from a community
    final response = await http.delete(
      Uri.parse(
          "$baseUrl/communities/$communityId/posts/removePost?Post_Id=$postId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final communityPosts = jsonDecode(response.body);

        if (communityPosts.isEmpty || communityPosts == []) {
          return [];
        }
        return communityPosts
            .map((post) => Post.fromJson(post))
            .toList()
            .cast<Post>();
      }
      // If the response is not 200 or 201, return an empty list
      else {
        return [];
      }
    } catch (e) {
    }
  }

  //share Image POST
  Future<Post?> shareImagePost({
    required File imageFile,
    required String postId,
    required String imageName,
  }) async {
    //todo
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));
      final mimeType = lookupMimeType(
          imageFile.path); // Get the MIME type based on file extension

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: '$imageName/$postId',
        contentType: MediaType('image',
            mimeType?.split('/').last ?? 'jpeg'), // Use the correct MIME type
      ));

      request.fields['from_micro'] = 'Community';
      request.fields['image_name'] = imageName;
      request.fields['id'] = postId;
      request.fields['map_key'] = 'Post_Media';
      request.fields['collection'] = 'Posts';

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Image uploaded successfully
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseData);
        if (jsonResponse['error'] == null) {
          return Post.fromJson(jsonResponse);
        } else {
          return null;
        }
      } else {
        // Failed to upload image
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Reply?> shareImageReply(
      {required File imageFile,
      required String postId,
      required String replyId,
      required String imageName}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));

      final mimeType = lookupMimeType(
          imageFile.path); // Get the MIME type based on file extension

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: '$imageName/$replyId',
        contentType: MediaType('image',
            mimeType?.split('/').last ?? 'jpeg'), // Use the correct MIME type
      ));

      request.fields['from_micro'] = 'Community';
      request.fields['image_name'] = imageName;
      request.fields['id'] = replyId;
      request.fields['map_key'] = 'Reply_Media';
      request.fields['collection'] = 'Replies';

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Image uploaded successfully
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseData);
        if (jsonResponse['error'] == null) {
          return Reply.fromJson(jsonResponse);
        } else {
          return null;
        }
      } else {
        // Failed to upload image
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadCommunityPicture(
      File imageFile, String id, String imageName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));

      final mimeType = lookupMimeType(
          imageFile.path); // Get the MIME type based on file extension

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: '$imageName/$id',
        contentType: MediaType('image',
            mimeType?.split('/').last ?? 'jpeg'), // Use the correct MIME type
      ));

      request.fields['from_micro'] = 'Community';
      request.fields['image_name'] = imageName;
      request.fields['id'] = id;
      request.fields['collection'] = 'Community';

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Image uploaded successfully
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseData);

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

// REPLY FUNCTIONS//
  // Get all replies of a post, using the community id and post id
  // This function returns a list of replies of a post
  Future<List<Reply>?> getPostReplies(String postId) async {
    //sending request to get replies of a post
    final response =
        await http.get(Uri.parse("$baseUrl/communities/posts/$postId/replies"));
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final postReplies = jsonDecode(response.body) as List<dynamic>;
        if (postReplies.isEmpty || postReplies == []) {
          return [];
        }
        return postReplies
            .map((post) {
              post['Associated_With'] = postId;
              return Reply.fromJson(post);
            })
            .toList()
            .cast<Reply>();
      }
      // If the response is not 200 or 201, return an empty list
      else {
        return [];
      }
    } catch (e) {
    }
  }

  // Get a specific reply of a post, using the community id, post id, and reply id
  // This function returns a reply of a post
  Future<Reply?> getPostReply(String postId, String replyId) async {
    //sending request to get a specific reply of a post
    final response = await http.get(
      Uri.parse("$baseUrl/communities/posts/$postId/replies?Reply_Id=$replyId"),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final postReply = jsonDecode(response.body);
      return Reply.fromJson(postReply);
    }
    // If the response is not 200 or 201, return null
    else {
      return null;
    }
  }

  // Add a reply to a post, using the community id and post id
  // This function returns a reply of a post
  Future<Reply?> addPostReply(
      String postId, Map<String, dynamic> replyInfo) async {
    //sending request to add a reply to a post
    final response = await http.post(
      Uri.parse("$baseUrl/communities/posts/$postId/replies/addReply"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(replyInfo),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      return Reply.fromJson(result);
    }
    // If the response is not 200 or 201, return null
    else {
      return null;
    }
  }

  Future<bool?> likePost(String postId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/communities/posts/$postId/likePost"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"User_Id": userId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        //check if it contains an error json key
        if (response.body.isEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> likeReply(String postId, String replyId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse(
            "$baseUrl/communities/posts/$postId/replies/$replyId/likeReply"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"User_Id": userId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        //check if it contains an error json key
        if (response.body.isEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool?> unLikeReply(
      String postId, String replyId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse(
            "$baseUrl/communities/posts/$postId/replies/$replyId/unlikeReply"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"User_Id": userId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        //check if it contains an error json key
        if (response.body.isEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> unLikePost(String postId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/communities/posts/$postId/unlikePost"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"User_Id": userId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        //check if it contains an error json key
        if (response.body.isEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
