// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../services/auth_manager.dart';
import '../../services/auth_service.dart';
import '../../utils/logger.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  final AuthManager _authManager = AuthManager();

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  @override
  void dispose() {
    _emailUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    try {
      await _authManager.initialize();
      if (_authManager.isLoggedIn && _authManager.hasValidToken()) {
        Logger.logInfo('User already logged in, navigating to profile');
        _navigateToProfile();
      }
    } catch (e) {
      Logger.logError('Error checking login status', e);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final emailUsername = _emailUsernameController.text.trim();
      final password = _passwordController.text;

      Logger.logInfo('Attempting login for: $emailUsername');

      final success = await _authManager.login(
        emailUsername: emailUsername,
        password: password,
      );

      if (success) {
        Logger.logSuccess('Login successful');
        UIUtils.showSuccessSnackBar(context, 'Login successful!');

        // Small delay to show success message
        await Future.delayed(Duration(milliseconds: 500));

        _navigateToProfile();
      } else {
        UIUtils.showErrorSnackBar(context, 'Login failed. Please try again.');
      }

    } on AuthException catch (e) {
      Logger.logError('Login failed with AuthException', e);
      UIUtils.showErrorSnackBar(context, e.message);
    } catch (e) {
      Logger.logError('Unexpected login error', e);
      UIUtils.showErrorSnackBar(context, 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToProfile() {
    // Check if user came from a specific screen
    if (Navigator.canPop(context)) {
      // If there's a previous screen, go back to it
      Navigator.pop(context);
    } else {
      // If login was accessed directly, go to main navigation
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2E86AB),
        elevation: 1,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              _buildHeader(),
              SizedBox(height: 40),
              _buildLoginForm(),
              SizedBox(height: 30),
              _buildLoginButton(),
              SizedBox(height: 20),
              _buildForgotPassword(),
              SizedBox(height: 30),
              _buildDivider(),
              SizedBox(height: 30),
              _buildSocialLogin(),
              SizedBox(height: 40),
              _buildSignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.lock_outline,
          size: 80,
          color: AppConstants.primaryColor,
        ),
        SizedBox(height: 20),
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailUsernameField(),
          SizedBox(height: 20),
          _buildPasswordField(),
          SizedBox(height: 15),
          _buildRememberMeRow(),
        ],
      ),
    );
  }

  Widget _buildEmailUsernameField() {
    return TextFormField(
      controller: _emailUsernameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email or Username',
        hintText: 'Enter your email or username',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email or username';
        }
        if (value.trim().length < 3) {
          return 'Email or username must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isPasswordHidden,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 3) {
          return 'Password must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: AppConstants.primaryColor,
        ),
        Text(
          'Remember me',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        disabledBackgroundColor: AppConstants.primaryColor.withOpacity(0.6),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        'Login',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/forgot-password');
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        _buildSocialButton(
          'Continue with Google',
          Icons.g_mobiledata,
          Colors.red,
              () {
            UIUtils.showInfoSnackBar(context, 'Google login coming soon!');
          },
        ),
        SizedBox(height: 12),
        _buildSocialButton(
          'Continue with Facebook',
          Icons.facebook,
          Colors.blue,
              () {
            UIUtils.showInfoSnackBar(context, 'Facebook login coming soon!');
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}