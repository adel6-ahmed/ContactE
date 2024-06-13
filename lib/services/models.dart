class MyUser {
  String name;
  String phoneNumber;
  String img;
  Map<String, dynamic> socialMediaPlatforms;
  String uid;
  Map<String, dynamic> interests; // Updated to Map

  MyUser({
    this.name = '',
    this.img = '',
    this.phoneNumber = '',
    this.socialMediaPlatforms = const {},
    this.uid = "",
    this.interests = const {}, // Default to empty map
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'img': img,
      'socialMediaPlatforms': socialMediaPlatforms,
      'interests': interests, // Include interests as a Map
    };
  }

  MyUser fromMap(Map<String, dynamic>? myMap) {
    if (myMap == null) {
      return MyUser(); // Return an empty MyUser if myMap is null
    }
    return MyUser(
      img: myMap['img'] ?? '',
      name: myMap['name'] ?? '',
      phoneNumber: myMap['phoneNumber'] ?? '',
      socialMediaPlatforms: myMap['socialMediaPlatforms'] ?? {},
      interests: Map<String, dynamic>.from(myMap['interests'] ?? {}),
    );
  }

  MyUser creatFriend(Map<String, dynamic>? myMap) {
    if (myMap == null) {
      return MyUser(); // Return an empty MyUser if myMap is null
    }
    return MyUser(
      img: myMap['img'] ?? '',
      name: myMap['name'] ?? '',
      phoneNumber: myMap['phoneNumber'] ?? '',
      socialMediaPlatforms: myMap['socialMediaPlatforms'] ?? {},
      interests: Map<String, dynamic>.from(myMap['interests'] ?? {}),
    );
  }
}

class MyNetwork {
  List<dynamic> myNetwork;

  MyNetwork({
    this.myNetwork = const [],
  });

  Map<String, dynamic> toMap() {
    return {};
  }

  MyNetwork fromMap(Map<String, dynamic>? myMap) {
    return MyNetwork(
      myNetwork: myMap!['myNetwork'] != null
          ? List<dynamic>.from(myMap['myNetwork'])
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
    return {'name': name, 'img': img, 'members': members};
  }

  Group fromMap(Map<String, dynamic>? myMap) {
    return Group(
      img: myMap!['img'],
      name: myMap['name'],
      members: myMap['members'],
    );
  }
}
