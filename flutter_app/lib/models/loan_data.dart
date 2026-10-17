class LoanData {
  final double annualIncome;
  final double debtToIncomeRatio;
  final double creditScore;
  final double loanAmount;
  final double interestRate;
  final int loanTermMonths;
  final String gender;
  final String maritalStatus;
  final String educationLevel;
  final String employmentStatus;
  final String loanPurpose;
  final String gradeSubgrade;

  LoanData({
    required this.annualIncome,
    required this.debtToIncomeRatio,
    required this.creditScore,
    required this.loanAmount,
    required this.interestRate,
    this.loanTermMonths = 36,
    required this.gender,
    required this.maritalStatus,
    required this.educationLevel,
    required this.employmentStatus,
    required this.loanPurpose,
    required this.gradeSubgrade,
  });

  /// Serializes the model into the exact snake_case keys expected by the scikit-learn pipeline
  Map<String, dynamic> toJson() {
    return {
      'currency': 'INR',
      'loan_term_months': loanTermMonths,
      'annual_income': annualIncome,
      'debt_to_income_ratio': debtToIncomeRatio,
      'credit_score': creditScore,
      'loan_amount': loanAmount,
      'interest_rate': interestRate,
      'gender': gender,
      'marital_status': maritalStatus,
      'education_level': educationLevel,
      'employment_status': employmentStatus,
      'loan_purpose': loanPurpose,
      'grade_subgrade': gradeSubgrade,
    };
  }

  /// Deserializes a JSON map into a LoanData instance
  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      loanTermMonths: (json['loan_term_months'] as num?)?.toInt() ?? 36,
      annualIncome: (json['annual_income'] as num).toDouble(),
      debtToIncomeRatio: (json['debt_to_income_ratio'] as num).toDouble(),
      creditScore: (json['credit_score'] as num).toDouble(),
      loanAmount: (json['loan_amount'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num).toDouble(),
      gender: json['gender'] as String,
      maritalStatus: json['marital_status'] as String,
      educationLevel: json['education_level'] as String,
      employmentStatus: json['employment_status'] as String,
      loanPurpose: json['loan_purpose'] as String,
      gradeSubgrade: json['grade_subgrade'] as String,
    );
  }

  /// Creates a copy of the instance with updated fields
  LoanData copyWith({
    double? annualIncome,
    double? debtToIncomeRatio,
    double? creditScore,
    double? loanAmount,
    double? interestRate,
    int? loanTermMonths,
    String? gender,
    String? maritalStatus,
    String? educationLevel,
    String? employmentStatus,
    String? loanPurpose,
    String? gradeSubgrade,
  }) {
    return LoanData(
      loanTermMonths: loanTermMonths ?? this.loanTermMonths,
      annualIncome: annualIncome ?? this.annualIncome,
      debtToIncomeRatio: debtToIncomeRatio ?? this.debtToIncomeRatio,
      creditScore: creditScore ?? this.creditScore,
      loanAmount: loanAmount ?? this.loanAmount,
      interestRate: interestRate ?? this.interestRate,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      educationLevel: educationLevel ?? this.educationLevel,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      loanPurpose: loanPurpose ?? this.loanPurpose,
      gradeSubgrade: gradeSubgrade ?? this.gradeSubgrade,
    );
  }
}