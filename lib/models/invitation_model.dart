import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationModel {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String gameId;
  final String gameName;
  final String gameDescription;
  final String stakes;
  final String detail;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;

  const InvitationModel({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.gameId,
    required this.gameName,
    required this.gameDescription,
    required this.stakes,
    required this.detail,
    this.status = 'pending',
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toMap() => {
        'fromUserId': fromUserId,
        'fromUsername': fromUsername,
        'toUserId': toUserId,
        'gameId': gameId,
        'gameName': gameName,
        'gameDescription': gameDescription,
        'stakes': stakes,
        'detail': detail,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory InvitationModel.fromMap(String id, Map<String, dynamic> map) =>
      InvitationModel(
        id: id,
        fromUserId: map['fromUserId'] as String? ?? '',
        fromUsername: map['fromUsername'] as String? ?? '',
        toUserId: map['toUserId'] as String? ?? '',
        gameId: map['gameId'] as String? ?? '',
        gameName: map['gameName'] as String? ?? '',
        gameDescription: map['gameDescription'] as String? ?? '',
        stakes: map['stakes'] as String? ?? '',
        detail: map['detail'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
