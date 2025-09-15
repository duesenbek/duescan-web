import 'dart:math';

import '../models/pair.dart';

class AiAssessment {
  final int score; // 0..100
  final String label; // High/Medium/Low
  final String explanation;

  const AiAssessment({required this.score, required this.label, required this.explanation});
}

/// Simple deterministic heuristic combining short-term momentum, volume and liquidity.
class AiService {
  const AiService();

  AiAssessment assessPair(Pair p) {
    final change5m = p.change5m ?? 0;
    final change1h = p.change1h ?? 0;
    final vol = p.volume24h ?? 0;
    final liq = p.liquidityUsd ?? 0;

    // Normalize components
    final momentum = _sigmoid((change5m * 0.6) + (change1h * 0.4)); // -inf..+inf -> 0..1
    final volNorm = _logNorm(vol, 1e3, 1e8); // scale between 0..1
    final liqNorm = _logNorm(liq, 1e3, 1e8);

    final raw = (momentum * 0.5) + (volNorm * 0.3) + (liqNorm * 0.2);
    final score = (raw * 100).clamp(0, 100).round();

    String label;
    if (score >= 70) {
      label = 'High';
    } else if (score >= 40) {
      label = 'Medium';
    } else {
      label = 'Low';
    }

    final explanation = _buildExplanation(p, score, label);
    return AiAssessment(score: score, label: label, explanation: explanation);
  }

  double _sigmoid(double x) => 1 / (1 + exp(-x / 10));

  double _logNorm(double v, double minV, double maxV) {
    final clamped = v.clamp(minV, maxV);
    final n = (log(clamped) - log(minV)) / (log(maxV) - log(minV));
    return n.clamp(0.0, 1.0);
  }

  String _buildExplanation(Pair p, int score, String label) {
    final parts = <String>[];
    if ((p.change5m ?? 0) > 0) parts.add('positive short-term momentum');
    if ((p.volume24h ?? 0) > 0) parts.add('solid 24h volume');
    if ((p.liquidityUsd ?? 0) > 0) parts.add('available liquidity');
    final base = parts.isEmpty ? 'limited data' : parts.join(', ');
    return 'Assessment: $label potential ($score/100) based on $base. Not financial advice.';
  }
}
