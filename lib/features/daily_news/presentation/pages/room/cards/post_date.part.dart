part of '../daily_news_hbb.dart';

class _PostDate extends StatelessWidget {
  const _PostDate({
    required this.date,
    this.preferRelative = true,
  });

  final DateTime? date;
  final bool preferRelative;

  @override
  Widget build(BuildContext context) {
    final d = date;
    if (d == null) return const SizedBox.shrink();

    final text = _format(context, d);
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.grey.shade500,
      ),
    );
  }

  String _format(BuildContext context, DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (preferRelative && !diff.isNegative) {
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
    }

    final loc = MaterialLocalizations.of(context);
    final md = loc.formatShortMonthDay(d);
    final y = (d.year == now.year) ? '' : ', ${d.year}';
    return '$md$y';
  }
}
