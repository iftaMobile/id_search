// lib/models/coin_info.dart

class CoinInfo {
  final String tierConnected;
  final String device;

  CoinInfo({
    required this.tierConnected,
    required this.device,
  });

  /// Erzeugt eine Instanz aus einem JSON-Map
  factory CoinInfo.fromJson(Map<String, dynamic> json) {
    return CoinInfo(
      tierConnected: json['tier_connected'] as String,
      device:        json['device']         as String,
    );
  }

  /// Optional: Umwandlung zurück in Map (z. B. für Debugging)
  Map<String, dynamic> toJson() {
    return {
      'tier_connected': tierConnected,
      'device':         device,
    };
  }
}