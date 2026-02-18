// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HomeTasks';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get or => 'or';

  @override
  String continueWith(String provider) {
    return 'Continue with $provider';
  }

  @override
  String get login => 'Log in';

  @override
  String get logout => 'Log out';

  @override
  String get register => 'Sign up';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Enter your credentials to access your account';

  @override
  String get createAccount => 'Create an account';

  @override
  String get registerSubtitle => 'Enter your information to get started';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get email => 'Email';

  @override
  String get emailPlaceholder => 'name@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordPlaceholder => '••••••••';

  @override
  String get name => 'Full name';

  @override
  String get namePlaceholder => 'John Doe';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String passwordMinLength(int length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get nameRequired => 'Full name is required';

  @override
  String get networkError =>
      'No internet connection. Please check your network.';

  @override
  String get serverError => 'Something went wrong on our end. Try again later.';

  @override
  String get unauthorizedError =>
      'Your session has expired. Please log in again.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get defaultHomeName => 'My Home';

  @override
  String get viewDay => 'Day';

  @override
  String get viewWeek => 'Week';

  @override
  String get progressDay => 'Today\'s progress';

  @override
  String get progressWeek => 'Weekly progress';

  @override
  String tasksCompleted(int completed, int total) {
    return '$completed of $total tasks completed';
  }

  @override
  String get newTask => 'New task';

  @override
  String get taskFieldLabel => 'TASK';

  @override
  String get taskFieldHint => 'Describe the task...';

  @override
  String get descFieldLabel => 'DESCRIPTION';

  @override
  String get descFieldOptional => '(optional)';

  @override
  String get descFieldHint => 'Add details or notes...';

  @override
  String get categoryLabel => 'CATEGORY';

  @override
  String get timeLabel => 'TIME';

  @override
  String get assigneeLabel => 'ASSIGNEE';

  @override
  String get assigneeHint => 'Name';

  @override
  String get addTask => 'Add task';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPreferences => 'PREFERENCES';

  @override
  String get settingsSectionAbout => 'ABOUT';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsSoundsOn => 'Enabled';

  @override
  String get settingsSoundsOff => 'Disabled';

  @override
  String get settingsContact => 'Contact us';

  @override
  String get settingsContactSubtitle => 'Send feedback or report issues';

  @override
  String get settingsFollow => 'Follow us';

  @override
  String get settingsFollowSubtitle => 'Social media and updates';

  @override
  String get settingsRate => 'Rate us';

  @override
  String get settingsRateSubtitle => 'Leave a review on the App Store';

  @override
  String get settingsTerms => 'Terms of service';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsVersion => 'Home v1.0.0';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summarySubtitle => 'This week';

  @override
  String summaryPoints(int points) {
    return '$points pts';
  }

  @override
  String summaryWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get taskDetailToday => 'Today';

  @override
  String get taskDetailStatusPending => 'Pending';

  @override
  String get taskDetailStatusPendingSubtitle =>
      'Mark as completed when you\'re done';

  @override
  String get taskDetailStatusCompleted => 'Completed';

  @override
  String get taskDetailStatusCompletedSubtitle =>
      'This task has already been done';

  @override
  String get taskDetailMarkCompleted => 'Mark as completed';

  @override
  String get taskDetailMarkPending => 'Mark as pending';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';
}
