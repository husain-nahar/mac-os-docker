import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'dart:ui';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final List<IconData> _items = const [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];
  late int? hoveredIndex;
  late double baseItemHeight;
  late double baseTranslationY;

  double getScaledSize(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseItemHeight,
      maxValue: 60,
      nonHoveredMaxValue: 30,
    );
  }

  double getTranslationY(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -12,
      nonHoveredMaxValue: -8,
    );
  }

  double getPropertyValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    late final double propertyValue;

    // 1.
    if (hoveredIndex == null) {
      return baseValue;
    }

    // 2.
    final difference = (hoveredIndex! - index).abs();

    // 3.
    final itemsAffected = _items.length;

    // 4.
    if (difference == 0) {
      propertyValue = maxValue;

      // 5.
    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;

      propertyValue = lerpDouble(baseValue, nonHoveredMaxValue, ratio)!;

      // 6.
    } else {
      propertyValue = baseValue;
    }
    return propertyValue;
  }

  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    baseItemHeight = 60;
    baseTranslationY = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        canvasColor: Colors.grey[300],
        shadowColor: Colors.grey[300],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        canvasColor: Colors.grey[300],
        shadowColor: Colors.grey[300],
      ),
      home: Scaffold(
        body: Center(
          child: Dock(
              items: _items,
              builder: (e) {
                int index = _items.indexWhere(
                  ($0) => $0.hashCode == e.hashCode,
                );
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  key: ValueKey(e.hashCode),
                  onEnter: ((event) {
                    setState(() {
                      hoveredIndex = index;
                    });
                  }),
                  onExit: (event) {
                    setState(() {
                      hoveredIndex = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..translate(
                        0.0,
                        getTranslationY(index),
                        0.0,
                      ),
                    height: getScaledSize(index),
                    width: getScaledSize(index),
                    child: Container(
                      key: ValueKey(e.hashCode),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors
                            .primaries[e.hashCode % Colors.primaries.length],
                        boxShadow: [
                          BoxShadow(
                            blurStyle: BlurStyle.inner,
                            offset: const Offset(0, 15),
                            color: Colors.primaries[
                                e.hashCode % Colors.primaries.length],
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Expanded(
                              child: Icon(
                                e,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 372, maxHeight: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ReorderableGridView.count(
            // shrinkWrap: true,
            clipBehavior: Clip.none,
            dragStartDelay: const Duration(),
            crossAxisCount: _items.length,
            crossAxisSpacing: 12,
            children: _items.map(widget.builder).toList(),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                final element = _items.removeAt(oldIndex);
                _items.insert(newIndex, element);
              });
            }),
      ),
    );
  }
}
