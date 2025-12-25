import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemImageView extends StatelessWidget {
  final String path;
  final double size;

  const ItemImageView({required this.path, this.size = 100});

  @override
  Widget build(BuildContext context) {
    // アイコンの場合
    if (path.startsWith('icon:')) {
      final iconName = path.replaceFirst('icon:', '');
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(20)),
        child: Icon(_getIconData(iconName), size: size * 0.6, color: Colors.blueGrey),
      );
    }

    // 画像ファイルの場合
    return Container(
      width: size, height: size,
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

  // 文字列からIconDataに変換（主要なものを定義）
  IconData _getIconData(String name) {
    switch (name) {
    // 病院
      case 'medical': return FontAwesomeIcons.fileMedical;
      case 'pills': return FontAwesomeIcons.pills;
      case 'hospital': return FontAwesomeIcons.hospital;
      case 'mask': return FontAwesomeIcons.maskFace;
    // 仕事・学校
      case 'briefcase': return FontAwesomeIcons.briefcase;
      case 'school': return FontAwesomeIcons.graduationCap;
      case 'laptop': return FontAwesomeIcons.laptop;
      case 'pen': return FontAwesomeIcons.penNib;
    // 外出
      case 'umbrella': return FontAwesomeIcons.umbrella;
      case 'wallet': return FontAwesomeIcons.wallet;
      case 'key': return FontAwesomeIcons.key;
      case 'mobile': return FontAwesomeIcons.mobileScreen;
      case 'camera': return FontAwesomeIcons.camera;
      case 'ticket': return FontAwesomeIcons.ticket;
      case 'bottle': return FontAwesomeIcons.bottleWater;
      case 'map': return FontAwesomeIcons.mapLocationDot;
    // その他
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
}