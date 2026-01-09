// lib/view/parts/common_ad_banner.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CommonAdBanner extends StatelessWidget {
  // ★ 外部（各画面）から、その画面専用の広告を受け取る
  final BannerAd? ad;

  const CommonAdBanner({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 広告がロードされていない場合は何も出さない（安全策）
    if (ad == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: ad!.size.width.toDouble(),
      height: ad!.size.height.toDouble(),
      // Key を付けることで、遷移時のチラつきや衝突を防ぐ
      child: AdWidget(
        key: ObjectKey(ad),
        ad: ad!,
      ),
    );
  }
}