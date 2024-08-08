import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginService {
  Future<Map<String, dynamic>> getLogin(String userId);
  void addUser(MemberUser user);

  Future<List<PartnerUser>> getAllPartnerUser();
}

class LoginFirebaseService implements LoginService {
  @override
  Future<Map<String, dynamic>> getLogin(String userId) async {
    DocumentSnapshot qs = await FirebaseFirestore.instance
        .collection('partner')
        .doc(userId)
        .get();
    if (qs.data() != null) {
      Map<String, dynamic> userData = qs.data() as Map<String, dynamic>;
      dynamic user = FirebaseAuth.instance.currentUser;
      userData['id'] = user.uid;
      userData['email'] = user.email;
      print(userData);
      return userData;
    } else {
      print("Document does not exist or is empty.");
      return {};
    }
  }

  @override
  void addUser(MemberUser user) {
    print('Login user id=${user.id}');
    FirebaseFirestore.instance.collection('partner').doc(user.id).update({
      // 'emailUser': user.emailUser,
      'partnerName': user.partnerName,
      'partnerPhone': user.partnerPhone,
      'contactName': user.contactName,
      'taxId': user.taxId,
      'totalSeats': user.totalSeats,
      'tableLabels': user.tableLabels,
      'userStatus': user.userStatus,
    });
  }

  @override
  Future<List<PartnerUser>> getAllPartnerUser() async {
    print("getAllPartnerUser is called");
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('partner')
        .where('role', isEqualTo: "partner")
        .get();
    print("Partner count: ${qs.docs.length}");
    AllPartnerUsers PartnerUsers = AllPartnerUsers.fromSnapshot(qs);
    print(PartnerUsers.partnerusers);
    return PartnerUsers.partnerusers;
  }
}
