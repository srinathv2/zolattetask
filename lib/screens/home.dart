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
  var username, userdname, address, age, phonenumber, usermail, tapIndex = 0;
  var userimage;
  var userDataLoading = true, userExistsLoading = true;
  late bool usernotexists;

  snapshot() async {
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
    setState(() {
      userExistsLoading = true;
    });
    try {
      final User? user = auth.currentUser;

      await FirebaseFirestore.instance
          .collection('usersData')
          .doc(user?.uid)
          .get()
          .then((value) {
        setState(() {
          usernotexists = value.data()!.isEmpty;
          userExistsLoading = false;
        });
      });
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
    if (userDataLoading || userExistsLoading) {
      return SizedBox(
          child: Center(child: CircularProgressIndicator()),
          width: 100,
          height: 100);
    } else {
      if (!usernotexists) {
        return MaterialApp(
          home: SafeArea(
            child: Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.logout), label: 'Logout'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.delete), label: 'Delete Account')
                ],
                showUnselectedLabels: true,
                backgroundColor: Colors.black,
                unselectedItemColor: Colors.white,
                currentIndex: tapIndex,
                onTap: (value) {
                  if (value == 0) {
                    Navigator.pushNamed(context, '/logout');
                  } else if (value == 1) {
                    Navigator.pushNamed(context, '/delete');
                  }
                  setState(() {
                    tapIndex = value;
                  });
                },
              ),
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
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Username:- ' + username,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Usermail:- ' + usermail,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Age:- ' + age,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Phonenumber:- ' + phonenumber,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Address:- ' + address,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ],
                          ),
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
                            // validator: ((value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter some text';
                            //   }
                            //   return null;
                            // }),
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
                              if (value == '') {
                                return null;
                              } else if (!RegExp(r'^(?:[+0]9)?[0-9]{10,12}$')
                                  .hasMatch(value!)) {
                                return 'Please enter valid phone number';
                              }
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
                                    "address": addressController.text == ''
                                        ? address
                                        : addressController.text,
                                    "phonenumber":
                                        phoneNumberController.text == ''
                                            ? phonenumber
                                            : phoneNumberController.text,
                                    "age": dropdownvalue ?? age
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
                            if (value == '') {
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
                            if (value == '' ||
                                !RegExp(r'^(?:[+0]9)?[0-9]{10,12}$')
                                    .hasMatch(value!)) {
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
        );
      }
    }
  }
}
