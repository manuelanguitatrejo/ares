import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/widgets/voice_options_button.dart';
import 'package:hermes_android/l10n/app_localizations.dart';

import 'support/voice_menu.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool micEnabled = true,
  bool handsFreeActive = false,
  VoidCallback? onHandsFree,
  bool spokenReplies = true,
  VoidCallback? onMic,
  VoidCallback? onSpoken,
}) {
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomRight,
          child: VoiceOptionsButton(
            micEnabled: micEnabled,
            onMic: onMic ?? () {},
            handsFreeActive: handsFreeActive,
            handsFreeEnabled: true,
            onHandsFree: onHandsFree,
            spokenReplies: spokenReplies,
            onSpokenReplies: onSpoken ?? () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('menu offers the three voice controls with their labels', (
    tester,
  ) async {
    await _pump(tester, onHandsFree: () {});
    await openVoiceMenu(tester);
    expect(find.text('Speak to Hermes'), findsOneWidget);
    expect(find.text('Start hands-free'), findsOneWidget);
    expect(find.text('Spoken replies'), findsOneWidget);
    expect(find.text('On'), findsOneWidget);
  });

  testWidgets('each entry runs its own action and closes the menu', (
    tester,
  ) async {
    final calls = <String>[];
    await _pump(
      tester,
      onMic: () => calls.add('mic'),
      onHandsFree: () => calls.add('hf'),
      onSpoken: () => calls.add('tts'),
    );
    await tapVoiceEntry(tester, VoiceOptionsButton.micKey);
    await tapVoiceEntry(tester, VoiceOptionsButton.handsFreeKey);
    await tapVoiceEntry(tester, VoiceOptionsButton.spokenRepliesKey);
    expect(calls, ['mic', 'hf', 'tts']);
    expect(find.byKey(VoiceOptionsButton.micKey), findsNothing);
  });

  testWidgets('hands-free entry is hidden when unavailable', (tester) async {
    await _pump(tester);
    expect(
      await voiceMenuHas(tester, VoiceOptionsButton.handsFreeKey),
      isFalse,
    );
    expect(await voiceMenuHas(tester, VoiceOptionsButton.micKey), isTrue);
  });

  testWidgets('active hands-free offers Stop and marks the button', (
    tester,
  ) async {
    await _pump(tester, handsFreeActive: true, onHandsFree: () {});
    expect(find.byType(Badge), findsOneWidget);
    await openVoiceMenu(tester);
    expect(find.text('Stop hands-free'), findsOneWidget);
  });

  testWidgets('disabled microphone is shown but inert; speaker shows Off', (
    tester,
  ) async {
    var mic = 0;
    await _pump(
      tester,
      micEnabled: false,
      spokenReplies: false,
      onMic: () => mic++,
    );
    await openVoiceMenu(tester);
    expect(find.text('Off'), findsOneWidget);
    await tester.tap(find.byKey(VoiceOptionsButton.micKey));
    await tester.pump();
    expect(mic, 0);
  });
}
