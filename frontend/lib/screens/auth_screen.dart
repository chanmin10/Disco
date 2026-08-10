import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

enum _AuthView { login, signup, signupSent, forgot, forgotSent }

const _kAccent = Color(0xFF0A84FF);
const _kDanger = Color(0xFFFF3B30);
const _kWarn = Color(0xFFFF9F0A);
const _kSuccess = Color(0xFF34C759);
const _kBorderColor = Color(0x14000000); // rgba(0,0,0,0.08)
const _kFieldBorder = Color(0x24000000); // rgba(0,0,0,0.14)
const _kTitleBarHeight = 52.0;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _forgotFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  final _loginPasswordFocus = FocusNode();
  final _signupPasswordFocus = FocusNode();
  final _signupConfirmFocus = FocusNode();

  _AuthView _view = _AuthView.login;
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorText;
  String _sentEmail = '';

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    _forgotEmailController.dispose();
    _loginPasswordFocus.dispose();
    _signupPasswordFocus.dispose();
    _signupConfirmFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return '이메일을 입력해주세요';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  String? _validateLoginPassword(String? v) {
    if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
    return null;
  }

  String? _validateSignupPassword(String? v) {
    final value = v ?? '';
    if (value.length < 8) return '8자 이상 입력해주세요';
    var kinds = 0;
    if (RegExp(r'[a-zA-Z]').hasMatch(value)) kinds++;
    if (RegExp(r'[0-9]').hasMatch(value)) kinds++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) kinds++;
    if (kinds < 2) return '영문, 숫자, 특수문자 중 2가지 이상 조합해주세요';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v != _signupPasswordController.text) return '비밀번호가 일치하지 않습니다';
    return null;
  }

  int _passwordStrength(String v) {
    if (v.isEmpty) return 0;
    var kinds = 0;
    if (RegExp(r'[a-z]').hasMatch(v)) kinds++;
    if (RegExp(r'[A-Z]').hasMatch(v)) kinds++;
    if (RegExp(r'[0-9]').hasMatch(v)) kinds++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(v)) kinds++;
    if (v.length < 8) return 1;
    if (v.length >= 12 && kinds >= 3) return 3;
    if (kinds >= 2) return 2;
    return 1;
  }

  void _switchView(_AuthView view) {
    setState(() {
      _view = view;
      _errorText = null;
    });
  }

  Future<void> _submitLogin() async {
    if (_isSubmitting) return;
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      // On success, main.dart's onAuthStateChange listener routes to MainScreen.
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = '연결에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitSignup() async {
    if (_isSubmitting) return;
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final email = _signupEmailController.text.trim();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: _signupPasswordController.text,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _sentEmail = email;
        _view = _AuthView.signupSent;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = '연결에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  Future<void> _submitForgot() async {
    if (_isSubmitting) return;
    if (!_forgotFormKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final email = _forgotEmailController.text.trim();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _sentEmail = email;
        _view = _AuthView.forgotSent;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = '연결에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDF0),
      body: Column(
        children: [
          _buildTitleBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: _kTitleBarHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F8),
        border: Border(bottom: BorderSide(color: _kBorderColor)),
      ),
      child: DragToMoveArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: const [
              Center(
                child: Text(
                  'DISCO',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_view) {
      case _AuthView.login:
        return _buildLoginForm();
      case _AuthView.signup:
        return _buildSignupForm();
      case _AuthView.signupSent:
        return _buildSentScreen(
          title: '이메일을 확인해주세요',
          message: '$_sentEmail 로\n인증 링크를 보냈어요',
        );
      case _AuthView.forgot:
        return _buildForgotForm();
      case _AuthView.forgotSent:
        return _buildSentScreen(
          title: '이메일을 확인해주세요',
          message: '$_sentEmail 로\n재설정 링크를 보냈어요',
        );
    }
  }

  Widget _buildHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Color(0xFF86868B), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFEECEC),
        border: Border.all(color: _kDanger.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(color: _kDanger, shape: BoxShape.circle),
            child: const Center(
              child: Text('!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorText ?? '',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A2C26), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
    Iterable<String>? autofillHints,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3C))),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            validator: validator,
            autofillHints: autofillHints,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB0B0B6)),
              filled: true,
              fillColor: const Color(0xFFF7F7F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kFieldBorder, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kFieldBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kAccent, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kDanger, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kDanger, width: 1.5),
              ),
              errorStyle: const TextStyle(fontSize: 11.5, color: _kDanger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityToggle(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
      color: const Color(0xFF86868B),
      onPressed: onTap,
    );
  }

  Widget _buildPrimaryButton({required String label, required bool loading, required VoidCallback onPressed}) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kAccent.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSwitchLine(String question, String actionLabel, VoidCallback onTap) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(question, style: const TextStyle(fontSize: 12.5, color: Color(0xFF86868B))),
          GestureDetector(
            onTap: onTap,
            child: Text(actionLabel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('로그인', '번역하며 나만의 단어장을 만들어보세요'),
          if (_errorText != null) _buildErrorBanner(),
          _buildField(
            label: '이메일',
            controller: _loginEmailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _loginPasswordFocus.requestFocus(),
          ),
          _buildField(
            label: '비밀번호',
            controller: _loginPasswordController,
            focusNode: _loginPasswordFocus,
            hint: '비밀번호',
            obscureText: _obscureLoginPassword,
            textInputAction: TextInputAction.done,
            validator: _validateLoginPassword,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submitLogin(),
            suffixIcon: _buildVisibilityToggle(
              _obscureLoginPassword,
              () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _switchView(_AuthView.forgot),
              child: const Text('비밀번호를 잊으셨나요?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kAccent)),
            ),
          ),
          const SizedBox(height: 8),
          _buildPrimaryButton(label: '로그인', loading: _isSubmitting, onPressed: _submitLogin),
          const SizedBox(height: 16),
          _buildSwitchLine('계정이 없으신가요? ', '회원가입', () => _switchView(_AuthView.signup)),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('회원가입', '몇 가지 정보만 입력하면 바로 시작할 수 있어요'),
          if (_errorText != null) _buildErrorBanner(),
          _buildField(
            label: '이메일',
            controller: _signupEmailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _signupPasswordFocus.requestFocus(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('비밀번호', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3C))),
                ),
                TextFormField(
                  controller: _signupPasswordController,
                  focusNode: _signupPasswordFocus,
                  obscureText: _obscureSignupPassword,
                  textInputAction: TextInputAction.next,
                  validator: _validateSignupPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _signupConfirmFocus.requestFocus(),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F)),
                  decoration: InputDecoration(
                    hintText: '8자 이상, 영문/숫자/특수문자 조합',
                    hintStyle: const TextStyle(color: Color(0xFFB0B0B6)),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                    suffixIcon: _buildVisibilityToggle(
                      _obscureSignupPassword,
                      () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _kFieldBorder, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _kFieldBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _kAccent, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _kDanger, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _kDanger, width: 1.5),
                    ),
                    errorStyle: const TextStyle(fontSize: 11.5, color: _kDanger),
                  ),
                ),
                if (_signupPasswordController.text.isNotEmpty) _buildStrengthMeter(_signupPasswordController.text),
              ],
            ),
          ),
          _buildField(
            label: '비밀번호 확인',
            controller: _signupConfirmController,
            focusNode: _signupConfirmFocus,
            hint: '비밀번호를 다시 입력해주세요',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: _validateConfirmPassword,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) => _submitSignup(),
            suffixIcon: _buildVisibilityToggle(
              _obscureConfirmPassword,
              () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          const SizedBox(height: 8),
          _buildPrimaryButton(label: '회원가입', loading: _isSubmitting, onPressed: _submitSignup),
          const SizedBox(height: 16),
          _buildSwitchLine('이미 계정이 있으신가요? ', '로그인', () => _switchView(_AuthView.login)),
        ],
      ),
    );
  }

  Widget _buildStrengthMeter(String password) {
    final strength = _passwordStrength(password);
    final colors = [const Color(0xFFE5E5E7), const Color(0xFFE5E5E7), const Color(0xFFE5E5E7)];
    final strengthColor = strength == 1 ? _kDanger : (strength == 2 ? _kWarn : _kSuccess);
    for (var i = 0; i < strength; i++) {
      colors[i] = strengthColor;
    }
    final label = switch (strength) { 1 => '약함', 2 => '보통', 3 => '강함', _ => '' };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: colors
                  .map((c) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          height: 4,
                          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: strengthColor)),
        ],
      ),
    );
  }

  Widget _buildForgotForm() {
    return Form(
      key: _forgotFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('비밀번호 찾기', '가입하신 이메일로 재설정 링크를 보내드려요'),
          if (_errorText != null) _buildErrorBanner(),
          _buildField(
            label: '이메일',
            controller: _forgotEmailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateEmail,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _submitForgot(),
          ),
          _buildPrimaryButton(label: '재설정 메일 보내기', loading: _isSubmitting, onPressed: _submitForgot),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => _switchView(_AuthView.login),
              child: const Text('로그인으로 돌아가기', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kAccent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentScreen({required String title, required String message}) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(color: _kAccent, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF86868B), height: 1.6),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => _switchView(_AuthView.login),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kFieldBorder),
              foregroundColor: const Color(0xFF3A3A3C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('로그인으로 돌아가기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}
