import 'package:flutter/widgets.dart';
import 'package:stateful_inheritance/src/util/observation_helper.dart';

//chose to extend inheritedwidget instead of proxy widget, because flutter does not allow
//me to easily create a custom dependency system, i also want my statefulinheritedwidget to be
//able to function as a regular inherited widget
abstract class StatefulInheritedWidget extends InheritedWidget {
  const StatefulInheritedWidget({super.key, required super.child});

  @override
  StatefulInheritedElement createElement() => StatefulInheritedElement(this);

  InheritedState createState();

  @override
  //updateShould notify should default to false, this is chosen behaviour
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class StatefulInheritedElement extends InheritedElement with ObservationHelper {
  StatefulInheritedElement(super.widget)
    : _state = (widget as StatefulInheritedWidget).createState() {
    initObservatory(_state);
    _state._widget = widget as StatefulInheritedWidget;
    _state._element = this;
    _state.initState();
  }

  final InheritedState _state;

  @override
  void update(StatefulInheritedWidget newWidget) {
    _state._widget = newWidget;
    _state.didUpdateWidget();
    super.update(newWidget);
  }

  @override
  void unmount() {
    _state.dispose();
    super.unmount();
  }
}

abstract class InheritedState<T extends StatefulInheritedWidget> {
  @protected
  T get widget => _widget!;

  T? _widget;

  StatefulInheritedElement? _element;

  @protected
  @mustCallSuper
  void initState() {}

  @protected
  void didUpdateWidget() {}

  @protected
  @mustCallSuper
  void dispose() {}

  ///Set the state, this will notify all observing widgets to rebuild themselves.
  ///Optionally affected keys can be given to make only those widgets rebuild,
  ///if no keys are given all widgets are rebuilt regardless of their key.
  @protected
  void setState({List<String>? affects}) {
    _element!.markObserversForBuild(affects ?? List.empty());
  }
}

extension DependOnInheritedStateOfExactType on BuildContext {
  InheritedState<T>? getInheritedStateOf<T extends StatefulInheritedWidget>() {
    final element =
        getElementForInheritedWidgetOfExactType<T>()
            as StatefulInheritedElement?;

    return element?._state as InheritedState<T>?;
  }

  //we add a new prefix called [observe] (next to [get] and [depend]), that will subscripe the context to 'observe'
  //something (I.E.) rebuild on changes
  InheritedState<T>?
  observeInheritedStateOf<T extends StatefulInheritedWidget>({String? key}) {
    final element =
        getElementForInheritedWidgetOfExactType<T>()
            as StatefulInheritedElement?;

    element?.addObserverFor(this as Element, key: key);

    return element?._state as InheritedState<T>?;
  }
}
