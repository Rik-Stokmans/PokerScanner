import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipModel {
  final String id;
  final String userId;
  final String friendId;
  final String requestedBy;
  final String status; // 'pending', 'accepted'
  final String userUsername;
  final String friendUsername;
  final String friendStatus; // 'online', 'offline', 'in_game'
  final String? friendCurrentGameId;
  final DateTime createdAt;

  const FriendshipModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.requestedBy,
    required this.status,
    required this.userUsername,
    required this.friendUsername,
    this.friendStatus = 'offline',
    this.friendCurrentGameId,
    required this.createdAt,
  });

  bool isPending(String currentUserId) =>
      status == 'pending' && friendId == currentUserId;

  bool isAccepted() => status == 'accepted';

  String otherUserId(String currentUserId) =>
      userId == currentUserId ? friendId : userId;

  String otherUsername(String currentUserId) =>
      userId == currentUserId ? friendUsername : userUsername;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'friendId': friendId,
        'requestedBy': requestedBy,
        'status': status,
        'userUsername': userUsername,
        'friendUsername': friendUsername,
        'friendStatus': friendStatus,
        'friendCurrentGameId': friendCurrentGameId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory FriendshipModel.fromMap(String id, Map<String, dynamic> map) =>
      FriendshipModel(
        id: id,
        userId: map['userId'] as String? ?? '',
        friendId: map['friendId'] as String? ?? '',
        requestedBy: map['requestedBy'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        userUsername: map['userUsername'] as String? ?? '',
        friendUsername: map['friendUsername'] as String? ?? '',
        friendStatus: map['friendStatus'] as String? ?? 'offline',
        friendCurrentGameId: map['friendCurrentGameId'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
