import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
// ignore_for_file: public_member_api_docs, sort_constructors_first

class Post {
  final String id;
  final Poster poster;
  final String postContent;
  final DateTime createdAt;
  final List<String> postLikesIds;
  // final String userImage;
  // final String userBio;
  // final String displayName;

  final List<String> postMedia;
  final int postLikeCount;
  final int posterReplyCount;

  const Post(
      {required this.poster,
      required this.id,
      required this.postContent,
      required this.postLikeCount,
      required this.postMedia,
      required this.createdAt,
      required this.posterReplyCount,
      required this.postLikesIds,
      // required this.userImage,
      // required this.userBio,
      // required this.displayName,
      });

  //create factory
  factory Post.fromJson(Map<String, dynamic> json) {  
     List<String> postMedia= [];
     List<String> postLikesIds= [];
    try {
  if (json['Post_Media'] is List<dynamic>) {
    postMedia = (json['Post_Media'] as List<dynamic>).map((e) => e.toString()).toList();
  } else if (json['Post_Media'] is Map<String, dynamic>) {
    postMedia = (json['Post_Media'] as Map<String, dynamic>).values.map((e) => e.toString()).toList();
  } 
  else if (json['Post_Media'] == null ){
  }else {
    throw Exception('Unexpected type for Post_Media: ${json['Post_Media'].runtimeType}');
  }

  if(json['Post_Likes'] is List<dynamic>){
        postLikesIds = (json['Post_Likes'] as List<dynamic>).map((e) => e.toString()).toList();
  }
  else if (json['Post_Likes'] ==null){

  }
  else {
    throw Exception('Unexpected type for Post_Likes: ${json['Post_Likes'].runtimeType}');
  }
  return Post(
      id: json['Post_Id'],
      postContent: json['Post_Content'],
      posterReplyCount: json['Post_Replies_Count'] ?? 737,
      poster: Poster.fromjson(json['Poster']),
      postLikeCount: json['Post_Likes_Count'],
      postMedia: postMedia,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['Created_At']['_seconds'] * 1000),
          postLikesIds: postLikesIds,
    );
  
    } catch (e) {
    }
     return Post(
      id: json['Post_Id'],
      postContent: json['Post_Content'],
      posterReplyCount: json['Post_Replies_Count'] ?? 737,
      poster: Poster.fromjson(json['Poster']),
      postLikeCount: json['Post_Likes_Count'],
      postMedia: postMedia,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['Created_At']['_seconds'] * 1000),
          postLikesIds: postLikesIds,
    );
  }

  String getHumaneDate() {
    return timeago.format(createdAt, locale: 'en');
  }

  //create to json
  //  Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,

  //     'userImage': userImage,
  //     'userBio': userBio,
  //     'displayName': displayName,
  //   };
  // }

  //create copy with 
  Post copyWith({
    String? id,
    Poster? poster,
    String? postContent,
    DateTime? createdAt,
    List<String>? postMedia,
    int? postLikeCount,
    int? posterReplyCount,
    List<String>? postLikesIds,
    // String? userImage,
    // String? userBio,
    // String? displayName,
  }) {
    return Post(
      id: id?? this.id,
      poster: poster?? this.poster,
      postContent: postContent?? this.postContent,
      createdAt: createdAt?? this.createdAt,
      postMedia: postMedia?? this.postMedia,
      postLikeCount: postLikeCount?? this.postLikeCount,
      posterReplyCount: posterReplyCount?? this.posterReplyCount,
      postLikesIds: postLikesIds?? this.postLikesIds,
      // userImage: userImage?? this.userImage,
      // userBio: userBio?? this.userBio,
      // displayName: displayName?? this.displayName,
    );
  }
}

class Poster {
  final String userId;
  final String userName;
  final String profilePicture;
  final String displayName;

  const Poster(
      {required this.userId,
      required this.displayName,
      required this.profilePicture,
      required this.userName});

  Poster copyWith({
    String? userId,
    String? userName,
    String? profilePicture,
    String? displayName,
  }) {
    return Poster(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profilePicture: profilePicture ?? this.profilePicture,
      displayName: displayName ?? this.displayName,
    );
  }

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'userId': userId,
  //     'userName': userName,
  //     'profilePicture': profilePicture,
  //     'displayName': displayName,
  //   };
  // }

  factory Poster.fromjson(Map<String, dynamic> map) {
    return Poster(
      userId: map['User_Id'] as String,
      userName: map['User_Name'] as String,
      profilePicture: map['Profile_Picture'] as String,
      displayName: map['Display_Name'] as String,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Poster.fromJson(String source) => Poster.fromMap(json.decode(source) as Map<String, dynamic>);
}
