import 'dart:async';
import 'package:flutter/material.dart';

/// Timer import
import 'dart:async';

/// Performance utilities to help reduce frame drops and improve app performance
class PerformanceUtils {
  static final Map<String, Timer> _timers = {};

  /// Debounce function calls to prevent excessive rebuilds
  static void debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }

  /// Dispose all timers
  static void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

/// Mixin to add performance optimizations to StatefulWidgets
mixin PerformanceOptimizedState<T extends StatefulWidget> on State<T> {
  /// Debounced setState to prevent excessive rebuilds
  void setStateDebounced(
    VoidCallback fn, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    PerformanceUtils.debounce(
      '${widget.runtimeType}_setState',
      () => setState(fn),
      delay: delay,
    );
  }

  @override
  void dispose() {
    PerformanceUtils.dispose();
    super.dispose();
  }
}

/// Widget that builds its child only when needed to improve performance
class LazyBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final bool shouldBuild;

  const LazyBuilder({
    super.key,
    required this.builder,
    this.shouldBuild = true,
  });

  @override
  State<LazyBuilder> createState() => _LazyBuilderState();
}

class _LazyBuilderState extends State<LazyBuilder> {
  Widget? _cachedChild;

  @override
  Widget build(BuildContext context) {
    if (widget.shouldBuild && _cachedChild == null) {
      _cachedChild = widget.builder(context);
    }

    return _cachedChild ?? const SizedBox.shrink();
  }
}

/// Optimized ListView that only builds visible items
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance optimizations
      cacheExtent: 200,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }
}
