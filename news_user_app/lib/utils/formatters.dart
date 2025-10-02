
String timeAgo(DateTime? dateTime) {
  if (dateTime == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inSeconds < 45) return 'just now';
  if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) return '$weeks wk${weeks == 1 ? '' : 's'} ago';

  final months = (diff.inDays / 30).floor();
  if (months < 12) return '$months mo${months == 1 ? '' : 's'} ago';

  final years = (diff.inDays / 365).floor();
  return '$years yr${years == 1 ? '' : 's'} ago';
}
