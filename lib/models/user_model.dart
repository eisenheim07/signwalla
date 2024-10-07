class UserModel {
  final String firstName;
  final String lastName;
  final String username;
  final String phoneNumber;
  final String email;
  final String uuid;
  final bool isVerified;
  final dynamic createdAt;
  final String profilePic;
  final String userStatus;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.uuid,
    required this.isVerified,
    required this.createdAt,
    required this.profilePic,
    required this.userStatus,
  });

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      uuid: data['uuid'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt'] ?? '',
      profilePic: data['profilePic'] ?? '',
      userStatus: data['userStatus'] ?? '',
    );
  }

  // Method to convert a UserModel instance to a Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'phoneNumber': phoneNumber,
      'email': email,
      'uuid': uuid,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'profilePic': profilePic,
      'userStatus': userStatus,
    };
  }
}
