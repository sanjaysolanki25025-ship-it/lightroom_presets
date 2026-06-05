import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState.initial()) {
    on<DashboardTabChangedEvent>(_onTabChanged);
    on<DashboardBackPressedEvent>(_onBackPressed);
  }

  void _onTabChanged(DashboardTabChangedEvent event, Emitter<DashboardState> emit) {
    if (state.currentIndex == event.index) return;

    final List<int> newHistory = List.from(state.tabHistory);
    if (newHistory.contains(event.index)) {
      newHistory.remove(event.index);
    }
    newHistory.add(event.index);

    emit(state.copyWith(
      currentIndex: event.index,
      tabHistory: newHistory,
    ));
  }

  void _onBackPressed(DashboardBackPressedEvent event, Emitter<DashboardState> emit) {
    if (state.tabHistory.length > 1) {
      final List<int> newHistory = List.from(state.tabHistory);
      newHistory.removeLast();
      final int previousIndex = newHistory.last;

      emit(state.copyWith(
        currentIndex: previousIndex,
        tabHistory: newHistory,
      ));
    }
  }
}
