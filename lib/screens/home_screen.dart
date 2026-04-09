import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('歡迎'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 重新發送驗證信（如果未驗證）
              if (!authService.isEmailVerified) {
                authService.sendEmailVerification();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 用戶頭像
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user?['email']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 歡迎訊息
                Text(
                  '歡迎回來！',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Email
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '登入信箱',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?['email'] ?? '未知',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email 驗證狀態
                Card(
                  color: authService.isEmailVerified
                      ? Colors.green[50]
                      : Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          authService.isEmailVerified
                              ? Icons.verified_user
                              : Icons.pending,
                          color: authService.isEmailVerified
                              ? Colors.green
                              : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authService.isEmailVerified
                                    ? '信箱已驗證'
                                    : '信箱尚未驗證',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: authService.isEmailVerified
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              if (!authService.isEmailVerified) ...[
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final success = await authService.verifyEmail();
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('信箱驗證成功！')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.email, size: 16),
                                  label: const Text('驗證信箱'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 功能卡片
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: const Text('修改密碼'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('用戶統計'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showUserStats(context),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('應用信息'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAppInfo(context),
                  ),
                ),
                const SizedBox(height: 24),

                // 登出按鈕
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('確認登出'),
                        content: const Text('您確定要登出嗎？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('登出'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await authService.logout();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('登出'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showChangePasswordDialog(BuildContext context) {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('修改密碼'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '舊密碼',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '新密碼',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '確認新密碼',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (oldPasswordController.text.isEmpty ||
                newPasswordController.text.isEmpty ||
                confirmPasswordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('請填寫所有欄位')),
              );
              return;
            }

            if (newPasswordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('兩次密碼不一致')),
              );
              return;
            }

            if (newPasswordController.text.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('密碼至少需要 6 個字元')),
              );
              return;
            }

            final authService = Provider.of<AuthService>(context, listen: false);
            final success = await authService.changePassword(
              oldPasswordController.text,
              newPasswordController.text,
            );

            if (context.mounted) {
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密碼修改成功！')),
                );
              }
            }
          },
          child: const Text('確認修改'),
        ),
      ],
    ),
  );
}

void _showUserStats(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final stats = await authService.getUserStats();

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用戶統計'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('總用戶數: ${stats['totalUsers']}'),
            const SizedBox(height: 8),
            Text('已驗證: ${stats['verifiedUsers']}'),
            const SizedBox(height: 8),
            Text('未驗證: ${stats['unverifiedUsers']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
}

void _showAppInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AlertDialog(
      title: Text('應用信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('應用名稱: Flutter Auth App'),
          SizedBox(height: 8),
          Text('版本: 1.0.0'),
          SizedBox(height: 8),
          Text('數據庫: SQLite'),
          SizedBox(height: 8),
          Text('密碼加密: SHA-256'),
          SizedBox(height: 8),
          Text('離線模式: 是'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: null,
          child: Text('關閉'),
        ),
      ],
    ),
  );
}
