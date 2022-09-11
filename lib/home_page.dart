import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_game/blank_pixel.dart';
import 'package:flutter_snake_game/food_pixel.dart';
import 'package:flutter_snake_game/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SnakeDirection { up, down, left, right }

class _HomePageState extends State<HomePage> {
  // gridDelegate
  int rowSize = 10;
  int numberOfSquares = 100;

  // snake position
  List<int> snakePositions = [0, 1, 2];

  // food position
  int foodPositions = 17;

  // pause game state
  bool pause = false;

  bool gameRunning = false;

  int currentScore = 0;

  // initial snake movement direction
  SnakeDirection currentDirection = SnakeDirection.right;

  // game sounds handler
  final foodPlayer = AudioPlayer();
  final musicPlayer = AudioPlayer();
  bool isMusicPlaying = false;

  // state game state
  void startGame() {
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        // Verify that game is over
        checkGameOver(timer);

        // Verify that game is pause
        checkGamePause(timer);

        if (!isMusicPlaying) {
          musicPlayer.setReleaseMode(
              ReleaseMode.loop); // for playing music in loop mode
          musicPlayer.setVolume(3.0);
          musicPlayer.play(AssetSource('sounds/background_music.mp3'));
        }
        // moving snake
        moveSnake();
      });
    });
  }

  void restartGame() {
    setState(() {
      // snake position
      snakePositions = [0, 1, 2];

      // food position
      foodPositions = 17;

      // pause game state
      pause = false;

      gameRunning = false;

      currentScore = 0;

      // initial snake movement direction
      currentDirection = SnakeDirection.right;

      musicPlayer.stop();
      foodPlayer.stop();
      isMusicPlaying = false;
    });
  }

  // function for movement of the snake
  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirection.right:
        {
          // add a new head [0,1,2] --> [0,1,2,(prev_num+1)]
          if (snakePositions.last % rowSize == 9) {
            snakePositions.add(snakePositions.last + 1 - rowSize);
          } else {
            snakePositions.add(snakePositions.last + 1);
          }
        }
        break;
      case SnakeDirection.left:
        {
          // add a new head [0,1,2] --> [(next_num-1),0,1,2]
          if (snakePositions.last % rowSize == 0) {
            snakePositions.add(snakePositions.last - 1 + rowSize);
          } else {
            snakePositions.add(snakePositions.last - 1);
          }
        }
        break;
      case SnakeDirection.up:
        {
          // add a new head [0,1,2] --> [0,1,2,(prev_num+rowSize)]
          if (snakePositions.last < rowSize) {
            snakePositions.add(snakePositions.last + numberOfSquares - rowSize);
          } else {
            snakePositions.add(snakePositions.last - rowSize);
          }
        }
        break;
      case SnakeDirection.down:
        {
          // add a new head [0,1,2] --> [(next_num-rowSize),0,1,2]
          if (snakePositions.last + rowSize > numberOfSquares) {
            snakePositions.add(snakePositions.last + rowSize - numberOfSquares);
          } else {
            snakePositions.add(snakePositions.last + rowSize);
          }
        }
        break;
      default:
    }

    if (snakePositions.last != foodPositions) {
      // remove the tail [0,1,2,(prev_num+rowSize)] --> [1,2,(prev_num+rowSize)]
      snakePositions.removeAt(0);
    } else {
      // * eating food --> no need to remove the tail
      eatFood();
    }
  }

  void eatFood() {
    currentScore++;
    foodPlayer.play(AssetSource("sounds/apple_bite.mp3"));

    // changing the position of food
    while (snakePositions.contains(foodPositions)) {
      foodPositions = Random().nextInt(numberOfSquares);
    }
  }

  // function for checking if game is pause
  void checkGamePause(Timer timer) {
    if (pause == true) {
      musicPlayer.pause();
      timer.cancel();
      gameRunning = false;
    } else {
      // skip if the game is running
    }
  }

  // game over
  void checkGameOver(Timer timer) {
    // snake bite itself then game over
    // check if snakePositions list having duplicate positions or values that's mean snake bite itself
    List<int> snakeBody = snakePositions.sublist(0, snakePositions.length - 1);
    if (snakeBody.contains(snakePositions.last)) {
      timer.cancel();

      // display the game is over dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.white70,
              title: const Text(
                "Game Over",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Your Score is ${currentScore.toString()}",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () => {
                          restartGame(),
                          Navigator.pop(context),
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        child: const Text("Exit Game"),
                      ),
                      MaterialButton(
                        onPressed: () => {
                          restartGame(),
                          Navigator.pop(context),
                        },
                        color: Colors.green,
                        textColor: Colors.white,
                        child: const Text("Restart"),
                      )
                    ],
                  )
                ],
              ));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // game dashboard
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Your game dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text(
                            "Your Score",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentScore.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // game board
            Expanded(
              flex: 6,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) => {
                  if (details.delta.dx < 0 &&
                      currentDirection != SnakeDirection.right)
                    // Left drag
                    currentDirection = SnakeDirection.left
                  else if (details.delta.dx > 0 &&
                      currentDirection != SnakeDirection.left)
                    // Right drag
                    currentDirection = SnakeDirection.right
                },
                onVerticalDragUpdate: (details) => {
                  if (details.delta.dy < 0 &&
                      currentDirection != SnakeDirection.down)
                    // Down drag
                    currentDirection = SnakeDirection.up
                  else if (details.delta.dy > 0 &&
                      currentDirection != SnakeDirection.up)
                    // Up drag
                    currentDirection = SnakeDirection.down
                },
                child: GridView.builder(
                  itemCount: numberOfSquares,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowSize,
                  ),
                  itemBuilder: (context, index) {
                    if (snakePositions.contains(index)) {
                      return const SnakePixel();
                    } else if (index == foodPositions) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  },
                ),
              ),
            ),

            // game controls and buttons
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () => {
                        if (!gameRunning)
                          {
                            startGame(),
                            gameRunning = true,
                            pause = false,
                            // if music already playing then just resume musicPlayer
                            if (isMusicPlaying) musicPlayer.resume()
                          }
                      },
                      color: gameRunning ? Colors.grey : Colors.green,
                      textColor: Colors.white,
                      child: const Text('PLAY'),
                    ),
                    const SizedBox(width: 40),
                    MaterialButton(
                      onPressed: () => {pause = true},
                      color: Colors.red,
                      textColor: Colors.white,
                      child: const Text('PAUSE'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
