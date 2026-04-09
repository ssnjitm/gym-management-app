import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class DashboardStats {
  final int totalMembers;
  final int todayCheckins;
  final int expiringThisWeek;
  final double monthlyRevenue;
  final double totalRevenue;
  final double collectionTarget;
  
  DashboardStats({
    required this.totalMembers,
    required this.todayCheckins,
    required this.expiringThisWeek,
    required this.monthlyRevenue,
    required this.totalRevenue,
    required this.collectionTarget,
  });
  
  double get collectionPercentage => 
      collectionTarget > 0 ? (monthlyRevenue / collectionTarget) * 100 : 0;
}

class RecentActivity {
  final String id;
  final String memberName;
  final String action;
  final DateTime time;
  final String? thumbnail;
  
  RecentActivity({
    required this.id,
    required this.memberName,
    required this.action,
    required this.time,
    this.thumbnail,
  });
}

class ExpiringMember {
  final String memberId;
  final String memberName;
  final String phone;
  final String packageName;
  final DateTime expiryDate;
  final int daysLeft;
  
  ExpiringMember({
    required this.memberId,
    required this.memberName,
    required this.phone,
    required this.packageName,
    required this.expiryDate,
    required this.daysLeft,
  });
  
  bool get isUrgent => daysLeft <= 3;
  String get statusText => isUrgent ? 'Urgent' : 'Soon';
  Color get statusColor => isUrgent ? Colors.red : Colors.orange;
}