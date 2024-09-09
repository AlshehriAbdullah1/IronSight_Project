import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class Reply {
  final String id;
  final Replier replier;
  final String relpyContent;
  final DateTime createdAt;
  final List<String> replyMedia;
  final int replyLikeCount;
  final List<String> replyLikesIds;
  final String associatedWithPost;
  const Reply({
    required this.replier,
    required this.id,
    required this.relpyContent,
    required this.replyLikeCount,
    required this.replyMedia,
    required this.createdAt,
    required this.replyLikesIds,
    required this.associatedWithPost,
  });


  //create copywith 
  Reply copyWith({
    String? id,
    Replier? replier,
    String? relpyContent,
    DateTime? createdAt,
    List<String>? replyMedia,
    int? replyLikeCount,
    List<String>? replyLikesIds,
    String? associatedWithPost,
  }) {
    return Reply(
      id: id ?? this.id,
      replier: replier ?? this.replier,
      relpyContent: relpyContent ?? this.relpyContent,
      createdAt: createdAt ?? this.createdAt,
      replyMedia: replyMedia ?? this.replyMedia,
      replyLikeCount: replyLikeCount ?? this.replyLikeCount,
      replyLikesIds: replyLikesIds ?? this.replyLikesIds,
      associatedWithPost: associatedWithPost?? this.associatedWithPost
    );
  }
  //create factory
  factory Reply.fromJson(Map<String, dynamic> json) {
      List<String> replyMedia= [];
      List<String> replyLikesIds=[];
     
    try {
  if (json['Reply_Media'] is List<dynamic>) {
    replyMedia = (json['Reply_Media'] as List<dynamic>).map((e) => e.toString()).toList();
  } else if (json['Reply_Media'] is Map<String, dynamic>) {
    replyMedia = (json['Reply_Media'] as Map<String, dynamic>).values.map((e) => e.toString()).toList();
  } else {
    throw Exception('Unexpected type for Reply_Media: ${json['Reply_Media'].runtimeType}');
  }
  if (json['Reply_Likes'] is List<dynamic>) {
    replyLikesIds = (json['Reply_Likes'] as List<dynamic>).map((e) => e.toString()).toList();
  }
  else{
  }
  
    } catch (e) {
    }
    return Reply(
      id: json['Reply_Id']  // probelm
      ,
      associatedWithPost: json['Associated_With'],
      relpyContent: json['Reply_Content']?? "ss",
      replier: Replier.fromjson(json['Replier']),
      replyLikeCount: json['Reply_Likes_Count']??0,
      replyMedia: replyMedia,
      // replyMedia: [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['Created_At']['_seconds'] * 1000),replyLikesIds: replyLikesIds
          
    );
  }

  String getHumaneDate() {
    return timeago.format(createdAt, locale: 'en');
  }
}

class Replier {
  final String userId;
  final String userName;
  final String profilePicture;
  final String displayName;

  const Replier(
      {required this.userId,
      required this.displayName,
      required this.profilePicture,
      required this.userName});

  Replier copyWith({
    String? userId,
    String? userName,
    String? profilePicture,
    String? displayName,
  }) {
    return Replier(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profilePicture: profilePicture ?? this.profilePicture,
      displayName: displayName ?? this.displayName,
    );
  }

  factory Replier.fromjson(Map<String, dynamic> map) {
    return Replier(
      userId: map['User_Id'] as String,
      userName: map['User_Name'] as String,
      profilePicture: map['Profile_Picture'] as String,
      displayName: map['Display_Name'] as String,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Poster.fromJson(String source) => Poster.fromMap(json.decode(source) as Map<String, dynamic>);
}
