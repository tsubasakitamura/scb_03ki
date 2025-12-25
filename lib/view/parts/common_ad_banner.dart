import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../main.dart';

class CommonAdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: adManager.bannerAd.size.width.toDouble(),
      height: adManager.bannerAd.size.height.toDouble(),
      child: AdWidget(ad: adManager.bannerAd),
    );
  }
}