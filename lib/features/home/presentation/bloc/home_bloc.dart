import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_recent_activities.dart';
import '../../domain/usecases/get_expiring_members.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardStats getDashboardStats;
  final GetRecentActivities getRecentActivities;
  final GetExpiringMembers getExpiringMembers;
  
  HomeBloc({
    required this.getDashboardStats,
    required this.getRecentActivities,
    required this.getExpiringMembers,
  }) : super(HomeInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }
  
  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    
    final statsResult = await getDashboardStats(event.gymId);
    final activitiesResult = await getRecentActivities(event.gymId);
    final expiringResult = await getExpiringMembers(event.gymId);
    
    statsResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) {
        activitiesResult.fold(
          (failure) => emit(HomeError(failure.message)),
          (activities) {
            expiringResult.fold(
              (failure) => emit(HomeError(failure.message)),
              (expiring) {
                emit(HomeLoaded(
                  stats: stats,
                  recentActivities: activities,
                  expiringMembers: expiring,
                ));
              },
            );
          },
        );
      },
    );
  }
  
  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    add(LoadDashboardEvent(gymId: event.gymId));
  }
}