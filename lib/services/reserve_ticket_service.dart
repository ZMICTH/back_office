import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TicketConcertService {
  Future<List<TicketConcertModel>> getAllTicketConcertModel();

  Future<List<BookingTicket>> getAllReservationTicket();
}

class TicketConcertFirebaseService implements TicketConcertService {
  @override
  Future<List<TicketConcertModel>> getAllTicketConcertModel() async {
    print("getTicketCatalog is called");
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('ticket_concert_catalog')
        .get();
    print("TicketCatalog count: ${qs.docs.length}");
    AllTicketConcertModel allTicketConcertModel =
        AllTicketConcertModel.fromSnapshot(qs);
    print(allTicketConcertModel.allTicketConcertModel);
    return allTicketConcertModel.allTicketConcertModel;
  }

  @override
  Future<List<BookingTicket>> getAllReservationTicket() async {
    print("getAllReservationTicket is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('reservation_ticket').get();
    print("ReservationTicket count: ${qs.docs.length}");
    AllReservationTicketModel allReservationTicketModel =
        AllReservationTicketModel.fromSnapshot(qs);
    print(allReservationTicketModel.allReservationTicketModel);
    return allReservationTicketModel.allReservationTicketModel;
  }
}
