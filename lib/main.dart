import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ble_test_provider/pages/home_page.dart';
import 'package:ble_test_provider/provider/ble_provider.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (contex)=> Bleprovider())
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ble test',
      initialRoute: 'home',
      routes: {
        'home': (context) => const HomePage()
      },
    ),
    );
  }
}