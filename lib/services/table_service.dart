import 'package:back_office/model/reserve_table_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TableCatalogFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTableData(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
    List<DateTime> closeDates,
    List<TableLabel> tableLables,
  ) async {
    // Prepare batch write
    WriteBatch batch = _firestore.batch();

    for (DateTime date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      String docId = '${date.year}-${date.month}-${date.day}-${partnerId}';
      var docRef = _firestore.collection('table_catalog').doc(docId);

      // Check if the current date is a close date
      bool isCloseDate = closeDates.any((d) => d.isAtSameMomentAs(date));

      // Prepare data to be set in Firestore
      Map<String, dynamic> data = {
        'partnerId': partnerId,
        'onTheDay': date,
        'closeDate': isCloseDate,
        'tableLables': tableLables
            .map((label) => {
                  'label': label.label,
                  'seats': label.seats,
                  'totaloftable': label.totaloftable,
                  'numberofchairs': label.numberofchairs,
                  'tablePrices': label.tablePrices,
                })
            .toList(),
      };

      // Set data in batch
      batch.set(docRef, data);
    }

    // Commit the batch
    await batch
        .commit()
        .then((_) => print("Data successfully added to Firestore!"))
        .catchError((error) => print("Failed to add data: $error"));
  }

  Future<List<TableCatalog>> getAllTableCatalog() async {
    print("getAllTableCatalog is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('table_catalog').get();
    print("TableCatalog count: ${qs.docs.length}");
    AllTableCatalog TableCatalogs = AllTableCatalog.fromSnapshot(qs);
    print(TableCatalogs.tablecatalogs);
    return TableCatalogs.tablecatalogs;
  }

  Future<List<ReserveTableHistory>> getAllReserveTableHistory() async {
    print("getAllReserveTableHistory is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('reservation_table').get();
    print("ReserveTable count: ${qs.docs.length}");
    AllReserveTableHistory ReserveTableHistories =
        AllReserveTableHistory.fromSnapshot(qs);
    print(ReserveTableHistories.reservetables);
    return ReserveTableHistories.reservetables;
  }
}
