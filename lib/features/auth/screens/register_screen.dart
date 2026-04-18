import 'package:echo_nlu/core/router/app_infor_router.dart';
import 'package:echo_nlu/features/auth/controllers/auth_controller.dart';
import 'package:echo_nlu/features/auth/widgets/check_login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/components/button_custom.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/header.dart';
import '../widgets/input_text.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return StateRegisterScreen();
  }



}
class StateRegisterScreen extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      debugPrint('build register screen');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    debugPrint('dispose register screen');

  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(registerControllerProvider);
    final authController = ref.watch(registerControllerProvider.notifier);

    debugPrint('register build with state  : $authState');

    ref.listen<AuthState>(registerControllerProvider, (previous, next) {
      if (previous?.status == next.status) return;

      if (next.status == AuthStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );
        context.go(AppInforRouter.loginPath);
      } else if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thất bại!')),
        );
      }
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Đăng ký'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(CupertinoIcons.back, color: AppColors.primary),
          ),
        ),

        body: Container(
            decoration:
            BoxDecoration(
                color: Colors.white,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 25,
                    offset: Offset(0, 20),

                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 8),
                  )
                ]

            ),
            child: authState.status == AuthStatus.submitting
                ? const Center(child: CircularProgressIndicator())
                : SizedBox.expand(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Header(title: 'NLU Echo', subtitle: 'Đặt chân, mở khóa khoảnh khắc', icon: Icons.energy_savings_leaf_outlined),
                            SizedBox(height: AppSpacing.xl),
                            _form(theme,authState,authController),
                            // SizedBox(height: AppSpacing.xl,),
                            //  _policy(theme),
                            SizedBox(height: AppSpacing.xxl,),
                            ButtonCustom(titleButton: 'Đăng ký', onNextPressed: () => authState.status != AuthStatus.submitting ? authController.submitRegister() : null),
                            SizedBox(height: AppRadius.xl,),
                            CheckAccount(title: 'Bạn đã có tài khoản? ', subtitle: 'Đăng nhập ngay', onPressed: () => context.go(AppInforRouter.loginPath))
                          ]

                      ),
                    ),
                  ),
                )
        )
    );
  }

  Widget _form(ThemeData theme, AuthState authState,AuthController authController) {
    return Column(
        children: [
          InputText(
            label: 'Full name',
            hint: 'Phuc Lam',
            leadingIcon: CupertinoIcons.person_fill,
            type: TextInputType.text,
            errorText: authState.fullNameError,
            onChanged: authController.onFullNameChanged,
            controller: fullNameController,
          ),
          SizedBox(height: AppSpacing.xl),
          InputText(
            label: 'Email',
            hint: 'yourname@st.hcmuaf.edu.vn',
            leadingIcon: CupertinoIcons.mail_solid,
            type: TextInputType.emailAddress,
            errorText: authState.emailError,
            onChanged: authController.onEmailChanged,
            controller: emailController,
          ),
          SizedBox(height: AppSpacing.xl),
          InputText(
            label: 'Mật khẩu',
            hint: '*******',
            leadingIcon: CupertinoIcons.lock_fill,
            trailingIcon: CupertinoIcons.eye_fill,
            type: TextInputType.visiblePassword,
            isPassword: true,
            obscureText: true,
            errorText: authState.passwordError,
            onChanged: authController.onPasswordChanged,
            controller: passwordController,
          )


        ]
    );


  }

  Widget _policy(ThemeData theme) {
    return Text(
      'Bằng việc đăng ký, bạn đã đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi.',
      style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic
      ),
      textAlign: TextAlign.center,
    );
  }
}