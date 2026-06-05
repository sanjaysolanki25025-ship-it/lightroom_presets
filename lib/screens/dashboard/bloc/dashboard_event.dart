part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class DashboardTabChangedEvent extends DashboardEvent {
  final int index;
  DashboardTabChangedEvent(this.index);
}

class DashboardBackPressedEvent extends DashboardEvent {}
