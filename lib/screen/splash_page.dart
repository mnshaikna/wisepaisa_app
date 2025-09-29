import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/providers/settings_provider.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Center(
                child: Hero(
                  tag: 'logo',
                  transitionOnUserGestures: true,
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
              Spacer(),
              CupertinoActivityIndicator(),
              SizedBox(height: 25.0),
            ],
          ),
        ),
      ),
    );
  }
}
