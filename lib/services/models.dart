class MyUser {
  String name;
  String phoneNumber;
  String img;
  Map<String, dynamic> socialMediaPlatforms;
  String uid;
  MyUser({
    this.name = '',
    this.img = '',
    this.phoneNumber = '',
    this.socialMediaPlatforms = const {},
    this.uid = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'img': img,
      'socialMediaPlatforms': socialMediaPlatforms,
     
    };
  }

  MyUser fromMap(Map<String, dynamic>? myMap) {
    return MyUser(
      img: myMap!['img'],
      name: myMap['name'],
      phoneNumber: myMap['phoneNumber'],
      socialMediaPlatforms: myMap['socialMediaPlatforms'],
      
    );
  }

  MyUser creatFriend(Map<String, dynamic>? myMap) {
    return MyUser(
      img: myMap!['img'],
      name: myMap['name'],
      phoneNumber: myMap['phoneNumber'],
      socialMediaPlatforms: myMap['socialMediaPlatforms'],
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
      myNetwork: myMap!['myNetwork'] != null ? List<dynamic>.from(myMap['myNetwork']) : [],
    );
  }
}

class Group{
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
   
     
    };
  }

  Group fromMap(Map<String, dynamic>? myMap) {
    return Group(
      img: myMap!['img'],
      name: myMap['name'],
      
      
    );
  }
}

