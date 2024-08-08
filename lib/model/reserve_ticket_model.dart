import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TicketConcertModel {
  String id = "";
  String eventName;
  String imageEvent;
  String partnerId;
  int numberOfTickets;
  DateTime eventDate;
  DateTime openingSaleDate;
  DateTime endingSaleDate;
  double ticketPrice;

  TicketConcertModel({
    required this.eventName,
    required this.imageEvent,
    required this.partnerId,
    required this.numberOfTickets,
    required this.eventDate,
    required this.openingSaleDate,
    required this.endingSaleDate,
    required this.ticketPrice,
  });

  factory TicketConcertModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return TicketConcertModel(
      eventName: json['eventName'] as String,
      imageEvent: json['imageEvent'] as String,
      partnerId: json['partnerId'] as String,
      numberOfTickets: json['numberOfTickets'] as int,
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      openingSaleDate: (json['openingSaleDate'] as Timestamp).toDate(),
      endingSaleDate: (json['endingSaleDate'] as Timestamp).toDate(),
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': id,
      'eventName': eventName,
      'imageEvent': imageEvent,
      'partnerId': partnerId,
      'numberOfTickets': numberOfTickets,
      'eventDate': eventDate,
      'openingSaleDate': openingSaleDate,
      'endingSaleDate': endingSaleDate,
      'ticketPrice': ticketPrice,
    };
  }
}

class AllTicketConcertModel {
  final List<TicketConcertModel> allTicketConcertModel;

  AllTicketConcertModel(this.allTicketConcertModel);

  factory AllTicketConcertModel.fromJson(List<dynamic> json) {
    print(json);
    List<TicketConcertModel> allTicketConcertModel;

    allTicketConcertModel =
        json.map((item) => TicketConcertModel.fromJson(item)).toList();

    return AllTicketConcertModel(allTicketConcertModel);
  }

  factory AllTicketConcertModel.fromSnapshot(QuerySnapshot qs) {
    List<TicketConcertModel> allTicketConcertModel;

    allTicketConcertModel = qs.docs.map((DocumentSnapshot ds) {
      TicketConcertModel ticketconcertmodel =
          TicketConcertModel.fromJson(ds.data() as Map<String, dynamic>);
      ticketconcertmodel.id = ds.id;
      return ticketconcertmodel;
    }).toList();
    return AllTicketConcertModel(allTicketConcertModel);
  }
}

class BookingTicket {
  String id = "";
  String userId;
  String ticketId;
  String nicknameUser;
  String eventName;
  String selectedTableLabel;
  DateTime eventDate;
  double totalPayment;
  int ticketQuantity;
  bool payable;
  bool checkIn;
  DateTime paymentTime;
  int sharedCount;
  List<String>? sharedWith;
  String partnerId;
  String? tableNo; // Add tableNo
  String? roundtable; // Add roundtable
  bool? checkOut;
  bool? outOfTimeCheckIn;
  String userPhone;

  BookingTicket({
    this.id = "",
    required this.userId,
    required this.ticketId,
    required this.nicknameUser,
    required this.eventName,
    required this.selectedTableLabel,
    required this.eventDate,
    required this.totalPayment,
    required this.ticketQuantity,
    required this.payable,
    required this.checkIn,
    required this.paymentTime,
    required this.sharedCount,
    required this.sharedWith,
    required this.partnerId,
    required this.tableNo, // Add tableNo
    required this.roundtable, // Add roundtable
    required this.checkOut,
    required this.outOfTimeCheckIn,
    required this.userPhone,
  });

  factory BookingTicket.fromJson(Map<String, dynamic> json) {
    print(json);
    return BookingTicket(
      id: json['id'] as String,
      userId: json['userId'] as String,
      ticketId: json['ticketId'] as String,
      nicknameUser: json['nicknameUser'] as String,
      eventName: json['eventName'] as String,
      selectedTableLabel: json['selectedTableLabel'] as String,
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      totalPayment:
          (json['totalPayment'] as num).toDouble(), // Ensures double type
      ticketQuantity: json['ticketQuantity'] as int,
      payable: json['payable'] as bool,
      checkIn: json['checkIn'] as bool,
      paymentTime: (json['paymentTime'] as Timestamp).toDate(),
      sharedCount: json['sharedCount'] as int? ?? 0,
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
      partnerId: json['partnerId'] as String,
      tableNo: json['tableNo'] as String? ?? "",
      roundtable: json['roundtable'] as String? ?? "",
      checkOut: json['checkOut'],
      outOfTimeCheckIn: json['outOfTimeCheckIn'],
      userPhone: json['userPhone'] as String,
    );
  }

  factory BookingTicket.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return BookingTicket(
      id: snapshot.id, // Correctly assign the document ID
      userId: json['userId'] as String,
      ticketId: json['ticketId'] as String,
      nicknameUser: json['nicknameUser'] as String,
      eventName: json['eventName'] as String,
      selectedTableLabel: json['selectedTableLabel'] as String,
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      totalPayment:
          (json['totalPayment'] as num).toDouble(), // Ensures double type
      ticketQuantity: json['ticketQuantity'] as int,
      payable: json['payable'] as bool,
      checkIn: json['checkIn'] as bool,
      paymentTime: (json['paymentTime'] as Timestamp).toDate(),
      sharedCount: json['sharedCount'] as int? ?? 0,
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
      partnerId: json['partnerId'] as String,
      tableNo: json['tableNo'] as String? ?? "",
      roundtable: json['roundtable'] as String? ?? "",
      checkOut: json['checkOut'],
      outOfTimeCheckIn: json['outOfTimeCheckIn'],
      userPhone: json['userPhone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ticketId': ticketId,
      'nicknameUser': nicknameUser,
      'eventName': eventName,
      'selectedTableLabel': selectedTableLabel,
      'eventDate': eventDate,
      'totalPayment': totalPayment,
      'ticketQuantity': ticketQuantity,
      'payable': payable,
      'checkIn': checkIn,
      'paymentTime': paymentTime,
      'sharedCount': sharedCount,
      'sharedWith': sharedWith,
      'partnerId': partnerId,
      'tableNo': tableNo, // Add tableNo
      'roundtable': roundtable, // Add roundtable
      'checkOut': checkOut,
      'outOfTimeCheckIn': outOfTimeCheckIn,
      'userPhone': userPhone,
    };
  }
}

class AllReservationTicketModel {
  final List<BookingTicket> allReservationTicketModel;

  AllReservationTicketModel(this.allReservationTicketModel);

  factory AllReservationTicketModel.fromJson(List<dynamic> json) {
    List<BookingTicket> allReservationTicketModel =
        json.map((item) => BookingTicket.fromJson(item)).toList();

    return AllReservationTicketModel(allReservationTicketModel);
  }

  factory AllReservationTicketModel.fromSnapshot(QuerySnapshot qs) {
    List<BookingTicket> allReservationTicketModel =
        qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return BookingTicket.fromJson(dataWithId);
    }).toList();
    return AllReservationTicketModel(allReservationTicketModel);
  }

  Map<String, dynamic> toJson() {
    return {
      'reservetickets': allReservationTicketModel
          .map((reservetickets) => reservetickets.toJson())
          .toList(),
    };
  }
}

class ReservationTicketProvider extends ChangeNotifier {
  List<BookingTicket> _allReservationTicket = [];
  List<BookingTicket> get reservationtickets => _allReservationTicket;

  List<TicketConcertModel> _allTickets = [];
  List<TicketConcertModel> get AllTickets => _allTickets;

  void clearBookingTable() {
    _allReservationTicket.clear();
    notifyListeners();
  }

  void setAllReservationTicket(List<BookingTicket> reservationtickets) {
    _allReservationTicket = reservationtickets;
    notifyListeners();
  }

  void addAllReserveTickets(List<BookingTicket> bookingTickets) {
    _allReservationTicket.addAll(bookingTickets);
    notifyListeners();
  }

  void setTicketCatalog(List<TicketConcertModel> ticketCatalog) {
    _allTickets = ticketCatalog;
    notifyListeners();
  }

  BookingTicket? getReservationById(String id) {
    try {
      return _allReservationTicket
          .firstWhere((reservation) => reservation.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateCheckInStatus(String id, bool checkIn) {
    final index =
        _allReservationTicket.indexWhere((reservation) => reservation.id == id);
    if (index != -1) {
      _allReservationTicket[index].checkIn = checkIn;
      notifyListeners();
    }
  }

  List<TicketConcertModel> get upcomingTickets {
    final now = DateTime.now();
    return _allTickets
        .where((ticket) => ticket.eventDate.isAfter(now))
        .toList();
  }

  List<TicketConcertModel> get pastTickets {
    final now = DateTime.now();
    return _allTickets
        .where((ticket) => ticket.eventDate.isBefore(now))
        .toList();
  }

  // Add this method to prepare the data for the report
  List<Map<String, dynamic>> get reservationTicketData {
    return _allReservationTicket
        .map((ticket) => {
              'Date': ticket.eventDate.toString(),
              'Event Name': ticket.eventName,
              'User': ticket.nicknameUser,
              'Table Selection': ticket.selectedTableLabel,
              'Check-In': ticket.checkIn ? 'Yes' : 'No',
              'Ticket ': ticket.ticketQuantity,
              'Total Price': ticket.totalPayment,
              'Payable': ticket.payable ? 'Yes' : 'No',
              'Shared Count': ticket.sharedWith?.length,
              'Shared With': ticket.sharedWith?.join(', ') ?? '',
            })
        .toList();
  }

  // Method to get available tables based on zone and availability status
  List<String> getAvailableTables(
      MemberUserModel memberUserModel, String tableLabel) {
    Set<String> reservedTables = _allReservationTicket
        .where((reservation) =>
            reservation.selectedTableLabel == tableLabel &&
            reservation.checkIn &&
            !(reservation.checkOut ?? false)) // Ensure checkOut is non-nullable
        .map((reservation) =>
            reservation.tableNo ?? "") // Ensure tableNo is non-nullable
        .toSet();

    List<String> availableTables = [];
    // Get totalTables from MemberUserModel
    var tableInfo = memberUserModel.memberUser?.tableLabels.firstWhere(
        (table) => table['label'] == tableLabel,
        orElse: () => <String, dynamic>{});
    int totalTables = tableInfo?['totaloftable'] ?? 0;

    for (var i = 1; i <= totalTables; i++) {
      String tableNo = "$tableLabel $i";
      if (!reservedTables.contains(tableNo)) {
        availableTables.add(tableNo);
      }
    }

    print("Available tables for $tableLabel: $availableTables");
    return availableTables;
  }

  // Method to get round tables and their availability status for a specific table on a given date
  Map<String, bool> getRoundTableAvailability(String tableNo, DateTime date) {
    List<int> usedRoundTables = _allReservationTicket
        .where((reservation) =>
            reservation.tableNo == tableNo &&
            reservation.eventDate.year == date.year &&
            reservation.eventDate.month == date.month &&
            reservation.eventDate.day == date.day)
        .map((reservation) => int.tryParse(reservation.roundtable ?? '0') ?? 0)
        .toList();

    print("Used round tables for $tableNo on $date: $usedRoundTables");

    Map<String, bool> roundTableAvailability = {};
    for (int i = 1; i <= 5; i++) {
      roundTableAvailability[i.toString()] = !usedRoundTables.contains(i);
    }

    print(
        "Round table availability for $tableNo on $date: $roundTableAvailability");
    return roundTableAvailability;
  }
}
