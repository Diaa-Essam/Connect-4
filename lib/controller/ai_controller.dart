import 'package:connect_four/model/algorithm.dart';
import 'package:connect_four/model/board.dart';
import 'package:connect_four/model/node.dart';

class AiResult {
  final int column;
  final Node root;
  final int nodesExpanded;
  final Duration elapsedTime;
  AiResult(this.column, this.root, this.nodesExpanded, this.elapsedTime);
}

class AiController {
  final Algorithm algorithm;
  final int maxDepth;
  int _nodesExpanded = 0;

  AiController({required this.algorithm, required this.maxDepth});

  AiResult getBestMove(Board board, int player) {
    _nodesExpanded = 0;
    final stopwatch = Stopwatch()..start();

    Node root = Node(
      nodeType: player == 1 ? NodeType.maxNode : NodeType.minNode,
      column: null,
      depth: 0,
    );
    int bestCol = -1;

    final validCols = _getValidColumns(board);

    if (algorithm == Algorithm.minimax) {
      int bestVal = player == 1 ? -(1 << 62) : (1 << 62);
      for (final col in validCols) {
        final temp = board.clone();
        temp.dropPiece(col, player);
        final child = Node(
          nodeType: player == 1 ? NodeType.minNode : NodeType.maxNode,
          column: col,
          depth: 1,
        );
        root.neighbors.add(child);

        final val = player == 1
            ? _minimize(child, temp, maxDepth - 1)
            : _maximize(child, temp, maxDepth - 1);

        if (player == 1 ? val > bestVal : val < bestVal) {
          bestVal = val;
          bestCol = col;
        }
      }
      root.utility = bestVal;
    } else if (algorithm == Algorithm.minimaxAlphaBeta) {
      int bestVal = player == 1 ? -(1 << 62) : (1 << 62);
      int alpha = -(1 << 62);
      int beta = (1 << 62);
      root.alpha = alpha;
      root.beta = beta;
      for (final col in validCols) {
        final temp = board.clone();
        temp.dropPiece(col, player);
        final child = Node(
          nodeType: player == 1 ? NodeType.minNode : NodeType.maxNode,
          column: col,
          depth: 1,
          alpha: alpha,
          beta: beta,
        );
        root.neighbors.add(child);

        final val = player == 1
            ? _minimizeAB(child, temp, maxDepth - 1, alpha, beta)
            : _maximizeAB(child, temp, maxDepth - 1, alpha, beta);

        if (player == 1) {
          if (val > bestVal) {
            bestVal = val;
            bestCol = col;
          }
          if (val > alpha) alpha = val;
        } else {
          if (val < bestVal) {
            bestVal = val;
            bestCol = col;
          }
          if (val < beta) beta = val;
          if (val > alpha)
            alpha =
                val; // Bug 3 fix: alpha must be updated for player 2 root so children can be pruned correctly
        }
      }
      root.utility = bestVal;
    } else if (algorithm == Algorithm.expectedMinimax) {
      double bestVal = player == 1 ? -double.infinity : double.infinity;
      for (final col in validCols) {
        final child = Node(
          nodeType: NodeType.chanceNode,
          column: col,
          depth: 1,
        );
        root.neighbors.add(child);

        final val = _expected(child, board, maxDepth - 1, player == 1);
        final int intVal = val.isFinite
            ? val.round()
            : (player == 1 ? (1 << 62) : -(1 << 62));

        if (player == 1 ? val > bestVal : val < bestVal) {
          bestVal = val;
          bestCol = col;
        }
        child.utility = intVal;
      }
      root.utility = bestVal.isFinite
          ? bestVal.round()
          : (player == 1 ? (1 << 62) : -(1 << 62));
    }

    stopwatch.stop();
    return AiResult(bestCol, root, _nodesExpanded, stopwatch.elapsed);
  }

  List<int> _getValidColumns(Board board) {
    List<int> cols = [];
    for (int c = 0; c < 7; c++) {
      if (board.grid[0][c] == 0) cols.add(c);
    }
    return cols;
  }

  bool _isTerminal(Board board) => board.isBoardFull();

  int _evaluate(Board board) => board.heuristicScore();

  // ---------- Minimax ----------
  int _maximize(Node node, Board board, int depth) {
    _nodesExpanded++;
    if (_isTerminal(board) || depth == 0) {
      return node.utility = _evaluate(board);
    }
    int value = -(1 << 62);
    for (final col in _getValidColumns(board)) {
      final temp = board.clone();
      temp.dropPiece(col, 1);
      final child = Node(
        nodeType: NodeType.minNode,
        column: col,
        depth: node.depth + 1,
      );
      node.neighbors.add(child);
      final v = _minimize(child, temp, depth - 1);
      if (v > value) value = v;
    }
    return node.utility = value;
  }

  int _minimize(Node node, Board board, int depth) {
    _nodesExpanded++;
    if (_isTerminal(board) || depth == 0) {
      return node.utility = _evaluate(board);
    }
    int value = (1 << 62);
    for (final col in _getValidColumns(board)) {
      final temp = board.clone();
      temp.dropPiece(col, 2);
      final child = Node(
        nodeType: NodeType.maxNode,
        column: col,
        depth: node.depth + 1,
      );
      node.neighbors.add(child);
      final v = _maximize(child, temp, depth - 1);
      if (v < value) value = v;
    }
    return node.utility = value;
  }

  // ---------- Alpha-Beta ----------
  int _maximizeAB(Node node, Board board, int depth, int alpha, int beta) {
    _nodesExpanded++;
    node.alpha = alpha;
    node.beta = beta;
    if (_isTerminal(board) || depth == 0) {
      return node.utility = _evaluate(board);
    }
    int value = -(1 << 62);
    for (final col in _getValidColumns(board)) {
      final temp = board.clone();
      temp.dropPiece(col, 1);
      final child = Node(
        nodeType: NodeType.minNode,
        column: col,
        depth: node.depth + 1,
        alpha: alpha,
        beta: beta,
      );
      node.neighbors.add(child);
      final v = _minimizeAB(child, temp, depth - 1, alpha, beta);
      if (v > value) value = v;
      if (value > alpha) alpha = value;
      // Write updated alpha back so node shows the tightest bound it achieved
      node.alpha = alpha;
      if (value >= beta) {
        node.utility = value;
        return value; // prune
      }
    }
    return node.utility = value;
  }

  int _minimizeAB(Node node, Board board, int depth, int alpha, int beta) {
    _nodesExpanded++;
    node.alpha = alpha;
    node.beta = beta;
    if (_isTerminal(board) || depth == 0) {
      return node.utility = _evaluate(board);
    }
    int value = (1 << 62);
    for (final col in _getValidColumns(board)) {
      final temp = board.clone();
      temp.dropPiece(col, 2);
      final child = Node(
        nodeType: NodeType.maxNode,
        column: col,
        depth: node.depth + 1,
        alpha: alpha,
        beta: beta,
      );
      node.neighbors.add(child);
      final v = _maximizeAB(child, temp, depth - 1, alpha, beta);
      if (v < value) value = v;
      if (value < beta) beta = value;
      // Write updated beta back so node shows the tightest bound it achieved
      node.beta = beta;
      if (value <= alpha) {
        node.utility = value;
        return value; // prune
      }
    }
    return node.utility = value;
  }

  // ---------- Expected Minimax ----------
  double _expected(Node node, Board board, int depth, bool isMaximizing) {
    _nodesExpanded++;
    if (_isTerminal(board) || depth == 0) {
      final h = _evaluate(board).toDouble();
      node.utility = h.round();
      return h;
    }

    if (node.nodeType == NodeType.chanceNode) {
      // Chance node: expected value over intended (0.6), left (0.2), right (0.2)
      int col = node.column!;
      double ev = 0.0;
      final outcomes = <(int col, double prob)>[];

      outcomes.add((col, 0.6));
      if (col > 0 && board.grid[0][col - 1] == 0) outcomes.add((col - 1, 0.2));
      if (col < 6 && board.grid[0][col + 1] == 0) outcomes.add((col + 1, 0.2));

      // Normalize if neighbors invalid
      double total = outcomes.fold(0.0, (s, o) => s + o.$2);
      for (final out in outcomes) {
        double p = out.$2 / total;
        final temp = board.clone();
        int playerAtNode = isMaximizing ? 1 : 2;
        temp.dropPiece(out.$1, playerAtNode);
        final child = Node(
          nodeType: isMaximizing ? NodeType.minNode : NodeType.maxNode,
          column: out.$1,
          depth: node.depth + 1,
          probability: p,
        );
        node.neighbors.add(child);
        final v = _expected(child, temp, depth - 1, !isMaximizing);
        ev += p * v;
      }
      node.utility = ev.isFinite ? ev.round() : 0;
      return ev;
    } else if (node.nodeType == NodeType.maxNode) {
      double value = -double.infinity;
      for (final col in _getValidColumns(board)) {
        final child = Node(
          nodeType: NodeType.chanceNode,
          column: col,
          depth: node.depth + 1,
        );
        node.neighbors.add(child);
        final v = _expected(child, board, depth - 1, true);
        if (v > value) value = v;
      }
      node.utility = value.isFinite ? value.round() : -(1 << 62);
      return value;
    } else {
      double value = double.infinity;
      for (final col in _getValidColumns(board)) {
        final child = Node(
          nodeType: NodeType.chanceNode,
          column: col,
          depth: node.depth + 1,
        );
        node.neighbors.add(child);
        final v = _expected(child, board, depth - 1, false);
        if (v < value) value = v;
      }
      node.utility = value.isFinite ? value.round() : (1 << 62);
      return value;
    }
  }

  // ---------- Console Tree Printer ----------
  static void printTree(Node node, {String indent = ""}) {
    final typeStr = node.nodeType == NodeType.maxNode
        ? "MAX"
        : node.nodeType == NodeType.minNode
        ? "MIN"
        : "CHANCE";
    final prob = node.probability != null
        ? " p=${node.probability!.toStringAsFixed(2)}"
        : "";
    final ab = (node.alpha != null && node.beta != null)
        ? " α=${node.alpha} β=${node.beta}"
        : "";
    final col = node.column != null ? " col=${node.column}" : "";
    print("$indent$typeStr$col utility=${node.utility}$prob$ab");
    for (final child in node.neighbors) {
      printTree(child, indent: "$indent  ");
    }
  }
}
