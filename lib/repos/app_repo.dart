import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signwalla/common/constants.dart';

class AppRepo {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseStore;

  AppRepo(this._firebaseAuth, this._firebaseStore);

  Future<UserCredential> signup(String firstName, String lastName,
      String phoneNo, String email, String password) async {
    var response = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (response.user != null) {
      await _firebaseStore
          .collection(Constants.DB_NAME)
          .doc(response.user!.uid)
          .set({
        "firstName": firstName,
        "lastName": lastName,
        "username": "$firstName $lastName",
        "phoneNumber": phoneNo,
        "email": email,
        "password": password,
        "uuid": response.user!.uid,
        "isVerified": response.user!.emailVerified,
        "createdAt": DateTime.now().toString(),
        "profilePic": "",
        "userStatus": "NONE"
      });
    }
    return response;
  }

  Future<User?> signin(String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
  }

  Future<void> logout() async {
    return await _firebaseAuth.signOut();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserDetails(
      String uuid) async {
    return await _firebaseStore
        .collection(Constants.DB_NAME)
        .where("uuid", isEqualTo: uuid)
        .get();
  }

  Future<void> getUpdateStatus(String uuid, String status, String key) async {
    await _firebaseStore
        .collection(Constants.DB_NAME)
        .doc(uuid)
        .update({key: status});
  }
}
