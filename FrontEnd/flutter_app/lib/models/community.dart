// this file is a model for community class
//this is its attrbiutes

// 1.	community_name
// 2.	description
// 3.	community_tag
// 4.	members
// 5.	banner
// 6.	community_picture
// 7.	moderator
// 8.	owner (one person)
// 9.	private
// 10.	password
// 11.	thumbnail
// 12.	verified
// 13.	third_party_link
// 14.	blocked_users

// import 'package:iron_sight/models/user.dart';

import 'package:iron_sight/models/member.dart';

class Community {
  final String id;
  final String communityName;
  final String description;
  final String communityTag;
  List<Member> members = [];
  int moderatorsLength;
  int membersLength;
  final String banner;
  final String communityPicture;
  List<String> moderatorsIds;
  List<String> membersIds = [];
// final List<String> moderators;
  final String owner;
  final bool isPrivate;
  final String thumbnail;
  final bool isVerified;
  final Map<String, dynamic> thirdPartyLink;
  final List<String> blockedUsers;
  String? password;

  Community({
    this.membersLength = 0,
    this.moderatorsLength = 0,
    required this.id,
    required this.communityName,
    required this.description,
    required this.communityTag,
    // required this.members,
    // required this.moderators,
    required this.banner,
    required this.communityPicture,
    required this.moderatorsIds,
    required this.membersIds,
    required this.owner,
    required this.isPrivate,
    required this.thumbnail,
    required this.isVerified,
    required this.thirdPartyLink,
    required this.blockedUsers,
    this.password,
  });

//create copywithfrom json data

  Community copyWithFromMap(Map<String, dynamic> updatedData) {
    return Community(
      id: updatedData['Community_Id'] ?? id,
      communityName: updatedData['Community_Name'] ?? communityName,
      description: updatedData['Description'] ?? description,
      communityTag: updatedData['Community_Tag'] ?? communityTag,
      membersLength: (updatedData['Members'] is List)
          ? List<String>.from(updatedData['Members'].map((x) => x.toString()))
              .length
          : membersLength,
      moderatorsLength: (updatedData['Moderators'] is List)
          ? List<String>.from(
              updatedData['Moderators'].map((x) => x.toString())).length
          : moderatorsLength,
      // members: updatedData['members'],
      banner: updatedData['Banner'] ?? banner,
      communityPicture: updatedData['Community_Picture'] ?? communityPicture,
      // moderators: updatedData['moderators'],
      moderatorsIds: (updatedData['Moderators'] is List)
          ? List<String>.from(
              updatedData['Moderators'].map((x) => x.toString()))
          : moderatorsIds,
      owner: updatedData['Owner'] ?? owner,
      isPrivate: updatedData['isPrivate'] ?? isPrivate,
      thumbnail: updatedData['Thumbnail'] ?? thumbnail,
      isVerified: updatedData['isVerified'] ?? isVerified,
      thirdPartyLink: updatedData['Third_Party_Link'] ?? thirdPartyLink,
      membersIds: updatedData['Members'] != null
          ? List<String>.from(updatedData['Members'].map((x) => x.toString()))
          : membersIds,

      //  moderatorsIds: updatedData['Moderators']??[],
      // blockedUsers: updatedData['Blocked_Users']?? blockedUsers, // todo
      blockedUsers: updatedData['Blocked_Users'] != null
          ? List<String>.from(
              updatedData['Blocked_Users'].map((x) => x.toString()))
          : blockedUsers,
      password: updatedData['Password'] ?? password,
    );
  }

  //create copywith
  Community copyWith({
    String? id,
    String? communityName,
    String? description,
    String? communityTag,
    List<Member>? members,
    int? moderatorsLength,
    int? membersLength,
    String? banner,
    String? communityPicture,
    List<String>? moderators,
    String? owner,
    bool? isPrivate,
    List<String>? membersIds,
    List<String>? moderatorsIds,
    String? thumbnail,
    bool? isVerified,
    Map<String, dynamic>? thirdPartyLink,
    List<String>? blockedUsers,
    String? password,
  }) {
    return Community(
      id: id ?? this.id,
      communityName: communityName ?? this.communityName,
      description: description ?? this.description,
      communityTag: communityTag ?? this.communityTag,
      // members: members?? this.members,
      moderatorsLength: moderatorsLength ?? this.moderatorsLength,
      membersLength: membersLength ?? this.membersLength,
      banner: banner ?? this.banner,
      communityPicture: communityPicture ?? this.communityPicture,
      // moderators: moderators?? this.moderators,
      owner: owner ?? this.owner,
      moderatorsIds: moderators ?? this.moderatorsIds,
      isPrivate: isPrivate ?? this.isPrivate,
      thumbnail: thumbnail ?? this.thumbnail,
      isVerified: isVerified ?? this.isVerified,
      thirdPartyLink: thirdPartyLink ?? this.thirdPartyLink,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      password: password ?? this.password,
      membersIds: membersIds ?? this.membersIds,
      // moderatorsIds: moderatorsIds??this.membersIds
    );
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    //print the type of each key
    // print(json['Community_Id'].runtimeType);
    // print(json['Community_Name'].runtimeType);
    // print(json['Description'].runtimeType);
    // print(json['Community_Tag'].runtimeType);
    // print(json['Members'].runtimeType); //List<dynamic>
    // print(json['Banner'].runtimeType);
    // print(json['Community_Picture'].runtimeType);
    // print(json['Owner'].runtimeType); // _Map<String, dynamic>
    return Community(
      id: json['Community_Id'],
      communityName: json['Community_Name'],
      description: json['Description'],
      communityTag: json['Community_Tag'],
      membersLength: (json['Members'] is List) ? json['Members'].length : 0,
      banner: json['Banner'],
      communityPicture: json['Community_Picture'],
      // moderatorsLength:List<String>.from( json['Moderator']).length,
      moderatorsLength:
          (json['Moderators'] is List) ? json['Moderators'].length : 0,
      membersIds: (json['Members'] is List)
          ? List<String>.from(json['Members'].map((x) => x.toString()))
          : [],
      // moderatorsIds: (json['Moderators'] is List)? json['Moderators']:[],
      // owner: json['Owner'],
      owner: json['Owner'],
      isPrivate: json['isPrivate'],
      thumbnail: json['Thumbnail'],
      isVerified: json['isVerified'] ?? false,
      thirdPartyLink: json['Third_Party_Link'] ?? {},
      // blockedUsers: List<String>.from(json['Blocked_Users']),
      blockedUsers: (json['Blocked_Users'] is List)
          ? List<String>.from(json['Blocked_Users'].map((x) => x.toString()))
          : [],
      password: json['Password'] ?? "",
      moderatorsIds: (json['Moderators'] is List)
          ? List<String>.from(json['Moderators'].map((x) => x.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Community_Id': id,
      'Community_Name': communityName,
      'Description': description,
      'Community_Tag': communityTag,
      'Members': members,
      'Banner': banner,
      'Community_Picture': communityPicture,
      'Owner': owner,
      'isPrivate': isPrivate,
      'Thumbnail': thumbnail,
      'isVerified': isVerified,
      'Third_Party_Link': thirdPartyLink,
      'Blocked_Users': blockedUsers,
      'Password': password,
    };
  }
}
