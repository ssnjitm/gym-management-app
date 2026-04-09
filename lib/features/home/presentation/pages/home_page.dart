import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  
  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.add(LoadDashboardEvent(gymId: widget.gymId));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
          
          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _homeBloc.add(RefreshDashboardEvent(gymId: widget.gymId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    const SizedBox(height: 16),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        StatsCard(
                          title: 'Total Members',
                          value: state.stats.totalMembers.toString(),
                          icon: Icons.people,
                          color: AppColors.primary,
                          onTap: () {
                            // Navigate to members list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Members list coming soon!')),
                            );
                          },
                        ),
                        StatsCard(
                          title: "Today's Check-ins",
                          value: state.stats.todayCheckins.toString(),
                          icon: Icons.fitness_center,
                          color: AppColors.success,
                          onTap: () {
                            // Show today's attendance
                          },
                        ),
                        StatsCard(
                          title: 'Expiring This Week',
                          value: state.stats.expiringThisWeek.toString(),
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange,
                          onTap: () {
                            // Show expiring members
                          },
                        ),
                        StatsCard(
                          title: 'Monthly Revenue',
                          value: '₹${state.stats.monthlyRevenue.toStringAsFixed(0)}',
                          icon: Icons.currency_rupee,
                          color: AppColors.secondary,
                          onTap: () {
                            // Show revenue details
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Collection Progress
                    _buildCollectionProgress(state),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const QuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activities
                    RecentActivityList(activities: state.recentActivities),
                    
                    const SizedBox(height: 24),
                    
                    // Expiring Members
                    ExpiringMembersList(
                      members: state.expiringMembers,
                      onRenewTap: (memberId) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Renewal for member $memberId coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add member feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${_getTimeOfDay()}!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome back to FitManager',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
                    '₹${state.stats.monthlyRevenue.toStringAsFixed(0)}',
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
                    '₹${state.stats.collectionTarget.toStringAsFixed(0)}',
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