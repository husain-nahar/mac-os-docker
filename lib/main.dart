import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
              items: const [
                Icons.person,
                Icons.message,
                Icons.call,
                Icons.camera,
                Icons.photo,
              ],
              builder: (e) {
                return Container(
                  key: ValueKey(e.hashCode),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Colors.primaries[e.hashCode % Colors.primaries.length],
                  ),
                  child: Center(
                    child: Icon(
                      e,
                      color: Colors.white,
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
      constraints: const BoxConstraints(maxWidth: 312, maxHeight: 72),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ReorderableGridView.count(
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
