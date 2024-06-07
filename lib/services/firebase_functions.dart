import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';
import '../shared/methods/navigation.dart';
import '../shared/theme/colors.dart';
import '../shared/theme/texet.dart';
import 'models.dart';

class FireBaseServices {
  var fireStoreref = FirebaseFirestore.instance;
  var usersColRef = FirebaseFirestore.instance.collection('users');
  var networksColRef = FirebaseFirestore.instance.collection('networks');

  CreateNewUser(
      {required String name, required String phoneNumber, context}) async {
    var ref = usersColRef.doc();
    var user = MyUser(
        img: 'img',
        name: name,
        phoneNumber: phoneNumber,
        socialMediaPlatforms: {'facebook': 'www.facebook.com/adel'});
    await ref.set(
      user.toMap(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'User Added Successfully',
          style: body,
        ),
        backgroundColor: Lyellow,
        showCloseIcon: true,
        duration: Duration(seconds: 2),
        closeIconColor: Ldark,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await Future.delayed(
      Duration(seconds: 2),
    );
    GoTo(
      context: context,
      screen: ProfileScreen(),
    );
  }

  Future<MyUser> getUser() async {
    var ref = usersColRef.doc('2j8M93CHwcvgL4KfAFaq');
    var myDoc = await ref.get();
    var theTrueData = MyUser().fromMap(
      myDoc.data(),
    );
    theTrueData.uid = ref.id;
    return theTrueData; 
  }
    Future<MyUser> getUserById( {required String id}) async {
    var ref = usersColRef.doc(id);
    var myDoc = await ref.get();
    var theTrueData = MyUser().creatFriend(
      myDoc.data(),);
      theTrueData.uid = ref.id;
    return theTrueData;
  }

    Future<MyNetwork> getNetwork( {required String id}) async {
    var ref = networksColRef.doc(id);
    var myDoc = await ref.get();
    var theTrueData = MyNetwork().fromMap(
      myDoc.data(),);
    return theTrueData;
  }

    Stream<List<MyUser>> getNetworkByStream() {
      return FirebaseFirestore.instance.collection('users').snapshots().map(
           (event) => event.docs.map(
             (e) => MyUser().fromMap(
               e.data(),
            ),
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
