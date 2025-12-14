import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:news_app_clean_architecture/core/services/auth_service.dart';
import 'widgets/login_google_view.dart';
import 'widgets/profile_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return LoginGoogleView(
            onLogin: auth.signInWithGoogle,
          );
        }

        return ProfileView(
          user: user,
          onLogout: auth.signOut,
        );
      },
    );
  }
}
