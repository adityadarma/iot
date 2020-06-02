import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  final _formKey = new GlobalKey<FormState>();

  var email = TextEditingController();
  var password = TextEditingController();
  var token = TextEditingController();
  bool isLoading = false;

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = new TextEditingController(text: prefs.getString('email'));
      token = new TextEditingController(text: prefs.getString('token'));
    });    
  }

  Future<void> save() async {
    try{
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      var token = "Bearer " + prefs.getString('token');
      await http.post(
        Uri.encodeFull('http://restapi-ta.kubusoftware.com/change'),
        body: {'email': email.text, 'password': password.text},
        headers: {"Accept": "application/json", 'Authorization':token}
      ).then((response) async {
        var data = json.decode(response.body);
        if(response.statusCode == 200){
          prefs.setString('email', email.text);
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 3,
            backgroundColor: Colors.grey[400],
            textColor: Colors.white,
            fontSize: 16.0
          );
        }else if(response.statusCode == 401){
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 3,
            backgroundColor: Colors.red[400],
            textColor: Colors.white,
            fontSize: 16.0
          );
        }
        setState(() {
          isLoading = false;
        }); 
      });
    }catch(e){
      setState(() {
        isLoading = false;
      }); 
      print(e.message);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: new Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              SizedBox(height: 20.0),
              //email
              Text('Email', style: TextStyle(color: Colors.black87, fontSize: 15.0,fontWeight: FontWeight.bold),),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Masukkan Email';
                  }
                  return null;
                },
                controller: email,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Email',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              SizedBox(height: 8.0),

              //password
              Text('Password', style: TextStyle(color: Colors.black87, fontSize: 15.0,fontWeight: FontWeight.bold),),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Masukkan Password';
                  }
                  return null;
                },
                controller: password,
                autofocus: false,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Password',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              SizedBox(height: 4.0),

              //token
              Text('Token', style: TextStyle(color: Colors.black87, fontSize: 15.0,fontWeight: FontWeight.bold),),
              TextFormField(
                controller: token,
                autofocus: false,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Password',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              SizedBox(height: 4.0),

              //saveButton
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        ),
                      )
                    : RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text(
                          "Perbaharui",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        onPressed: () {
                          save();
                        },
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}