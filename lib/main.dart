import 'package:flutter/material.dart';

import 'theme/theme.dart';

void main() {
  runApp(const GewerberApp());
}

class GewerberApp extends StatelessWidget {
  const GewerberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gewerber',
      debugShowCheckedModeBanner: false,
      theme: GewerberTheme.light(),
      darkTheme: GewerberTheme.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gewerber')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(GewerberTokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Business. Simplified.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: GewerberTokens.space8),
                  Text(
                    'Welcome to Gewerber — a friendly platform for solo '
                    'business owners in Germany.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: GewerberTokens.space24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Let’s start'),
                        ),
                      ),
                      const SizedBox(width: GewerberTokens.space12),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Learn more'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
