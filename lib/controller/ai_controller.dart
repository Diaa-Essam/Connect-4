import 'package:connect_four/model/board.dart';
import 'package:connect_four/model/node.dart';

class AiController {
  (int, Node) getBestMoveWithTree(Board board) {
    Node root = Node(nodeType: NodeType.minNode);
    int bestCol = -1;

    for (int col = 0; col < board.grid[0].length; col++) {
      if (board.grid[0][col] != 0) continue;

      Board tempBoard = board.clone();
      tempBoard.dropPiece(col, 2);

      Node child = Node(nodeType: NodeType.maxNode);
      root.neighbors.add(child);

      int utility = maximizeNode(child, tempBoard, 3);

      if (utility < root.utility) {
        root.utility = utility;
        bestCol = col;
      }
    }

    return (bestCol, root);
  }

  int getBestMove(Board board) {
    final (col, _) = getBestMoveWithTree(board);
    return col;
  }

  int maximizeNode(Node node, Board board, int depth) {
    if (board.checkWin(1) != null) return node.utility = 1000 + depth;
    if (board.checkWin(2) != null) return node.utility = -1000 - depth;
    if (board.isBoardFull() || depth == 0) return node.utility = 0;

    for (int col = 0; col < board.grid[0].length; col++) {
      if (board.grid[0][col] != 0) continue;

      Board tempBoard = board.clone();
      tempBoard.dropPiece(col, 1);

      Node child = Node(nodeType: NodeType.minNode);
      node.neighbors.add(child);

      int utility = minimizeNode(child, tempBoard, depth - 1);

      if (utility > node.utility) {
        node.utility = utility;
      }
    }
    return node.utility;
  }

  int minimizeNode(Node node, Board board, int depth) {
    if (board.checkWin(1) != null) return node.utility = 1000 + depth;
    if (board.checkWin(2) != null) return node.utility = -1000 - depth;
    if (board.isBoardFull() || depth == 0) return node.utility = 0;

    for (int col = 0; col < board.grid[0].length; col++) {
      if (board.grid[0][col] != 0) continue;

      Board tempBoard = board.clone();
      tempBoard.dropPiece(col, 2);

      Node child = Node(nodeType: NodeType.maxNode);
      node.neighbors.add(child);

      int utility = maximizeNode(child, tempBoard, depth - 1);

      if (utility < node.utility) {
        node.utility = utility;
      }
    }
    return node.utility;
  }
}
