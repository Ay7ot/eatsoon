import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/auth/presentation/screens/signup_screen.dart';
import 'package:eat_soon/features/auth/presentation/widgets/custom_textfield.dart';
import 'package:eat_soon/features/auth/presentation/widgets/forgot_password_dialog.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'login_email_required'.tr;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'login_email_invalid'.tr;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'login_password_required'.tr;
    }
    if (value.length < 6) {
      return 'login_password_short'.tr;
    }
    return null;
  }

  void _attemptLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login_success'.tr),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // AuthWrapper will navigate automatically after state change.
      } else {
        final errorMessage = authProvider.errorMessage ?? 'login_failed'.tr;
        debugPrint('Login Error: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _attemptGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('login_success'.tr),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // AuthWrapper handles navigation
    } else if (authProvider.errorMessage != null) {
      final errorMessage = authProvider.errorMessage!;
      debugPrint('Google Sign-In Error: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => ForgotPasswordDialog(rootContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset('assets/images/logo.png', height: 100),
                  ),
                  const SizedBox(height: 40),
                  Text('login_welcome_title'.tr, style: AppTheme.headingStyle),
                  const SizedBox(height: 8),
                  Text(
                    'login_welcome_subtitle'.tr,
                    style: AppTheme.captionStyle,
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    hintText: 'login_email_hint'.tr,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    focusNode: _emailFocusNode,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'login_password_hint'.tr,
                    controller: _passwordController,
                    isPassword: !_isPasswordVisible,
                    focusNode: _passwordFocusNode,
                    validator: _validatePassword,
                    suffixIcon: SvgPicture.asset(
                      _isPasswordVisible
                          ? 'assets/icons/eye_visible.svg'
                          : 'assets/icons/eye_hidden.svg',
                      height: 24,
                    ),
                    onSuffixIconPressed: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'login_forget_password'.tr,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed:
                            authProvider.isLoading ? null : _attemptLogin,
                        style: AppTheme.primaryButtonStyle,
                        child:
                            authProvider.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  'login_continue'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton.icon(
                    onPressed: _attemptGoogleSignIn,
                    icon: SvgPicture.asset(
                      'assets/icons/google_logo.svg',
                      height: 24,
                    ),
                    label: Text(
                      'login_continue_google'.tr,
                      style: AppTheme.bodyStyle,
                    ),
                    style: AppTheme.secondaryButtonStyle,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('login_no_account'.tr, style: AppTheme.bodyStyle),
                      TextButton(
                        onPressed:
                            () => Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SignupScreen(),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  var begin = const Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.easeOutCubic;
                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(
                                  milliseconds: 500,
                                ),
                              ),
                            ),
                        child: Text(
                          'login_signup'.tr,
                          style: AppTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
