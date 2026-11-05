import 'package:flutter/material.dart';

import '../widgets/status_view.dart';

/// Empty screen with the right title and Back (skeleton DoD).
/// Each owner replaces their placeholder with the real screen in app_router.dart.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.id,
    required this.title,
    required this.owner,
    this.params = const {},
    this.isTabRoot = false,
  });

  final String id;
  final String title;
  final String owner;
  final Map<String, String> params;
  final bool isTabRoot;

  @override
  Widget build(BuildContext context) {
    final details = params.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: !isTabRoot),
      body: StatusView(
        icon: Icons.construction,
        title: '$id: $title',
        message: ['Owner: $owner', if (details.isNotEmpty) details].join('\n'),
      ),
    );
  }
}
