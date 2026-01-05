// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get loginPageDescription => '';

  @override
  String get loginPageGoogleLogin => 'Google로 로그인';

  @override
  String get loginPageFacebookLogin => 'Facebook으로 로그인';

  @override
  String get loginPageEmailLogin => 'Email로 로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get collections => '컬렉션';

  @override
  String get myPage => '마이 페이지';

  @override
  String get purchasedCollections => '구매한 컬렉션';

  @override
  String get storyList => '작품 목록';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get search => '검색';

  @override
  String get searchPlaceholder => '컬렉션 또는 작품 검색을 검색하세요';

  @override
  String get searchDescription => '제목, 설명으로 검색이 가능합니다.';

  @override
  String get freeContent => '무료';

  @override
  String get paidContent => '유료';

  @override
  String get purchased => '구매완료';

  @override
  String get storyCountLabel => '개의 작품';

  @override
  String get buyCollection => '컬렉션 구매';

  @override
  String get logoutConfirm => '정말 로그아웃하시겠습니까?';

  @override
  String get buy => '구매하기';

  @override
  String get restore => '복원';

  @override
  String get cancel => '취소';

  @override
  String get noPurchasedCollections => '구매한 컬렉션이 없습니다';

  @override
  String get storyTitle => '제목';

  @override
  String get storyIntro => '소개';

  @override
  String get storyCommentary => '해설';
}
