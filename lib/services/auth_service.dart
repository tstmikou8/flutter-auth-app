import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static Database? _database;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  // 用戶信息
  Map<String, dynamic>? _currentUser;
  
  Stream<bool> get authStateChanges => _authStateController.stream;
  Map<String, dynamic>? get user => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmailVerified => _currentUser?['emailVerified'] ?? false;

  AuthService() {
    _initAuth();
  }

  // 初始化數據庫和檢查登入狀態
  Future<void> _initAuth() async {
    await _initDatabase();
    await _checkLoginState();
  }

  // 初始化 SQLite 數據庫
  Future<Database> _initDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 創建用戶表
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            emailVerified INTEGER DEFAULT 0,
            createdAt INTEGER NOT NULL,
            lastLoginAt INTEGER
          )
        ''');

        // 創建會話表
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            token TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            expiresAt INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        print('數據庫創建成功');
      },
    );

    return _database!;
  }

  // 檢查登入狀態
  Future<void> _checkLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId != null) {
        final db = await _initDatabase();
        final users = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
          limit: 1,
        );

        if (users.isNotEmpty) {
          _currentUser = users.first;
          _authStateController.add(true);
          notifyListeners();
          return;
        }
      }

      _authStateController.add(false);
      notifyListeners();
    } catch (e) {
      print('檢查登入狀態失敗: $e');
      _authStateController.add(false);
      notifyListeners();
    }
  }

  // 密碼哈希（使用 SHA-256）
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // 註冊新用戶
  Future<bool> register(String email, String password) async {
    try {
      final db = await _initDatabase();
      
      // 檢查信箱是否已存在
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
      );

      if (existingUsers.isNotEmpty) {
        Fluttertoast.showToast(msg: '此信箱已被註冊');
        return false;
      }

      // 插入新用戶
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final id = await db.insert('users', {
        'email': email.trim(),
        'password': hashedPassword,
        'emailVerified': 0, // 默認未驗證
        'createdAt': now,
      });

      Fluttertoast.showToast(msg: '註冊成功！');
      print('用戶註冊成功: $email, ID: $id');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '註冊失敗：$e');
      print('註冊錯誤: $e');
      return false;
    }
  }

  // 登入
  Future<bool> login(String email, String password) async {
    try {
      final db = await _initDatabase();
      
      // 查找用戶
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
        limit: 1,
      );

      if (users.isEmpty) {
        Fluttertoast.showToast(msg: '找不到此帳號');
        return false;
      }

      final user = users.first;
      final hashedPassword = _hashPassword(password);

      // 驗證密碼
      if (user['password'] != hashedPassword) {
        Fluttertoast.showToast(msg: '密碼錯誤');
        return false;
      }

      // 更新最後登入時間
      await db.update(
        'users',
        {'lastLoginAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      // 保存登入狀態
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user['id'] as int);

      _currentUser = user;
      _authStateController.add(true);
      notifyListeners();

      Fluttertoast.showToast(msg: '登入成功！');
      print('用戶登入成功: ${user['email']}');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '登入失敗：$e');
      print('登入錯誤: $e');
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    try {
      // 清除 SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      // 清除當前用戶
      _currentUser = null;
      _authStateController.add(false);
      notifyListeners();

      Fluttertoast.showToast(msg: '已登出');
      print('用戶已登出');
    } catch (e) {
      Fluttertoast.showToast(msg: '登出失敗：$e');
      print('登出錯誤: $e');
    }
  }

  // 忘記密碼 - 模擬發送重設連結
  Future<bool> resetPassword(String email) async {
    try {
      final db = await _initDatabase();
      
      // 檢查用戶是否存在
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
        limit: 1,
      );

      if (users.isEmpty) {
        Fluttertoast.showToast(msg: '找不到此信箱');
        return false;
      }

      // 模擬發送重設連結
      // 在實際應用中，這裡會發送郵件
      Fluttertoast.showToast(msg: '密碼重設連結已發送到 $email');
      print('密碼重設請求: $email');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '發送失敗：$e');
      print('重設密碼錯誤: $e');
      return false;
    }
  }

  // 模擬驗證 Email（實際應用中會通過郵件連結）
  Future<bool> verifyEmail() async {
    try {
      if (_currentUser == null) {
        Fluttertoast.showToast(msg: '請先登入');
        return false;
      }

      final db = await _initDatabase();
      await db.update(
        'users',
        {'emailVerified': 1},
        where: 'id = ?',
        whereArgs: [_currentUser!['id']],
      );

      _currentUser!['emailVerified'] = 1;
      notifyListeners();

      Fluttertoast.showToast(msg: '信箱驗證成功！');
      print('信箱驗證成功: ${_currentUser!['email']}');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '驗證失敗：$e');
      print('驗證錯誤: $e');
      return false;
    }
  }

  // 重新發送驗證信（模擬）
  Future<bool> sendEmailVerification() async {
    try {
      if (_currentUser == null) {
        Fluttertoast.showToast(msg: '請先登入');
        return false;
      }

      Fluttertoast.showToast(msg: '驗證信已重新發送到 ${_currentUser!['email']}');
      print('重新發送驗證信: ${_currentUser!['email']}');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '發送失敗：$e');
      print('發送驗證信錯誤: $e');
      return false;
    }
  }

  // 修改密碼
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null) {
        Fluttertoast.showToast(msg: '請先登入');
        return false;
      }

      final db = await _initDatabase();
      
      // 驗證舊密碼
      final hashedOldPassword = _hashPassword(oldPassword);
      if (_currentUser!['password'] != hashedOldPassword) {
        Fluttertoast.showToast(msg: '舊密碼錯誤');
        return false;
      }

      // 更新密碼
      final hashedNewPassword = _hashPassword(newPassword);
      await db.update(
        'users',
        {'password': hashedNewPassword},
        where: 'id = ?',
        whereArgs: [_currentUser!['id']],
      );

      _currentUser!['password'] = hashedNewPassword;
      notifyListeners();

      Fluttertoast.showToast(msg: '密碼修改成功！');
      print('密碼修改成功: ${_currentUser!['email']}');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '修改失敗：$e');
      print('修改密碼錯誤: $e');
      return false;
    }
  }

  // 刪除帳號
  Future<bool> deleteAccount() async {
    try {
      if (_currentUser == null) {
        Fluttertoast.showToast(msg: '請先登入');
        return false;
      }

      final db = await _initDatabase();
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [_currentUser!['id']],
      );

      // 清除登入狀態
      await logout();

      Fluttertoast.showToast(msg: '帳號已刪除');
      print('帳號已刪除: ${_currentUser!['email']}');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '刪除失敗：$e');
      print('刪除帳號錯誤: $e');
      return false;
    }
  }

  // 獲取用戶統計信息
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final db = await _initDatabase();
      
      final totalUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users')
      ) ?? 0;

      final verifiedUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users WHERE emailVerified = 1')
      ) ?? 0;

      return {
        'totalUsers': totalUsers,
        'verifiedUsers': verifiedUsers,
        'unverifiedUsers': totalUsers - verifiedUsers,
      };
    } catch (e) {
      print('獲取統計信息錯誤: $e');
      return {
        'totalUsers': 0,
        'verifiedUsers': 0,
        'unverifiedUsers': 0,
      };
    }
  }

  // 清理過期會話
  Future<void> cleanExpiredSessions() async {
    try {
      final db = await _initDatabase();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await db.delete(
        'sessions',
        where: 'expiresAt < ?',
        whereArgs: [now],
      );

      print('過期會話已清理');
    } catch (e) {
      print('清理會話錯誤: $e');
    }
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
