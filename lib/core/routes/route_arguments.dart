import 'package:equatable/equatable.dart';

/// Route arguments for passing data between screens
class RouteArguments extends Equatable {
  final Map<String, dynamic>? data;
  final Function? callback;

  const RouteArguments({
    this.data,
    this.callback,
  });

  @override
  List<Object?> get props => [data, callback];

  /// Create route arguments with data
  factory RouteArguments.withData(Map<String, dynamic> data) {
    return RouteArguments(data: data);
  }

  /// Create route arguments with callback
  factory RouteArguments.withCallback(Function callback) {
    return RouteArguments(callback: callback);
  }

  /// Create route arguments with both data and callback
  factory RouteArguments.withBoth({
    required Map<String, dynamic> data,
    required Function callback,
  }) {
    return RouteArguments(data: data, callback: callback);
  }

  /// Get typed data from arguments
  T? getData<T>(String key) {
    if (data == null || !data!.containsKey(key)) {
      return null;
    }
    return data![key] as T?;
  }

  /// Check if data contains key
  bool hasData(String key) {
    return data != null && data!.containsKey(key);
  }
}