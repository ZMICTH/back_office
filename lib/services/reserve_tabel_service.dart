import 'package:back_office/model/reserve_table_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ReserveTableHistoryService {
  Future<List<ReserveTableHistory>> getAllReserveTableHistory();
}

class ReserveTableFirebaseService implements ReserveTableHistoryService {
  @override
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
