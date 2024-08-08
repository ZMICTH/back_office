import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TableLabel {
  String label;
  int numberofchairs;
  int seats;
  double tablePrices;
  int totaloftable;

  TableLabel({
    required this.label,
    required this.numberofchairs,
    required this.seats,
    required this.tablePrices,
    required this.totaloftable,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'numberofchairs': numberofchairs,
      'seats': seats,
      'tablePrices': tablePrices,
      'totaloftable': totaloftable,
    };
  }

  factory TableLabel.fromJson(Map<String, dynamic> json) {
    return TableLabel(
      label: json['label'],
      numberofchairs: json['numberofchairs'],
      seats: json['seats'],
      tablePrices: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totaloftable: json['totaloftable'],
    );
  }
}

class TableCatalog {
  String id = "";
  String partnerId;
  DateTime onTheDay;
  bool closeDate;
  List<TableLabel> tableLables;

  TableCatalog({
    this.id = "",
    required this.partnerId,
    required this.onTheDay,
    required this.closeDate,
    required this.tableLables,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'onTheDay': onTheDay,
      'closeDate': closeDate,
      'tableLables': tableLables.map((label) => label.toJson()).toList(),
    };
  }

  factory TableCatalog.fromJson(Map<String, dynamic> json) {
    return TableCatalog(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String,
      onTheDay: (json['onTheDay'] as Timestamp).toDate(),
      closeDate: json['closeDate'],
      tableLables: (json['tableLables'] as List<dynamic>)
          .map((e) => TableLabel.fromJson(e))
          .toList(),
    );
  }

  // Factory constructor to create a TableCatalog instance from a Firestore DocumentSnapshot
  factory TableCatalog.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
    return TableCatalog(
      id: snapshot.id,
      partnerId: json['partnerId'] as String,
      onTheDay: (json['onTheDay'] as Timestamp).toDate(),
      closeDate: json['closeDate'],
      tableLables: (json['tableLables'] as List<dynamic>)
          .map((e) => TableLabel.fromJson(e))
          .toList(),
    );
  }
}

class AllTableCatalog {
  final List<TableCatalog> tablecatalogs;

  AllTableCatalog(this.tablecatalogs);

  factory AllTableCatalog.fromJson(List<dynamic> json) {
    List<TableCatalog> tablecatalogs =
        json.map((item) => TableCatalog.fromJson(item)).toList();
    return AllTableCatalog(tablecatalogs);
  }

  factory AllTableCatalog.fromSnapshot(QuerySnapshot qs) {
    List<TableCatalog> tablecatalogs = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return TableCatalog.fromJson(dataWithId);
    }).toList();
    return AllTableCatalog(tablecatalogs);
  }

  Map<String, dynamic> toJson() {
    return {
      'tablecatalogs':
          tablecatalogs.map((tablecatalogs) => tablecatalogs.toJson()).toList(),
    };
  }
}

class ReserveTableHistory {
  String id = "";
  String selectedTableId;
  int quantityTable;
  String selectedTableLabel;
  double totalPrices;
  DateTime formattedSelectedDay;
  String userId;
  String nicknameUser;
  bool checkIn;
  int selectedSeats;
  String userPhone;
  bool payable;
  DateTime paymentTime;
  int sharedCount;
  List<String>? sharedWith;
  String partnerId;
  String? tableNo; // Add tableNo
  String? roundtable; // Add roundtable
  bool? checkOut;
  bool? outOfTimeCheckIn;

  ReserveTableHistory({
    this.id = "",
    required this.selectedTableId,
    required this.quantityTable,
    required this.selectedTableLabel,
    required this.totalPrices,
    required this.formattedSelectedDay,
    required this.userId,
    required this.nicknameUser,
    required this.checkIn,
    required this.selectedSeats,
    required this.userPhone,
    required this.payable,
    required this.paymentTime,
    required this.sharedCount,
    required this.sharedWith,
    required this.partnerId,
    required this.tableNo, // Add tableNo
    required this.roundtable, // Add roundtable
    required this.checkOut,
    required this.outOfTimeCheckIn,
  });

  factory ReserveTableHistory.fromJson(Map<String, dynamic> json) {
    print(json);
    return ReserveTableHistory(
      id: json['id'] as String,
      userId: json['userId'],
      selectedTableId: json['selectedTableId'],
      quantityTable: json['quantityTable'] as int,
      selectedTableLabel: json['selectedTableLabel'],
      totalPrices: (json['totalPrices'] as num).toDouble(),
      formattedSelectedDay:
          (json['formattedSelectedDay'] as Timestamp).toDate(), // Corrected
      nicknameUser: json['nicknameUser'],
      selectedSeats: json['selectedSeats'] as int,
      userPhone: json['userPhone'],
      checkIn: json['checkIn'],
      payable: json['payable'],
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
    );
  }

  factory ReserveTableHistory.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return ReserveTableHistory(
      id: snapshot.id, // Correctly assign the document ID
      userId: json['userId'],
      selectedTableId: json['selectedTableId'],
      quantityTable: json['quantityTable'] as int,
      selectedTableLabel: json['selectedTableLabel'],
      totalPrices: (json['totalPrices'] as num).toDouble(),
      formattedSelectedDay:
          (json['formattedSelectedDay'] as Timestamp).toDate(), // Corrected
      nicknameUser: json['nicknameUser'],
      selectedSeats: json['selectedSeats'] as int,
      userPhone: json['userPhone'],
      checkIn: json['checkIn'],
      payable: json['payable'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTableId': selectedTableId,
      'quantityTable': quantityTable,
      'selectedTableLabel': selectedTableLabel,
      'totalPrices': totalPrices,
      'formattedSelectedDay': formattedSelectedDay,
      'userId': userId,
      'nicknameUser': nicknameUser,
      'checkIn': checkIn,
      'selectedSeats': selectedSeats,
      'userPhone': userPhone,
      'payable': payable,
      'paymentTime': paymentTime,
      'sharedCount': sharedCount,
      'sharedWith': sharedWith,
      'partnerId': partnerId,
      'tableNo': tableNo, // Add tableNo
      'roundtable': roundtable, // Add roundtable
      'checkOut': checkOut,
      'outOfTimeCheckIn': outOfTimeCheckIn,
    };
  }
}

class AllReserveTableHistory {
  final List<ReserveTableHistory> reservetables;

  AllReserveTableHistory(this.reservetables);

  factory AllReserveTableHistory.fromJson(List<dynamic> json) {
    List<ReserveTableHistory> reservetables =
        json.map((item) => ReserveTableHistory.fromJson(item)).toList();
    return AllReserveTableHistory(reservetables);
  }

  factory AllReserveTableHistory.fromSnapshot(QuerySnapshot qs) {
    List<ReserveTableHistory> reservetables =
        qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return ReserveTableHistory.fromJson(dataWithId);
    }).toList();
    return AllReserveTableHistory(reservetables);
  }

  Map<String, dynamic> toJson() {
    return {
      'reservetables':
          reservetables.map((reservetable) => reservetable.toJson()).toList(),
    };
  }
}

class ReserveTableProvider extends ChangeNotifier {
  List<ReserveTableHistory> _allReserveTable = [];
  List<ReserveTableHistory> get allReserveTable => _allReserveTable;

  List<TableCatalog> _allTables = [];
  List<TableCatalog> get allTables => _allTables;

  List<String> _reservedTableNumbers = [];
  List<String> get reservedTableNumbers => _reservedTableNumbers;

  String? _selectedTableNo;
  String? get selectedTableNo => _selectedTableNo;

  void setTableCatalog(List<TableCatalog> tablecatalog) {
    _allTables = tablecatalog;
    notifyListeners();
  }

  // Method to set reservation data from Firebase
  void setReserveTable(List<ReserveTableHistory> bookingTable) {
    _allReserveTable = bookingTable;
    notifyListeners();
  }

  void clearBookingTable() {
    _allReserveTable.clear();
    notifyListeners();
  }

  void addReserveTable(ReserveTableHistory bookingTable) {
    _allReserveTable.add(bookingTable);
    notifyListeners();
  }

  void addAllReserveTables(List<ReserveTableHistory> bookingTables) {
    _allReserveTable.addAll(bookingTables);
    notifyListeners();
  }

  ReserveTableHistory? getReservationById(String id) {
    try {
      return _allReserveTable.firstWhere((reservation) => reservation.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateCheckInStatus(String id, bool checkIn) {
    final index =
        _allReserveTable.indexWhere((reservation) => reservation.id == id);
    if (index != -1) {
      _allReserveTable[index].checkIn = checkIn;
      notifyListeners();
    }
  }

  // Add this method to prepare the data for the report
  List<Map<String, dynamic>> get reserveTableData {
    return _allReserveTable
        .map((reservation) => {
              'Date': reservation.formattedSelectedDay.toString(),
              'Table Selection': reservation.selectedTableLabel,
              'User': reservation.nicknameUser,
              'Phone': reservation.userPhone,
              'Check-In': reservation.checkIn ? 'Yes' : 'No',
              'Seats': reservation.selectedSeats,
              'Total Price': reservation.totalPrices,
              'Payable': reservation.payable ? 'Yes' : 'No',
              'Shared Count': reservation.sharedWith?.length,
              'Shared With': reservation.sharedWith?.join(', ') ?? '',
              'Check-Out': reservation.checkOut ?? false ? 'Yes' : 'No',
            })
        .toList();
  }

  void setSelectedTableNo(String? tableNo) {
    _selectedTableNo = tableNo;
    print("setSelectedTableNo called. Selected tableNo: $tableNo");
    notifyListeners();
  }

  // Method to get available tables based on zone and availability status
  List<String> getAvailableTables(
      MemberUserModel memberUserModel, String tableLabel) {
    Set<String> reservedTables = _allReserveTable
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
    List<int> usedRoundTables = _allReserveTable
        .where((reservation) =>
            reservation.tableNo == tableNo &&
            reservation.formattedSelectedDay.year == date.year &&
            reservation.formattedSelectedDay.month == date.month &&
            reservation.formattedSelectedDay.day == date.day)
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
