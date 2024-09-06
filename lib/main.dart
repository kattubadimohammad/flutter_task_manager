import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _sendDeviceInfo();
  }

  Future<void> _sendDeviceInfo() async {
    final response = await http.post(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/device/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "deviceType": "android",
        "deviceId": "C6179909526098",
        "deviceName": "Samsung-MT200",
        "deviceOSVersion": "2.3.6",
        "deviceIPAddress": "11.433.445.66",
        "lat": 9.9312,
        "long": 76.2673,
        "buyer_gcmid": "",
        "buyer_pemid": "",
        "app": {
          "version": "1.20.5",
          "installTimeStamp": "2022-02-10T12:33:30.696Z",
          "uninstallTimeStamp": "2022-02-10T12:33:30.696Z",
          "downloadTimeStamp": "2022-02-10T12:33:30.696Z"
        }
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(deviceId: responseData['data']['deviceId'])),
        );
      } else {
        // Handle error
        print('Failed to add device: ${responseData['data']['message']}');
      }
    } else {
      // Handle server error
      print('Failed to send device info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String deviceId;
  LoginScreen({required this.deviceId});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();

  Future<void> _requestOtp() async {
    final response = await http.post(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "mobileNumber": _mobileController.text,
        "deviceId": widget.deviceId,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen(deviceId: widget.deviceId)),
      );
    } else {
      // Handle error
      print('Failed to request OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _mobileController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestOtp,
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String deviceId;
  OtpScreen({required this.deviceId});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final String _userId = '62b43547c84bb6dac82e0525';

  Future<void> _verifyOtp() async {
    final response = await http.post(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/otp/verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "otp": _otpController.text,
        "deviceId": widget.deviceId,
        "userId": _userId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Handle error
        print('Failed to verify OTP');
      }
    } else {
      // Handle server error
      print('Failed to verify OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/products'),
    );

    if (response.statusCode == 200) {
      final products = jsonDecode(response.body);
      // Handle products data
      print(products);
    } else {
      // Handle error
      print('Failed to fetch products');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
