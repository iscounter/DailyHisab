import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Consistent empty state: friendly icon, headline and optional hint.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.icon,
    required this.message,
    this.hint,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: cs.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Consistent error state; technical details are secondary text, never the
/// headline, and monetary data is only ever shown if the error itself
/// contains it (repository errors do not).
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({required this.details, super.key});

  final String details;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return EmptyStateView(
      icon: Icons.error_outline,
      message: t.somethingWrong,
      hint: t.errorWithDetails(details),
    );
  }
}

/// Semantics wrapper so color-only states are also announced.
class StatusSemantic extends StatelessWidget {
  const StatusSemantic({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(label: label, excludeSemantics: true, child: child);
  }
}
