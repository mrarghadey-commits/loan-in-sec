import '../widgets/photo_scaffold.dart';
import '../widgets/planning_banner.dart';
import 'package:flutter/material.dart';

import '../models/loan_data.dart';
import '../services/api_service.dart';
import '../widgets/loan_form.dart';
import 'auth_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = 'User',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  String get _displayName {
    final name = widget.userName.trim();
    if (name.isEmpty) return 'User';
    return name.characters.first.toUpperCase() + name.characters.skip(1).join();
  }

  // ============================================================
  // LOAN PREDICTION
  // ============================================================

  Future<void> _handleEvaluation(LoanData data) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Send current user's loan information to Flask backend
      final Map<String, dynamic> result =
          await ApiService.predictLoan(data);

      if (!mounted) return;

      // Open result page with complete dynamic prediction result
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            predictionResult: result,
            loanData: data,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();

      // Remove "Exception:" from error message
      message = message.replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
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

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await ApiService.logout();
    } catch (_) {
      // Even if backend logout fails,
      // user will still be returned to login screen.
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  Future<void> _showLogoutDialog() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PhotoScaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,

        title: Row(
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bolt,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            // App name
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan in Sec | Application',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'INR Affordability Calculator',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // ======================================================
        // USER + LOGOUT
        // ======================================================

        actions: [
          // Logged-in user
          if (MediaQuery.of(context).size.width > 600)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _displayName,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Logout
          IconButton(
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // WELCOME SECTION
                    // ==================================================

                    const PlanningBanner(),
                    const SizedBox(height: 28),
                    Text(
                      'Welcome, $_displayName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Enter annual income in rupees and your existing debt ratio to estimate affordability.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // PROGRESS CARD
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFFEAF6F3),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '2',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          color:
                                              Color(0xFF087F75),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    const Expanded(
                                      child: Text(
                                        'Financial & Employment',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 14,
                                          color:
                                              Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE6F9F0),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Step 2 of 4',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF059669),
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(6),
                            child:
                                const LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 6,
                              backgroundColor:
                                  Color(0xFFF1F5F9),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // LOAN FORM
                    // ==================================================

                    LoanForm(
                      isLoading: _isLoading,

                      // When form submits,
                      // call ML prediction API.
                      onSubmit: (LoanData data) {
                        _handleEvaluation(data);
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // LOADING OVERLAY
          // ========================================================

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.15,
                ),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 22,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Analyzing application...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
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
