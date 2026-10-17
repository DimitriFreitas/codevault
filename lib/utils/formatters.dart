/// Formats a timestamp as `dd/MM/yyyy HH:mm` in local time.
///
/// Kept dependency-free on purpose (no `intl` package for a single format).
String formatDateTime(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}
