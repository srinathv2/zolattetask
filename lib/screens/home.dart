// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zolattetask/screens/delete.dart';
import 'package:zolattetask/screens/logout.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  var dropdownvalue, x, y;
  var items = new List<String>.generate(100, (i) => (i + 1).toString());
  final FirebaseAuth auth = FirebaseAuth.instance;
  var username, userdname, address, age, phonenumber, usermail;
  var userimage;
  var userDataLoading = true, userExistsLoading = true;
  late bool usernotexists;

  snapshot() async {
    print('snapshot');
    setState(() {
      userDataLoading = true;
    });
    final User? user = auth.currentUser;

    x = await FirebaseFirestore.instance
        .collection('usersData')
        .doc(user?.uid)
        .get();

    await getUserData(x);
  }

  getUserData(DocumentSnapshot<Map<String, dynamic>> data) async {
    print('getuserdata');
    var ud = data.data();
    setState(() {
      username = ud?["username"];
      usermail = ud?["usermail"];
      address = ud?["address"];
      age = ud?["age"];
      phonenumber = ud?["phonenumber"];
      userDataLoading = false;
    });
  }

  checkExists() async {
    print('checkexists');
    setState(() {
      userExistsLoading = true;
    });
    try {
      print('try checkexists');

      final User? user = auth.currentUser;

      await FirebaseFirestore.instance
          .collection('usersData')
          .doc(user?.uid)
          .get()
          .then((value) {
        setState(() {
          usernotexists = value.data()!.isEmpty;
          // print('&&&&&&${userexists}');
          userExistsLoading = false;
        });
      });

      // .then((value) => {userexists = value.exists});

    } catch (e) {
      setState(() {
        usernotexists = true;
        userExistsLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User? user = auth.currentUser;
    userimage = user?.photoURL;
    userdname = user?.displayName;
    snapshot();
    checkExists();
  }

  @override
  Widget build(BuildContext context) {
    print('${userDataLoading},${userExistsLoading}');
    if (userDataLoading || userExistsLoading) {
      return CircularProgressIndicator();
    } else {
      if (!usernotexists) {
        return MaterialApp(
          home: SafeArea(
            child: Scaffold(
              drawer: Drawer(child: Column(children: [
                ElevatedButton(onPressed: (){
                  Navigator.pushNamed(context, '/logout');
                }, child: Text('Logout')),
                ElevatedButton(onPressed: (){
                  Navigator.pushNamed(context, '/delete');
                }, child: Text('Delete'))
          
              ],)),
              body: Center(
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(child: Image.network(userimage)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Username:- ' + username,
                                style:
                                    TextStyle(color: Colors.black, fontSize: 20)),
                            Text('Usermail:- ' + usermail,
                                style:
                                    TextStyle(color: Colors.black, fontSize: 20)),
                            Text('Age:- ' + age,
                                style:
                                    TextStyle(color: Colors.black, fontSize: 20)),
                            Text('Phonenumber:- ' + phonenumber,
                                style:
                                    TextStyle(color: Colors.black, fontSize: 20)),
                            Text('Address:- ' + address,
                                style:
                                    TextStyle(color: Colors.black, fontSize: 20)),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.all(30),
                          width: 400,
                          height: 50,
                          child: TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Address',
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            }),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(30),
                          width: 400,
                          height: 50,
                          child: TextFormField(
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Phone Number',
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                            validator: ((value) {
                              if (value == null ||
                                  value.length < 10 ||
                                  value.length > 10 ||
                                  !value.contains(RegExp(r'[0-9]'))) {
                                return 'Please enter valid phone number';
                              }
                              return null;
                            }),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(30),
                          width: 400,
                          height: 50,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Age',
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 30),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(13),
                            ),
                            child: DropdownButton(
                              value: dropdownvalue,
                              isDense: true,
                              isExpanded: true,
                              elevation: 8,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  dropdownvalue = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final User? user = auth.currentUser;
                                  final uid = user?.uid;
                                  FirebaseFirestore.instance
                                      .collection('usersData')
                                      .doc(uid)
                                      .set({
                                    "username": user?.displayName,
                                    "usermail": user?.email,
                                    "userid": uid,
                                    "address": addressController.text,
                                    "phonenumber": phoneNumberController.text,
                                    "age": dropdownvalue
                                  });
                                  snapshot();
                                }
                              },
                              child: Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                        )
                      ],
                    )),
              ),
              appBar: AppBar(
                title: Text('Welcome'),
                centerTitle: true,
              ),
            ),
          ),
        );
      } else {
        return MaterialApp(
          home: Scaffold(
            drawer: Drawer(),
            body: Center(
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(child: Image.network(userimage)),
                      ),
                      Text(userdname,
                          style: TextStyle(color: Colors.black, fontSize: 30)),
                      Container(
                        margin: EdgeInsets.all(30),
                        width: 400,
                        height: 50,
                        child: TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Address',
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 30),
                          ),
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          }),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(30),
                        width: 400,
                        height: 50,
                        child: TextFormField(
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number',
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 30),
                          ),
                          validator: ((value) {
                            if (value == null ||
                                value.length < 10 ||
                                value.length > 10 ||
                                !value.contains(RegExp(r'[0-9]'))) {
                              return 'Please enter valid phone number';
                            }
                            return null;
                          }),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(30),
                        width: 400,
                        height: 50,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 30),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(13),
                          ),
                          child: DropdownButton(
                            value: dropdownvalue,
                            isDense: true,
                            isExpanded: true,
                            elevation: 8,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                dropdownvalue = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final User? user = auth.currentUser;
                                final uid = user?.uid;
                                FirebaseFirestore.instance
                                    .collection('usersData')
                                    .doc(uid)
                                    .set({
                                  "username": user?.displayName,
                                  "usermail": user?.email,
                                  "userid": uid,
                                  "address": addressController.text,
                                  "phonenumber": phoneNumberController.text,
                                  "age": dropdownvalue
                                });
                                snapshot();
                                setState(() {
                                  usernotexists = false;
                                });
                              }
                            },
                            child: Text('Submit')),
                      )
                    ],
                  )),
            ),
            appBar: AppBar(
              title: Text('Welcome'),
              centerTitle: true,
            ),
          ),
        );
      }
    }
  }
}
