class Member {
  final String id ; 
  final String userName; 
  final String userImage;
  final String userBio;
  final String displayName; 
  final bool isOwner;
  final bool isModerator;
  // final bool isOwner;
  // final bool isModerator;


  const Member({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.userBio,
    required this.displayName,
    this.isOwner = false,
    this.isModerator = false,
    // required this.isOwner,
    // required this.isModerator,
  });

  //create factory 
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['User_Id'],
      userName: json['User_Name'],
      userImage: json['Profile_Picture'],
      userBio: json['Bio'],
      displayName: json['Display_Name'],
isModerator: json['Is_Moderator']?? false,
isOwner: json['Is_Owner']?? false,
    );
  
 
  }


   //create to json
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'userBio': userBio,
      'displayName': displayName,

      // 'isOwner': isOwner,
      // 'isModerator': isModerator,
    };
  }
}

class BlockedMember {
  final String id ; 
  final String userName; 
  final String userImage;
  final String userBio;
  final String displayName; 

  // final bool isOwner;
  // final bool isModerator;


  const BlockedMember({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.userBio,
    required this.displayName,

    // required this.isOwner,
    // required this.isModerator,
  });

  //create factory 
  factory BlockedMember.fromJson(Map<String, dynamic> json) {
    return BlockedMember(
      id: json['User_Id'],
      userName: json['User_Name'],
      userImage: json['Profile_Picture'],
      userBio: json['Bio'],
      displayName: json['Display_Name'],

      // isOwner: json['Is_Owner']?? false,
      // isModerator: json['Is_Moderator']?? false,
    );
  
 
  }


   //create to json
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'userBio': userBio,
      'displayName': displayName,

      // 'isOwner': isOwner,
      // 'isModerator': isModerator,
    };
  }
}

class Moderator {
  final String id ; 
  final String userName; 
  final String userImage;
  final String userBio;
  final String displayName; 
  final bool isOwner;
  final bool isModerator;
  // final bool isOwner;
  // final bool isModerator;


  const Moderator({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.userBio,
    required this.displayName,
    this.isOwner = false,
    this.isModerator = false,
    // required this.isOwner,
    // required this.isModerator,
  });

  //create factory 
  factory Moderator.fromJson(Map<String, dynamic> json) {
    return Moderator(
      id: json['User_Id'],
      userName: json['User_Name'],
      userImage: json['Profile_Picture'],
      userBio: json['Bio'],
      displayName: json['Display_Name'],
      isModerator: json['Is_Moderator']?? false,
      isOwner: json['Is_Owner']?? false,
    );
  
 
  }


   //create to json
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'userBio': userBio,
      'displayName': displayName,

      // 'isOwner': isOwner,
      // 'isModerator': isModerator,
    };
  }
}
