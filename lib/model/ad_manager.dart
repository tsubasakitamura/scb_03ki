// ==========================================================================
// File: ad_manager.dart
// --------------------------------------------------------------------------
// [広告管理クラス：広告の初期化とインスタンス生成を担当]
// ==========================================================================

import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // ★ インスタンスを直接持たず、生成メソッドにする
  // これにより、画面ごとに独立した広告IDがネイティブ側で発行され、衝突が防げます

  Future<void> initAdmob() {
    print("initAdmob");
    return MobileAds.instance.initialize();
  }

  // ★ 修正：BannerAd を作成して返す関数にする
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print("Ad Loaded: ${ad.adUnitId}"),
        onAdFailedToLoad: (ad, error) {
          print("Ad Failed to Load: $error");
          ad.dispose(); // ロード失敗時はメモリ解放
        },
      ),
    )..load(); // 作成と同時にロードを開始
  }

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3364901739591913~8717473906";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3364901739591913~8497433316";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3364901739591913/3273575530";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3364901739591913/6992779952";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}