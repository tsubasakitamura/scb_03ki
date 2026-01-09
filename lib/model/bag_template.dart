import 'package:flutter/material.dart';

class TemplateItem {
  final String name;
  final String imagePath;
  TemplateItem(this.name, this.imagePath);
}

class BagTemplate {
  final String name;
  final int iconCode;
  final List<TemplateItem> items;

  BagTemplate({
    required this.name,
    required this.iconCode,
    required this.items,
  });

  static List<BagTemplate> get defaultTemplates => [
    BagTemplate(
      name: "ジム",
      iconCode: Icons.fitness_center.codePoint,
      items: [
        TemplateItem("タオル", "icon:towel"),
        TemplateItem("飲み物", "icon:bottle"),
        TemplateItem("着替え", "icon:tshirt"),
        TemplateItem("会員証", "icon:card"),
      ],
    ),
    BagTemplate(
      name: "通院",
      iconCode: Icons.local_hospital.codePoint,
      items: [
        TemplateItem("診察券", "icon:card"),
        TemplateItem("保険証", "icon:card"),
        TemplateItem("お薬手帳", "icon:medical"),
        TemplateItem("お財布", "icon:wallet"),
      ],
    ),
    BagTemplate(
      name: "お買い物",
      iconCode: Icons.shopping_cart.codePoint,
      items: [
        TemplateItem("エコバッグ", "icon:bag"),
        TemplateItem("お財布", "icon:wallet"),
        TemplateItem("ポイントカード", "icon:card"),
        TemplateItem("スマホ", "icon:mobile"),
      ],
    ),
    BagTemplate(
      name: "散歩",
      iconCode: Icons.directions_walk.codePoint,
      items: [
        TemplateItem("水筒", "icon:bottle"),
        TemplateItem("タオル", "icon:towel"),
        TemplateItem("小銭入れ", "icon:wallet"),
        TemplateItem("スマホ", "icon:mobile"),
      ],
    ),
    BagTemplate(
      name: "習い事",
      iconCode: Icons.menu_book.codePoint,
      items: [
        TemplateItem("筆記用具", "icon:pen"),
        TemplateItem("ノート", "icon:pen"),
        TemplateItem("月謝袋", "icon:wallet"),
        TemplateItem("テキスト", "icon:pen"),
      ],
    ),
    BagTemplate(
      name: "お葬式",
      iconCode: Icons.church.codePoint,
      items: [
        TemplateItem("数珠", "icon:box"),
        TemplateItem("ふくさ（黒系）", "icon:box"),
        TemplateItem("お香典", "icon:wallet"),
        TemplateItem("黒ハンカチ", "icon:towel"),
      ],
    ),
    BagTemplate(
      name: "お祝い事",
      iconCode: Icons.celebration.codePoint,
      items: [
        TemplateItem("ご祝儀", "icon:wallet"),
        TemplateItem("ふくさ（赤系）", "icon:box"),
        TemplateItem("招待状", "icon:pen"),
        TemplateItem("ハンカチ", "icon:towel"),
      ],
    ),
    BagTemplate(
      name: "ビジネス",
      iconCode: Icons.business_center.codePoint,
      items: [
        TemplateItem("ノートPC", "icon:mobile"),
        TemplateItem("充電器", "icon:mobile"),
        TemplateItem("名刺入れ", "icon:card"),
        TemplateItem("筆記用具", "icon:pen"),
      ],
    ),
    BagTemplate(
      name: "旅行",
      iconCode: Icons.luggage.codePoint,
      items: [
        TemplateItem("着替え", "icon:tshirt"),
        TemplateItem("洗面用具", "icon:bottle"),
        TemplateItem("充電器", "icon:mobile"),
        TemplateItem("常備薬", "icon:medical"),
      ],
    ),
  ];
}