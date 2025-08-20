import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/exceptions.dart';
import '../../models/auth_token_model.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(AuthTokenModel token);
  Future<AuthTokenModel?> getToken();
  Future<void> deleteToken();
  
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
  
  Future<void> saveRememberMe(bool value);
  Future<bool> getRememberMe();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _rememberMeKey = 'remember_me';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl(
    this._secureStorage,
    this._sharedPreferences,
  );

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    try {
      final tokenJson = json.encode(token.toJson());
      await _secureStorage.write(key: _tokenKey, value: tokenJson);
    } catch (e) {
      throw CacheException(message: 'Erro ao salvar token');
    }
  }

  @override
  Future<AuthTokenModel?> getToken() async {
    try {
      final tokenJson = await _secureStorage.read(key: _tokenKey);
      if (tokenJson != null) {
        final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(tokenMap);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Erro ao obter token');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao deletar token');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _sharedPreferences.setString(_userKey, userJson);
    } catch (e) {
      throw CacheException(message: 'Erro ao salvar usuário');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = _sharedPreferences.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Erro ao obter usuário');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _sharedPreferences.remove(_userKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao deletar usuário');
    }
  }

  @override
  Future<void> saveRememberMe(bool value) async {
    try {
      await _sharedPreferences.setBool(_rememberMeKey, value);
    } catch (e) {
      throw CacheException(message: 'Erro ao salvar preferência');
    }
  }

  @override
  Future<bool> getRememberMe() async {
    try {
      return _sharedPreferences.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      throw CacheException(message: 'Erro ao obter preferência');
    }
  }
}