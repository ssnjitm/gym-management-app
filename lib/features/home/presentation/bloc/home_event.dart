import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends HomeEvent {
  final String gymId;
  
  const LoadDashboardEvent({required this.gymId});
  
  @override
  List<Object?> get props => [gymId];
}

class RefreshDashboardEvent extends HomeEvent {
  final String gymId;
  
  const RefreshDashboardEvent({required this.gymId});
  
  @override
  List<Object?> get props => [gymId];
}