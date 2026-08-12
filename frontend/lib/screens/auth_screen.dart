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

/// Bundles a field's controller/focus/error state so validation can be
/// driven by focus transitions instead of Form's built-in autovalidate
/// (which has no "only after blur, and only if non-empty" mode).
class _FieldState {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String? error;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginEmail = _FieldState();
  final _loginPassword = _FieldState();
  final _signupEmail = _FieldState();
  final _signupPassword = _FieldState();
  final _signupConfirm = _FieldState();
  final _forgotEmail = _FieldState();

  bool _loginSubmitAttempted = false;
  bool _signupSubmitAttempted = false;
  bool _forgotSubmitAttempted = false;

  _AuthView _view = _AuthView.login;
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorText;
  String _sentEmail = '';

  @override
  void initState() {
    super.initState();
    _bindField(_loginEmail, _validateEmail, () => _loginSubmitAttempted);
    _bindField(_loginPassword, _validateLoginPassword, () => _loginSubmitAttempted);
    _bindField(_signupEmail, _validateEmail, () => _signupSubmitAttempted);
    _bindField(_signupPassword, _validateSignupPassword, () => _signupSubmitAttempted);
    _bindField(_signupConfirm, _validateConfirmPassword, () => _signupSubmitAttempted);
    _bindField(_forgotEmail, _validateEmail, () => _forgotSubmitAttempted);
  }

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    _signupConfirm.dispose();
    _forgotEmail.dispose();
    super.dispose();
  }

  /// Shows [field]'s error only once the user has finished editing it: it
  /// clears the moment they type (so nothing flashes mid-keystroke) and is
  /// recomputed on blur — but only displayed then if the field still has
  /// text in it, unless the owning form already had a submit attempt (which
  /// forces "required" errors on blank fields to stay visible).
  void _bindField(_FieldState field, String? Function(String) validator, bool Function() submitAttempted) {
    field.controller.addListener(() {
      if (field.error != null) setState(() => field.error = null);
    });
    field.focusNode.addListener(() {
      if (field.focusNode.hasFocus) return;
      final text = field.controller.text;
      if (text.trim().isEmpty && !submitAttempted()) return;
      final result = validator(text);
      if (result != field.error) setState(() => field.error = result);
    });
  }

  String? _validateEmail(String v) {
    final value = v.trim();
    if (value.isEmpty) return '이메일을 입력해주세요';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  String? _validateLoginPassword(String v) {
    if (v.isEmpty) return '비밀번호를 입력해주세요';
    return null;
  }

  String? _validateSignupPassword(String v) {
    if (v.length < 8) return '8자 이상 입력해주세요';
    var kinds = 0;
    if (RegExp(r'[a-zA-Z]').hasMatch(v)) kinds++;
    if (RegExp(r'[0-9]').hasMatch(v)) kinds++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(v)) kinds++;
    if (kinds < 2) return '영문, 숫자, 특수문자 중 2가지 이상 조합해주세요';
    return null;
  }

  String? _validateConfirmPassword(String v) {
    if (v != _signupPassword.controller.text) return '비밀번호가 일치하지 않습니다';
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
    final emailError = _validateEmail(_loginEmail.controller.text);
    final passwordError = _validateLoginPassword(_loginPassword.controller.text);
    setState(() {
      _loginSubmitAttempted = true;
      _loginEmail.error = emailError;
      _loginPassword.error = passwordError;
    });
    if (emailError != null) {
      _loginEmail.focusNode.requestFocus();
      return;
    }
    if (passwordError != null) {
      _loginPassword.focusNode.requestFocus();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _loginEmail.controller.text.trim(),
        password: _loginPassword.controller.text,
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
    final emailError = _validateEmail(_signupEmail.controller.text);
    final passwordError = _validateSignupPassword(_signupPassword.controller.text);
    final confirmError = _validateConfirmPassword(_signupConfirm.controller.text);
    setState(() {
      _signupSubmitAttempted = true;
      _signupEmail.error = emailError;
      _signupPassword.error = passwordError;
      _signupConfirm.error = confirmError;
    });
    if (emailError != null) {
      _signupEmail.focusNode.requestFocus();
      return;
    }
    if (passwordError != null) {
      _signupPassword.focusNode.requestFocus();
      return;
    }
    if (confirmError != null) {
      _signupConfirm.focusNode.requestFocus();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final email = _signupEmail.controller.text.trim();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: _signupPassword.controller.text,
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
    final emailError = _validateEmail(_forgotEmail.controller.text);
    setState(() {
      _forgotSubmitAttempted = true;
      _forgotEmail.error = emailError;
    });
    if (emailError != null) {
      _forgotEmail.focusNode.requestFocus();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final email = _forgotEmail.controller.text.trim();
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

  InputDecoration _fieldDecoration({required String hint, String? errorText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B0B6)),
      filled: true,
      fillColor: const Color(0xFFF7F7F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorMaxLines: 2,
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
    );
  }

  Widget _buildField({
    required String label,
    required _FieldState field,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
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
          TextField(
            controller: field.controller,
            focusNode: field.focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onFieldSubmitted,
            autofillHints: autofillHints,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F)),
            decoration: _fieldDecoration(hint: hint, errorText: field.error, suffixIcon: suffixIcon),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('로그인', '번역하며 나만의 단어장을 만들어보세요'),
        if (_errorText != null) _buildErrorBanner(),
        _buildField(
          label: '이메일',
          field: _loginEmail,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => _loginPassword.focusNode.requestFocus(),
        ),
        _buildField(
          label: '비밀번호',
          field: _loginPassword,
          hint: '비밀번호',
          obscureText: _obscureLoginPassword,
          textInputAction: TextInputAction.done,
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
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('회원가입', '몇 가지 정보만 입력하면 바로 시작할 수 있어요'),
        if (_errorText != null) _buildErrorBanner(),
        _buildField(
          label: '이메일',
          field: _signupEmail,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => _signupPassword.focusNode.requestFocus(),
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
              TextField(
                controller: _signupPassword.controller,
                focusNode: _signupPassword.focusNode,
                obscureText: _obscureSignupPassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _signupConfirm.focusNode.requestFocus(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F)),
                decoration: _fieldDecoration(
                  hint: '8자 이상, 영문/숫자/특수문자 조합',
                  errorText: _signupPassword.error,
                  suffixIcon: _buildVisibilityToggle(
                    _obscureSignupPassword,
                    () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
                  ),
                ),
              ),
              if (_signupPassword.controller.text.isNotEmpty) _buildStrengthMeter(_signupPassword.controller.text),
            ],
          ),
        ),
        _buildField(
          label: '비밀번호 확인',
          field: _signupConfirm,
          hint: '비밀번호를 다시 입력해주세요',
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('비밀번호 찾기', '가입하신 이메일로 재설정 링크를 보내드려요'),
        if (_errorText != null) _buildErrorBanner(),
        _buildField(
          label: '이메일',
          field: _forgotEmail,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
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
