class MyUser {
  String name;
  String phoneNumber;
  String img;
  Map<String, dynamic> socialMediaPlatforms;
  String uid;
  Map<String, dynamic> interests;

  MyUser({
    this.name = '',
    this.img = '',
    this.phoneNumber = '',
    this.socialMediaPlatforms = const {},
    this.uid = "",
    this.interests = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'img': img,
      'socialMediaPlatforms': socialMediaPlatforms,
      'interests': interests,
    };
  }

  factory MyUser.fromMap(Map<String, dynamic>? map, String uid) {
    if (map == null) {
      return MyUser(uid: uid);
    }
    return MyUser(
      uid: uid,
      img: map['img'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      socialMediaPlatforms: Map<String, dynamic>.from(map['socialMediaPlatforms'] ?? {}),
      interests: Map<String, dynamic>.from(map['interests'] ?? {}),
    );
  }

  // تم تصحيح اسم الدالة من creatFriend إلى createFriend
  MyUser createFriend(Map<String, dynamic>? map, String uid) {
    return MyUser.fromMap(map, uid);
  }
}

class MyNetwork {
  List<dynamic> myNetwork;

  MyNetwork({
    this.myNetwork = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'myNetwork': myNetwork,
    };
  }

  factory MyNetwork.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return MyNetwork();
    }
    return MyNetwork(
      myNetwork: map['myNetwork'] != null
          ? List<dynamic>.from(map['myNetwork'])
          : [],
    );
  }
}

class Group {
  String name;
  String img;
  List<dynamic> members;
  
  Group({
    this.img = '',
    this.name = '',
    this.members = const [],
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name, 
      'img': img, 
      'members': members
    };
  }

  factory Group.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Group();
    }
    return Group(
      img: map['img'] ?? '',
      name: map['name'] ?? '',
      members: List<dynamic>.from(map['members'] ?? []),
    );
  }
}