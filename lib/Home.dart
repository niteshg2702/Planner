import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool enble = true;
  
  @override
  Widget build(BuildContext context) {

    String todo,newtodo;

    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference user = db.collection('Todo');



    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Some Functions'),
            ),
            ListTile(
              title: Text("Clear List"),
              leading: Icon(Icons.delete),
              enabled: enble,
              onTap: () {
                setState(() {
                  enble = false;
                });
                user.get()
                    .then((value) => value.docs.forEach((element) {
                  element.reference.delete();})
                ).then((value) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                      content: Text("Everything removed"))
                  );
                });
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Planner"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: user.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if(snapshot.data.docs.length == 0) {
            return Container(
              color: Colors.transparent,
              child: Center(child: Text("Empty List")),
            );
          }
          else {
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot documents) {
                return Dismissible(
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete,color: Colors.white,),
                  ),
                  direction: DismissDirection.startToEnd,
                  key: ObjectKey(documents),
                  onDismissed: (direction) {
                    setState(() {
                      user
                          .doc(documents.id)
                          .delete()
                          .then((value) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                            content: Text("Removed"))
                        );
                      }).catchError((error) => print(error.toString())
                      );
                    });
                  },
                  child: Card(
                    elevation: 8,
                    child: ListTile(
                      title: Text(documents.data()["title"]),
                      leading: IconButton(
                        icon: Icon(Icons.check_circle_rounded),
                        color: documents.data()["iscmpltd"] ? Colors.greenAccent : Colors.grey[400],
                        onPressed: () {
                          user
                              .doc(documents.id)
                              .update({"iscmpltd": true})
                              .then((value) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                content: Text("Completed"))
                            );
                          }).catchError((error) => print(error.toString())
                          );
                        },
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.edit),
                        onPressed: () {
                            return showDialog(
                                context: context,
                                builder: (ctxt) => new SimpleDialog(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Edit"),
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                                      child: SizedBox(
                                        height: 50.0,
                                        child: TextFormField(
                                          initialValue: documents.data()["title"],
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(15.0)
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(15.0)
                                              )
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              newtodo = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                                      child: SizedBox(
                                        height: 40.0,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0)
                                          ),
                                          color: Colors.teal,
                                          textColor: Colors.white,
                                          child: Text('Update'),
                                          onPressed: () {
                                            if(newtodo == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                  content: Text("Cannot update with old value"))
                                              );
                                            }else {
                                              user.doc(documents.id).update({
                                                'title': newtodo,
                                                'iscmpltd': false
                                              })
                                                  .then((value) => print("added"))
                                                  .catchError((error) => print(error.toString()));

                                              Navigator.of(context).pop();
                                            }
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            );
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        }
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,
        onPressed: () {

          showDialog(
              context: context,
              builder: (ctxt) => new SimpleDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Todo"),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: SizedBox(
                      height: 50.0,
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)
                            )
                        ),
                        onChanged: (val) {
                          setState(() {
                            todo = val;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: SizedBox(
                      height: 40.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        color: Colors.teal,
                        textColor: Colors.white,
                        child: Text('Submit'),
                        onPressed: () {
                          setState(() {
                            enble = true;
                          });
                          if(todo == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                content: Text("Cannot fill null value"))
                            );
                          }
                          else {
                            user.add({
                              'title': todo,
                              'iscmpltd': false
                            })
                                .then((value) => print("added"))
                                .catchError((error) => print(error.toString()));

                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  )
                ],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)
                ),
              )

          );
        },
      ),
    );
  }
}