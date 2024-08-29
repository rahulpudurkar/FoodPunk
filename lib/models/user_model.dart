
class UserModel {
  final String uid;
  final String phone;
  final String? email;
  final String address;
  final String name;
  final String photoUrl;


  UserModel(
      {required this.uid,
      required this.email,
      required this.photoUrl,
      required this.address,
      required this.name,
      required this.phone});


  set photoUrl(String photoUrl) {
    this.photoUrl = photoUrl;
  }

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['email'] = user.email;
    data['phone'] = user.phone;
    data['address'] = user.address;
    data['name'] = user.name;
    data['photoUrl'] = user.photoUrl;
    return data;
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> mapData) {
    return UserModel(
      uid: mapData['uid'],
      email: mapData['email'],
      phone: mapData['phone'],
      photoUrl: mapData['photoUrl'],
      name: mapData['name'],
      address: mapData['address'],
    );
  }
}
