import 'package:flutter/foundation.dart';
import '../errors/failures.dart';

enum ViewState { idle, loading, success, error }

abstract class BaseState extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  Failure? _failure;
  String? _successMessage;

  ViewState get state => _state;
  Failure? get failure => _failure;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isSuccess => _state == ViewState.success;

  void setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  void setLoading() {
    _state = ViewState.loading;
    _failure = null;
    _successMessage = null;
    notifyListeners();
  }

  void setSuccess([String? message]) {
    _state = ViewState.success;
    _successMessage = message;
    _failure = null;
    notifyListeners();
  }

  void setError(Failure failure) {
    _state = ViewState.error;
    _failure = failure;
    _successMessage = null;
    notifyListeners();
  }

  void setIdle() {
    _state = ViewState.idle;
    _failure = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_state == ViewState.error) {
      setIdle();
    }
  }

  void clearSuccess() {
    if (_state == ViewState.success) {
      setIdle();
    }
  }

  @override
  void dispose() {
    _failure = null;
    _successMessage = null;
    super.dispose();
  }
}