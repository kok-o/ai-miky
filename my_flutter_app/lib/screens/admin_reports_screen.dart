import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/logo_01.dart';
import '../theme/theme_constants.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(l10n.adminPanel, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: scheme.errorContainer.withOpacity(0.1)),
                  const Center(child: Logo01(size: 60, showText: false)),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(child: Center(child: Text(l10n.generalError(snapshot.error.toString()))));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return SliverFillRemaining(child: Center(child: Text(l10n.noReports)));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index].data();
                      final timestamp = data['timestamp'] as Timestamp?;
                      final dateStr = timestamp != null 
                          ? DateFormat('dd.MM.yyyy HH:mm').format(timestamp.toDate())
                          : l10n.unknown;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: ThemeConstants.kDurationMed,
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.errorContainer,
                              child: Icon(Icons.bug_report_rounded, color: scheme.error),
                            ),
                            title: Text(data['userEmail'] ?? l10n.anonymous, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(dateStr),
                            trailing: _StatusChip(status: data['status'] ?? 'new', l10n: l10n),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(data['description'] ?? l10n.noDescription),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (data['status'] != 'fixed')
                                          FilledButton.tonal(
                                            onPressed: () => docs[index].reference.update({'status': 'fixed'}),
                                            child: Text(l10n.fixed),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton.filledTonal(
                                          icon: const Icon(Icons.delete_outline_rounded),
                                          onPressed: () => docs[index].reference.delete(),
                                          color: scheme.error,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;
  const _StatusChip({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'fixed':
        color = Colors.green;
        label = l10n.fixed;
        break;
      case 'new':
      default:
        color = Colors.orange;
        label = l10n.newStatus;
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
