import 'dart:async';

import 'package:back_office/model/login_model.dart';
import 'package:back_office/services/login_service.dart';

class LoginController {
  Map<String, dynamic> currentuser = {};
  List<PartnerUser> PartnerUsers = List.empty();

  final LoginService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;
  LoginController(this.service);

  Future<Map<String, dynamic>> fetchLogin(userId) async {
    onSyncController.add(true);
    currentuser = await service.getLogin(userId);
    onSyncController.add(false);
    return currentuser;
  }

  void addUser(MemberUser user) async {
    service.addUser(user);
  }

  Future<List<PartnerUser>> fetchPartnerUser() async {
    print("fetchReserveTableHistory was: ${PartnerUsers}");
    onSyncController.add(true);
    PartnerUsers = await service.getAllPartnerUser();
    onSyncController.add(false);
    return PartnerUsers;
  }
}
