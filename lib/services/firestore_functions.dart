import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models.dart';

class FireBaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  CollectionReference get usersColRef => _firestore.collection('users');
  CollectionReference get networksColRef => _firestore.collection('networks');

  Future<void> updateUserSocialMedia({
    required String uid,
    required Map<String, dynamic> socialMedia,
  }) async {
    try {
      await usersColRef.doc(uid).update({
        'socialMediaPlatforms': socialMedia,
      });
    } catch (e) {
      throw Exception('Failed to update social media: $e');
    }
  }

  Future<void> createNewUser({
    required String name,
    required String uid,
    required String phoneNumber,
    required BuildContext context,
    required Map<String, dynamic> interests,
  }) async {
    try {
      final user = MyUser(
        name: name,
        phoneNumber: phoneNumber,
        img: 'https://via.placeholder.com/150',
        interests: interests,
        uid: uid,
      );
      
      await usersColRef.doc(uid).set(user.toMap());
      
      final network = MyNetwork(myNetwork: []);
      await networksColRef.doc(uid).set(network.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<List<MyUser>> getSuggestedFriends(String userId) async {
    try {
      final currentUserDoc = await usersColRef.doc(userId).get();
      if (!currentUserDoc.exists) return [];
      
      final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
      if (currentUserData == null) return [];
      
      final currentUser = MyUser.fromMap(currentUserData, currentUserDoc.id);
      final allUsersSnapshot = await usersColRef.get();
      
      final List<MyUser> suggestedFriends = [];
      
      for (final doc in allUsersSnapshot.docs) {
        if (doc.id != userId) {
          final userData = doc.data() as Map<String, dynamic>?;
          if (userData != null) {
            final user = MyUser.fromMap(userData, doc.id);
            final commonInterests = currentUser.interests.keys
                .where((interest) => user.interests.containsKey(interest))
                .length;
            
            final commonInterestPercentage = commonInterests / currentUser.interests.keys.length;
            if (commonInterestPercentage >= 0.6) {
              suggestedFriends.add(user);
            }
          }
        }
      }
      return suggestedFriends;
    } catch (e) {
      throw Exception('Failed to get suggested friends: $e');
    }
  }

  Future<MyUser> getUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');
      
      final userDoc = await usersColRef.doc(currentUser.uid).get();
      if (!userDoc.exists) throw Exception('User not found');
      
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) throw Exception('User data is null');
      
      return MyUser.fromMap(userData, currentUser.uid);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<MyUser> getUserById({required String id}) async {
    try {
      final userDoc = await usersColRef.doc(id).get();
      if (!userDoc.exists) throw Exception('User not found');
      
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) throw Exception('User data is null');
      
      return MyUser.fromMap(userData, id);
    } catch (e) {
      throw Exception('Failed to get user by ID: $e');
    }
  }

  Future<MyNetwork> getNetwork({required String id}) async {
    try {
      final networkDoc = await networksColRef.doc(id).get();
      if (!networkDoc.exists) throw Exception('Network not found');
      
      final networkData = networkDoc.data() as Map<String, dynamic>?;
      if (networkData == null) throw Exception('Network data is null');
      
      return MyNetwork.fromMap(networkData);
    } catch (e) {
      throw Exception('Failed to get network: $e');
    }
  }

  Future<List<MyUser>> searchForContact({required String phoneNumber}) async {
    try {
      final querySnapshot = await usersColRef
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return MyUser.fromMap(data ?? {}, doc.id);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to search contacts: $e');
    }
  }

  Future<List<Group>> getGroups({required String id}) async {
    try {
      final groupsSnapshot = await usersColRef.doc(id).collection('groups').get();
      
      return groupsSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return Group.fromMap(data ?? {});
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get groups: $e');
    }
  }
}