import 'package:equatable/equatable.dart';

class TokenProfile extends Equatable {
  final String address;
  final String symbol;
  final String name;
  final String? imageUrl;

  const TokenProfile({
    required this.address,
    required this.symbol,
    required this.name,
    this.imageUrl,
  });

  factory TokenProfile.fromJson(Map<String, dynamic> json) => TokenProfile(
        address: json['address'] as String? ?? '',
        symbol: json['symbol'] as String? ?? '',
        name: json['name'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
      );

  @override
  List<Object?> get props => [address, symbol, name, imageUrl];
}

class TokenBoost extends Equatable {
  final String address;
  final int boost;

  const TokenBoost({required this.address, required this.boost});

  factory TokenBoost.fromJson(Map<String, dynamic> json) => TokenBoost(
        address: json['address'] as String? ?? '',
        boost: (json['boost'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [address, boost];
}
