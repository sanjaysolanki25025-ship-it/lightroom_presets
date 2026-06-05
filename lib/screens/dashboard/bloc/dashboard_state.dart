part of 'dashboard_bloc.dart';

class DashboardState {
  final int currentIndex;
  final List<int> tabHistory;

  DashboardState({
    required this.currentIndex,
    required this.tabHistory,
  });

  DashboardState copyWith({
    int? currentIndex,
    List<int>? tabHistory,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
      tabHistory: tabHistory ?? this.tabHistory,
    );
  }

  factory DashboardState.initial() {
    return DashboardState(
      currentIndex: 0,
      tabHistory: [0],
    );
  }
}
