import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes_app/functions.dart';
import 'package:notes_app/noteModel.dart';
import 'package:notes_app/userModel.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as Firebase_Storage;
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel noteModel;
  EditNoteScreen({Key key,this.noteModel}):super(key:key);
  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  File _image;
  String _noteImageURL;
  final imagePicker = ImagePicker();
  String taskID;
  TextEditingController tname=TextEditingController();
  TextEditingController tdes=TextEditingController();
  DateTime createdOn;
  DateTime editedOn;
  pickImage() async {
    final PickedFile pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
    print(_image.path);
  }

  uploadImageToFirebase(String uid, String taskID) async {
    String fileName = basename(taskID);
    Firebase_Storage.StorageReference firebaseStorageRef = Firebase_Storage.FirebaseStorage.instance.ref().child('studentProfileImages/$fileName');
    Firebase_Storage.StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    Firebase_Storage.StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then((value) {
      print("Done: $value");
      setState(() {
        _noteImageURL = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _noteImageURL=widget.noteModel.imageURL;
    tname=TextEditingController(text: widget.noteModel.title);
    tdes=TextEditingController(text: widget.noteModel.description);
    taskID=widget.noteModel.taskID;
    createdOn=widget.noteModel.createdOn;
    editedOn= widget.noteModel.lastEdited;
  }
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: InkWell(
                onTap: () async {
                  print(_noteImageURL);
                  await pickImage();
                  if(_image!=null){
                    print("uploading");
                    uploadImageToFirebase(userModel.uid,taskID);
                  }
                },
                child: _noteImageURL!=null && _noteImageURL.isNotEmpty
                    ? FadeInImage.assetNetwork(
                    placeholder: "assets/loading.gif",
                    image: _noteImageURL != null ? _noteImageURL : "No image")
                    : Icon(Icons.note,size: 80,),
              ),
              margin: EdgeInsets.all(50.0),
              width: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            TextField(
              controller: tname,
              decoration: InputDecoration(
                  labelText: "Name"
              ),
            ),
            TextField(
              controller: tdes,
              decoration: InputDecoration(
                  labelText: "Description"
              ),
            ),
            createdOn!=null ? Text("Created on: ${createdOn.day}/${createdOn.month}"): null,
            editedOn!=null? Text("Edited on: ${editedOn.day}/${editedOn.month}"): null,
            FlatButton(
                onPressed: () async {
                  String name=tname.text.trim();
                  String des=tdes.text;
                  print(DateTime.now().runtimeType);
                  NoteModel nM= NoteModel(
                      taskID: taskID,title: name, description: des,imageURL:  _noteImageURL,lastEdited: DateTime.now());
                  print(nM.lastEdited);
                  await BEFunctions.editNote(userModel.uid, taskID, nM);
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.lightBlue,
                    padding: EdgeInsets.all(10),
                    child: Text("Edit Note")))
          ],
        ),
      ),
    );
  }
}
