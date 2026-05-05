class Node {
  int utility;
  NodeType nodeType;
  List<Node> neighbors = [];

  Node({required this.nodeType, int? utility, List<Node>? neighbors})
    : utility =
          utility ?? (nodeType == NodeType.minNode ? (1 << 62) : -(1 << 62)),
      neighbors = neighbors ?? [];
}

enum NodeType { minNode, maxNode }
