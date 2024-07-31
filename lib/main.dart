import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(StroopApp()); // Inicializa la aplicación
}

class StroopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stroop Test', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema de la aplicación
      ),
      debugShowCheckedModeBanner: false, // Oculta la bandera de modo debug
      home: HomeScreen(), // Pantalla inicial de la aplicación
    );
  }
}

class HighScore {
  final String name;
  final int score;

  HighScore(this.name, this.score); // Constructor para la clase HighScore
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() =>
      _HomeScreenState(); // Crea el estado para HomeScreen
}

class _HomeScreenState extends State<HomeScreen> {
  List<HighScore> highScores = []; // Lista de puntajes altos
  int maxFailures = 3; // Número máximo de fallos por defecto
  int wordChangeTime =
      2; // Tiempo de cambio de palabras en segundos por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stroop Test'), // Título en la barra de la aplicación
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra los elementos en la columna
          children: <Widget>[
            Image.asset("assets/img/logocolor.jpeg",
                width: 100, height: 100), // Imagen con un tamaño específico
            SizedBox(height: 20), // Espacio entre la imagen y el botón
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      onGameEnd: (score) => addHighScore(context, score),
                      maxFailures: maxFailures,
                      wordChangeTime: wordChangeTime,
                    ),
                  ),
                );
              },
              child: Text('Iniciar Juego'), // Texto del botón
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HighScoresScreen(
                      highScores: highScores,
                    ),
                  ),
                );
              },
              child: Text('Ver Puntajes Altos'), // Texto del botón
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfigScreen(
                      maxFailures: maxFailures,
                      wordChangeTime: wordChangeTime,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    maxFailures = result['maxFailures'];
                    wordChangeTime = result['wordChangeTime'];
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        onGameEnd: (score) => addHighScore(context, score),
                        maxFailures: maxFailures,
                        wordChangeTime: wordChangeTime,
                      ),
                    ),
                  );
                }
              },
              child: Text('Configuración'), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }

  void addHighScore(BuildContext context, int score) {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        return AlertDialog(
          title: Text('Guardar Puntaje'), // Título del diálogo
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del contenido
            children: <Widget>[
              Text('Palabras correctas: $score'), // Muestra el puntaje
              TextField(
                onChanged: (value) {
                  name = value; // Actualiza el nombre ingresado
                },
                decoration: InputDecoration(
                    hintText: 'Ingresa tu nombre'), // Pista para el TextField
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Guardar'), // Texto del botón
              onPressed: () {
                setState(() {
                  highScores.add(
                      HighScore(name, score)); // Añade el puntaje a la lista
                  highScores.sort((a, b) => b.score
                      .compareTo(a.score)); // Ordena la lista de puntajes
                });
                Navigator.of(context).popUntil((route) =>
                    route.isFirst); // Cierra el diálogo y vuelve al inicio
              },
            ),
          ],
        );
      },
    );
  }
}

class ConfigScreen extends StatefulWidget {
  final int maxFailures;
  final int wordChangeTime;

  ConfigScreen({required this.maxFailures, required this.wordChangeTime});

  @override
  _ConfigScreenState createState() =>
      _ConfigScreenState(); // Crea el estado para ConfigScreen
}

class _ConfigScreenState extends State<ConfigScreen> {
  late int _maxFailures;
  late int _wordChangeTime;

  @override
  void initState() {
    super.initState();
    _maxFailures = widget.maxFailures; // Inicializa _maxFailures
    _wordChangeTime = widget.wordChangeTime; // Inicializa _wordChangeTime
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'), // Título en la barra de la aplicación
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Número máximo de fallos'), // Texto de instrucción
            Slider(
              value: _maxFailures.toDouble(), // Valor actual del deslizador
              min: 1,
              max: 10,
              divisions: 9,
              label: _maxFailures.toString(), // Etiqueta del valor actual
              onChanged: (value) {
                setState(() {
                  _maxFailures =
                      value.toInt(); // Actualiza el valor del deslizador
                });
              },
            ),
            Text(
                'Tiempo de cambio de palabras (segundos)'), // Texto de instrucción
            Slider(
              value: _wordChangeTime.toDouble(), // Valor actual del deslizador
              min: 1,
              max: 10,
              divisions: 9,
              label: _wordChangeTime.toString(), // Etiqueta del valor actual
              onChanged: (value) {
                setState(() {
                  _wordChangeTime =
                      value.toInt(); // Actualiza el valor del deslizador
                });
              },
            ),
            Text(
                'Tiempo restante: $_wordChangeTime segundos'), // Muestra el tiempo restante
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'maxFailures': _maxFailures,
                  'wordChangeTime': _wordChangeTime,
                });
              },
              child: Text('Guardar y Jugar'), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final Function(int) onGameEnd;
  final int maxFailures;
  final int wordChangeTime;

  GameScreen({
    required this.onGameEnd,
    required this.maxFailures,
    required this.wordChangeTime,
  });

  @override
  _GameScreenState createState() =>
      _GameScreenState(); // Crea el estado para GameScreen
}

class _GameScreenState extends State<GameScreen> {
  final List<String> colors = [
    'amarillo',
    'rojo',
    'verde',
    'azul'
  ]; // Lista de colores
  final Random random = Random(); // Generador de números aleatorios
  String currentWord = '';
  Color currentColor = Colors.black; // Inicialización por defecto
  int score = 0;
  int totalWords = 0;
  int incorrectAttempts = 0; // Para contar los fallos
  int pauseCount = 0; // Para contar las pausas
  Timer? _timer;
  bool isPaused = false;
  List<String> shuffledColors = []; // Lista de colores barajada
  int timeRemaining = 0; // Tiempo restante

  @override
  void initState() {
    super.initState();
    shuffledColors = List.from(colors)..shuffle(); // Baraja los colores
    Future.delayed(
        Duration.zero, startCountdown); // Utilizar Future.delayed aquí
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    int countdown = 3;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(Duration(seconds: 1), () {
              if (countdown > 1) {
                setState(() {
                  countdown--;
                });
              } else {
                Navigator.of(context).pop();
                nextWord(); // Comienza el juego
              }
            });
            return AlertDialog(
              title: Text('Preparado...'), // Título del diálogo
              content: Text('$countdown'), // Muestra la cuenta regresiva
            );
          },
        );
      },
    );
  }

  void nextWord() {
    if (incorrectAttempts < widget.maxFailures) {
      setState(() {
        currentWord =
            colors[random.nextInt(colors.length)]; // Palabra aleatoria
        currentColor = getRandomColor(); // Color aleatorio
        totalWords++;
        shuffledColors.shuffle(); // Barajar los colores
        timeRemaining = widget.wordChangeTime; // Reiniciar tiempo restante
      });

      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          timeRemaining--; // Decrementa el tiempo restante
        });

        if (timeRemaining <= 0) {
          setState(() {
            incorrectAttempts++; // Incrementa los fallos
            if (incorrectAttempts >= widget.maxFailures) {
              widget.onGameEnd(score); // Termina el juego
              _timer?.cancel();
            } else {
              nextWord(); // Pasa a la siguiente palabra
            }
          });
        }
      });
    } else {
      widget.onGameEnd(score); // Termina el juego
    }
  }

  void pauseGame() {
    if (pauseCount < 2) {
      setState(() {
        isPaused = true;
        pauseCount++;
      });
      _timer?.cancel();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Juego Pausado'), // Título del diálogo
            content: Text(
                'Presiona continuar para seguir jugando'), // Texto del diálogo
            actions: <Widget>[
              TextButton(
                child: Text('Continuar'), // Texto del botón
                onPressed: () {
                  setState(() {
                    isPaused = false;
                  });
                  Navigator.of(context).pop();
                  nextWord(); // Continua el juego
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'No puedes pausar más de dos veces')), // Mensaje de snack bar
      );
    }
  }

  Color getRandomColor() {
    switch (colors[random.nextInt(colors.length)]) {
      case 'amarillo':
        return Colors.yellow;
      case 'rojo':
        return Colors.red;
      case 'verde':
        return Colors.green;
      case 'azul':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  void selectColor(Color color) {
    if (!isPaused) {
      if (color == currentColor) {
        setState(() {
          score++;
        });
      } else {
        setState(() {
          incorrectAttempts++;
        });
      }

      if (incorrectAttempts >= widget.maxFailures) {
        widget.onGameEnd(score);
        _timer?.cancel();
      } else {
        nextWord();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego Stroop'), // Título en la barra de la aplicación
        actions: [
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: pauseGame, // Botón para pausar el juego
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centra los elementos en la columna
        children: <Widget>[
          Text(
            currentWord,
            style: TextStyle(
                fontSize: 40,
                color:
                    currentColor), // Muestra la palabra con el color correspondiente
          ),
          SizedBox(height: 20),
          Text('Fallos: $incorrectAttempts'), // Muestra el número de fallos
          SizedBox(height: 20),
          Text(
              'Tiempo restante: $timeRemaining segundos'), // Muestra el tiempo restante
          SizedBox(height: 20),
          Text(
              'Palabras correctas: $score'), // Muestra el número de palabras correctas
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, // Espacia uniformemente los botones
            children: shuffledColors.map((color) {
              return GestureDetector(
                onTap: () {
                  selectColor(getColorFromString(
                      color)); // Maneja la selección de color
                },
                child: Container(
                  color: getColorFromString(color), // Color del contenedor
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    color.toUpperCase(),
                    style: TextStyle(color: Colors.white), // Texto del color
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color getColorFromString(String color) {
    switch (color) {
      case 'amarillo':
        return Colors.yellow;
      case 'rojo':
        return Colors.red;
      case 'verde':
        return Colors.green;
      case 'azul':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}

class HighScoresScreen extends StatelessWidget {
  final List<HighScore> highScores;

  HighScoresScreen({required this.highScores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puntajes Altos'), // Título en la barra de la aplicación
      ),
      body: ListView.builder(
        itemCount: highScores.length, // Número de elementos en la lista
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(highScores[index].name), // Nombre del jugador
            trailing:
                Text(highScores[index].score.toString()), // Puntaje del jugador
          );
        },
      ),
    );
  }
}
