import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DashboardStats stats;
  final List<RecentActivity> recentActivities;
  final List<ExpiringMember> expiringMembers;
  
  const HomeLoaded({
    required this.stats,
    required this.recentActivities,
    required this.expiringMembers,
  });
  
  @override
  List<Object?> get props => [stats, recentActivities, expiringMembers];
}

class HomeError extends HomeState {
  final String message;
  
  const HomeError(this.message);
  
  @override
  List<Object?> get props => [message];
}