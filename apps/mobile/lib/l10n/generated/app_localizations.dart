import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DailyHisab'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTxns.
  ///
  /// In en, this message translates to:
  /// **'Txns'**
  String get navTxns;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @netThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Net this month'**
  String get netThisMonth;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Tap + to add your first one.'**
  String get noTransactionsYet;

  /// No description provided for @accountsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} account} other{{count} accounts}}'**
  String accountsCount(int count);

  /// No description provided for @savingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @kindIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get kindIncome;

  /// No description provided for @kindExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get kindExpense;

  /// No description provided for @kindTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get kindTransfer;

  /// No description provided for @chipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chipAll;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes…'**
  String get searchNotesHint;

  /// No description provided for @exportCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvTooltip;

  /// No description provided for @csvCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} transactions as CSV'**
  String csvCopied(int count);

  /// No description provided for @noTxnMatch.
  ///
  /// In en, this message translates to:
  /// **'No transactions match your search.'**
  String get noTxnMatch;

  /// No description provided for @addAccountFirst.
  ///
  /// In en, this message translates to:
  /// **'Add an account first (Accounts tab).'**
  String get addAccountFirst;

  /// No description provided for @addTxnTitle.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTxnTitle;

  /// No description provided for @editTxnTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTxnTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (BDT)'**
  String get amountLabel;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500 or 500.50'**
  String get amountHint;

  /// No description provided for @fromAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccountLabel;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @toAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get toAccountLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than 0'**
  String get invalidAmount;

  /// No description provided for @transferAccountsMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Transfer accounts must differ'**
  String get transferAccountsMustDiffer;

  /// No description provided for @addCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a category first.'**
  String get addCategoryFirst;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @updateLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @deleteTxnTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get deleteTxnTitle;

  /// No description provided for @deleteTxnMessage.
  ///
  /// In en, this message translates to:
  /// **'The transaction will be hidden from lists and totals. You can undo right after.'**
  String get deleteTxnMessage;

  /// No description provided for @undoLabel.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoLabel;

  /// No description provided for @txnDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get txnDeleted;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet. Add Cash, Bank, or Wallet.'**
  String get noAccountsYet;

  /// No description provided for @addAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountTitle;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cash, bKash'**
  String get accountNameHint;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountTypeLabel;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening balance (BDT)'**
  String get openingBalanceLabel;

  /// No description provided for @invalidOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Invalid opening balance'**
  String get invalidOpeningBalance;

  /// No description provided for @kindCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get kindCash;

  /// No description provided for @kindBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get kindBank;

  /// No description provided for @kindWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile wallet'**
  String get kindWallet;

  /// No description provided for @kindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get kindOther;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{kind} • Balance {amount}'**
  String accountSubtitle(String kind, String amount);

  /// No description provided for @archiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTooltip;

  /// No description provided for @unarchiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchiveTooltip;

  /// No description provided for @archiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive account?'**
  String get archiveConfirmTitle;

  /// No description provided for @archiveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Archived accounts are hidden from lists but keep their history and balance.'**
  String get archiveConfirmMessage;

  /// No description provided for @accountArchived.
  ///
  /// In en, this message translates to:
  /// **'Account archived'**
  String get accountArchived;

  /// No description provided for @accountRestored.
  ///
  /// In en, this message translates to:
  /// **'Account restored'**
  String get accountRestored;

  /// No description provided for @archivedSection.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedSection;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Tap + to add.'**
  String get noCategories;

  /// No description provided for @addCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameLabel;

  /// No description provided for @incomeSection.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeSection;

  /// No description provided for @expenseSection.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseSection;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets for this month. Tap + to add.'**
  String get noBudgets;

  /// No description provided for @addBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get addBudgetTitle;

  /// No description provided for @budgetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get budgetNameLabel;

  /// No description provided for @budgetDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get budgetDefaultName;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit (BDT)'**
  String get limitLabel;

  /// No description provided for @budgetSpentOf.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} of {limit}'**
  String budgetSpentOf(String spent, String limit);

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudget(String amount);

  /// No description provided for @deleteBudgetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete budget'**
  String get deleteBudgetTooltip;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get spendingByCategory;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get noExpensesThisMonth;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(String details);

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWrong;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @currencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyTitle;

  /// No description provided for @currencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{code} — fixed in v1'**
  String currencySubtitle(String code);

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get langSystem;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get langBangla;

  /// No description provided for @backupSection.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupSection;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a JSON backup of all your data'**
  String get exportBackupSubtitle;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current data from a backup file'**
  String get restoreBackupSubtitle;

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'DailyHisab backup ({date})'**
  String backupShareText(String date);

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces ALL current data with the backup contents: {accounts} accounts, {categories} categories, {transactions} transactions, {budgets} budgets, {goals} savings goals.'**
  String restoreConfirmMessage(
      int accounts, int categories, int transactions, int budgets, int goals);

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {details}'**
  String restoreFailed(String details);

  /// No description provided for @invalidBackup.
  ///
  /// In en, this message translates to:
  /// **'Not a valid DailyHisab backup file'**
  String get invalidBackup;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {details}'**
  String backupExportFailed(String details);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'DailyHisab — offline-first personal finance. Money is stored as integer poisha.'**
  String get aboutSubtitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @savingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsTitle;

  /// No description provided for @noSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet. Tap + to create one.'**
  String get noSavingsGoals;

  /// No description provided for @newGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'New savings goal'**
  String get newGoalTitle;

  /// No description provided for @goalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalNameLabel;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target (BDT)'**
  String get targetLabel;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String goalProgress(String saved, String target);

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get addMoney;

  /// No description provided for @addToSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to savings'**
  String get addToSavingsTitle;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @enterValidGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter a name and a valid target'**
  String get enterValidGoal;

  /// No description provided for @appStartupError.
  ///
  /// In en, this message translates to:
  /// **'Startup error: {details}'**
  String appStartupError(String details);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
