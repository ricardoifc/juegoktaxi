import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../game/ktaxi_game.dart';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class KTaxiPage extends StatefulWidget {
  static const PAGE_ROUTE = "ktaxipageroutegame";

  @override
  State<KTaxiPage> createState() => _KTaxiPageState();
}

class _KTaxiPageState extends State<KTaxiPage> {
  GoogleMapController? _mapController;
  LatLng _initialCameraPosition = const LatLng(-4.008723, -79.206341);

  @override
  Widget build(BuildContext context) {
    double medidaX = MediaQuery.of(context).size.width * 0.6;
    int bestScore = 5; //Variable global guardada de el usuario
    final CarGame game = CarGame(medidaX, calculateHeight(medidaX), bestScore);
    return Scaffold(
      body: Stack(
        children: [
          /*GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialCameraPosition, zoom: 15),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),*/
          Container(
            color: Colors.lightBlueAccent,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                color: Colors.white,
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Text(
                        'Espere su taxi...',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: medidaX,
                        height: calculateHeight(medidaX),
                        child: GestureDetector(
                          onTapDown: (details) {
                            game.onTapDown(details);
                          },
                          child: GameWidget(
                            game: game,
                          ),
                        ),

                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 25,
            left: 16,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back), // Usar Icon en lugar de Icons
            ),
          ),
        ],
      ),
    );
  }
}

double calculateHeight(double width) {
  //relacion de aspecto 2:1
  return width / 2;
}

