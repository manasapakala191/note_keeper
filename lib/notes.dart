import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/add-note.dart';
import 'package:notes_app/edit-note.dart';
import 'package:notes_app/functions.dart';
import 'package:notes_app/noteModel.dart';
import 'package:notes_app/userModel.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  TextEditingController _queryController=TextEditingController();
  String _dropDownValue="lastEdited";
  int _view=0;
  bool _up=false;
  @override
  Widget build(BuildContext context) {
    final _screenSize= MediaQuery.of(context).size;
    final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: userModel.name!=null ? Text("Hi "+userModel.name):Text("Hi"),
        actions: [
          IconButton(icon: Icon(Icons.add_box_outlined),
              onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddNoteScreen()));
              })
        ],
      ),
      drawer: Drawer(

        child: ListView(
          shrinkWrap: true,
          children: [
            DrawerHeader(
              child: Container(
                alignment: Alignment.center,
                color: Colors.blueAccent,
                  child: Text("Hi ${userModel.name}",style: TextStyle(color: Colors.white,fontSize: 30),)),
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: () async {
                await BEFunctions.logout();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.topCenter,
        // width: _screenSize.width*0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: _screenSize.width*0.5,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by Name"
                    ),
                    onEditingComplete: (){
                      setState(() {
                        _view=1;
                      });
                      print("hey");
                    },
                    controller: _queryController,
                    onChanged: (val) async {
                      // Query qResult = await BEFunctions.queryByName(userModel.uid, val);
                      // QuerySnapshot qDocs = await qResult.getDocuments();
                      // print(qDocs.documents.length);
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _dropDownValue,
                  icon: Icon(Icons.arrow_drop_down_circle_outlined),
                  iconSize: _screenSize.height*0.03,
                  // elevation: 16,
                  // // style: TextStyle(color: Colors.deepPurple),
                  // underline: Container(
                  //   height: 2,
                  //   color: Colors.deepPurpleAccent,
                  // ),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropDownValue = newValue;
                      _view=2;
                    });
                  },
                  items: <String>['lastEdited', 'createdOn', 'name', 'description']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                IconButton(
                    icon: _up? Icon(Icons.arrow_upward_rounded) : Icon(Icons.arrow_downward_rounded),
                    onPressed: (){
                      setState(() {
                        _up=!_up;
                        _view=2;
                      });
                    })
              ],
            ),
            Padding(padding: EdgeInsets.all(10)),
            FutureBuilder(
              // stream: Firestore.instance.collection("users").document(userModel.uid).collection("notes").getDocuments().asStream(),
              future: _view==0 ? BEFunctions.getNotes(userModel.uid) : _view==1 ?BEFunctions.queryByName(userModel.uid, _queryController.text) :
              BEFunctions.orderBy(userModel.uid, _dropDownValue,_up),
              builder: (context,snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasError){
                    return Text("There's an error");
                  }
                  if(snapshot.hasData){
                    List<DocumentSnapshot> notesDocs=snapshot.data;
                    return ListView.separated(
                        itemCount: notesDocs.length,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                          Map notesData = notesDocs[index].data;
                          NoteModel nM = NoteModel.fromJSON(notesData, notesDocs[index].documentID);
                          return InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EditNoteScreen(noteModel: nM,)));
                            },
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          color: Colors.black54,
                                          height: _screenSize.height*0.07,
                                          width: _screenSize.width*0.3,
                                          child: nM.imageURL!=null && nM.imageURL.isNotEmpty
                                              ? FadeInImage.assetNetwork(
                                              placeholder: "assets/loading.gif",
                                              image: nM.imageURL != null ? nM.imageURL : "No image")
                                              : Icon(Icons.note)
                                        ),
                                        Container(
                                          child: nM.title!=null && nM.title.isNotEmpty ?Text(nM.title): null
                                        ),
                                        Container(
                                            child: nM.description!=null && nM.description.isNotEmpty ?Text(nM.description): null
                                        ),
                                        Container(
                                          child: nM.createdOn!=null ? Text("Created on: ${nM.createdOn.day}/${nM.createdOn.month}"): null,
                                        ),
                                        Container(
                                          child: nM.lastEdited!=null? Text("Last Edited: ${nM.lastEdited.day}/${nM.lastEdited.month}"):null,
                                        ),
                                      ],
                                    ),
                                    IconButton(icon: Icon(Icons.delete), onPressed: () async {
                                      await BEFunctions.deleteNote(userModel.uid, nM.taskID,nM.imageURL);
                                      setState(() {
                                      });
                                    })
                                  ],
                                ),
                              ),
                            ),
                          );
                      },
                      separatorBuilder: (context, index){
                          return Padding(padding: EdgeInsets.all(8));
                      },
                    );
                  }
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        )
      ),
    );
  }

  _returnNotes(int view, String uid){

  }
}
