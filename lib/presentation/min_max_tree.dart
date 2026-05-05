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
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legend(Colors.blue.shade400, '▲ MAX (Player)'),
              const SizedBox(width: 20),
              _legend(Colors.red.shade400, '▼ MIN (AI)'),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  double _computeWidth(Node node) {
    int leaves = _countLeaves(node);
    // 80px per leaf gives enough breathing room
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
  static const double _vPad = 40; // top/bottom padding

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

  void _assignPositions(
      Node node, int depth, double left, double right, double levelH) {
    node.x = (left + right) / 2;
    node.y = _vPad + depth * levelH;

    if (node.neighbors.isEmpty) return;
    final double slotW = (right - left) / node.neighbors.length;
    for (int i = 0; i < node.neighbors.length; i++) {
      _assignPositions(
        node.neighbors[i],
        depth + 1,
        left + i * slotW,
        left + (i + 1) * slotW,
        levelH,
      );
    }
  }

  // Draw edges before nodes so nodes paint on top.
  void _drawEdges(Canvas canvas, Node node) {
    for (final child in node.neighbors) {
      canvas.drawLine(
        Offset(node.x, node.y),
        Offset(child.x, child.y),
        _edgePaint,
      );
      _drawEdges(canvas, child);
    }
  }

  void _drawNodes(Canvas canvas, Node node) {
    _drawNode(canvas, node);
    for (final child in node.neighbors) {
      _drawNodes(canvas, child);
    }
  }

  void _drawNode(Canvas canvas, Node node) {
    final bool isMax = node.nodeType == NodeType.maxNode;
    final Color fill = isMax ? Colors.blue.shade800 : Colors.red.shade800;
    final Color border = isMax ? Colors.blue.shade300 : Colors.red.shade300;

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    if (isMax) {
      // ▲ pointing up
      path.moveTo(node.x, node.y - _nodeR);
      path.lineTo(node.x - _nodeR, node.y + _nodeR * 0.7);
      path.lineTo(node.x + _nodeR, node.y + _nodeR * 0.7);
      path.close();
    } else {
      // ▼ pointing down
      path.moveTo(node.x, node.y + _nodeR);
      path.lineTo(node.x - _nodeR, node.y - _nodeR * 0.7);
      path.lineTo(node.x + _nodeR, node.y - _nodeR * 0.7);
      path.close();
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // Utility label
    final bool isInfinity = node.utility.abs() >= (1 << 60);
    final String label = isInfinity
        ? (isMax ? '-∞' : '+∞')
        : node.utility.toString();

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 3 ? 9 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Shift text slightly toward the wide base of the triangle
    final double textY = isMax
        ? node.y + 2  // push down toward base for ▲
        : node.y - 2; // push up toward base for ▼

    tp.paint(canvas, Offset(node.x - tp.width / 2, textY - tp.height / 2));
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