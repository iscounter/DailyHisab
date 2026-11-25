// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'DailyHisab';

  @override
  String get navHome => 'হোম';

  @override
  String get navTxns => 'লেনদেন';

  @override
  String get navAccounts => 'অ্যাকাউন্ট';

  @override
  String get navCategories => 'খাত';

  @override
  String get navBudgets => 'বাজেট';

  @override
  String get navAnalytics => 'বিশ্লেষণ';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get totalBalance => 'মোট ব্যালেন্স';

  @override
  String get netThisMonth => 'এই মাসের নিট';

  @override
  String get income => 'আয়';

  @override
  String get expense => 'ব্যয়';

  @override
  String get transfer => 'স্থানান্তর';

  @override
  String get thisMonth => 'এই মাস';

  @override
  String get recentTransactions => 'সাম্প্রতিক লেনদেন';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get noTransactionsYet => 'এখনো কোনো লেনদেন নেই। যোগ করতে + চাপুন।';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টি অ্যাকাউন্ট',
      one: '$count টি অ্যাকাউন্ট',
    );
    return '$_temp0';
  }

  @override
  String get savingsTooltip => 'সঞ্চয় লক্ষ্য';

  @override
  String get settingsTooltip => 'সেটিংস';

  @override
  String get addLabel => 'যোগ করুন';

  @override
  String get kindIncome => 'আয়';

  @override
  String get kindExpense => 'ব্যয়';

  @override
  String get kindTransfer => 'স্থানান্তর';

  @override
  String get chipAll => 'সব';

  @override
  String get transactionsTitle => 'লেনদেন';

  @override
  String get searchNotesHint => 'নোট খুঁজুন…';

  @override
  String get exportCsvTooltip => 'CSV এক্সপোর্ট';

  @override
  String csvCopied(int count) {
    return '$count টি লেনদেন CSV হিসেবে কপি হয়েছে';
  }

  @override
  String get noTxnMatch => 'আপনার খোঁজার সাথে কোনো লেনদেন মেলেনি।';

  @override
  String get addAccountFirst =>
      'প্রথমে একটি অ্যাকাউন্ট যোগ করুন (অ্যাকাউন্ট ট্যাব)।';

  @override
  String get addTxnTitle => 'লেনদেন যোগ করুন';

  @override
  String get editTxnTitle => 'লেনদেন সম্পাদনা';

  @override
  String get amountLabel => 'পরিমাণ (৳)';

  @override
  String get amountHint => 'যেমন 500 বা 500.50';

  @override
  String get fromAccountLabel => 'যে অ্যাকাউন্ট থেকে';

  @override
  String get accountLabel => 'অ্যাকাউন্ট';

  @override
  String get toAccountLabel => 'যে অ্যাকাউন্টে';

  @override
  String get categoryLabel => 'খাত';

  @override
  String get noteLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get dateLabel => 'তারিখ';

  @override
  String get invalidAmount => '০-এর বেশি সঠিক পরিমাণ লিখুন';

  @override
  String get transferAccountsMustDiffer =>
      'স্থানান্তরের দুটি অ্যাকাউন্ট আলাদা হতে হবে';

  @override
  String get addCategoryFirst => 'প্রথমে একটি খাত যোগ করুন।';

  @override
  String get saveLabel => 'সংরক্ষণ';

  @override
  String get updateLabel => 'হালনাগাদ';

  @override
  String get cancelLabel => 'বাতিল';

  @override
  String get deleteLabel => 'মুছুন';

  @override
  String get deleteTxnTitle => 'এই লেনদেন মুছবেন?';

  @override
  String get deleteTxnMessage =>
      'লেনদেনটি তালিকা ও হিসাব থেকে সরে যাবে। সাথে সাথেই আনডু করা যাবে।';

  @override
  String get undoLabel => 'আনডু';

  @override
  String get txnDeleted => 'লেনদেন মুছে ফেলা হয়েছে';

  @override
  String get accountsTitle => 'অ্যাকাউন্ট';

  @override
  String get noAccountsYet =>
      'এখনো কোনো অ্যাকাউন্ট নেই। ক্যাশ, ব্যাংক বা ওয়ালেট যোগ করুন।';

  @override
  String get addAccountTitle => 'অ্যাকাউন্ট যোগ করুন';

  @override
  String get accountNameLabel => 'নাম';

  @override
  String get accountNameHint => 'যেমন ক্যাশ, bKash';

  @override
  String get accountTypeLabel => 'ধরন';

  @override
  String get openingBalanceLabel => 'প্রারম্ভিক জমা (৳)';

  @override
  String get invalidOpeningBalance => 'সঠিক প্রারম্ভিক জমা লিখুন';

  @override
  String get kindCash => 'ক্যাশ';

  @override
  String get kindBank => 'ব্যাংক';

  @override
  String get kindWallet => 'মোবাইল ওয়ালেট';

  @override
  String get kindOther => 'অন্যান্য';

  @override
  String accountSubtitle(String kind, String amount) {
    return '$kind • জমা $amount';
  }

  @override
  String get archiveTooltip => 'আর্কাইভ';

  @override
  String get unarchiveTooltip => 'আনআর্কাইভ';

  @override
  String get archiveConfirmTitle => 'অ্যাকাউন্ট আর্কাইভ করবেন?';

  @override
  String get archiveConfirmMessage =>
      'আর্কাইভ করলে অ্যাকাউন্ট তালিকা থেকে সরে যাবে, তবে ইতিহাস ও জমা অপরিবর্তিত থাকবে।';

  @override
  String get accountArchived => 'অ্যাকাউন্ট আর্কাইভ হয়েছে';

  @override
  String get accountRestored => 'অ্যাকাউন্ট ফিরিয়ে আনা হয়েছে';

  @override
  String get archivedSection => 'আর্কাইভ করা';

  @override
  String get categoriesTitle => 'খাত';

  @override
  String get noCategories => 'এখনো কোনো খাত নেই। যোগ করতে + চাপুন।';

  @override
  String get addCategoryTitle => 'খাত যোগ করুন';

  @override
  String get categoryNameLabel => 'নাম';

  @override
  String get incomeSection => 'আয়';

  @override
  String get expenseSection => 'ব্যয়';

  @override
  String get budgetsTitle => 'বাজেট';

  @override
  String get noBudgets => 'এই মাসের কোনো বাজেট নেই। যোগ করতে + চাপুন।';

  @override
  String get addBudgetTitle => 'বাজেট যোগ করুন';

  @override
  String get budgetNameLabel => 'নাম';

  @override
  String get budgetDefaultName => 'মাসিক বাজেট';

  @override
  String get limitLabel => 'সীমা (৳)';

  @override
  String budgetSpentOf(String spent, String limit) {
    return '$limit-এর মধ্যে খরচ $spent';
  }

  @override
  String overBudget(String amount) {
    return 'সীমার $amount বেশি খরচ হয়েছে';
  }

  @override
  String get deleteBudgetTooltip => 'বাজেট মুছুন';

  @override
  String get analyticsTitle => 'বিশ্লেষণ';

  @override
  String get spendingByCategory => 'খাতভিত্তিক খরচ';

  @override
  String get noExpensesThisMonth => 'এই মাসে কোনো ব্যয় নেই।';

  @override
  String errorWithDetails(String details) {
    return 'সমস্যা: $details';
  }

  @override
  String get somethingWrong => 'কিছু একটা সমস্যা হয়েছে';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get currencyTitle => 'মুদ্রা';

  @override
  String currencySubtitle(String code) {
    return '$code — v1-এ নির্দিষ্ট';
  }

  @override
  String get themeTitle => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get langSystem => 'সিস্টেম';

  @override
  String get langEnglish => 'English';

  @override
  String get langBangla => 'বাংলা';

  @override
  String get backupSection => 'ব্যাকআপ ও রিস্টোর';

  @override
  String get exportBackup => 'ব্যাকআপ এক্সপোর্ট';

  @override
  String get exportBackupSubtitle => 'সব ডেটার JSON ব্যাকআপ সেভ করুন';

  @override
  String get restoreBackup => 'ব্যাকআপ রিস্টোর';

  @override
  String get restoreBackupSubtitle => 'ব্যাকআপ ফাইল থেকে বর্তমান ডেটা বদলান';

  @override
  String backupShareText(String date) {
    return 'DailyHisab ব্যাকআপ ($date)';
  }

  @override
  String get restoreConfirmTitle => 'ব্যাকআপ রিস্টোর করবেন?';

  @override
  String restoreConfirmMessage(
      int accounts, int categories, int transactions, int budgets, int goals) {
    return 'এতে বর্তমান সব ডেটা বদলে ব্যাকআপের ডেটা বসবে: $accounts অ্যাকাউন্ট, $categories খাত, $transactions লেনদেন, $budgets বাজেট, $goals সঞ্চয় লক্ষ্য।';
  }

  @override
  String get restoreSuccess => 'ডেটা রিস্টোর হয়েছে';

  @override
  String restoreFailed(String details) {
    return 'রিস্টোর ব্যর্থ: $details';
  }

  @override
  String get invalidBackup => 'এটি বৈধ DailyHisab ব্যাকআপ ফাইল নয়';

  @override
  String backupExportFailed(String details) {
    return 'এক্সপোর্ট ব্যর্থ: $details';
  }

  @override
  String get aboutTitle => 'অ্যাপ সম্পর্কে';

  @override
  String get aboutSubtitle =>
      'DailyHisab — অফলাইন-ফার্স্ট ব্যক্তিগত হিসাব। টাকা পয়শা হিসেবে সংরক্ষিত থাকে।';

  @override
  String versionLabel(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get savingsTitle => 'সঞ্চয় লক্ষ্য';

  @override
  String get noSavingsGoals =>
      'এখনো কোনো সঞ্চয় লক্ষ্য নেই। তৈরি করতে + চাপুন।';

  @override
  String get newGoalTitle => 'নতুন সঞ্চয় লক্ষ্য';

  @override
  String get goalNameLabel => 'নাম';

  @override
  String get targetLabel => 'লক্ষ্য (৳)';

  @override
  String goalProgress(String saved, String target) {
    return '$target-এর মধ্যে $saved';
  }

  @override
  String get addMoney => 'টাকা যোগ করুন';

  @override
  String get addToSavingsTitle => 'সঞ্চয়ে যোগ করুন';

  @override
  String get goalReached => 'লক্ষ্য পূরণ হয়েছে';

  @override
  String get enterValidGoal => 'নাম ও সঠিক লক্ষ্য লিখুন';

  @override
  String appStartupError(String details) {
    return 'অ্যাপ চালু করতে সমস্যা: $details';
  }
}
