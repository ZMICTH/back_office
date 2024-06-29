import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberUser {
  String id = "";
  String emailUser;
  String partnerName;
  String partnerPhone;
  String contactName;
  String taxId;
  int totalSeats;
  List<Map<String, dynamic>> tableLabels;
  String userStatus;

  MemberUser({
    required this.emailUser,
    required this.partnerName,
    required this.partnerPhone,
    required this.contactName,
    required this.taxId,
    required this.totalSeats,
    required this.tableLabels,
    required this.userStatus,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    print(json);
    return MemberUser(
      emailUser: json['emailUser'] as String,
      partnerName: json['partnerName'] as String,
      partnerPhone: json['partnerPhone'] as String,
      contactName: json['contactName'] as String? ?? "",
      taxId: json['taxId'] as String,
      totalSeats: json['totalSeats'] as int? ?? 0,
      tableLabels: (json['tableLabels'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((tableLable) {
        return Map<String, dynamic>.from(tableLable as Map);
      }).toList(),
      userStatus: json['userStatus'] as String? ?? "",
    );
  }

  factory MemberUser.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return MemberUser(
      emailUser: json['emailUser'] as String,
      partnerName: json['partnerName'] as String,
      partnerPhone: json['partnerPhone'] as String,
      contactName: json['contactName'] as String? ?? "",
      taxId: json['taxId'] as String,
      totalSeats: json['totalSeats'] as int? ?? 0,
      tableLabels: (json['tableLabels'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((tableLabel) {
        return Map<String, dynamic>.from(tableLabel as Map);
      }).toList(),
      userStatus: json['userStatus'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emailUser': emailUser,
      'partnerName': partnerName,
      'partnerPhone': partnerPhone,
      'contactName': contactName,
      'taxId': taxId,
      'totalSeats': totalSeats,
      'tableLabels': tableLabels
          .map((table) => {
                'label': table['label'],
                'numberofchairs': table['numberofchairs'],
                'seats': table['seats'],
                'tablePrices': table['tablePrices'],
                'totaloftable': table['totaloftable'],
              })
          .toList(),
      'userStatus': userStatus,
    };
  }
}

class MemberUserModel with ChangeNotifier {
  MemberUser? _memberUser;
  List<MemberUser> _profile = [];

  MemberUser? get memberUser => _memberUser;
  List<MemberUser> get profile => _profile;

  void setMemberUser(MemberUser memberUser) {
    _memberUser = memberUser;
    print('Member was call');
    print(memberUser);
    notifyListeners();
  }

  void clearMemberUser() {
    _memberUser = null;
    notifyListeners();
  }

  void setTables(List<MemberUser> newProfile) {
    _profile = newProfile;

    notifyListeners();
  }

  // You can add other methods here to modify the MemberUser data
  // For example, updating the first name:
  void updateFirstName(String partnerName) {
    if (_memberUser != null) {
      _memberUser!.partnerName = partnerName;
      notifyListeners();
    }
  }
}
