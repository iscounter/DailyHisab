// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DailyHisab';

  @override
  String get navHome => 'Home';

  @override
  String get navTxns => 'Txns';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navCategories => 'Categories';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get netThisMonth => 'Net this month';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get thisMonth => 'This month';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactionsYet =>
      'No transactions yet. Tap + to add your first one.';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '$count account',
    );
    return '$_temp0';
  }

  @override
  String get savingsTooltip => 'Savings goals';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get addLabel => 'Add';

  @override
  String get kindIncome => 'Income';

  @override
  String get kindExpense => 'Expense';

  @override
  String get kindTransfer => 'Transfer';

  @override
  String get chipAll => 'All';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get searchNotesHint => 'Search notes…';

  @override
  String get exportCsvTooltip => 'Export CSV';

  @override
  String csvCopied(int count) {
    return 'Copied $count transactions as CSV';
  }

  @override
  String get noTxnMatch => 'No transactions match your search.';

  @override
  String get addAccountFirst => 'Add an account first (Accounts tab).';

  @override
  String get addTxnTitle => 'Add transaction';

  @override
  String get editTxnTitle => 'Edit transaction';

  @override
  String get amountLabel => 'Amount (BDT)';

  @override
  String get amountHint => 'e.g. 500 or 500.50';

  @override
  String get fromAccountLabel => 'From account';

  @override
  String get accountLabel => 'Account';

  @override
  String get toAccountLabel => 'To account';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get dateLabel => 'Date';

  @override
  String get invalidAmount => 'Enter a valid amount greater than 0';

  @override
  String get transferAccountsMustDiffer => 'Transfer accounts must differ';

  @override
  String get addCategoryFirst => 'Add a category first.';

  @override
  String get saveLabel => 'Save';

  @override
  String get updateLabel => 'Update';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get deleteTxnTitle => 'Delete this transaction?';

  @override
  String get deleteTxnMessage =>
      'The transaction will be hidden from lists and totals. You can undo right after.';

  @override
  String get undoLabel => 'Undo';

  @override
  String get txnDeleted => 'Transaction deleted';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get noAccountsYet => 'No accounts yet. Add Cash, Bank, or Wallet.';

  @override
  String get addAccountTitle => 'Add account';

  @override
  String get accountNameLabel => 'Name';

  @override
  String get accountNameHint => 'e.g. Cash, bKash';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get openingBalanceLabel => 'Opening balance (BDT)';

  @override
  String get invalidOpeningBalance => 'Invalid opening balance';

  @override
  String get kindCash => 'Cash';

  @override
  String get kindBank => 'Bank';

  @override
  String get kindWallet => 'Mobile wallet';

  @override
  String get kindOther => 'Other';

  @override
  String accountSubtitle(String kind, String amount) {
    return '$kind • Balance $amount';
  }

  @override
  String get archiveTooltip => 'Archive';

  @override
  String get unarchiveTooltip => 'Unarchive';

  @override
  String get archiveConfirmTitle => 'Archive account?';

  @override
  String get archiveConfirmMessage =>
      'Archived accounts are hidden from lists but keep their history and balance.';

  @override
  String get accountArchived => 'Account archived';

  @override
  String get accountRestored => 'Account restored';

  @override
  String get archivedSection => 'Archived';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get noCategories => 'No categories yet. Tap + to add.';

  @override
  String get addCategoryTitle => 'Add category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get incomeSection => 'Income';

  @override
  String get expenseSection => 'Expense';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get noBudgets => 'No budgets for this month. Tap + to add.';

  @override
  String get addBudgetTitle => 'Add budget';

  @override
  String get budgetNameLabel => 'Name';

  @override
  String get budgetDefaultName => 'Monthly budget';

  @override
  String get limitLabel => 'Limit (BDT)';

  @override
  String budgetSpentOf(String spent, String limit) {
    return 'Spent $spent of $limit';
  }

  @override
  String overBudget(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String get deleteBudgetTooltip => 'Delete budget';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get noExpensesThisMonth => 'No expenses this month.';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get somethingWrong => 'Something went wrong';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get currencyTitle => 'Currency';

  @override
  String currencySubtitle(String code) {
    return '$code — fixed in v1';
  }

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get langSystem => 'System';

  @override
  String get langEnglish => 'English';

  @override
  String get langBangla => 'বাংলা';

  @override
  String get backupSection => 'Backup & restore';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupSubtitle => 'Save a JSON backup of all your data';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get restoreBackupSubtitle => 'Replace current data from a backup file';

  @override
  String backupShareText(String date) {
    return 'DailyHisab backup ($date)';
  }

  @override
  String get restoreConfirmTitle => 'Restore backup?';

  @override
  String restoreConfirmMessage(
      int accounts, int categories, int transactions, int budgets, int goals) {
    return 'This replaces ALL current data with the backup contents: $accounts accounts, $categories categories, $transactions transactions, $budgets budgets, $goals savings goals.';
  }

  @override
  String get restoreSuccess => 'Data restored';

  @override
  String restoreFailed(String details) {
    return 'Restore failed: $details';
  }

  @override
  String get invalidBackup => 'Not a valid DailyHisab backup file';

  @override
  String backupExportFailed(String details) {
    return 'Export failed: $details';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle =>
      'DailyHisab — offline-first personal finance. Money is stored as integer poisha.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get savingsTitle => 'Savings goals';

  @override
  String get noSavingsGoals => 'No savings goals yet. Tap + to create one.';

  @override
  String get newGoalTitle => 'New savings goal';

  @override
  String get goalNameLabel => 'Name';

  @override
  String get targetLabel => 'Target (BDT)';

  @override
  String goalProgress(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get addMoney => 'Add money';

  @override
  String get addToSavingsTitle => 'Add to savings';

  @override
  String get goalReached => 'Goal reached';

  @override
  String get enterValidGoal => 'Enter a name and a valid target';

  @override
  String appStartupError(String details) {
    return 'Startup error: $details';
  }
}
