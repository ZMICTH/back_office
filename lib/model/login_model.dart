import 'package:back_office/model/reserve_table_model.dart';
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

class PartnerUser {
  String id = "";
  String emailUser;
  String partnerName;
  String partnerPhone;
  String contactName;
  String taxId;
  int totalSeats;
  List<Map<String, dynamic>> tableLabels;
  String userStatus;
  String fileURL;
  String role;

  PartnerUser({
    this.id = "",
    required this.emailUser,
    required this.partnerName,
    required this.partnerPhone,
    required this.contactName,
    required this.taxId,
    required this.totalSeats,
    required this.tableLabels,
    required this.userStatus,
    required this.fileURL,
    required this.role,
  });
  factory PartnerUser.fromJson(Map<String, dynamic> json) {
    print(json);
    return PartnerUser(
      id: json['id'] as String,
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
      fileURL: json['fileURL'] as String? ?? "",
      role: json['role'] as String? ?? "",
    );
  }

  factory PartnerUser.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return PartnerUser(
      id: snapshot.id,
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
      fileURL: json['fileURL'] as String,
      role: json['role'] as String,
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
      'fileURL': fileURL,
      'role': role,
    };
  }
}

class AllPartnerUsers {
  final List<PartnerUser> partnerusers;

  AllPartnerUsers(this.partnerusers);

  factory AllPartnerUsers.fromJson(List<dynamic> json) {
    List<PartnerUser> partnerusers =
        json.map((item) => PartnerUser.fromJson(item)).toList();
    return AllPartnerUsers(partnerusers);
  }

  factory AllPartnerUsers.fromSnapshot(QuerySnapshot qs) {
    List<PartnerUser> partnerusers = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return PartnerUser.fromJson(dataWithId);
    }).toList();
    return AllPartnerUsers(partnerusers);
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerusers':
          partnerusers.map((partneruser) => partneruser.toJson()).toList(),
    };
  }
}

class MemberUserModel with ChangeNotifier {
  MemberUser? _memberUser;
  List<MemberUser> _profile = [];
  List<PartnerUser> _allpartner = [];
  PartnerUser? _selectedInactivePartner;

  MemberUser? get memberUser => _memberUser;
  List<MemberUser> get profile => _profile;
  List<PartnerUser> get allpartner => _allpartner;
  PartnerUser? get selectedInactivePartner => _selectedInactivePartner;

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

  void updateFirstName(String partnerName) {
    if (_memberUser != null) {
      _memberUser!.partnerName = partnerName;
      notifyListeners();
    }
  }

  void setPartnerDetail(List<PartnerUser> allDetail) {
    _allpartner = allDetail;
    notifyListeners();
  }

  void selectInactivePartner() {
    _selectedInactivePartner =
        _allpartner.firstWhere((partner) => partner.userStatus == 'Inactive',
            orElse: () => PartnerUser(
                  emailUser: '',
                  partnerName: '',
                  partnerPhone: '',
                  contactName: '',
                  taxId: '',
                  totalSeats: 0,
                  tableLabels: [],
                  userStatus: '',
                  fileURL: '',
                  role: '',
                ));
    notifyListeners();
    print("inactive process");
  }
}
