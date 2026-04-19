class Board {
  List<List<int>> grid;
  Board() : grid = List.generate(6, (_) => List.filled(7, 0));

  Board clone() {
    Board newBoard = Board();
    for (int i = 0; i < grid.length; i++) {
      newBoard.grid[i] = List.from(grid[i]);
    }
    return newBoard;
  }

  int getAvailableRow(int column) {
    for (int row = grid.length - 1; row >= 0; row--) {
      if (grid[row][column] == 0) {
        return row;
      }
    }
    return -1;
  }

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

  List<List<int>>? checkWin(int player) {
    return checkHorizontalWin(player) ??
        checkVerticalWin(player) ??
        checkDiagonalDownLeftWin(player) ??
        checkDiagonalDownRightWin(player);
  }

  List<List<int>>? checkHorizontalWin(int player) {
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[0].length - 3; col++) {
        bool allMatch = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row][col + k] != player) {
            allMatch = false;
            break;
          }
        }

        if (allMatch) {
          List<List<int>> positions = [];
          for (int k = 0; k < 4; k++) {
            positions.add([row, col + k]);
          }
          return positions;
        }
      }
    }
    return null;
  }

  List<List<int>>? checkVerticalWin(int player) {
    for (int col = 0; col < grid[0].length; col++) {
      for (int row = 0; row < grid.length - 3; row++) {
        bool allMatch = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row + k][col] != player) {
            allMatch = false;
            break;
          }
        }
        if (allMatch) {
          List<List<int>> positions = [];
          for (int k = 0; k < 4; k++) {
            positions.add([row + k, col]);
          }
          return positions;
        }
      }
    }

    return null;
  }

  List<List<int>>? checkDiagonalDownRightWin(int player) {
    for (int row = 0; row < grid.length - 3; row++) {
      for (int col = 0; col < grid[0].length - 3; col++) {
        bool allMatch = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row + k][col + k] != player) {
            allMatch = false;
            break;
          }
        }
        if (allMatch) {
          List<List<int>> positions = [];
          for (int k = 0; k < 4; k++) {
            positions.add([row + k, col + k]);
          }
          return positions;
        }
      }
    }
    return null;
  }

  List<List<int>>? checkDiagonalDownLeftWin(int player) {
    for (int row = 0; row < grid.length - 3; row++) {
      for (int col = 3; col < grid[0].length; col++) {
        bool allMatch = true;
        for (int k = 0; k < 4; k++) {
          if (grid[row + k][col - k] != player) {
            allMatch = false;
            break;
          }
        }
        if (allMatch) {
          List<List<int>> positions = [];
          for (int k = 0; k < 4; k++) {
            positions.add([row + k, col - k]);
          }
          return positions;
        }
      }
    }
    return null;
  }
}
