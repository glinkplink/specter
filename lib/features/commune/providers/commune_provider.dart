import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/premium_provider.dart';

enum MessageRole { user, spirit }

class SessionSummary {
  final int messagesReceived;
  final int questionsSent;
  final int durationSeconds;
  final int remainingSessions;

  SessionSummary({
    required this.messagesReceived,
    required this.questionsSent,
    required this.durationSeconds,
    required this.remainingSessions,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class Message {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isSeanceResponse;

  Message({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isSeanceResponse = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toApiFormat() {
    return {
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
    };
  }
}

class CommuneState {
  final String? sessionId;
  final List<Message> messages;
  final bool isConnecting;
  final bool isSessionActive;
  final double connectionStrength;
  final int sessionCount;
  final int seanceCount; // Track free séance usage
  final bool isPremium;
  final String? error;
  final bool isRecordingSeance;
  final int sessionSecondsRemaining; // Time left in current session
  final DateTime? sessionStartTime;
  final SessionSummary? pendingSummary; // Summary to show after session ends

  const CommuneState({
    this.sessionId,
    this.messages = const [],
    this.isConnecting = false,
    this.isSessionActive = false,
    this.connectionStrength = 0.0,
    this.sessionCount = 0,
    this.seanceCount = 0,
    this.isPremium = false,
    this.error,
    this.isRecordingSeance = false,
    this.sessionSecondsRemaining = 300, // 5 minutes
    this.sessionStartTime,
    this.pendingSummary,
  });

  static const int sessionDurationSeconds = 300; // 5 minutes
  static const int maxFreeSeances = 1;

  bool get hasSessionsRemaining =>
      isPremium || sessionCount < SupabaseConfig.maxFreeSessions;

  int get remainingSessions =>
      isPremium ? -1 : SupabaseConfig.maxFreeSessions - sessionCount;

  bool get hasSeancesRemaining => isPremium || seanceCount < maxFreeSeances;

  int get remainingSeances => isPremium ? -1 : maxFreeSeances - seanceCount;

  CommuneState copyWith({
    String? sessionId,
    List<Message>? messages,
    bool? isConnecting,
    bool? isSessionActive,
    double? connectionStrength,
    int? sessionCount,
    int? seanceCount,
    bool? isPremium,
    String? error,
    bool? isRecordingSeance,
    int? sessionSecondsRemaining,
    DateTime? sessionStartTime,
    SessionSummary? pendingSummary,
    bool clearPendingSummary = false,
  }) {
    return CommuneState(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isConnecting: isConnecting ?? this.isConnecting,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      connectionStrength: connectionStrength ?? this.connectionStrength,
      sessionCount: sessionCount ?? this.sessionCount,
      seanceCount: seanceCount ?? this.seanceCount,
      isPremium: isPremium ?? this.isPremium,
      error: error,
      isRecordingSeance: isRecordingSeance ?? this.isRecordingSeance,
      sessionSecondsRemaining:
          sessionSecondsRemaining ?? this.sessionSecondsRemaining,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      pendingSummary:
          clearPendingSummary ? null : (pendingSummary ?? this.pendingSummary),
    );
  }
}

class CommuneNotifier extends StateNotifier<CommuneState> {
  CommuneNotifier(this.ref) : super(const CommuneState()) {
    _loadSessionCount();

    // Listen to premium status changes
    ref.listen<PremiumState>(premiumProvider, (previous, next) {
      if (previous?.isPremium != next.isPremium) {
        state = state.copyWith(isPremium: next.isPremium);
      }
    });
  }

  final Ref ref;
  Timer? _connectionStrengthTimer;
  Timer? _sessionTimer;
  final List<int> _usedFallbackIndices = [];

  Future<void> _loadSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('commune_session_count') ?? 0;
    final seanceCount = prefs.getInt('commune_seance_count') ?? 0;
    state = state.copyWith(sessionCount: count, seanceCount: seanceCount);
  }

  Future<void> _saveSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('commune_session_count', state.sessionCount);
  }

  Future<void> _saveSeanceCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('commune_seance_count', state.seanceCount);
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isSessionActive) {
        timer.cancel();
        return;
      }

      final remaining = state.sessionSecondsRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        _autoEndSession();
      } else {
        state = state.copyWith(sessionSecondsRemaining: remaining);
      }
    });
  }

  Future<void> _autoEndSession() async {
    // Add a final "connection fading" message from spirit
    final fadingMessage = Message(
      role: MessageRole.spirit,
      content: _getSessionEndingMessage(),
    );

    state = state.copyWith(
      messages: [...state.messages, fadingMessage],
    );

    // Wait a moment then end
    await Future.delayed(const Duration(seconds: 2));
    await endSession(showSummary: true);
  }

  String _getSessionEndingMessage() {
    final messages = [
      "...the veil grows heavy... our time fades... return to me soon...",
      "...I cannot hold this connection... there is more to say... come back...",
      "...the channel closes... but I will wait... I have waited so long already...",
      "...something important... I must tell you... no... the darkness takes me...",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  Future<bool> startSession() async {
    if (!state.hasSessionsRemaining) {
      state =
          state.copyWith(error: 'No sessions remaining. Upgrade to continue.');
      return false;
    }

    state = state.copyWith(
      isConnecting: true,
      error: null,
    );

    // Simulate connection animation
    _startConnectionAnimation();

    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(
      sessionId: const Uuid().v4(),
      isConnecting: false,
      isSessionActive: true,
      messages: [],
      connectionStrength: 0.7 + (DateTime.now().millisecond % 30) / 100,
      sessionSecondsRemaining: CommuneState.sessionDurationSeconds,
      sessionStartTime: DateTime.now(),
    );

    // Start the session countdown timer
    _startSessionTimer();

    return true;
  }

  void _startConnectionAnimation() {
    _connectionStrengthTimer?.cancel();
    double strength = 0.0;

    _connectionStrengthTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!state.isConnecting) {
        timer.cancel();
        return;
      }

      strength += 0.05;
      if (strength > 1.0) strength = 1.0;

      state = state.copyWith(connectionStrength: strength);
    });
  }

  void _fluctuateConnectionStrength() {
    _connectionStrengthTimer?.cancel();

    _connectionStrengthTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!state.isSessionActive) {
        timer.cancel();
        return;
      }

      final variation = (DateTime.now().millisecond % 20 - 10) / 100;
      final newStrength =
          (state.connectionStrength + variation).clamp(0.5, 1.0);

      state = state.copyWith(connectionStrength: newStrength);
    });
  }

  Future<void> sendMessage(String text, {bool isSeanceMessage = false}) async {
    if (!state.isSessionActive || text.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      role: MessageRole.user,
      content: text.trim(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isConnecting: true,
    );

    try {
      // Ensure we have a JWT for the edge function without forcing explicit login.
      final client = Supabase.instance.client;
      var session = client.auth.currentSession;
      if (session == null) {
        try {
          session = (await client.auth.signInAnonymously()).session;
        } catch (_) {
          // If anonymous auth isn't enabled server-side, the edge function will reject the call.
        }
      }

      if (session == null) {
        throw Exception('Not authenticated');
      }

      // Build conversation history for API
      final conversationHistory = state.messages
          .where((m) => m != userMessage)
          .map((m) => m.toApiFormat())
          .toList();

      // Call Supabase Edge Function
      if (kDebugMode) {
        debugPrint(
            'CommuneProvider: calling edge function ${SupabaseConfig.communeFunctionUrl}');
      }

      final response = await http
          .post(
            Uri.parse(SupabaseConfig.communeFunctionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.accessToken}',
              // Some deployments expect the apikey header in addition to the JWT.
              'apikey': SupabaseConfig.supabaseAnonKey,
            },
            body: jsonEncode({
              'message': text.trim(),
              'conversation_history': conversationHistory,
              'seance_audio_recorded': isSeanceMessage,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('CommuneProvider: response ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final spiritResponse = data['response'] as String;

        // Add spirit message
        final spiritMessage = Message(
          role: MessageRole.spirit,
          content: spiritResponse,
          isSeanceResponse: isSeanceMessage,
        );

        state = state.copyWith(
          messages: [...state.messages, spiritMessage],
          isConnecting: false,
        );

        _fluctuateConnectionStrength();
      } else {
        throw Exception('Status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CommuneProvider: error calling edge function: $e');
      }
      // Fallback response if API fails
      final fallbackMessage = Message(
        role: MessageRole.spirit,
        content: _getFallbackResponse(isSeanceMessage),
        isSeanceResponse: isSeanceMessage,
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackMessage],
        isConnecting: false,
      );
    }
  }

  String _getFallbackResponse(bool isSeance) {
    // These are only used when the API fails - keep them atmospheric but brief
    final responses = isSeance
        ? [
            'The static clears... I heard something... your name perhaps',
            'A voice in the noise... it spoke of you... listen again',
            'The recording captured more than sound... there was a presence',
            'In the silence between sounds... someone waits for you',
          ]
        : [
            'The connection weakens... ask again... I am here',
            'Your question echoes... give me a moment... the veil is thick',
            'I sense your presence... speak clearly... I will answer',
            'The channel fades... but I heard you... try once more',
          ];

    // Reset if we've used all responses
    if (_usedFallbackIndices.length >= responses.length) {
      _usedFallbackIndices.clear();
    }

    // Find an unused index
    int index;
    do {
      index = DateTime.now().millisecond % responses.length;
    } while (_usedFallbackIndices.contains(index));

    _usedFallbackIndices.add(index);
    return responses[index];
  }

  bool canUseSeance() {
    return state.hasSeancesRemaining;
  }

  void setRecordingSeance(bool isRecording) {
    state = state.copyWith(isRecordingSeance: isRecording);
  }

  Future<bool> sendSeanceMessage() async {
    if (!state.hasSeancesRemaining) {
      state =
          state.copyWith(error: 'Séance requires premium. Upgrade to unlock.');
      return false;
    }

    await sendMessage(
      'I just recorded audio from my surroundings. What did you hear?',
      isSeanceMessage: true,
    );

    // Increment séance count after use
    final newSeanceCount = state.seanceCount + 1;
    state = state.copyWith(seanceCount: newSeanceCount);
    await _saveSeanceCount();

    return true;
  }

  // Get session summary before ending
  SessionSummary getSessionSummary() {
    final spiritMessages =
        state.messages.where((m) => m.role == MessageRole.spirit).length;
    final userMessages =
        state.messages.where((m) => m.role == MessageRole.user).length;
    final duration = state.sessionStartTime != null
        ? DateTime.now().difference(state.sessionStartTime!).inSeconds
        : 0;

    return SessionSummary(
      messagesReceived: spiritMessages,
      questionsSent: userMessages,
      durationSeconds: duration,
      remainingSessions: state.isPremium
          ? -1
          : SupabaseConfig.maxFreeSessions - state.sessionCount - 1,
    );
  }

  Future<void> endSession({bool showSummary = false}) async {
    _connectionStrengthTimer?.cancel();
    _sessionTimer?.cancel();

    // Get summary before clearing state
    final summary = showSummary ? getSessionSummary() : null;

    // Increment session count
    final newCount = state.sessionCount + 1;

    state = state.copyWith(
      sessionId: null,
      isSessionActive: false,
      messages: [],
      connectionStrength: 0.0,
      sessionCount: newCount,
      sessionSecondsRemaining: CommuneState.sessionDurationSeconds,
      sessionStartTime: null,
      pendingSummary: summary,
    );

    await _saveSessionCount();
  }

  void clearPendingSummary() {
    state = state.copyWith(clearPendingSummary: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _connectionStrengthTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}

final communeProvider =
    StateNotifierProvider<CommuneNotifier, CommuneState>((ref) {
  return CommuneNotifier(ref);
});
