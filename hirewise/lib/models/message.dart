import 'base_model.dart';

class Conversation extends BaseModel {
  @override
  final String id;
  final String participantName;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;

  const Conversation({
    required this.id,
    required this.participantName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
  }) : super();

  Conversation.newThread({
    required this.id,
    required this.participantName,
    this.avatarUrl = '',
    this.isOnline = false,
  })  : lastMessage = 'Start a conversation...',
        time = 'Just now',
        unreadCount = 0,
        super();

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
        id: map['id'] as String? ?? '',
        participantName: map['participantName'] as String? ?? '',
        avatarUrl: map['avatarUrl'] as String? ?? '',
        lastMessage: map['lastMessage'] as String? ?? '',
        time: map['time'] as String? ?? '',
        unreadCount: map['unreadCount'] as int? ?? 0,
        isOnline: map['isOnline'] as bool? ?? false,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'participantName': participantName,
        'avatarUrl': avatarUrl,
        'lastMessage': lastMessage,
        'time': time,
        'unreadCount': unreadCount,
        'isOnline': isOnline,
      };

  Conversation copyWith({
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? isOnline,
  }) =>
      Conversation(
        id: id,
        participantName: participantName,
        avatarUrl: avatarUrl,
        lastMessage: lastMessage ?? this.lastMessage,
        time: time ?? this.time,
        unreadCount: unreadCount ?? this.unreadCount,
        isOnline: isOnline ?? this.isOnline,
      );
}

const List<Conversation> kConversations = [
  Conversation(
    id: '1',
    participantName: 'Leo Vance',
    avatarUrl: '',
    lastMessage: "I've attached the revised strategy document for your review.",
    time: '2 min ago',
    unreadCount: 2,
    isOnline: true,
  ),
  Conversation(
    id: '2',
    participantName: 'Sophia Thorne',
    avatarUrl: '',
    lastMessage: 'The site will be with you by tomorrow.',
    time: '1 hr ago',
    unreadCount: 0,
    isOnline: false,
  ),
  Conversation(
    id: '3',
    participantName: 'Marcus Reid',
    avatarUrl: '',
    lastMessage: 'Done! Please let me know if you need any changes.',
    time: '3 hr ago',
    unreadCount: 0,
    isOnline: true,
  ),
  Conversation(
    id: '4',
    participantName: 'Juliet Diaz',
    avatarUrl: '',
    lastMessage: 'Thanks for the quick turnaround on this!',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: false,
  ),
];
