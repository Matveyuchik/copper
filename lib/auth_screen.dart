import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final Client client = Client();
  late final Account account;

  bool _isLoading = false;
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAppwrite();
  }

  void _initAppwrite() {
    try {
      client
          .setEndpoint('https://fra.cloud.appwrite.io/v1')
          .setProject('68c418880030f91dbafc') // Ваш Project ID
          .setSelfSigned(status: true);

      account = Account(client);
      print('✅ Appwrite инициализирован');
    } catch (e) {
      print('❌ Ошибка инициализации Appwrite: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAuthForm(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 30),
                _buildEmailField(),
                const SizedBox(height: 15),
                _buildPasswordField(),
                if (!_isLogin) ...[
                  const SizedBox(height: 15),
                  _buildConfirmPasswordField(),
                ],
                const SizedBox(height: 20),
                _buildAuthButton(),
                const SizedBox(height: 15),
                _buildToggleAuthText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLogo() {
    return const Column(
      children: [
        Icon(Icons.chat, size: 80, color: Colors.blue),
        SizedBox(height: 10),
        Text(
          'Copper',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          'Общайтесь с комфортом.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите email';
        }
        if (!value.contains('@')) {
          return 'Введите корректный email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Пароль',
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите пароль';
        }
        if (value.length < 6) {
          return 'Пароль должен быть не менее 6 символов';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Подтвердите пароль',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: !_isLogin ? (value) {
        if (value == null || value.isEmpty) {
          return 'Подтвердите пароль';
        }
        if (value != _passwordController.text) {
          return 'Пароли не совпадают';
        }
        return null;
      } : null,
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _isLogin ? 'Войти' : 'Зарегистрироваться',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildToggleAuthText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Нет аккаунта?' : 'Уже есть аккаунт?',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isLogin = !_isLogin;
            });
          },
          child: Text(
            _isLogin ? 'Зарегистрироваться' : 'Войти',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        if (_isLogin) {
          await _login(email, password);
        } else {
          await _register(email, password);
        }
      } catch (e) {
        _handleError(e);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login(String email, String password) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      print('✅ Успешный вход: ${session.userId}');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home', arguments: email);
      }
    } catch (e) {
      print('❌ Ошибка входа: $e');
      rethrow;
    }
  }

  Future<void> _register(String email, String password) async {
    try {
      // Создаем пользователя
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: email.split('@').first,
      );
      print('✅ Пользователь создан: ${user.toMap()}');

      // Пытаемся войти сразу после регистрации
      await _login(email, password);

    } catch (e) {
      print('❌ Ошибка регистрации: $e');
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    String errorMessage = 'Произошла ошибка';

    if (error is AppwriteException) {
      switch (error.code) {
        case 401:
          errorMessage = 'Неверный email или пароль';
          break;
        case 409:
          errorMessage = 'Пользователь уже существует';
          break;
        case 400:
          errorMessage = 'Неверные данные';
          break;
        default:
          errorMessage = 'Ошибка Appwrite: ${error.message}';
      }
    } else {
      errorMessage = 'Ошибка: $error';
    }

    _showError(errorMessage);
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

}
