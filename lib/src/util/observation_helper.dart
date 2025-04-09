import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stateful_inheritance/inherited_state.dart';

typedef ConditionCallback = bool Function<T extends InheritedState>(T state);

mixin ObservationHelper {
  void initObservatory(InheritedState state) {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _isFirstFrame = false,
    );
  }

  bool get _isBuildPhase {
    final phase = SchedulerBinding.instance.schedulerPhase;
    return phase == SchedulerPhase.persistentCallbacks ||
        _isFirstFrame && phase == SchedulerPhase.idle;
  }

  bool _isFirstFrame = true;

  final _elements = HashSet<Element>.identity();
  final _observers = HashMap<Element, Observer>();

  void markObserversForBuild({
    required List<String> affects,
    required List<String> excludes,
  }) {
    //Maybe there is a more efficient way to instantly remove observers
    //without running logic every frame
    _elements.removeWhere((e) => !e.mounted);
    if (_isBuildPhase) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => markObserversForBuild(affects: affects, excludes: excludes),
      );
      return;
    }
    for (final element in _elements) {
      final observer = _observers[element]!;
      if (affects.isEmpty ||
          observer.hasKey && affects.contains(observer.key)) {
        if (excludes.isEmpty ||
            (observer.hasKey && !excludes.contains(observer.key))) {
          element.markNeedsBuild();
        }
      }
    }
  }

  void addObserverFor(Element element, {String? key}) {
    assert(
      _isBuildPhase,
      'Attempted to observe context outside of the build method',
    );
    _elements.add(element);
    _observers[element] ??= Observer(key: key);
  }
}

///Observer is used internally to store the information of an observer
///for now this is only the observers key, but this could get more properties in the future.
final class Observer {
  Observer({required this.key});

  final String? key;

  bool get hasKey => key != null;
}
