class UserModel {
  String name;
  String bio;
  String profilePicture;
  String createdAt;
  String phoneNumber;
  String uid;

  UserModel(
      {required this.name,
      required this.bio,
      required this.profilePicture,
      required this.createdAt,
      required this.phoneNumber,
      required this.uid});

// Getting the data from the server
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      createdAt: map['createdAt'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      uid: map['uid'] ?? '',
    );
  }

// Sending the data to the server
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'uid': uid,
    };
  }
}
