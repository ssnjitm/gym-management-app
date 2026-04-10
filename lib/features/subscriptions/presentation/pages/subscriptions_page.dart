import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subscription_list_item_entity.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';

class SubscriptionsPage extends StatefulWidget {
  final String gymId;

  const SubscriptionsPage({super.key, required this.gymId});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    context.read<SubscriptionsBloc>().add(SubscriptionsStarted(gymId: widget.gymId));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionsBloc, SubscriptionsState>(
      listenWhen: (p, c) => p.error != c.error || p.lastActionMessage != c.lastActionMessage,
      listener: (context, state) {
        final msg = state.lastActionMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
        final err = state.error;
        if (err != null && err.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscriptions'),
            actions: [
              IconButton(
                onPressed: () => context.read<SubscriptionsBloc>().add(SubscriptionsRefreshRequested(gymId: widget.gymId)),
                icon: const Icon(Icons.refresh),
              ),
            ],
            bottom: TabBar(
              controller: _tab,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Expiring (7d)'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              _List(
                loading: state.loadingAll,
                items: state.all,
                gymId: widget.gymId,
              ),
              _List(
                loading: state.loadingExpiring,
                items: state.expiring,
                gymId: widget.gymId,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _List extends StatelessWidget {
  final bool loading;
  final List<SubscriptionListItemEntity> items;
  final String gymId;

  const _List({
    required this.loading,
    required this.items,
    required this.gymId,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(child: Text('No subscriptions found.'));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        final s = item.subscription;
        final expiry = '${s.expiryDate.year}-${s.expiryDate.month.toString().padLeft(2, '0')}-${s.expiryDate.day.toString().padLeft(2, '0')}';
        final status = s.status;

        return ListTile(
          title: Text(item.memberName),
          subtitle: Text('${item.packageName} • Expires: $expiry • $status'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'open_member') {
                Navigator.pushNamed(context, '/member', arguments: {'memberId': s.memberId});
                return;
              }
              context.read<SubscriptionsBloc>().add(
                    SubscriptionStatusChangeRequested(
                      subscriptionId: s.subscriptionId,
                      status: value,
                      gymId: gymId,
                    ),
                  );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'open_member', child: Text('Open member detail')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'active', child: Text('Set status: active')),
              PopupMenuItem(value: 'grace', child: Text('Freeze (set grace)')),
              PopupMenuItem(value: 'cancelled', child: Text('Set status: cancelled')),
              PopupMenuItem(value: 'expired', child: Text('Set status: expired')),
            ],
          ),
          onTap: () => Navigator.pushNamed(context, '/member', arguments: {'memberId': s.memberId}),
        );
      },
    );
  }
}

