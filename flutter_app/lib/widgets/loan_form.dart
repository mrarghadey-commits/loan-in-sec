import 'package:flutter/material.dart';
import '../models/loan_data.dart';

class LoanForm extends StatefulWidget {
  final Function(LoanData) onSubmit;
  final bool isLoading;

  const LoanForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<LoanForm> createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();

  final _incomeController = TextEditingController(text: '94000');
  final _dtiController = TextEditingController(text: '10.8');
  final _creditScoreController = TextEditingController(text: '750');
  final _loanAmountController = TextEditingController(text: '25000');
  final _interestRateController = TextEditingController(text: '6.5');

  final _termController = TextEditingController(text: '36');

  String _gender = 'Female';
  String _maritalStatus = 'Single';
  String _educationLevel = "Bachelor's";
  String _employmentStatus = 'Employed';
  String _loanPurpose = 'Debt consolidation';
  String _gradeSubgrade = 'A1';

  final List<String> _genders = ['Female', 'Male', 'Other'];
  final List<String> _maritalStatuses = ['Divorced', 'Married', 'Single', 'Widowed'];
  final List<String> _educationLevels = ["Bachelor's", 'High School', "Master's", 'Other', 'PhD'];
  final List<String> _employmentStatuses = ['Employed', 'Retired', 'Self-employed', 'Student', 'Unemployed'];
  final List<String> _loanPurposes = ['Business', 'Car', 'Debt consolidation', 'Education', 'Home', 'Medical', 'Other', 'Vacation'];
  final List<String> _grades = [
    'A1', 'A2', 'A3', 'A4', 'A5',
    'B1', 'B2', 'B3', 'B4', 'B5',
    'C1', 'C2', 'C3', 'C4', 'C5',
    'D1', 'D2', 'D3', 'D4', 'D5',
    'E1', 'E2', 'E3', 'E4', 'E5',
    'F1', 'F2', 'F3', 'F4', 'F5'
  ];

  @override
  void dispose() {
    _termController.dispose();
    _incomeController.dispose();
    _dtiController.dispose();
    _creditScoreController.dispose();
    _loanAmountController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final loanData = LoanData(
        loanTermMonths: int.parse(_termController.text.trim()),
        annualIncome: double.parse(_incomeController.text),
        debtToIncomeRatio: double.parse(_dtiController.text),
        creditScore: double.parse(_creditScoreController.text),
        loanAmount: double.parse(_loanAmountController.text),
        interestRate: double.parse(_interestRateController.text),
        gender: _gender,
        maritalStatus: _maritalStatus,
        educationLevel: _educationLevel,
        employmentStatus: _employmentStatus,
        loanPurpose: _loanPurpose,
        gradeSubgrade: _gradeSubgrade,
      );
      widget.onSubmit(loanData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard(
            title: 'Financial Figures',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              _buildTextField(_incomeController, 'Annual Income (\u20b9)', Icons.currency_rupee),
              const SizedBox(height: 12),
              _buildTextField(_dtiController, 'Existing debt / income (%) - excludes new EMI', Icons.percent),
              const SizedBox(height: 12),
              _buildTextField(_creditScoreController, 'Credit Score (300-850)', Icons.speed),
              const SizedBox(height: 12),
              _buildTextField(_loanAmountController, 'Loan Amount (\u20b9)', Icons.currency_rupee),
              const SizedBox(height: 12),
              _buildTextField(_interestRateController, 'Annual Interest Rate (%)', Icons.trending_up),
              const SizedBox(height: 12),
              _buildTextField(_termController, 'Loan Duration (months)', Icons.calendar_month),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputCard(
            title: 'Applicant & Loan Profile',
            icon: Icons.person_outline,
            children: [
              _buildDropdown('Gender', _gender, _genders, (v) => setState(() => _gender = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Marital Status', _maritalStatus, _maritalStatuses, (v) => setState(() => _maritalStatus = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Education', _educationLevel, _educationLevels, (v) => setState(() => _educationLevel = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Employment', _employmentStatus, _employmentStatuses, (v) => setState(() => _employmentStatus = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Loan Purpose', _loanPurpose, _loanPurposes, (v) => setState(() => _loanPurpose = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Risk Grade Tier', _gradeSubgrade, _grades, (v) => setState(() => _gradeSubgrade = v!)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087F75),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check Affordability',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF087F75)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData prefixIcon) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        final value = double.tryParse(val?.trim() ?? '');
        if (value == null || !value.isFinite) return 'Enter a valid number';
        if (controller == _termController) {
          if (int.tryParse(val!.trim()) == null || value < 1 || value > 600) {
            return 'Enter whole months from 1 to 600';
          }
        } else if (controller == _creditScoreController) {
          if (value < 300 || value > 850) return 'Enter a score from 300 to 850';
        } else if (controller == _dtiController || controller == _interestRateController) {
          if (value < 0 || value > 100) return 'Enter a percentage from 0 to 100';
        } else if (value <= 0 || value > 1e12) {
          return 'Enter an amount greater than zero and at most 1 trillion';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        prefixIcon: Icon(prefixIcon, size: 18, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }
}