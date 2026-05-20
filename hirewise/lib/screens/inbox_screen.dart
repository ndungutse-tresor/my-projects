import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/chat_message.dart';
import '../models/expert.dart' hide ExpertService;
import '../theme/app_theme.dart';
import '../widgets/message_tile.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/auth_provider.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final conversations = conversationsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Inbox',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showNewMessage(context, ref),
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.backgroundGrey,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: conversationsAsync.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue))
                  : conversations.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 56, color: AppTheme.textMuted),
                              SizedBox(height: 12),
                              Text('No conversations yet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textMuted)),
                              Text('Tap the pencil icon to start one',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textMuted)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            return MessageTile(
                              conversation: conversations[index],
                              onTap: () =>
                                  _openChat(context, conversations[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewMessage(BuildContext context, WidgetRef ref) {
    final msgCtrl = TextEditingController();
    final experts = ref.read(expertsStreamProvider).valueOrNull ?? [];
    if (experts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No experts available yet. Try again shortly.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    Expert selectedExpert = experts.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setInner) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('New Message',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppTheme.textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('To',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedExpert.id,
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded,
                          color: AppTheme.textMuted),
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textDark),
                      onChanged: (v) {
                        final e = experts.firstWhere((e) => e.id == v!);
                        setInner(() => selectedExpert = e);
                      },
                      items: experts
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppTheme.primaryBlue
                                          .withValues(alpha: 0.12),
                                      child: Text(
                                          e.name.isNotEmpty ? e.name[0] : '?',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primaryBlue)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(e.name),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Message',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type your message…',
                    hintStyle: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FB),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppTheme.primaryBlue)),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = msgCtrl.text.trim();
                      if (text.isEmpty) return;
                      Navigator.of(context).pop();
                      final user = ref.read(currentUserProvider).valueOrNull;
                      if (user != null) {
                        try {
                          final convoId = await ref
                              .read(conversationServiceProvider)
                              .getOrCreateConversation(
                                userId: user.uid,
                                userName: user.name,
                                expertId: selectedExpert.id,
                                expertName: selectedExpert.name,
                              );
                          await ref
                              .read(conversationServiceProvider)
                              .sendMessage(
                                conversationId: convoId,
                                senderId: user.uid,
                                senderName: user.name,
                                text: text,
                                otherUserId: selectedExpert.id,
                              );
                        } catch (_) {}
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Message sent to ${selectedExpert.name}!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ));
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Message',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpertChatScreen(conversation: conversation),
      ),
    );
  }
}

class ExpertChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ExpertChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends ConsumerState<ExpertChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    _controller.clear();
    setState(() => _isSending = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      try {
        await ref.read(conversationServiceProvider).sendMessage(
              conversationId: widget.conversation.id,
              senderId: user.uid,
              senderName: user.name,
              text: text,
              otherUserId: '',
            );
      } catch (_) {}
    }
    if (mounted) setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';
    final messagesAsync =
        ref.watch(messagesProvider(widget.conversation.id));

    ref.listen(messagesProvider(widget.conversation.id),
        (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
              child: Text(widget.conversation.participantName[0],
                  style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conversation.participantName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
                Text(
                    widget.conversation.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                        fontSize: 11,
                        color: widget.conversation.isOnline
                            ? AppTheme.successGreen
                            : AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue)),
              error: (_, __) => const Center(
                  child: Text('Could not load messages',
                      style: TextStyle(color: AppTheme.textMuted))),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSay hello!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                          height: 1.6),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(
                        context, msg, msg.senderId == uid);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.backgroundGrey,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _isSending
                            ? Colors.grey.shade300
                            : AppTheme.primaryBlue,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg.text,
                style: TextStyle(
                    color: isMe ? Colors.white : AppTheme.textDark,
                    fontSize: 14,
                    height: 1.4)),
            const SizedBox(height: 4),
            Text(_fmtTime(msg.sentAt),
                style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
