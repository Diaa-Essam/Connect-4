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
      if (grid[row][column] == 0) return row;
    }
    return -1;
  }

  bool isBoardFull() {
    for (int col = 0; col < grid[0].length; col++) {
      if (grid[0][col] == 0) return false;
    }
    return true;
  }

  bool dropPiece(int column, int player) {
    if (column < 0 || column >= grid[0].length) return false;
    for (int row = grid.length - 1; row >= 0; row--) {
      if (grid[row][column] == 0) {
        grid[row][column] = player;
        return true;
      }
    }
    return false;
  }

  // Count ALL 4-in-a-rows for a player (for play-till-full scoring)
  int countAllConnections(int player) {
    int count = 0;
    // Horizontal
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player &&
            grid[r][c + 1] == player &&
            grid[r][c + 2] == player &&
            grid[r][c + 3] == player) {
          count++;
        }
      }
    }
    // Vertical
    for (int c = 0; c < 7; c++) {
      for (int r = 0; r < 3; r++) {
        if (grid[r][c] == player &&
            grid[r + 1][c] == player &&
            grid[r + 2][c] == player &&
            grid[r + 3][c] == player) {
          count++;
        }
      }
    }
    // Diagonal down-right
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player &&
            grid[r + 1][c + 1] == player &&
            grid[r + 2][c + 2] == player &&
            grid[r + 3][c + 3] == player) {
          count++;
        }
      }
    }
    // Diagonal down-left
    for (int r = 0; r < 3; r++) {
      for (int c = 3; c < 7; c++) {
        if (grid[r][c] == player &&
            grid[r + 1][c - 1] == player &&
            grid[r + 2][c - 2] == player &&
            grid[r + 3][c - 3] == player) {
          count++;
        }
      }
    }
    return count;
  }

  // Heuristic: positive = good for human (player 1), negative = good for AI (player 2)
  int heuristicScore() {
    int score = 0;
    // Center column preference (column 3)
    for (int r = 0; r < 6; r++) {
      if (grid[r][3] == 1) {
        score += 3;
      } else if (grid[r][3] == 2) score -= 3;
    }

    int evalWindow(List<int> w) {
      int human = w.where((x) => x == 1).length;
      int ai = w.where((x) => x == 2).length;
      int empty = w.where((x) => x == 0).length;

      if (human == 4) return 10000;
      if (human == 3 && empty == 1) return 100;
      if (human == 2 && empty == 2) return 10;
      if (ai == 4) return -10000;
      if (ai == 3 && empty == 1) return -100;
      if (ai == 2 && empty == 2) return -10;
      return 0;
    }

    List<int> getWindow(int r, int c, int dr, int dc) =>
        [grid[r][c], grid[r + dr][c + dc], grid[r + 2 * dr][c + 2 * dc], grid[r + 3 * dr][c + 3 * dc]];

    // Horizontal
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 4; c++) {
        score += evalWindow(getWindow(r, c, 0, 1));
      }
    }
    // Vertical
    for (int c = 0; c < 7; c++) {
      for (int r = 0; r < 3; r++) {
        score += evalWindow(getWindow(r, c, 1, 0));
      }
    }
    // Diagonal /
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 4; c++) {
        score += evalWindow(getWindow(r, c, 1, 1));
      }
    }
    // Diagonal \
    for (int r = 0; r < 3; r++) {
      for (int c = 3; c < 7; c++) {
        score += evalWindow(getWindow(r, c, 1, -1));
      }
    }

    return score;
  }
}