// ignore_for_file: sort_child_properties_last

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'api_service.dart';
import 'config.dart';

class OTPVerifyPage extends StatefulWidget {
  final String? mobileNo;
  final String? otpHash;

  const OTPVerifyPage({super.key, this.mobileNo, this.otpHash});

  @override
  // ignore: library_private_types_in_public_api
  _OTPVerifyPageState createState() => _OTPVerifyPageState();
}

class _OTPVerifyPageState extends State<OTPVerifyPage> {
  bool enableResendBtn = false;
  String _otpCode = "";
  bool hasError = false;
  bool _enableButton = false;
  bool isAPIcallProcess = false;
  StreamController<ErrorAnimationType>? errorController;
  TextEditingController textEditingController = TextEditingController();
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ProgressHUD(
          child: otpVerify(),
          inAsyncCall: isAPIcallProcess,
          opacity: 0.3,
          key: UniqueKey(),
        ),
      ),
    );
  }

  Widget otpVerify() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          "https://i.imgur.com/6aiRpKT.png",
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Phone Number Verification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
          child: RichText(
            text: TextSpan(
                text: "Enter the code sent to ",
                children: [
                  TextSpan(
                      text: "${widget.mobileNo}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
                style: const TextStyle(color: Colors.black54, fontSize: 15)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
            child: PinCodeTextField(
              appContext: context,
              pastedTextStyle: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              length: 6,
              obscureText: true,
              obscuringCharacter: '*',
              obscuringWidget: const FlutterLogo(
                size: 24,
              ),
              blinkWhenObscuring: true,
              animationType: AnimationType.fade,
              validator: (v) {
                if (v!.length < 3) {
                  return "I'm from validator";
                } else {
                  return null;
                }
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              cursorColor: Colors.black,
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              errorAnimationController: errorController,
              controller: textEditingController,
              keyboardType: TextInputType.number,
              boxShadows: const [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Colors.black12,
                  blurRadius: 10,
                )
              ],
              onCompleted: (v) {
                debugPrint("Completed");
              },
              // onTap: () {
              //   print("Pressed");
              // },
              onChanged: (value) {
                if (value.length == 6) {
                  _otpCode = value;
                  _enableButton = true;
                }
              },
              beforeTextPaste: (text) {
                debugPrint("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            hasError ? "*Please fill up all the cells properly" : "",
            style: const TextStyle(
                color: Colors.red, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive the code? ",
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            TextButton(
              onPressed: () => snackBar("OTP resend!!"),
              child: const Text(
                "RESEND",
                style: TextStyle(
                    color: Color(0xFF91D3B3),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 14,
        ),
        const SizedBox(height: 20),
        Center(
          child: FormHelper.submitButton(
            "Continue",
            () {
              if (_enableButton) {
                setState(() {
                  isAPIcallProcess = true;
                });

                APIService.verifyOtp(
                        widget.mobileNo!, widget.otpHash!, _otpCode)
                    .then((response) {
                  setState(() {
                    isAPIcallProcess = false;
                  });

                  if (response.data != null) {
                    //REDIRECT TO HOME SCREEN
                    FormHelper.showSimpleAlertDialog(
                      context,
                      Config.appName,
                      response.message,
                      "OK",
                      () {
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    FormHelper.showSimpleAlertDialog(
                      context,
                      Config.appName,
                      response.message,
                      "OK",
                      () {
                        Navigator.pop(context);
                      },
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
      ],
    );
  }
}
