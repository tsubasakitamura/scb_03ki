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
          // ★ 背景色を削除（または Colors.transparent に変更）
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        // アイコンの色（color: Colors.blueGrey）も必要に応じて調整してください
        child: Icon(getIconData(iconName), size: size * 0.5, color: Colors.blueGrey[700]),
      );
    }

    // 通常の画像パスの場合
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // ★ 背景色を削除（または Colors.transparent に変更）
        color: Colors.transparent,
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

IconData getIconData(String name) {
  switch (name) {
  // --- 目的地 ---
    case 'hospital_b': return FontAwesomeIcons.hospital;
    case 'clinic': return FontAwesomeIcons.houseMedical;
    case 'office': return FontAwesomeIcons.building;
    case 'school_b': return FontAwesomeIcons.school;
    case 'cafe': return FontAwesomeIcons.mugSaucer;
    case 'store': return FontAwesomeIcons.store;
    case 'home': return FontAwesomeIcons.house;
    case 'gym': return FontAwesomeIcons.dumbbell;

  // --- 医療・健康（スクショにあるもの） ---
    case 'medical_book': return FontAwesomeIcons.bookMedical; // お薬手帳
    case 'medical_card': return FontAwesomeIcons.addressCard; // 診察券・保険証（カード形状）
    case 'pills': return FontAwesomeIcons.pills;             // 常備薬・錠剤
    case 'mask': return FontAwesomeIcons.maskFace;           // マスク
    case 'wash': return FontAwesomeIcons.soap;               // 洗面用具・石鹸

  // --- デジタル・ビジネス ---
    case 'mobile': return FontAwesomeIcons.mobileScreenButton; // スマホ
    case 'laptop': return FontAwesomeIcons.laptop;             // ノートPC
    case 'battery': return FontAwesomeIcons.batteryFull;       // 充電器・バッテリー
    case 'pen': return FontAwesomeIcons.penNib;                // 筆記用具
    case 'id_case': return FontAwesomeIcons.idBadge;           // 名刺入れ

  // --- 貴重品・生活 ---
    case 'wallet': return FontAwesomeIcons.wallet;            // お財布
    case 'money': return FontAwesomeIcons.coins;              // 小銭入れ・月謝袋
    case 'card': return FontAwesomeIcons.creditCard;          // 会員証・ポイントカード
    case 'key': return FontAwesomeIcons.key;                  // 鍵
    case 'umbrella': return FontAwesomeIcons.umbrella;        // 傘
    case 'bottle': return FontAwesomeIcons.bottleWater;       // 水筒・ペットボトル
    case 'shopping': return FontAwesomeIcons.bagShopping;     // エコバッグ

  // --- 衣類・小物 ---
    case 'towel': return FontAwesomeIcons.rug;                // タオル（布の質感）
    case 'sauna_hat': return FontAwesomeIcons.dungeon;        // サウナハット（形が一番近い）
    case 'clothes': return FontAwesomeIcons.shirt;            // 着替え
    case 'glasses': return FontAwesomeIcons.glasses;          // 眼鏡

  // --- 文具・本 ---
    case 'book': return FontAwesomeIcons.book;                // テキスト・本
    case 'notebook': return FontAwesomeIcons.bookOpen;        // ノート

  // --- その他 ---
    case 'camera': return FontAwesomeIcons.camera;
    case 'ticket': return FontAwesomeIcons.ticket;
    case 'bicycle': return FontAwesomeIcons.bicycle;
    case 'baby': return FontAwesomeIcons.babyCarriage;
    case 'pet': return FontAwesomeIcons.paw;
    case 'travel': return FontAwesomeIcons.suitcaseRolling;
    case 'map': return FontAwesomeIcons.mapLocationDot;

    default: return FontAwesomeIcons.box;
  }
}

final Map<String, IconData> globalIconMap = {
  // 日常の貴重品
  'mobile': FontAwesomeIcons.mobileScreenButton,
  'wallet': FontAwesomeIcons.wallet,
  'key': FontAwesomeIcons.key,
  'card': FontAwesomeIcons.creditCard,
  'money': FontAwesomeIcons.coins,

  // 医療・衛生（スクショ重点）
  'medical_book': FontAwesomeIcons.bookMedical,
  'medical_card': FontAwesomeIcons.addressCard,
  'pills': FontAwesomeIcons.pills,
  'mask': FontAwesomeIcons.maskFace,
  'wash': FontAwesomeIcons.soap,

  // お出かけ・衣類
  'bottle': FontAwesomeIcons.bottleWater,
  'umbrella': FontAwesomeIcons.umbrella,
  'shopping': FontAwesomeIcons.bagShopping,
  'towel': FontAwesomeIcons.rug,
  'sauna_hat': FontAwesomeIcons.dungeon,
  'clothes': FontAwesomeIcons.shirt,
  'glasses': FontAwesomeIcons.glasses,

  // 仕事・勉強
  'laptop': FontAwesomeIcons.laptop,
  'battery': FontAwesomeIcons.batteryFull,
  'pen': FontAwesomeIcons.penNib,
  'id_case': FontAwesomeIcons.idBadge,
  'book': FontAwesomeIcons.book,
  'notebook': FontAwesomeIcons.bookOpen,

  // 目的地
  'home': FontAwesomeIcons.house,
  'office': FontAwesomeIcons.building,
  'school_b': FontAwesomeIcons.school,
  'hospital_b': FontAwesomeIcons.hospital,
  'gym': FontAwesomeIcons.dumbbell,
  'cafe': FontAwesomeIcons.mugSaucer,

  // その他
  'camera': FontAwesomeIcons.camera,
  'ticket': FontAwesomeIcons.ticket,
  'bicycle': FontAwesomeIcons.bicycle,
  'travel': FontAwesomeIcons.suitcaseRolling,
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

