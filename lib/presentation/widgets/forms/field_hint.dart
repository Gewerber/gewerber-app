/// Hint configuration for [CustomTextField].
///
/// [shortText] is shown as the tooltip of the info icon; [longText] (optional)
/// opens the adaptive info sheet with [shortText] as its title. When [topic]
/// is set, the sheet's "more" action deep-links into the guidance system.
class FieldHint {
  const FieldHint({required this.shortText, this.longText, this.topic});

  final String shortText;
  final String? longText;
  final String? topic;
}
