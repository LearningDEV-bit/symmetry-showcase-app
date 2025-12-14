import 'package:flutter/material.dart';
import 'google_sign_in_button.dart';

class LoginGoogleView extends StatelessWidget {
  const LoginGoogleView({
    super.key,
    required this.onLogin,
  });

  final Future<void> Function() onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: GoogleSignInButton(
          onPressed: () async {
            try {
              await onLogin();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        ),
      ),
    );
  }
}
