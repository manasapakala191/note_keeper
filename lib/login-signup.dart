import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/functions.dart';
import 'package:notes_app/notes.dart';
import 'package:notes_app/userModel.dart';
import 'package:provider/provider.dart';

class LoginSignup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Notes App"),
            bottom: TabBar(
              tabs: [
                Tab(text: "Login",),
                Tab(text: "Register",),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoginWidget(),
              RegisterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}


class LoginWidget extends StatelessWidget {
  TextEditingController emailTEC = TextEditingController();
  TextEditingController passTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final _screenSize= MediaQuery.of(context).size;
    return Container(
      width: _screenSize.width*0.6,
      child: Column(
        children: [
          Container(
            width: _screenSize.width*0.6,
            child: TextField(
              controller: emailTEC,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
          ),
          Container(
            width: _screenSize.width*0.6,
            child: TextField(
              controller: passTEC,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
          ),
          FlatButton(
              onPressed: () async {
                String email= emailTEC.text.trim();
                String password = passTEC.text.trim();
                var resultUID = await BEFunctions.signInWithEmailAndPassword(email, password);
                if(resultUID!=null){
                  var resultDetails = await BEFunctions.fetchUserDetails(resultUID);
                  userModel.setUserModel(resultDetails["name"], resultUID,resultDetails["email"]);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen()));
                } else {
                  print("Error");
                }
              }, 
              child: Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(10),
                  child: Text("Login"))
          )
        ],
      ),
    );
  }
}

class RegisterWidget extends StatelessWidget {
  TextEditingController nameTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController passTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final _screenSize= MediaQuery.of(context).size;
    final userModel = Provider.of<UserModel>(context);
    return Container(
      width: _screenSize.width*0.6,
      child: Column(
        children: [
          Container(
            width: _screenSize.width*0.6,
            child: TextField(
              controller: nameTEC,
              decoration: InputDecoration(
                labelText: "Name",
              ),
            ),
          ),
          Container(
            width: _screenSize.width*0.6,
            child: TextField(
              controller: emailTEC,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
          ),
          Container(
            width: _screenSize.width*0.6,
            child: TextField(
              controller: passTEC,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
          ),
          FlatButton(
              onPressed: () async {
                String name = nameTEC.text.trim();
                String email= emailTEC.text.trim();
                String password = passTEC.text.trim();
                var result = await BEFunctions.registerWithEmailAndPassword(name, email, password);
                if(result!=null){
                  await BEFunctions.createUserDoc(name, email, result);
                  userModel.setUserModel(name, result, email);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen()));
                } else {
                  print("Error");
                }
              },
              child: Container(
                color: Colors.lightBlue,
                  padding: EdgeInsets.all(10),
                  child: Text("Register"))
          )
        ],
      ),
    );
  }
}


