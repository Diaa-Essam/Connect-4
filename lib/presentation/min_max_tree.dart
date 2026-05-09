import 'package:flutter/material.dart';
import 'package:connect_four/model/node.dart';

class MinimaxTreeWidget extends StatelessWidget {
  final Node root;
  const MinimaxTreeWidget({super.key, required this.root});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MINIMAX TREE',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legend(Colors.blue.shade400, '▲ MAX'),
              const SizedBox(width: 16),
              _legend(Colors.red.shade400, '▼ MIN'),
              const SizedBox(width: 16),
              _legend(Colors.green.shade400, '◆ CHANCE'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Builder(builder: (context) {
                final double w = _computeWidth(root);
                return CustomPaint(
                  painter: _TreePainter(root),
                  size: Size(w, 320),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  double _computeWidth(Node node) {
    int leaves = _countLeaves(node);
    return (leaves * 80.0).clamp(320.0, 3000.0);
  }

  int _countLeaves(Node node) {
    if (node.neighbors.isEmpty) return 1;
    return node.neighbors.fold(0, (s, c) => s + _countLeaves(c));
  }
}

class _TreePainter extends CustomPainter {
  final Node root;
  _TreePainter(this.root);

  static const double _nodeR = 22;
  static const double _vPad = 40;

  final _edgePaint = Paint()
    ..color = Colors.white30
    ..strokeWidth = 1.2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final int depth = _maxDepth(root);
    final double levelH = (size.height - _vPad * 2) / depth.clamp(1, 99);
    _assignPositions(root, 0, 0, size.width, levelH);
    _drawEdges(canvas, root);
    _drawNodes(canvas, root);
  }

  void _assignPositions(Node node, int depth, double left, double right, double levelH) {
    node.x = (left + right) / 2;
    node.y = _vPad + depth * levelH;
    if (node.neighbors.isEmpty) return;
    final double slotW = (right - left) / node.neighbors.length;
    for (int i = 0; i < node.neighbors.length; i++) {
      _assignPositions(node.neighbors[i], depth + 1, left + i * slotW, left + (i + 1) * slotW, levelH);
    }
  }

  void _drawEdges(Canvas canvas, Node node) {
    for (final child in node.neighbors) {
      canvas.drawLine(Offset(node.x, node.y), Offset(child.x, child.y), _edgePaint);
      _drawEdges(canvas, child);
    }
  }

  void _drawNodes(Canvas canvas, Node node) {
    _drawNode(canvas, node);
    for (final child in node.neighbors) _drawNodes(canvas, child);
  }

  void _drawNode(Canvas canvas, Node node) {
    final isMax = node.nodeType == NodeType.maxNode;
    final isMin = node.nodeType == NodeType.minNode;
    final isChance = node.nodeType == NodeType.chanceNode;

    final Color fill = isMax
        ? Colors.blue.shade800
        : isMin
            ? Colors.red.shade800
            : Colors.green.shade800;
    final Color border = isMax
        ? Colors.blue.shade300
        : isMin
            ? Colors.red.shade300
            : Colors.green.shade300;

    final fillPaint = Paint()..color = fill..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (isChance) {
      // Diamond for chance
      final path = Path()
        ..moveTo(node.x, node.y - _nodeR)
        ..lineTo(node.x + _nodeR, node.y)
        ..lineTo(node.x, node.y + _nodeR)
        ..lineTo(node.x - _nodeR, node.y)
        ..close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    } else {
      final path = Path();
      if (isMax) {
        path.moveTo(node.x, node.y - _nodeR);
        path.lineTo(node.x - _nodeR, node.y + _nodeR * 0.7);
        path.lineTo(node.x + _nodeR, node.y + _nodeR * 0.7);
        path.close();
      } else {
        path.moveTo(node.x, node.y + _nodeR);
        path.lineTo(node.x - _nodeR, node.y - _nodeR * 0.7);
        path.lineTo(node.x + _nodeR, node.y - _nodeR * 0.7);
        path.close();
      }
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    }

    // Label: heuristic / utility
    final bool isInfinity = node.utility != null && node.utility!.abs() >= (1 << 60);
    String label = isInfinity
        ? (isMax ? '-∞' : isMin ? '+∞' : '?')
        : (node.utility?.toString() ?? '?');

    // Add column info if present
    if (node.column != null && node.depth == 1) {
      label = "c${node.column}\n$label";
    }

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 4 ? 8 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final double textY = isMax
        ? node.y + 2
        : isMin
            ? node.y - 2
            : node.y;

    tp.paint(canvas, Offset(node.x - tp.width / 2, textY - tp.height / 2));

    // Alpha-beta annotations
    if (node.alpha != null && node.beta != null) {
      final abText = TextPainter(
        text: TextSpan(
          text: "α${node.alpha} β${node.beta}",
          style: const TextStyle(color: Colors.white54, fontSize: 7),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      abText.paint(canvas, Offset(node.x - abText.width / 2, node.y + _nodeR + 4));
    }
  }

  int _maxDepth(Node node) {
    if (node.neighbors.isEmpty) return 0;
    return 1 + node.neighbors.map(_maxDepth).reduce((a, b) => a > b ? a : b);
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => old.root != root;
}

extension _NodeLayout on Node {
  static final _x = Expando<double>();
  static final _y = Expando<double>();
  double get x => _x[this] ?? 0;
  set x(double v) => _x[this] = v;
  double get y => _y[this] ?? 0;
  set y(double v) => _y[this] = v;
}