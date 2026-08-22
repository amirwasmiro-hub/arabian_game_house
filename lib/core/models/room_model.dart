class RoomModel {
  final String id;
  final String roomName;
  final String gameId;
  final String gameTitle;
  final String hostName;
  final String hostAvatar;
  final int currentPlayers;
  final int maxPlayers;
  final int betCoins;
  final bool isPrivate;
  final String status;

  RoomModel({
    required this.id,
    required this.roomName,
    required this.gameId,
    required this.gameTitle,
    required this.hostName,
    required this.hostAvatar,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.betCoins,
    required this.isPrivate,
    required this.status,
  });
}
