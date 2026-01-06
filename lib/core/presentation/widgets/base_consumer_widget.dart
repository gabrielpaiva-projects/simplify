import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base_state.dart';

typedef WidgetBuilderWithState<T extends BaseState> = Widget Function(
  BuildContext context,
  T state,
  Widget? child,
);

class BaseConsumerWidget<T extends BaseState> extends StatelessWidget {
  final WidgetBuilderWithState<T> builder;
  final Widget? child;
  final Widget? loadingWidget;
  final Widget Function(BuildContext, String)? errorBuilder;
  final bool showLoadingOverlay;

  const BaseConsumerWidget({
    super.key,
    required this.builder,
    this.child,
    this.loadingWidget,
    this.errorBuilder,
    this.showLoadingOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      child: child,
      builder: (context, state, child) {
        if (showLoadingOverlay && state.isLoading) {
          return Stack(
            children: [
              builder(context, state, child),
              _buildLoadingOverlay(context),
            ],
          );
        }

        if (state.isLoading && loadingWidget != null) {
          return loadingWidget!;
        }

        if (state.hasError && errorBuilder != null) {
          return errorBuilder!(
            context,
            state.failure?.message ?? 'Erro desconhecido',
          );
        }

        return builder(context, state, child);
      },
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class SimpleConsumer<T extends BaseState> extends StatelessWidget {
  final Widget Function(BuildContext, T) builder;

  const SimpleConsumer({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, state, _) => builder(context, state),
    );
  }
}

class StateSelector<T extends BaseState, S> extends StatelessWidget {
  final S Function(T) selector;
  final Widget Function(BuildContext, S, Widget?) builder;
  final Widget? child;

  const StateSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<T, S>(
      selector: (_, state) => selector(state),
      builder: builder,
      child: child,
    );
  }
}