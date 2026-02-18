import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'HomeTasks'**
  String get appTitle;

  /// Generic loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Back navigation
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Separator between options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Social sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String continueWith(String provider);

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register;

  /// Login screen headline
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your account'**
  String get loginSubtitle;

  /// Register screen headline
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your information to get started'**
  String get registerSubtitle;

  /// Link on register screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Link on login screen
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field placeholder
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailPlaceholder;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field placeholder
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordPlaceholder;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get name;

  /// Name field placeholder
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get namePlaceholder;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Validation: email required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Validation: invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// Validation: password required
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Validation: password min length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {length} characters'**
  String passwordMinLength(int length);

  /// Validation: name required
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get nameRequired;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get networkError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Try again later.'**
  String get serverError;

  /// Session expired message
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get unauthorizedError;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Default home name
  ///
  /// In en, this message translates to:
  /// **'My Home'**
  String get defaultHomeName;

  /// Day view tab
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get viewDay;

  /// Week view tab
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get viewWeek;

  /// Daily progress card title
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get progressDay;

  /// Weekly progress card title
  ///
  /// In en, this message translates to:
  /// **'Weekly progress'**
  String get progressWeek;

  /// Tasks completed summary
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks completed'**
  String tasksCompleted(int completed, int total);

  /// Create task sheet title
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// Task field section label
  ///
  /// In en, this message translates to:
  /// **'TASK'**
  String get taskFieldLabel;

  /// Task field hint
  ///
  /// In en, this message translates to:
  /// **'Describe the task...'**
  String get taskFieldHint;

  /// Description field section label
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descFieldLabel;

  /// Optional suffix
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get descFieldOptional;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Add details or notes...'**
  String get descFieldHint;

  /// Category section label
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get categoryLabel;

  /// Time section label
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// Assignee section label
  ///
  /// In en, this message translates to:
  /// **'ASSIGNEE'**
  String get assigneeLabel;

  /// Assignee field hint
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get assigneeHint;

  /// Submit button on create task sheet
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Preferences section header
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get settingsSectionPreferences;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsSectionAbout;

  /// Legal section header
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get settingsSectionLegal;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageEs;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Dark theme label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Light theme label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Sounds setting label
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get settingsSounds;

  /// Sounds enabled label
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsSoundsOn;

  /// Sounds disabled label
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsSoundsOff;

  /// Contact row title
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsContact;

  /// Contact row subtitle
  ///
  /// In en, this message translates to:
  /// **'Send feedback or report issues'**
  String get settingsContactSubtitle;

  /// Follow row title
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get settingsFollow;

  /// Follow row subtitle
  ///
  /// In en, this message translates to:
  /// **'Social media and updates'**
  String get settingsFollowSubtitle;

  /// Rate row title
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get settingsRate;

  /// Rate row subtitle
  ///
  /// In en, this message translates to:
  /// **'Leave a review on the App Store'**
  String get settingsRateSubtitle;

  /// Terms of service row title
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsTerms;

  /// Privacy policy row title
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// App version string
  ///
  /// In en, this message translates to:
  /// **'Home v1.0.0'**
  String get settingsVersion;

  /// Summary screen title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// Summary screen subtitle
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get summarySubtitle;

  /// Points label for each member
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String summaryPoints(int points);

  /// Week date range label
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String summaryWeekRange(String start, String end);

  /// Date label shown in task detail sheet
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get taskDetailToday;

  /// Pending status label in task detail
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskDetailStatusPending;

  /// Pending status subtitle
  ///
  /// In en, this message translates to:
  /// **'Mark as completed when you\'re done'**
  String get taskDetailStatusPendingSubtitle;

  /// Completed status label in task detail
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskDetailStatusCompleted;

  /// Completed status subtitle
  ///
  /// In en, this message translates to:
  /// **'This task has already been done'**
  String get taskDetailStatusCompletedSubtitle;

  /// CTA button when task is pending
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get taskDetailMarkCompleted;

  /// CTA button when task is completed
  ///
  /// In en, this message translates to:
  /// **'Mark as pending'**
  String get taskDetailMarkPending;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
