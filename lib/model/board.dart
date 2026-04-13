class Board {
  List<List<int>> grid;
  Board() : grid = List.generate(6, (_) => List.filled(7, 0));

  bool isBoardFull() {
    for (int col = 0; col < grid[0].length; col++) {
      if (grid[0][col] == 0) {
        return false;
      }
    }
    return true;
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

  bool checkWin(int player) {
    return checkHorizontalWin(player) ||
        checkVerticalWin(player) ||
        checkDiagonalDownLeftWin(player) ||
        checkDiagonalDownRightWin(player);
  }

  bool checkHorizontalWin(int player) {
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[0].length - 3; col++) {
        bool win = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row][col + k] != player) {
            win = false;
            break;
          }
        }
        if (win) return true;
      }
    }

    return false;
  }

  bool checkVerticalWin(int player) {
    for (int col = 0; col < grid[0].length; col++) {
      for (int row = 0; row < grid.length - 3; row++) {
        bool win = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row + k][col] != player) {
            win = false;
            break;
          }
        }
        if (win) return true;
      }
    }

    return false;
  }

  bool checkDiagonalDownRightWin(int player) {
    for (int row = 0; row < grid.length - 3; row++) {
      for (int col = 0; col < grid[0].length - 3; col++) {
        bool win = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row + k][col + k] != player) {
            win = false;
            break;
          }
        }
        if (win) return true;
      }
    }
    return false;
  }

  bool checkDiagonalDownLeftWin(int player) {
    for (int row = 0; row < grid.length - 3; row++) {
      for (int col = 3; col < grid[0].length; col++) {
        bool win = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row + k][col - k] != player) {
            win = false;
            break;
          }
        }
        if (win) return true;
      }
    }
    return false;
  }
}
