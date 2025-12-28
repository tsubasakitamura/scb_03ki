import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/vm/viewmodel.dart';

// --- 全ファイル共通：画像かアイコンかを判別して表示する部品 ---
class ItemImageDisplay extends StatelessWidget {
  final String path;
  final double size;

  const ItemImageDisplay({super.key, required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    // アイコンパス（icon:name）の場合
    if (path.startsWith('icon:')) {
      final iconName = path.replaceFirst('icon:', '');
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Icon(getIconData(iconName), size: size * 0.5, color: Colors.blueGrey),
      );
    }

    // 通常の画像パスの場合
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: path.isEmpty
              ? const AssetImage("assets/images/gray.png") as ImageProvider
              : FileImage(File(path)),
        ),
      ),
    );
  }
}

// --- アイコン名からFontAwesomeのデータに変換する共通関数 ---
IconData getIconData(String name) {
  switch (name) {
  // 建物・目的地
    case 'hospital_b': return FontAwesomeIcons.hospital;
    case 'clinic': return FontAwesomeIcons.houseMedical;
    case 'office': return FontAwesomeIcons.building;
    case 'school_b': return FontAwesomeIcons.school;
    case 'cafe': return FontAwesomeIcons.mugSaucer;
    case 'store': return FontAwesomeIcons.store;
    case 'home': return FontAwesomeIcons.house;
    case 'gym': return FontAwesomeIcons.dumbbell;
  // 医療・中身
    case 'medical': return FontAwesomeIcons.fileMedical;
    case 'pills': return FontAwesomeIcons.pills;
    case 'mask': return FontAwesomeIcons.maskFace;
    case 'briefcase': return FontAwesomeIcons.briefcase;
    case 'school': return FontAwesomeIcons.graduationCap;
    case 'laptop': return FontAwesomeIcons.laptop;
    case 'pen': return FontAwesomeIcons.penNib;
    case 'umbrella': return FontAwesomeIcons.umbrella;
    case 'wallet': return FontAwesomeIcons.wallet;
    case 'key': return FontAwesomeIcons.key;
    case 'mobile': return FontAwesomeIcons.mobileScreen;
    case 'camera': return FontAwesomeIcons.camera;
    case 'ticket': return FontAwesomeIcons.ticket;
    case 'bottle': return FontAwesomeIcons.bottleWater;
    case 'map': return FontAwesomeIcons.mapLocationDot;
    case 'shopping': return FontAwesomeIcons.bagShopping;
    case 'travel': return FontAwesomeIcons.suitcaseRolling;
    case 'baby': return FontAwesomeIcons.babyCarriage;
    case 'pet': return FontAwesomeIcons.paw;
    case 'id': return FontAwesomeIcons.idCard;
    case 'book': return FontAwesomeIcons.book;
    case 'glasses': return FontAwesomeIcons.glasses;
    case 'bicycle': return FontAwesomeIcons.bicycle;
    default: return FontAwesomeIcons.box;
  }
}

// --- アイコン選択肢の共通リスト ---
final Map<String, IconData> globalIconMap = {
  'hospital_b': FontAwesomeIcons.hospital,
  'clinic': FontAwesomeIcons.houseMedical,
  'office': FontAwesomeIcons.building,
  'school_b': FontAwesomeIcons.school,
  'cafe': FontAwesomeIcons.mugSaucer,
  'store': FontAwesomeIcons.store,
  'home': FontAwesomeIcons.house,
  'gym': FontAwesomeIcons.dumbbell,
  'medical': FontAwesomeIcons.fileMedical,
  'pills': FontAwesomeIcons.pills,
  'mask': FontAwesomeIcons.maskFace,
  'briefcase': FontAwesomeIcons.briefcase,
  'school': FontAwesomeIcons.graduationCap,
  'laptop': FontAwesomeIcons.laptop,
  'pen': FontAwesomeIcons.penNib,
  'umbrella': FontAwesomeIcons.umbrella,
  'wallet': FontAwesomeIcons.wallet,
  'key': FontAwesomeIcons.key,
  'mobile': FontAwesomeIcons.mobileScreen,
  'camera': FontAwesomeIcons.camera,
  'ticket': FontAwesomeIcons.ticket,
  'bottle': FontAwesomeIcons.bottleWater,
  'map': FontAwesomeIcons.mapLocationDot,
  'shopping': FontAwesomeIcons.bagShopping,
  'travel': FontAwesomeIcons.suitcaseRolling,
  'baby': FontAwesomeIcons.babyCarriage,
  'pet': FontAwesomeIcons.paw,
  'id': FontAwesomeIcons.idCard,
  'book': FontAwesomeIcons.book,
  'glasses': FontAwesomeIcons.glasses,
  'bicycle': FontAwesomeIcons.bicycle,
};

// --------------------------------------------------------------------------
// [Widget] PackingProgressBar
// --------------------------------------------------------------------------
class PackingProgressBar extends StatelessWidget {
  const PackingProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewModel>(
      builder: (context, vm, child) {
        final progress = vm.packingProgress;
        final percent = (progress * 100).toInt();
        final isComplete = progress >= 1.0;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- アイデア2: 状況に合わせてメッセージを変化させる ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      isComplete ? "✨ 準備完了！お気をつけて！" : "準備の進み具合",
                      key: ValueKey<bool>(isComplete),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isComplete ? Colors.green[700] : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    "$percent %",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isComplete ? Colors.green : Colors.lightBlue
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  // 完了時はゲージも安心感のある緑色に
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? Colors.green : Colors.lightBlue
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}