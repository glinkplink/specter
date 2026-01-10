import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_service.dart';
import 'providers/commune_provider.dart';
import 'widgets/spirit_message_bubble.dart';
import 'widgets/user_message_bubble.dart';
import 'widgets/connection_overlay.dart';
import 'widgets/seance_recorder.dart';

class CommuneScreen extends ConsumerStatefulWidget {
  const CommuneScreen({super.key});

  @override
  ConsumerState<CommuneScreen> createState() => _CommuneScreenState();
}

class _CommuneScreenState extends ConsumerState<CommuneScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await ref.read(communeProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _startSession() async {
    await ref.read(communeProvider.notifier).startSession();
  }

  Future<void> _endSession() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('End Session?'),
        content: const Text(
          'The spirit connection will be severed. This session will count toward your limit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Session'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'End Session',
              style: TextStyle(color: AppColors.zoneActive),
            ),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      await ref.read(communeProvider.notifier).endSession(showSummary: true);
    }
  }

  void _showSessionSummary(SessionSummary summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.ghostlyPurple),
            const SizedBox(width: 8),
            const Text('Session Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow('Duration', summary.formattedDuration),
            _summaryRow('Messages received', '${summary.messagesReceived}'),
            _summaryRow('Questions asked', '${summary.questionsSent}'),
            const SizedBox(height: 16),
            if (summary.remainingSessions >= 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.ghostlyPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      summary.remainingSessions > 0 ? Icons.hourglass_bottom : Icons.lock,
                      color: AppColors.ghostlyPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.remainingSessions > 0
                            ? '${summary.remainingSessions} session${summary.remainingSessions == 1 ? '' : 's'} remaining'
                            : 'The spirits have more to say...\nUpgrade to continue',
                        style: TextStyle(
                          color: AppColors.boneWhite.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          if (summary.remainingSessions == 0)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/paywall');
              },
              child: Text(
                'Upgrade',
                style: TextStyle(color: AppColors.spectralGreen),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.boneWhite.withOpacity(0.7))),
          Text(value, style: TextStyle(color: AppColors.boneWhite, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communeState = ref.watch(communeProvider);

    // Scroll to bottom when new messages arrive
    ref.listen<CommuneState>(communeProvider, (previous, next) {
      final prevLength = previous?.messages.length ?? 0;
      final nextLength = next.messages.length;
      if (prevLength != nextLength) {
        _scrollToBottom();
      }
      
      // Show summary when session auto-ends
      if (next.pendingSummary != null && previous?.pendingSummary == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSessionSummary(next.pendingSummary!);
          ref.read(communeProvider.notifier).clearPendingSummary();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('COMMUNE'),
        centerTitle: true,
        actions: [
          if (communeState.isSessionActive)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _endSession,
              tooltip: 'End Session',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.deepBlack,
                  AppColors.darkGray.withOpacity(0.3),
                  AppColors.deepBlack,
                ],
              ),
            ),
          ),

          // Main content
          if (!communeState.isSessionActive && !communeState.isConnecting)
            _buildStartScreen(communeState)
          else if (communeState.isConnecting && !communeState.isSessionActive)
            ConnectionOverlay(strength: communeState.connectionStrength)
          else
            _buildChatScreen(communeState),

          // Error snackbar
          if (communeState.error != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.zoneActive.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    communeState.error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartScreen(CommuneState communeState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mystical icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ghostlyPurple.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 60,
                color: AppColors.ghostlyPurple,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds),

            const SizedBox(height: 32),

            Text(
              'Reach Beyond the Veil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.boneWhite,
                    letterSpacing: 2,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Open a channel to communicate with spirits. Ask questions and receive messages from beyond.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.boneWhite.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Session info
            if (!communeState.isPremium) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.midGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  communeState.hasSessionsRemaining
                      ? '${communeState.remainingSessions} sessions remaining'
                      : 'No sessions remaining',
                  style: TextStyle(
                    color: communeState.hasSessionsRemaining
                        ? AppColors.boneWhite.withOpacity(0.7)
                        : AppColors.zoneActive,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Start button or Spirit Waiting teaser
            if (communeState.hasSessionsRemaining)
              ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ghostlyPurple,
                  foregroundColor: AppColors.boneWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Begin Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              )
            else ...[
              // Spirit waiting teaser
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.ghostlyPurple.withOpacity(0.2),
                      AppColors.ghostlyPurple.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.ghostlyPurple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.sensors,
                      color: AppColors.ghostlyPurple,
                      size: 32,
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fade(begin: 0.5, end: 1.0, duration: 1500.ms),
                    const SizedBox(height: 12),
                    Text(
                      'A presence is waiting...',
                      style: TextStyle(
                        color: AppColors.ghostlyPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Something important was left unsaid.\nThe spirits have more to reveal.',
                      style: TextStyle(
                        color: AppColors.boneWhite.withOpacity(0.7),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push('/paywall'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.spectralGreen,
                  foregroundColor: AppColors.deepBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatScreen(CommuneState communeState) {
    return Column(
      children: [
        // Connection strength and timer indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sensors,
                size: 16,
                color: AppColors.ghostlyPurple.withOpacity(communeState.connectionStrength),
              ),
              const SizedBox(width: 8),
              Text(
                'Connection: ${(communeState.connectionStrength * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.boneWhite.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.hourglass_bottom,
                size: 14,
                color: communeState.sessionSecondsRemaining < 60
                    ? AppColors.zoneActive
                    : AppColors.boneWhite.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(communeState.sessionSecondsRemaining),
                style: TextStyle(
                  color: communeState.sessionSecondsRemaining < 60
                      ? AppColors.zoneActive
                      : AppColors.boneWhite.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: communeState.sessionSecondsRemaining < 60 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: communeState.messages.isEmpty
              ? Center(
                  child: Text(
                    'The spirits await your question...',
                    style: TextStyle(
                      color: AppColors.boneWhite.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: communeState.messages.length,
                  itemBuilder: (context, index) {
                    final message = communeState.messages[index];
                    if (message.role == MessageRole.user) {
                      return UserMessageBubble(message: message);
                    } else {
                      return SpiritMessageBubble(
                        message: message,
                        isLatest: index == communeState.messages.length - 1,
                      );
                    }
                  },
                ),
        ),

        // Loading indicator
        if (communeState.isConnecting && communeState.isSessionActive)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.ghostlyPurple),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'The spirit responds...',
                  style: TextStyle(
                    color: AppColors.ghostlyPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Séance recorder
        if (communeState.isRecordingSeance)
          SeanceRecorder(
            onComplete: () async {
              ref.read(communeProvider.notifier).setRecordingSeance(false);
              await ref.read(communeProvider.notifier).sendSeanceMessage();
              _scrollToBottom();
            },
            onCancel: () {
              ref.read(communeProvider.notifier).setRecordingSeance(false);
            },
          ),

        // Input area
        if (!communeState.isRecordingSeance)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBlack.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Séance button
                IconButton(
                  onPressed: communeState.isConnecting
                      ? null
                      : () {
                          final canUse = ref.read(communeProvider.notifier).canUseSeance();
                          if (canUse) {
                            ref.read(communeProvider.notifier).setRecordingSeance(true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Séance mode requires premium'),
                                action: SnackBarAction(
                                  label: 'Upgrade',
                                  onPressed: () => context.push('/paywall'),
                                ),
                              ),
                            );
                          }
                        },
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.mic,
                        color: communeState.isConnecting
                            ? AppColors.lightGray
                            : communeState.hasSeancesRemaining
                                ? AppColors.ghostlyPurple
                                : AppColors.lightGray,
                      ),
                      if (!communeState.hasSeancesRemaining)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.lock,
                            size: 12,
                            color: AppColors.zoneActive,
                          ),
                        ),
                    ],
                  ),
                  tooltip: communeState.hasSeancesRemaining 
                      ? 'Séance Mode' 
                      : 'Séance Mode (Premium)',
                ),
                const SizedBox(width: 8),

                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !communeState.isConnecting,
                    decoration: InputDecoration(
                      hintText: 'Ask the spirits...',
                      hintStyle: TextStyle(color: AppColors.lightGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.ghostlyPurple),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                FloatingActionButton(
                  onPressed: communeState.isConnecting ? null : _sendMessage,
                  mini: true,
                  backgroundColor: AppColors.ghostlyPurple,
                  child: Icon(
                    Icons.send,
                    color: communeState.isConnecting
                        ? AppColors.lightGray
                        : AppColors.boneWhite,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
