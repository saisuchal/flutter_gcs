import 'package:flutter/material.dart';
import 'package:flutter_gcs/features/home/home_screen.dart';
import 'package:flutter_gcs/welcome_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return ProviderScope(
      child: MaterialApp(
        title:'Flutter GCS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        iconTheme: const IconThemeData(size: 24),
        fontFamily: 'MaterialIcons', // <- force MaterialIcons
      ),
        home: WelcomeScreen(),
      )
    );
  }
}