/// Hint configuration for [CustomTextField].
///
/// [shortText] is shown as the tooltip of the info icon; [longText] (optional)
/// opens the adaptive info sheet with the field's label as its title. The
/// caller deep-links [longText]'s extended explanation into the guidance
/// system via [CustomTextField.onHintMoreRequested].
class FieldHint {
  const FieldHint({required this.shortText, this.longText});

  final String shortText;
  final String? longText;
}
