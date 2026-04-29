import 'package:echo_nlu/core/components/button_custom.dart';
import 'package:echo_nlu/core/constants/app_colors.dart';
import 'package:echo_nlu/core/constants/app_radius.dart';
import 'package:echo_nlu/core/constants/app_spacing.dart';
import 'package:echo_nlu/core/router/app_infor_router.dart';
import 'package:echo_nlu/core/utils/toast_message.dart';
import 'package:echo_nlu/features/auth/controllers/auth_controller.dart';
import 'package:echo_nlu/features/auth/widgets/header.dart';
import 'package:echo_nlu/features/auth/widgets/input_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/check_login.dart';

class LoginScreen extends ConsumerStatefulWidget{

  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
      return StateLoginScreen();
  }

}

class StateLoginScreen extends ConsumerState<LoginScreen>{

  final  emailController = TextEditingController();
  final  passwordController = TextEditingController();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    debugPrint('dispose login screen');
  }


  @override
  Widget build(BuildContext context) {

    final authState = ref.watch(loginControllerProvider);
    final authController = ref.watch(loginControllerProvider.notifier);

    debugPrint('login build with state  : $authState');

    ref.listen<AuthState>(loginControllerProvider, (previous, next) {
      if (previous?.status == next.status) return;

      if (next.status == AuthStatus.authenticated) {
        context.go(AppInforRouter.homePath);
      } else if (next.status == AuthStatus.failure) {
        showToast(context, message: next.generalError ?? 'Đăng nhập thất bại. Vui lòng thử lại.');

      }
    });

    final theme = Theme.of(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Đăng nhập'),
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
                    blurRadius: 10,
                    offset: Offset(0, 8),
                  )
                ]

            ),
            child: authState.status == AuthStatus.submitting
                ? const Center(child: CircularProgressIndicator())
                :  SizedBox(
               height: MediaQuery.of(context).size.height,

              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 5),
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Header(title: 'NLU Echo', subtitle: 'Khám phá ký ức quanh bạn', icon: Icons.energy_savings_leaf_outlined),
                          SizedBox(height: AppSpacing.xl),
                          _form(theme, authState,authController),
                          SizedBox(height: AppSpacing.xxl,),
                          ButtonCustom(titleButton: 'Đăng nhập', onNextPressed: () => authState.status != AuthStatus.submitting ? authController.submitLogin() : null),
                          SizedBox(height: AppRadius.xl,),
                          loginWithGoogle(),
                          SizedBox(height: AppRadius.xl,),
                          CheckAccount(
                              title: 'Bạn chưa có tài khoản? ',
                              subtitle: 'Đăng ký ngay',
                              onPressed: () => context.push(AppInforRouter.registerPath)
                          )
                        ]
                    ),
                  )
                              ),
                )
        )
    );
  }


  Widget  _form(ThemeData theme,AuthState authState, AuthController authController) {
    return Column(
        children: [
          InputText(
            label: 'Email',
            hint: 'yourname@st.hcmuaf.edu.vn',
            leadingIcon: CupertinoIcons.mail_solid,
            type: TextInputType.emailAddress,
            onChanged: authController.onEmailChanged,
            errorText: authState.emailError,
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



  Widget loginWithGoogle() {
    return Column(
      children: [
        Text('Hoặc đăng nhập với', style: TextStyle(color: AppColors.textMuted)),
        SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/google.png',fit: BoxFit.cover, width: 24, height: 24),
              SizedBox(width: 8),
              Text('Đăng nhập với Google', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}