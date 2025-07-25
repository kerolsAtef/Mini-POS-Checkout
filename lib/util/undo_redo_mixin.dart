import 'package:equatable/equatable.dart';

/// Mixin that provides undo/redo functionality to any state
mixin UndoRedoMixin<T extends Equatable> {
  /// Maximum number of states to keep in history
  static const int maxHistorySize = 10;

  /// History of previous states
  final List<T> _history = [];

  /// Future states (for redo)
  final List<T> _future = [];

  /// Add a state to history before making changes
  void saveState(T currentState) {
    // Don't save if it's the same as the last saved state
    if (_history.isNotEmpty && _history.last == currentState) {
      return;
    }

    _history.add(currentState);

    // Keep history size manageable
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }

    // Clear future when new action is performed
    _future.clear();
  }

  /// Get the previous state (for undo)
  T? getPreviousState(T currentState) {
    if (_history.isEmpty) {
      return null;
    }

    // Move current state to future
    _future.add(currentState);

    // Get last state from history
    return _history.removeLast();
  }

  /// Get the next state (for redo)
  T? getNextState(T currentState) {
    if (_future.isEmpty) {
      return null;
    }

    // Move current state back to history
    _history.add(currentState);

    // Get next state from future
    return _future.removeLast();
  }

  /// Check if undo is available
  bool get canUndo => _history.isNotEmpty;

  /// Check if redo is available
  bool get canRedo => _future.isNotEmpty;

  /// Clear all history and future states
  void clearHistory() {
    _history.clear();
    _future.clear();
  }

  /// Get current history size
  int get historySize => _history.length;

  /// Get current future size
  int get futureSize => _future.length;
}