import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/widgets/voice_options_button.dart';

Future<void> openVoiceMenu(WidgetTester tester) async {
  final button = find.byKey(VoiceOptionsButton.buttonKey);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> closeVoiceMenu(WidgetTester tester) async {
  await tester.tapAt(const Offset(1, 1));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Opens the voice menu and taps one entry (see [VoiceOptionsButton] keys).
Future<void> tapVoiceEntry(WidgetTester tester, Key entry) async {
  await openVoiceMenu(tester);
  await tester.tap(find.byKey(entry));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Whether the menu currently offers an entry; leaves the menu closed.
Future<bool> voiceMenuHas(WidgetTester tester, Key entry) async {
  await openVoiceMenu(tester);
  final found = find.byKey(entry).evaluate().isNotEmpty;
  await closeVoiceMenu(tester);
  return found;
}
