

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/noteModel.dart';


class BEFunctions{
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Firestore _db = Firestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future createNote(String uid, String taskID,NoteModel noteModel){
    return _db.collection("users").document(uid).collection("notes").document(taskID).setData({
      "name": noteModel.title,
      "description": noteModel.description,
      "imageURL": noteModel.imageURL,
      "createdOn": noteModel.createdOn,
      "lastEdited": noteModel.lastEdited,
    });
  }

  static Future getNotes(String uid) async {
    QuerySnapshot notes = await _db.collection("users").document(uid).collection("notes").getDocuments();
    return notes.documents;
  }

  static Future deleteNote(String uid,String taskID,String imageURL) async {
    // DocumentSnapshot noteDoc = await _db.collection("users").document(uid).collection("notes").document(taskID).get();
    if(imageURL!=null){
      StorageReference photoRef = await _storage.getReferenceFromUrl(imageURL);
      await photoRef.delete();
    }
    print("inDelete");
    print(uid+" "+taskID);
    await _db.collection("users").document(uid).collection("notes").document(taskID).delete().whenComplete(() => print("Deleted"));
  }

  static Future editNote(String uid, String taskID, NoteModel noteModel) async {
    return _db.collection("users").document(uid).collection("notes").document(taskID).setData({
      "name": noteModel.title,
      "description": noteModel.description,
      "imageURL": noteModel.imageURL,
      "lastEdited": noteModel.lastEdited,
    },merge: true);
  }

  static Future queryByName(String uid, String name) async {
    Query qResult= await _db.collection("users").document(uid).collection("notes").where("name",isGreaterThanOrEqualTo: name,isLessThan: name+'z');
    QuerySnapshot qDocs=  await qResult.getDocuments();
    return qDocs.documents;
  }

  static Future orderBy(String uid, String ddval,bool asc) async {
    Query qResult = await _db.collection("users").document(uid).collection("notes").orderBy(ddval,descending: !asc);
    QuerySnapshot qDocs=  await qResult.getDocuments();
    return qDocs.documents;
  }
  //Register with email and password
  static Future registerWithEmailAndPassword(String name,String email, String password ) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      print(user.uid);
      return user.uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //  signin with email
  static Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      print(user.uid);
      return user.uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future logout() async {
    return await _auth.signOut();
  }

  static Future createUserDoc(String name, String email, String uid) {
    return _db.collection("users").document(uid).setData({
      "name": name,
      "email": email,
    },merge: true);
  }

  static Future fetchUserDetails(String uid) async {
    DocumentSnapshot userDoc = await _db.collection("users").document(uid).get();
    return userDoc.data;
  }
}