enum NodeType { maxNode, minNode, chanceNode }

class Node {
  int? utility;
  NodeType nodeType;
  List<Node> neighbors = [];
  int? column;           // move that led to this node
  int depth = 0;
  int? alpha;            // for alpha-beta display
  int? beta;             // for alpha-beta display
  double? probability;   // for expected minimax chance nodes

  Node({
    required this.nodeType,
    this.utility,
    this.column,
    this.depth = 0,
    this.alpha,
    this.beta,
    this.probability,
    List<Node>? neighbors,
  }) : neighbors = neighbors ?? [] {
    // Default init: max wants -inf, min wants +inf, chance starts 0
    if (utility == null) {
      if (nodeType == NodeType.maxNode) {
        utility = -(1 << 62);
      } else if (nodeType == NodeType.minNode) {
        utility = (1 << 62);
      } else {
        utility = 0;
      }
    }
  }
}