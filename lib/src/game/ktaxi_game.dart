import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'dart:ui' as ui;

class CarGame extends Game {
// nuevo modo de juego, un delivery que recoje cajas, obstaculos son bombas, si toca explota o algo asi
  int _best;
  double medidaXGame; //tamaño canva x
  double medidaYGame; //tamaño canva y

  //recibe tamaño X y Y con relación aspecto 2:1 o 400x200 o 400x(400/2) = 400x200 o 300x150 etc
  @override
  CarGame(double this.medidaXGame, double this.medidaYGame, this._best) {}

  bool debug = false; // ver datos variable en el juego

  ////////////////////////////////////////
  //Variables del juego

  // porcentaje de tamaño de objetos en el juego; 22%
  double tamObjPorcent = 22 / 100;

  //Dimensiones del obtejos como carro, obstaculos, texto
  double get medidasObjtWidth => medidaXGame * tamObjPorcent;
  double get medidasObjtHeight => medidasObjtWidth * 0.625;
  // distancia de carro desde el borde izquierdo
  static const double lanePadding = 10.0;
  //bandera para carriles; true = carril arriba, false = carril abajo
  bool _isTopLane = true;
  //Incremento de velocidad para obstáculos y fondo
  double _speedIncrement = 50.0;
  //Tiempo va de 0 hasta el incremento actual
  double _timeSinceLastSpeedIncrement = 0.0;
  //Tiempo hasta el próximo incremento de velocidad
  double _timeUntilSpeedIncrement = 5.0;
  //iniciar segundos de incrementos de velocidad
  double secIncrement = 7.0;

  ////////////////////////////////
  //No modificar estas variables
  //velocidad
  double speed = 200.0;
  //Puntuación del jugador
  int _score = 0;
  //Temporizador para la duración del juego
  double _timer = 0.0;
  //Inicializar variables
  double _obstacleSpawnTimer = 0.0;
  //Posición vertical del auto inicial
  double _carY = lanePadding;
  //Bandera que indica si el juego está pausado
  bool _isPaused = true;
  //posicion inicial del fondo
  double _backgroundX = 0.0;
  ui.Image? _carImage;
  ui.Image? _backgroundImage;

  List<Obstacle> _obstacles = [];
  List<ui.Image?> _obstacleImages = [];
  Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
  ////////////////////////////////


  void _startGame() {
    _isPaused = false;
    _resetGame();
  }

  void _resetGame() {
    _obstacles.clear();
    _score = 0;
    _timer = 0.0;
    _obstacleSpawnTimer = 0.0;
    _carY = lanePadding;
    speed = 200.0; // velocidad inicial
    secIncrement = 7.0; // segundos de espera para nuevo incremento
    _isTopLane = true;
    _timeSinceLastSpeedIncrement = 0.0;
    _spawnObstacle();
  }

  //best score comprobar
  void updateBestScore() {
    if (_score > _best) {
      _best = _score;
     /*
     agregar logica para guardar en variable global del usuario de su bestscore
     */
    }
  }

  // carga de imagenes
  @override
  Future<void> onLoad() async {
    _carImage = await _loadImage('assets/images/game/carro.png');
    _backgroundImage = await _loadImage('assets/images/game/carretera.png');
    //5 imagenes de obstaculos desde obst1.png a obst5.png
    for (int i = 1; i <= 5; i++) {
      final obstacleImage = await _loadImage('assets/images/game/obst$i.png');
      _obstacleImages.add(obstacleImage);
    }
  }

  @override
  void render(Canvas canvas) {

    //Aplica el recorte para que no se vean fuera los objetos
    canvas.clipRect(Rect.fromLTWH(0, 0, medidaXGame, medidaYGame));

    //Renderizado de fondo #1
      canvas.drawImageRect(
        _backgroundImage!,
        Rect.fromLTWH(_backgroundX, 0, _backgroundImage!.width.toDouble(),
            _backgroundImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, medidaXGame, medidaYGame),
        Paint(),
      );

    ////Renderizado de fondo #2, es la misma que 1 y no deja ver el fondo negro, sino un fondo infinito en loop
      canvas.drawImageRect(
        _backgroundImage!,
        Rect.fromLTWH(
            _backgroundX - _backgroundImage!.width.toDouble(),
            0,
            _backgroundImage!.width.toDouble(),
            _backgroundImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, medidaXGame, medidaYGame),
        Paint(),
      );

      //renderizando de carro
      final carImageWidth = _carImage!.width.toDouble();
      final carImageHeight = _carImage!.height.toDouble();
      final srcRect = Rect.fromLTWH(0, 0, carImageWidth, carImageHeight);
      final dstRect = Rect.fromLTWH(
        lanePadding,
        _carY,
        medidasObjtWidth,
        medidasObjtHeight,
      );

      canvas.drawImageRect(
        _carImage!,
        srcRect,
        dstRect,
        Paint(),
      );


      //renderizado de los obstaculos en orden random
    _obstacles.forEach((obstacle) {
      final obstacleImageWidth =
          _obstacleImages[obstacle.type]!.width.toDouble();
      final obstacleImageHeight =
          _obstacleImages[obstacle.type]!.height.toDouble();

      final srcRect =
          Rect.fromLTWH(0, 0, obstacleImageWidth, obstacleImageHeight);
      final dstRect = Rect.fromLTWH(
          obstacle.x, obstacle.y, obstacle.width, obstacle.height);

      canvas.drawImageRect(
        _obstacleImages[obstacle.type]!,
        srcRect,
        dstRect,
        Paint(),
      );
    });

    //render de textos
    final textScreen = TextPainter(
      text: TextSpan(
        text: 'Score: $_score\n'
            'Best: $_best',
        style: TextStyle(fontSize: medidaXGame *0.04, color: Colors.white),
      ),
      textDirection: TextDirection.rtl,
    );

    textScreen.layout();
    textScreen.paint(canvas, Offset(medidaXGame *0.98 - textScreen.width , medidaYGame *0.04  ));

    //render de textos de las variables, cambiar debug a true para ver
    if (debug == true) {
      String textVars =  'Time: ${_timer.toStringAsFixed(1)}\n' +
          'Increment: ${_timeUntilSpeedIncrement.toStringAsFixed(1)} s\n' +
          'IncrementLast: ${_timeSinceLastSpeedIncrement.toStringAsFixed(1)}\n' +
          'Current speed: $speed\n' +
          'Pause: $_isPaused\n' +
          '_isTopLane: $_isTopLane\n' +
          'secIncrement: $secIncrement\n';

      final textScreen = TextPainter(
        text: TextSpan(
          text: textVars,
          style: TextStyle(fontSize: medidaXGame *0.02, color: Colors.white),
        ),
        textDirection: TextDirection.rtl,
      );

      textScreen.layout();
      textScreen.paint(canvas, Offset(medidaXGame *0.98 - textScreen.width , medidaYGame *0.23  ));

    }
    //se muestra texto cuando esta en pausa
    if (_isPaused) {
      final pausedText = TextPainter(
        text: TextSpan(
          text: 'Toca para empezar',
          style: TextStyle(fontSize: medidaXGame * 0.05, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );

      pausedText.layout();
      pausedText.paint(canvas, Offset(medidaXGame / 2 - pausedText.width / 2, medidaYGame / 2));
    }
  }

  //resibe el gesto desde la pagina
  void onTapDown(TapDownDetails details) {
    if (_isPaused) {
      _startGame();
    } else {
      _changeLane();
    }
  }

  void _checkCollisions() {
    final carRect = Rect.fromLTWH(
      lanePadding,
      _carY,
      medidasObjtWidth,
      medidasObjtHeight,
    );

    for (final obstacle in _obstacles) {
      final obstacleRect = Rect.fromLTWH(
        obstacle.x,
        obstacle.y,
        obstacle.width,
        obstacle.height,
      );

      if (carRect.overlaps(obstacleRect)) {
        _isPaused = true;
        return;
      }

      if (_isTopLane) {
        final distanceX = (obstacle.x - carRect.right).abs();
        final distanceY = (obstacle.y + obstacle.height - _carY).abs();
        if (distanceX <= -10.0 && distanceY <= medidasObjtHeight) {
          _isPaused = true;
          return;
        }
      } else {
        final distanceX = (obstacle.x - carRect.right).abs();
        final distanceY = (obstacle.y - _carY).abs();
        if (distanceX <= -10.0 && distanceY <= medidasObjtHeight) {
          _isPaused = true;
          return;
        }
      }
    }
  }

  //cambio de carril
  void _changeLane() {
    _isTopLane = !_isTopLane;

    if (_isTopLane) {
      _targetCarY = lanePadding;
    } else {
      _targetCarY = medidaYGame - medidasObjtHeight - lanePadding;
    }
  }


  void _increaseScore() {
    _score++;
  }

  // no recuerdo para que era pero trata sobre el movimiento
  double _targetCarY = 10;

  int speedChangeLane = 7;// 1 es muy lento 10 muy rapido
  @override
  void update(double dt) {
    if (_isPaused) {
      return;
    }
    final double backgroundSpeed = speed * dt;
    _backgroundX += backgroundSpeed;

    //reiniciar posision fondo si llega al borde
    if (_backgroundX >= _backgroundImage!.width.toDouble()) {
      _backgroundX = 0.0;
    }

    // Interpola la posición actual del carro hacia _targetCarY
    _carY = lerpDouble(_carY, _targetCarY, speedChangeLane * dt)!;

    _timer += dt;
    _obstacleSpawnTimer += dt;
    _timeSinceLastSpeedIncrement += dt;

    if (_timeSinceLastSpeedIncrement >= secIncrement) {
      _increaseSpeedAndSpawnTime();
      _timeSinceLastSpeedIncrement = 0.0;
      secIncrement = secIncrement + 2;
      _timeUntilSpeedIncrement = secIncrement;
    } else {
      _timeUntilSpeedIncrement = secIncrement - _timeSinceLastSpeedIncrement;
    }

    if (_obstacleSpawnTimer >= 2.0) {
      _spawnObstacle();
      _obstacleSpawnTimer = 0.0;
    }

    final List<Obstacle> obstaclesCopy = List.from(_obstacles);

    obstaclesCopy.forEach((obstacle) {
      obstacle.x -= obstacle.speed * dt;

      if (obstacle.x + obstacle.width < 0) {
        _obstacles.remove(obstacle);
        _increaseScore();
      }
    });

    _checkCollisions();
    updateBestScore(); //cambia el best score si paso su best

  }


  void _increaseSpeedAndSpawnTime() {
    _obstacles.forEach((obstacle) {
      obstacle.speed += _speedIncrement;
    });
    speed += _speedIncrement;
  }


  void _spawnObstacle() {
    final random = Random();

    final obstacleType = random.nextInt(5);

    final obstacle = Obstacle(
      x: medidaXGame,
      y: random.nextBool()
          ? lanePadding
          : medidaYGame - medidasObjtHeight - lanePadding,
      width: medidasObjtWidth,
      height: medidasObjtHeight,
      speed: speed,
      type: obstacleType,
    );

    _obstacles.add(obstacle);
  }
}

class Obstacle {
  double x;
  double y;
  double width;
  double height;
  double speed;
  int type;

  Obstacle(
      {required this.x,
      required this.y,
      required this.width,
      required this.height,
      required this.speed,
      required this.type});
}
