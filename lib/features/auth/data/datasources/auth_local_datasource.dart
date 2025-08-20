import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<bool> hasUser();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  
  AuthLocalDataSourceImpl(this._sharedPreferences);
  
  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _sharedPreferences.setString(AppConstants.userKey, userJson);
    } catch (e) {
      throw CacheException(message: 'Failed to save user');
    }
  }
  
  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = _sharedPreferences.getString(AppConstants.userKey);
      if (userJson == null) {
        return null;
      }
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get user');
    }
  }
  
  @override
  Future<void> clearUser() async {
    try {
      await _sharedPreferences.remove(AppConstants.userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user');
    }
  }
  
  @override
  Future<bool> hasUser() async {
    return _sharedPreferences.containsKey(AppConstants.userKey);
  }
}