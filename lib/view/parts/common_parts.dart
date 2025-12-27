import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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