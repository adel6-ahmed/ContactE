import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

import '../shared/theme/colors.dart';
import '../shared/theme/texet.dart';
import 'models.dart';

class FireBaseServices {
  var fireStoreref = FirebaseFirestore.instance;
  var usersColRef = FirebaseFirestore.instance.collection('users');
  var networksColRef = FirebaseFirestore.instance.collection('networks');
  
  Future<void> updateUserSocialMedia({
    required String uid,
    required Map<String, dynamic> socialMedia,
  }) async {
    var ref = usersColRef.doc(uid);
    await ref.update({
      'socialMediaPlatforms': socialMedia,
    });
  }

  Future<void> createNewUser({
    required String name,
    required String uid,
    required String phoneNumber,
    required BuildContext context,
    required Map<String, dynamic> interests, // Change interests to Map
  }) async {
    var ref = usersColRef.doc(uid);
    var user = MyUser(
      img: 'img',
      name: name,
      phoneNumber: phoneNumber,
      interests: interests, // Include interests as a Map
    );
    await ref.set(user.toMap());
    var newRef = networksColRef.doc(uid);
    var network = MyNetwork(myNetwork: []);
    await newRef.set(network.toMap());
  }

  Future<List<MyUser>> getSuggestedFriends(String userId) async {
    var ref = usersColRef.doc(userId);
    var userDoc = await ref.get();
    var currentUser = MyUser().fromMap(userDoc.data());
    var allUsersSnapshot = await usersColRef.get();
    var allUsers = allUsersSnapshot.docs.map((doc) => MyUser().fromMap(doc.data())).toList();

    List<MyUser> suggestedFriends = [];

    for (var user in allUsers) {
      if (user.uid != userId) {
        int commonInterests = currentUser.interests.keys.where((interest) => user.interests.containsKey(interest)).length;
        double commonInterestPercentage = commonInterests / currentUser.interests.keys.length;
        if (commonInterestPercentage >= 0.6) {
          suggestedFriends.add(user);
        }
      }
    }
    return suggestedFriends;
  }

  Future<MyUser> getUser() async {
    var ref = usersColRef.doc('2j8M93CHwcvgL4KfAFaq');
    var myDoc = await ref.get();
    var theTrueData = MyUser().fromMap(myDoc.data());
    theTrueData.uid = ref.id;
    return theTrueData; 
  }

  Future<MyUser> getUserById({required String id}) async {
    var ref = usersColRef.doc(id);
    var myDoc = await ref.get();
    var theTrueData = MyUser().creatFriend(myDoc.data());
    theTrueData.uid = ref.id;
    return theTrueData;
  }

  Future<MyNetwork> getNetwork({required String id}) async {
    var ref = networksColRef.doc(id);
    var myDoc = await ref.get();
    var theTrueData = MyNetwork().fromMap(myDoc.data());
    return theTrueData;
  }

  Stream<List<MyUser>> getNetworkByStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
      (event) => event.docs.map(
        (e) => MyUser().fromMap(e.data()),
      ).toList(),
    );
  }

  Future<List<MyUser>> getNetworkbyFuture() async {
    var ref = usersColRef;
    var myDocs = await ref.get();
    var myUsersDocs = myDocs.docs.map((e) => e.data());
    var theTrueData = myUsersDocs.map((e) => MyUser().fromMap(e));
    return theTrueData.toList();
  }

  Future<List<MyUser>> searchForContact({required String phoneNumber}) async {
    var ref = usersColRef;
    var myDocs = await ref.where('phoneNumber', isEqualTo: phoneNumber).get();
    var myUsersDocs = myDocs.docs.map((e) => e.data());
    var theTrueData = myUsersDocs.map((e) => MyUser().fromMap(e));
    return theTrueData.toList();
  }

  Future<List<Group>> getGroups({required String id}) async {
    try {
      var ref = usersColRef.doc(id).collection('groups');
      var myDocs = await ref.get();
      var groupsDocs = myDocs.docs.map((e) => e.data());
      var theTrueData = groupsDocs.map((e) => Group().fromMap(e));
      return theTrueData.toList();
    } catch (e) {
      print("Error getting groups: $e");
      return [];
    }
  }
}


