import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// One composer button that groups hands-free, dictation and spoken replies.
///
/// A null callback hides its entry (hands-free unavailable); a disabled entry
/// stays visible but inert.
class VoiceOptionsButton extends StatelessWidget {
  static const buttonKey = Key('voice-options-button');
  static const micKey = Key('voice-options-mic');
  static const handsFreeKey = Key('voice-options-hands-free');
  static const spokenRepliesKey = Key('voice-options-spoken-replies');

  const VoiceOptionsButton({
    required this.micEnabled,
    required this.onMic,
    required this.handsFreeActive,
    required this.handsFreeEnabled,
    required this.onHandsFree,
    required this.spokenReplies,
    required this.onSpokenReplies,
    super.key,
  });

  final bool micEnabled;
  final VoidCallback onMic;

  /// Hands-free session running: the button shows it and the entry stops it.
  final bool handsFreeActive;
  final bool handsFreeEnabled;

  /// Null hides the hands-free entry.
  final VoidCallback? onHandsFree;
  final bool spokenReplies;
  final VoidCallback onSpokenReplies;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.voice_options,
      button: true,
      excludeSemantics: true,
      child: Builder(
        builder: (context) => IconButton(
          key: buttonKey,
          icon: Badge(
            isLabelVisible: handsFreeActive,
            smallSize: 8,
            backgroundColor: scheme.primary,
            child: Icon(
              handsFreeActive
                  ? Icons.graphic_eq
                  : Icons.keyboard_voice_outlined,
            ),
          ),
          tooltip: context.l10n.voice_options,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          onPressed: () => _showMenu(context),
        ),
      ),
    );
  }

  List<_Entry> _entries(BuildContext context) => [
    _Entry(
      key: micKey,
      icon: Icons.mic,
      title: context.l10n.speak_to_hermes,
      enabled: micEnabled,
      onTap: onMic,
    ),
    if (onHandsFree != null)
      _Entry(
        key: handsFreeKey,
        icon: handsFreeActive
            ? Icons.voice_over_off
            : Icons.record_voice_over_outlined,
        title: handsFreeActive
            ? context.l10n.hands_free_stop
            : context.l10n.hands_free_start,
        enabled: handsFreeEnabled,
        onTap: onHandsFree!,
      ),
    _Entry(
      key: spokenRepliesKey,
      icon: spokenReplies ? Icons.volume_up : Icons.volume_off,
      title: context.l10n.spoken_replies,
      value: spokenReplies ? context.l10n.on : context.l10n.off,
      enabled: true,
      onTap: onSpokenReplies,
    ),
  ];

  Future<void> _showMenu(BuildContext context) async {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final rect = Rect.fromPoints(
      box.localToGlobal(Offset.zero, ancestor: overlay),
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
    );
    final entries = _entries(context);
    final picked = await showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
      items: [
        for (var i = 0; i < entries.length; i++)
          PopupMenuItem<int>(
            key: entries[i].key,
            value: i,
            enabled: entries[i].enabled,
            child: Row(
              children: [
                Icon(entries[i].icon),
                const SizedBox(width: 12),
                Expanded(child: Text(entries[i].title)),
                if (entries[i].value != null) ...[
                  const SizedBox(width: 12),
                  Text(entries[i].value!),
                ],
              ],
            ),
          ),
      ],
    );
    if (picked != null) entries[picked].onTap();
  }
}

class _Entry {
  const _Entry({
    required this.key,
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onTap,
    this.value,
  });
  final Key key;
  final IconData icon;
  final String title;
  final String? value;
  final bool enabled;
  final VoidCallback onTap;
}
