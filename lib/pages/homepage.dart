import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voting_app/service/firebase_service.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open dialog box to add note
  void openTopicBox({String? docID}) {
    showDialog(context: context, builder: (context) => AlertDialog(
      content: TextField(
        controller: textController,
        ),
        actions: [
          // button to save
          ElevatedButton(
            onPressed: () {
              // update or add new note
              if (docID == null) {
                firestoreService.addTopic(textController.text);
              } else {
                firestoreService.updateTopic(docID, textController.text);
              }
               
              // clear text field
              textController.clear();

              // close dialog boc
              Navigator.pop(context);
            }, 
            child: const Text('Add')
      )
        ]
        ),
      );
    }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
          ),
          ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: openTopicBox,
        child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getTopicsStream(),
          builder: (context, snapshot) {
            // if we have data, get all docs
            if (snapshot.hasData) {
              List topicList = snapshot.data!.docs;

              // display as list
              return ListView.builder(
                itemCount: topicList.length,
                itemBuilder: (context, index) {
                  // get doc
                  DocumentSnapshot document = topicList[index];
                  String docID = document.id;

                  // get note in doc
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String topicText = data['topic'];
                  // get upvotes
                  int upvotes = data['upvotes'];
                  // get downvots
                  int downvotes = data['downvotes'];

                  // display as list tile
                  return SizedBox(
                    height: 100,
                    width: 100,
                    child: ListTile(
                      title: Text(topicText),
                      trailing: SizedBox(
                        height: 100,
                        width: 400,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // upvote button
                            IconButton(
                              onPressed: () => firestoreService.upvoteTopic(docID),
                              icon: const Icon(Icons.arrow_upward),
                              ),
                            // upvotes
                            TextField(
                              readOnly: true,
                              controller: TextEditingController(text: upvotes.toString()),
                            ),
                            // downvote button
                            IconButton(
                              onPressed: () => firestoreService.downvoteTopic(docID),
                              icon: const Icon(Icons.arrow_downward),
                            ),
                            // downvotes
                            TextField(
                              readOnly: true,
                              controller: TextEditingController(text: downvotes.toString()),
                            ),
                            // update button
                            IconButton(
                              onPressed: () => openTopicBox(docID: docID), 
                              icon: const Icon(Icons.settings),
                            ),
                          // delete button
                            IconButton(
                              onPressed: () => firestoreService.deleteTopic(docID), 
                              icon: const Icon(Icons.delete),
                            ),
                        ]),
                      )
                    ),
                  );
                },
              );
            } else {
              return const Text("No Topics...");
            }
          },
        ),
      );
    }
  }
  
