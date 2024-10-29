import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {

  // get collection of topics from db
  final CollectionReference topics = FirebaseFirestore.instance.collection('topics');

  // Create: add new topic
  Future<void> addTopic(String topic) {
    return topics.add(
      {'topic': topic,
      'upvotes': 0,
      'downvotes': 0,
      'timestap': Timestamp.now()}
    );
  }
 
  // Read: get topics from db
  Stream<QuerySnapshot> getTopicsStream() {
    final topicsStream = topics.orderBy('timestap', descending: true).snapshots();

    return topicsStream;
  }

  // Update: update topics in db given doc id
  Future<void> updateTopic(String docID, String newTopic) {
    return topics.doc(docID).update({
      'note': newTopic,
      'upvotes': 0,
      'downvotes': 0,
      'timestap': Timestamp.now()
    });
  }
  // Delete: delete notes from db given doc id
  Future<void> deleteTopic(String docID) {
    return topics.doc(docID).delete();
  }

  // Update: upvote a topic
  Future<void> upvoteTopic(String docID) {
    return topics.doc(docID).update({
      'upvotes': FieldValue.increment(1)
    });
  }

  // Update: downvote a topic
  Future<void> downvoteTopic(String docID) {
    return topics.doc(docID).update({
      'downvotes': FieldValue.increment(1)
    });
  }
}