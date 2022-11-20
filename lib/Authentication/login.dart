// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'api_service.dart';
import 'otp_verify.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAPIcallprocess = false;
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> globalformkey = GlobalKey<FormState>();
  String? mobilenumber;
  bool enableBtn = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: ProgressHUD(
          inAsyncCall: isAPIcallprocess,
          opacity: 0.3,
          key: UniqueKey(),
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color.fromARGB(255, 111, 164, 68),
                    Color.fromARGB(255, 159, 217, 201)
                  ])),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 150,
                    margin: const EdgeInsets.all(50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/logo.jpeg.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Text("YantrAadi",
                          style: TextStyle(
                              color: Color.fromARGB(255, 22, 12, 12),
                              fontSize: 35)),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Form(
                    key: globalformkey,
                    child: Column(children: [
                      TextFormField(
                        maxLines: 1,
                        maxLength: 10,
                        decoration: InputDecoration(
                            hintText: 'Mobile Number',
                            icon: new Icon(Icons.call, color: Colors.white),
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                            )),
                        keyboardType: TextInputType.number,
                        onChanged: (String value) {
                          if (value.length > 8) {
                            mobilenumber = value;
                            enableBtn = true;
                          }
                        },
                        validator: (value) {
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: FormHelper.submitButton(
                          "Continue",
                          () async {
                            if (enableBtn) {
                              setState(() {
                                isAPIcallprocess = true;
                              });

                              APIService.otpLogin(mobilenumber!)
                                  .then((response) async {
                                setState(() {
                                  isAPIcallprocess = false;
                                });

                                if (response.data != null) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OTPVerifyPage(
                                        otpHash: response.data,
                                        mobileNo: mobilenumber,
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                }
                              });
                            }
                          },
                          btnColor: HexColor("#78D0B1"),
                          borderColor: HexColor("#78D0B1"),
                          txtColor: HexColor(
                            "#000000",
                          ),
                          borderRadius: 20,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                new Color.fromRGBO(220, 60, 104, 1),
                            shadowColor: new Color.fromRGBO(137, 45, 255, 1),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            minimumSize: Size(120, 60)),
                        child: Text(
                          'Send OTP',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (globalformkey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Data')),
                            );
                          }
                        },
                      ),
                    ]),
                  ),
                ],
              ))),
    ));
  }
}
