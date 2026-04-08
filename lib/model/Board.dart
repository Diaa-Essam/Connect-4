class Board {
  List<List<int>> grid;
  Board() : grid = List.generate(6, (_) => List.filled(7, 0));

  void printBoard() {
    for (int i = 0; i < grid.length; i++) {
      print("Row: ${i + 1}: ${grid[i]}");
    }
  }

  bool dropPiece(int column, int player) {
    if (column >= grid[0].length || column < 0) return false;
    for (int row = grid.length - 1; row >= 0; row--) {
      if (grid[row][column] == 0) {
        grid[row][column] = player;
        return true;
      }
    }
    return false;
  }

  bool checkHorizontalWin(int player) {
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[0].length - 3; j++) {
        bool win = true;
        for (int k = 0; k < 4; k++) {
          if (grid[i][j + k] != player) {
            win = false;
            break;
          }
        }
        if (win == true) return true;
      }
    }

    return false;
  }
}
