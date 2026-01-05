import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('ko'),
    Locale('ar'),
  ];

  /// No description provided for @loginPageDescription.
  ///
  /// In ko, this message translates to:
  /// **''**
  String get loginPageDescription;

  /// No description provided for @loginPageGoogleLogin.
  ///
  /// In ko, this message translates to:
  /// **'Google로 로그인'**
  String get loginPageGoogleLogin;

  /// No description provided for @loginPageFacebookLogin.
  ///
  /// In ko, this message translates to:
  /// **'Facebook으로 로그인'**
  String get loginPageFacebookLogin;

  /// No description provided for @loginPageEmailLogin.
  ///
  /// In ko, this message translates to:
  /// **'Email로 로그인'**
  String get loginPageEmailLogin;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @collections.
  ///
  /// In ko, this message translates to:
  /// **'컬렉션'**
  String get collections;

  /// No description provided for @myPage.
  ///
  /// In ko, this message translates to:
  /// **'마이 페이지'**
  String get myPage;

  /// No description provided for @purchasedCollections.
  ///
  /// In ko, this message translates to:
  /// **'구매한 컬렉션'**
  String get purchasedCollections;

  /// No description provided for @storyList.
  ///
  /// In ko, this message translates to:
  /// **'작품 목록'**
  String get storyList;

  /// No description provided for @tryAgain.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get tryAgain;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @searchPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'컬렉션 또는 작품 검색을 검색하세요'**
  String get searchPlaceholder;

  /// No description provided for @searchDescription.
  ///
  /// In ko, this message translates to:
  /// **'제목, 설명으로 검색이 가능합니다.'**
  String get searchDescription;

  /// No description provided for @freeContent.
  ///
  /// In ko, this message translates to:
  /// **'무료'**
  String get freeContent;

  /// No description provided for @paidContent.
  ///
  /// In ko, this message translates to:
  /// **'유료'**
  String get paidContent;

  /// No description provided for @purchased.
  ///
  /// In ko, this message translates to:
  /// **'구매완료'**
  String get purchased;

  /// No description provided for @storyCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'개의 작품'**
  String get storyCountLabel;

  /// No description provided for @buyCollection.
  ///
  /// In ko, this message translates to:
  /// **'컬렉션 구매'**
  String get buyCollection;

  /// No description provided for @logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃하시겠습니까?'**
  String get logoutConfirm;

  /// No description provided for @buy.
  ///
  /// In ko, this message translates to:
  /// **'구매하기'**
  String get buy;

  /// No description provided for @restore.
  ///
  /// In ko, this message translates to:
  /// **'복원'**
  String get restore;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @noPurchasedCollections.
  ///
  /// In ko, this message translates to:
  /// **'구매한 컬렉션이 없습니다'**
  String get noPurchasedCollections;

  /// No description provided for @storyTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get storyTitle;

  /// No description provided for @storyIntro.
  ///
  /// In ko, this message translates to:
  /// **'소개'**
  String get storyIntro;

  /// No description provided for @storyCommentary.
  ///
  /// In ko, this message translates to:
  /// **'해설'**
  String get storyCommentary;
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
      <String>['ar', 'en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
