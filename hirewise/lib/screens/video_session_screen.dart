import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class VideoSessionScreen extends StatefulWidget {
  final String roomName;
  final String partnerName;
  final String subject;
  final String scheduledTime;
  final bool isTutor;

  const VideoSessionScreen({
    super.key,
    required this.roomName,
    required this.partnerName,
    required this.subject,
    required this.scheduledTime,
    required this.isTutor,
  });

  @override
  State<VideoSessionScreen> createState() => _VideoSessionScreenState();
}

class _VideoSessionScreenState extends State<VideoSessionScreen> {
  bool _joined = false;

  String get _jitsiUrl => 'https://meet.jit.si/${widget.roomName}';

  Future<void> _joinSession() async {
    final uri = Uri.parse(_jitsiUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (mounted) setState(() => _joined = true);
    } catch (_) {
      if (mounted) _showCopyFallback();
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _jitsiUrl));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Room link copied! Share it with your partner.'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  void _showCopyFallback() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Join Session',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Open this link in your browser to join:',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _copyLink,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_jitsiUrl,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.primaryBlue)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_rounded,
                        size: 16, color: AppTheme.primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _copyLink();
              Navigator.pop(context);
              setState(() => _joined = true);
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isTutor ? const Color(0xFF059669) : AppTheme.primaryBlue;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Video Session',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Session info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.subject,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                      widget.isTutor
                          ? 'Session with ${widget.partnerName}'
                          : 'Tutored by ${widget.partnerName}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(widget.scheduledTime,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // How it works banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Both you and ${widget.partnerName} tap "Join Video Session" on the same booking — you\'ll be connected in the same private room automatically.',
                      style: TextStyle(
                          fontSize: 12, color: color, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Room link card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Private Room',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 11, color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Text('End-to-end encrypted',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _copyLink,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_jitsiUrl,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textMuted),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.copy_rounded, size: 16, color: color),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Room ID: ${widget.roomName}',
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Before You Join',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  const SizedBox(height: 12),
                  _tip(Icons.mic_rounded,
                      'Allow microphone access when prompted', color),
                  const SizedBox(height: 8),
                  _tip(Icons.videocam_rounded,
                      'Allow camera access for video', color),
                  const SizedBox(height: 8),
                  _tip(Icons.wifi_rounded,
                      'Use a stable internet connection', color),
                  const SizedBox(height: 8),
                  _tip(Icons.people_rounded,
                      'Both parties must tap Join to connect', color),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Join button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _joinSession,
                icon: Icon(
                    _joined
                        ? Icons.check_circle_rounded
                        : Icons.videocam_rounded,
                    size: 22),
                label: Text(_joined ? 'Rejoin Session' : 'Join Video Session',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            if (_joined) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text('Session opened — waiting for ${widget.partnerName}',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _tip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ),
      ],
    );
  }
}
