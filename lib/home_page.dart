import 'package:flutter/material.dart';
import 'package:flutter_snake_game/blank_pixel.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const int rowSize = 10;
    const int numberOfSquares = rowSize * rowSize;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // game dashboard
          Expanded(
            child: Container(),
          ),

          // game board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: numberOfSquares,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (context, index) {
                return const BlankPixel();
              },
            ),
          ),

          // game controls and buttons
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
