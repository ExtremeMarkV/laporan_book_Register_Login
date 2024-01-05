import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laporan_book/firebase_options.dart';
import 'package:laporan_book/pages/AddFormPage.dart';
import 'package:laporan_book/pages/DetailPage.dart';
import 'package:laporan_book/pages/LoginPage.dart';
import 'package:laporan_book/pages/RegisterPage.dart';
import 'package:laporan_book/pages/SplashPage.dart';
import 'package:laporan_book/pages/dashboard/DashboardPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MaterialApp(
    title: 'Lapor Book',
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => AddFormPage(),
      '/detail': (context) => DetailPage(),
    },
  ));
  
}
