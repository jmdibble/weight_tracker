import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference _userWeightCollection(String userId) {
  return Firestore.instance.collection('/users/${userId}/records');
}

Stream<List<WeightRecord>> getAllWeights(String userId) {
  return _userWeightCollection(userId).snapshots().map<List<WeightRecord>>((query) {
    return query.documents
        .map<WeightRecord>((doc) => WeightRecord.fromDoc(doc))
        .toList(growable: false);
  });
}

class WeightRecord {
  DocumentReference _ref;
  DateTime date;
  int weightStone;
  double weightPounds;
  String notes;

  WeightRecord();

  factory WeightRecord.fromDoc(DocumentSnapshot doc){
    final record = WeightRecord();
    record._ref = doc.reference;
    record.date = (doc.data['date'] as Timestamp).toDate();
    record.weightStone = (doc.data['weightStone'] as int);
    record.weightPounds = (doc.data['weightPounds'] as double);
    record.notes = (doc.data['notes'] as String);
    return record;
  }

  Future<void> save(String userId) async {
    final data = {
      'date':  date,
      'weightStone': weightStone,
      'weightPounds': weightPounds,
      'notes':notes,
    };
    if(_ref == null){
      _ref = await _userWeightCollection(userId).add(data);
    }else {
      await _ref.setData(data);
    }
  }

}
