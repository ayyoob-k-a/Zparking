import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_cubit.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, required this.body, this.actions, this.fab, this.onLogout});
  final String title; final Widget body; final List<Widget>? actions; final Widget? fab; final VoidCallback? onLogout;
  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit?>();
    final toggle = themeCubit == null ? null : () => themeCubit.toggle();
    final themeAction = toggle == null ? null : IconButton(icon: const Icon(Icons.brightness_6_outlined), onPressed: toggle);
    final logoutAction = onLogout == null ? null : IconButton(icon: const Icon(Icons.logout), onPressed: onLogout);
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [if (actions != null) ...actions!, if (themeAction != null) themeAction, if (logoutAction != null) logoutAction]),
      floatingActionButton: fab,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(AppSizes.lg), child: body)),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.label, this.keyboardType, this.maxLength, this.obscureText = false, this.suffix, this.validator, this.onChanged});
  final TextEditingController controller; final String label; final TextInputType? keyboardType; final int? maxLength; final bool obscureText; final Widget? suffix; final String? Function(String?)? validator; final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label, suffixIcon: suffix, counterText: ''),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.text, required this.onPressed, this.loading = false});
  final String text; final VoidCallback? onPressed; final bool loading;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(text),
    );
  }
}

class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(height: 2.h);
}


