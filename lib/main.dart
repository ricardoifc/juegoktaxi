import 'package:flutter/material.dart';
import 'package:juegoktaxi/src/pages/ktaxi/ktaxi_page.dart';
import 'package:juegoktaxi/src/pages/myhome/myhome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: MyHomePage.PAGE_ROUTE,
      routes: routesGame,
    );
  }
}
final routesGame = <String, WidgetBuilder>{
  MyHomePage.PAGE_ROUTE: (BuildContext context) => MyHomePage(),
  KTaxiPage.PAGE_ROUTE: (BuildContext context) => KTaxiPage(),
};

