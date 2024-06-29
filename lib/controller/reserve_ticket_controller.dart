import 'dart:async';

import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/services/reserve_ticket_service.dart';

class TicketConcertController {
  List<TicketConcertModel> allTicketConcertModel = List.empty();
  List<BookingTicket> allReservationTicketModel = List.empty();
  final TicketConcertService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  TicketConcertController(this.service);

  Future<List<TicketConcertModel>> fetchTicketConcertModel() async {
    print("fetchTicketConcertModel was: ${allTicketConcertModel}");
    onSyncController.add(true);
    allTicketConcertModel = await service.getAllTicketConcertModel();
    onSyncController.add(false);
    return allTicketConcertModel;
  }

  Future<List<BookingTicket>> fetchReservationTicket() async {
    print("fetchReservationTicket was: ${allReservationTicketModel}");
    onSyncController.add(true);
    allReservationTicketModel = await service.getAllReservationTicket();
    onSyncController.add(false);
    return allReservationTicketModel;
  }
}
