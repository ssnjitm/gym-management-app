import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:members_management_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/expiring_members_list.dart';
import '../widgets/quick_actions.dart';
import '../../../../core/themes/color_schemes.dart';

class HomePage extends StatefulWidget {
  final String gymId;
  
  const HomePage({super.key, required this.gymId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  String _role = 'reception';
  String _staffName = 'Staff';
  String _gymName = '';
  final _supabase = supabase.Supabase.instance.client;
  
  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _role = authState.staff.role.toLowerCase();
      _staffName = authState.staff.fullName;
      _loadGymName(authState.staff.gymId);
    }
    if (_role != 'super_admin') {
      _homeBloc.add(LoadDashboardEvent(gymId: widget.gymId));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Gym Management',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications coming soon!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                // Navigate to profile
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutEvent());
              },
            ),
          ],
        ),
        body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _homeBloc.add(LoadDashboardEvent(gymId: widget.gymId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (_role == 'super_admin') {
            return _buildSuperAdminDashboard();
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                _homeBloc.add(RefreshDashboardEvent(gymId: widget.gymId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: _cardAspectRatio(context),
                      children: [
                        StatsCard(
                          title: 'Total Members',
                          value: state.stats.totalMembers.toString(),
                          icon: Icons.people_outline,
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.pushNamed(context, '/members', arguments: {'gymId': widget.gymId});
                          },
                        ),
                        StatsCard(
                          title: "Today's Attendance",
                          value: state.stats.todayCheckins.toString(),
                          icon: Icons.how_to_reg_outlined,
                          color: AppColors.success,
                          onTap: () {
                            // Show today's attendance
                          },
                        ),
                        StatsCard(
                          title: 'Expiring Soon',
                          value: state.stats.expiringThisWeek.toString(),
                          icon: Icons.timer_outlined,
                          color: AppColors.warning,
                          onTap: () {
                            // Show expiring members
                          },
                        ),
                        StatsCard(
                          title: 'Revenue',
                          value: 'NPR ${state.stats.monthlyRevenue.toStringAsFixed(0)}',
                          icon: Icons.payments_outlined,
                          color: AppColors.info,
                          onTap: () {
                            // Show revenue details
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    QuickActions(gymId: widget.gymId, role: _role),
                    
                    const SizedBox(height: 32),
                    
                    // Collection Progress Card
                    _buildCollectionProgress(state),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RecentActivityList(activities: state.recentActivities),
                    
                    const SizedBox(height: 32),
                    
                    // Expiring Members Header
                    Text(
                      'Expiring Subscriptions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpiringMembersList(
                      members: state.expiringMembers,
                      onRenewTap: (memberId) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Renewal for member $memberId coming soon!')),
                        );
                      },
                    ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildSuperAdminDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(
            subtitle: 'Control all gyms, settings, and multi-tenant operations.',
          ),
          const SizedBox(height: 24),
          Text(
            'Platform Controls',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: _cardAspectRatio(context),
            children: [
              StatsCard(
                title: 'Gyms',
                value: 'Manage',
                icon: Icons.business,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/manage', arguments: {'gymId': widget.gymId}),
              ),
              StatsCard(
                title: 'All Payments',
                value: 'View',
                icon: Icons.payments_outlined,
                color: AppColors.info,
                onTap: () => Navigator.pushNamed(context, '/payments', arguments: {'gymId': widget.gymId}),
              ),
              StatsCard(
                title: 'All Subscriptions',
                value: 'View',
                icon: Icons.receipt_long_outlined,
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, '/subscriptions', arguments: {'gymId': widget.gymId}),
              ),
              StatsCard(
                title: 'Attendance',
                value: 'Track',
                icon: Icons.how_to_reg_outlined,
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(context, '/attendance', arguments: {'gymId': widget.gymId}),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'All Gyms',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 12),

          //loading gyms 
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadGyms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final gyms = snapshot.data ?? const [];
              if (gyms.isEmpty) {
                return const Text('No gyms found.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gyms.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final g = gyms[index];
                  return Card(
                    child: ListTile(
                      title: Text((g['gym_name'] ?? '').toString()),
                      subtitle: Text((g['address'] ?? '').toString()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/manage',
                        arguments: {'gymId': (g['gym_id'] ?? '').toString()},
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),
          QuickActions(gymId: widget.gymId, role: _role),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadGyms() async {
    final res = await _supabase
        .from('gyms')
        .select('gym_id, gym_name, address')
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }
  
  Widget _buildWelcomeSection({String? subtitle}) {
    final roleLabel = _role.replaceAll('_', ' ');
    final headingRole = roleLabel.isEmpty ? 'Staff' : '${roleLabel[0].toUpperCase()}${roleLabel.substring(1)}';
    final gymText = _role == 'super_admin'
        ? 'Platform access: All gyms'
        : (_gymName.isEmpty ? 'Gym: ${widget.gymId}' : 'Gym: $_gymName');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getTimeOfDay()}, $headingRole!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _role == 'super_admin'
                      ? 'Welcome $_staffName. You can operate every gym in the platform.'
                      : 'Welcome $_staffName. Manage your gym operations smoothly.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gymText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.wb_sunny_outlined,
            size: 48,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
  
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  double _cardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.0;
    if (width < 420) return 1.15;
    return 1.35;
  }

  Future<void> _loadGymName(String gymId) async {
    if (_role == 'super_admin') return;
    try {
      final res = await _supabase.from('gyms').select('gym_name').eq('gym_id', gymId).maybeSingle();
      if (!mounted) return;
      setState(() {
        _gymName = (res?['gym_name'] ?? '').toString();
      });
    } catch (_) {
      // Keep fallback to gym id text.
    }
  }
  
  Widget _buildCollectionProgress(HomeLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Collection Target',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NPR ${state.stats.monthlyRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Collected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NPR ${state.stats.collectionTarget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.stats.collectionPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.stats.collectionPercentage.toStringAsFixed(1)}% of target achieved',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}