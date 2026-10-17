import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

Future<void> _authenticate() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // LOGIN
    if (isLogin) {
      final result = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      final user = Map<String, dynamic>.from(
        result['user'] ?? {},
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName:
                user['name']?.toString() ?? 'User',
          ),
        ),
      );
    }

    // REGISTRATION
    else {
      await ApiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      // IMPORTANT:
      // Registration does NOT open HomeScreen.
      // User must now login.
      setState(() {
        isLogin = true;
        _passwordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful. Now login with the same email and password.',
          ),
          backgroundColor: Color(0xFF059669),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final form = Center(child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: wide ? 40 : 24, vertical: 16),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460),
          child: AutofillGroup(child: Form(key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Loan in Sec', style: TextStyle(color: Color(0xFFAC302B), fontSize: 34,
                fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              const Text('PLAN TODAY. MOVE FORWARD.', style: TextStyle(fontSize: 10,
                letterSpacing: 2, color: Color(0xFF806E68))),
              const SizedBox(height: 18),
              Text(isLogin ? 'Welcome back.' : 'Start your next chapter.',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Explore your loan affordability with clarity.', style: TextStyle(color: Color(0xFF756C68))),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [ButtonSegment(value: true, label: Text('Sign in')),
                  ButtonSegment(value: false, label: Text('Register'))],
                selected: {isLogin}, showSelectedIcon: false,
                onSelectionChanged: _isLoading ? null : (values) => setState(() { isLogin = values.first; _formKey.currentState?.reset(); }),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? const Color(0xFFCE5745) : Colors.white),
                  foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : const Color(0xFF59453F)),
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(height: 16),
              if (!isLogin) ...[
                TextFormField(controller: _nameController, enabled: !_isLoading,
                  autofillHints: const [AutofillHints.name],
                  decoration: _decoration('Full name', Icons.person_outline),
                  validator: (value) => (value?.trim().length ?? 0) < 2 ? 'Enter your name' : null),
                const SizedBox(height: 18),
              ],
              TextFormField(controller: _emailController, enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email],
                decoration: _decoration('Email address', Icons.mail_outline),
                validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email'),
              const SizedBox(height: 18),
              TextFormField(controller: _passwordController, enabled: !_isLoading,
                obscureText: !_showPassword,
                autofillHints: [isLogin ? AutofillHints.password : AutofillHints.newPassword],
                onFieldSubmitted: (_) { if (!_isLoading) _authenticate(); },
                decoration: _decoration('Password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword),
                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                    icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))),
                validator: (value) => (value?.length ?? 0) < 6 ? 'Minimum 6 characters' : null),
              const SizedBox(height: 16),
              FilledButton(onPressed: _isLoading ? null : _authenticate,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFCE5745),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                child: _isLoading ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isLogin ? 'Sign in to Loan in Sec' : 'Create account')),
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF5EF), borderRadius: BorderRadius.circular(12)),
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text(isLogin ? 'New to Loan in Sec?  ' : 'Already registered?  '),
                  TextButton(onPressed: _isLoading ? null : () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? 'Create your account' : 'Sign in', style: const TextStyle(color: Color(0xFFAC302B)))),
                ])),
              const SizedBox(height: 14),
              const Text('Educational demo | Fictional lenders | No real loan disbursal',
                style: TextStyle(fontSize: 11, color: Color(0xFF806E68))),
            ]),
          )),
        ),
      ));
      if (wide) {
        return Row(children: [Expanded(child: _visualPanel()), Expanded(child: form)]);
      }
      return Column(children: [
        if (constraints.maxHeight >= 900)
          SizedBox(height: 180, child: _visualPanel(compact: true)),
        Expanded(child: form),
      ]);
    }),
  );

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon, size: 20),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD7CECA))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCE5745), width: 2)),
  );

  Widget _visualPanel({bool compact = false}) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft,
      end: Alignment.bottomRight, colors: [Color(0xFFAD2E24), Color(0xFFE1785B)])),
    child: Stack(fit: StackFit.expand, children: [
      Positioned.fill(child: Opacity(opacity: .23, child: Image.asset('assets/images/planning.png',
        fit: BoxFit.cover, alignment: Alignment.centerRight, excludeFromSemantics: true))),
      LayoutBuilder(builder: (context, size) => Center(child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(width: size.maxWidth, child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Your plans deserve\na clearer path.', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: compact ? 28 : 42,
              height: 1.2, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          const Text('Understand your budget. Explore your possibilities.', textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFFFE9DE), fontSize: 15)),
          if (!compact) ...[
            const SizedBox(height: 36),
            ClipRRect(borderRadius: BorderRadius.circular(24), child: AspectRatio(
              aspectRatio: 1.5, child: Image.asset('assets/images/planning.png', fit: BoxFit.cover,
                excludeFromSemantics: true))),
            const SizedBox(height: 16),
            const Wrap(alignment: WrapAlignment.center, spacing: 20, runSpacing: 10, children: [
              Text('01  Estimate EMI', style: TextStyle(color: Colors.white)),
              Text('02  Check affordability', style: TextStyle(color: Colors.white)),
              Text('03  Explore demo lenders', style: TextStyle(color: Colors.white)),
            ]),
          ],
        ]),
      ))))),
    ]),
  );
}
