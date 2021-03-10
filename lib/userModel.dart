

import 'package:flutter/cupertino.dart';

class UserModel extends ChangeNotifier{
  String name;
  String uid;
  String email;

  setUserModel(String name1, String uid1, String email1){
    name=name1;
    uid=uid1;
    email=email1;
    notifyListeners();
  }
}