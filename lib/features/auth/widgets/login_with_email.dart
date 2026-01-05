import 'package:flutter/material.dart';

class LoginWithEmail extends StatelessWidget {
  const LoginWithEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email로 로그인')),
      body: Column(
        children: [
          Text('Email로 로그인'),
          TextField(decoration: InputDecoration(labelText: 'Email')),
          TextField(decoration: InputDecoration(labelText: 'Password')),
          ElevatedButton(onPressed: () {}, child: Text('로그인')),
        ],
      ),
    );
  }
}
