import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _showBottomSheet = true;
      });
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150.0),
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    !isDark
                        ? 'assets/logos/logo_light.png'
                        : 'assets/logos/logo_dark.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          if (_showBottomSheet)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  elevation: 12,
                  color:
                      isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                  surfaceTintColor: theme.colorScheme.surfaceTint,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(
                        isDark ? 0.25 : 0.1,
                      ),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.dividerColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to WisePaisa!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 25.0,
                            ),
                          ),
                          const Text(
                            "Sign in to continue\nYou're only one step away!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.0,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return GoogleAuthButton(
                                onPressed: _handleGoogleSignIn,
                                isLoading: authProvider.isLoading,
                                style: const AuthButtonStyle(
                                  iconBackground: Colors.transparent,
                                  buttonColor: Colors.white,
                                  progressIndicatorStrokeWidth: 2.0,
                                  textStyle: TextStyle(
                                    fontSize: 17.7,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  buttonType: AuthButtonType.secondary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          if (Platform.isIOS)
                            AppleAuthButton(
                              onPressed: () {},
                              style: const AuthButtonStyle(
                                textStyle: TextStyle(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                buttonType: AuthButtonType.secondary,
                              ),
                            ),
                          const SizedBox(height: 20.0),
                          const Text(
                            "By creating an account, you agree to our\nPrivacy Policy and Terms of Use",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.0,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
