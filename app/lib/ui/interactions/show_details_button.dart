import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final detailsModeProvider = StateProvider<bool>((ref) => false);

class ShowDetailsButton extends ConsumerWidget {
  const ShowDetailsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsMode = ref.watch(detailsModeProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 130, // Set the desired width
        height: 40, // Set the desired height
        child: ElevatedButton(
          onPressed: () {
            ref.read(detailsModeProvider.notifier).state = !detailsMode;
          },
          child: Text(detailsMode ? 'Details: YES' : 'Details: NO '),
        ),
      ),
    );
  }
}