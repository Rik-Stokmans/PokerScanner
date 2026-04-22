import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String status; // 'online', 'offline', 'in_game'
  final String? currentGameId;
  final int totalHandsPlayed;
  final double totalWinnings;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.status = 'online',
    this.currentGameId,
    this.totalHandsPlayed = 0,
    this.totalWinnings = 0.0,
    required this.createdAt,
  });

  String get initial => username.isNotEmpty ? username[0].toUpperCase() : '?';

  Map<String, dynamic> toMap() => {
        'username': username,
        'email': email,
        'status': status,
        'currentGameId': currentGameId,
        'totalHandsPlayed': totalHandsPlayed,
        'totalWinnings': totalWinnings,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
        id: id,
        username: map['username'] as String? ?? '',
        email: map['email'] as String? ?? '',
        status: map['status'] as String? ?? 'offline',
        currentGameId: map['currentGameId'] as String?,
        totalHandsPlayed: (map['totalHandsPlayed'] as num?)?.toInt() ?? 0,
        totalWinnings: (map['totalWinnings'] as num?)?.toDouble() ?? 0.0,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  UserModel copyWith({
    String? status,
    String? currentGameId,
    bool clearGameId = false,
    int? totalHandsPlayed,
    double? totalWinnings,
  }) =>
      UserModel(
        id: id,
        username: username,
        email: email,
        status: status ?? this.status,
        currentGameId: clearGameId ? null : (currentGameId ?? this.currentGameId),
        totalHandsPlayed: totalHandsPlayed ?? this.totalHandsPlayed,
        totalWinnings: totalWinnings ?? this.totalWinnings,
        createdAt: createdAt,
      );
}
