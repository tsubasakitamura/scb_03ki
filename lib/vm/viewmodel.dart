// ==========================================================================
// File: viewmodel.dart
// --------------------------------------------------------------------------
// [アプリの状態管理とビジネスロジックを担当]
//
// < 目次 >
// 1. [Properties] 状態管理用の変数
// 2. [Image/Icon] 画像選択・アイコン選択のロジック
// 3. [Item Logic] もちもの（Item）の取得・追加・編集・削除
// 4. [Bag Logic] バッグ（Bag）の取得・作成・更新・削除
// 5. [Preparation] 準備状態（用意した/していない/ピン留め）の管理
// ==========================================================================

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/database.dart';
import '../main.dart';

class ViewModel extends ChangeNotifier {
  final MyDatabase db;
  ViewModel({required this.db});

  // --------------------------------------------------------------------------
  // 1. [Properties] 状態管理用の変数
  // --------------------------------------------------------------------------

  // バッグ関連
  List<Bag> validBags = [];     // 名前とアイテムが揃っている有効なバッグ
  List<Bag> selectedBags = [];  // 削除用などで選択されたバッグ
  List<Bag> allBags = [];       // すべてのバッグ
  Bag? currentBag;              // 現在編集・表示中のバッグ

  // アイテム関連
  List<Item> allItems = [];           // 全アイテム
  final Set<Item> selectedItems = {}; // 選択状態のアイテム
  List<Item> unpreparedItems = [];    // 未準備リスト
  List<Item> preparedItems = [];      // 準備済みリスト
  final Set<int> pinnedItemIds = {};  // ピン留め（固定）されたアイテムID

  // 入力フォーム用の一時変数
  String inputName = "";        // 入力中の名前（バッグ/アイテム共通）
  String? selectedIconPath;     // 選択されたアイコンパス
  File? imageFile;              // 選択された画像ファイル

  // パッキング進捗率のゲッター (0.0 ～ 1.0)
  double get packingProgress {
    final total = unpreparedItems.length + preparedItems.length;
    if (total == 0) return 0.0;
    return preparedItems.length / total;
  }

  // --------------------------------------------------------------------------
  // 2. [Image/Icon] 画像・アイコン選択ロジック
  // --------------------------------------------------------------------------

  void setIconPath(String path) {
    selectedIconPath = path;
    imageFile = null;
    notifyListeners();
  }

  void updateItemName(String name) {
    inputName = name;
    // テキストフィールドの入力ごとに notifyListeners を呼ぶと重いため、ここでは保持のみ
  }

  Future<void> pickImage(ImageSource source) async {
    imageFile = null;
    selectedIconPath = null;
    notifyListeners();

    final imagePicker = ImagePicker();
    final XFile? _image = await imagePicker.pickImage(
      source: source,
      imageQuality: 15,
    );
    if (_image == null) return;

    final tempImageFile = File(_image.path);
    final appDirectory = await getApplicationDocumentsDirectory();
    final String inAppPath = appDirectory.path;
    final itemImageName = basename(_image.path);
    final File _savedImage = await tempImageFile.copy('$inAppPath/$itemImageName');

    imageFile = _savedImage;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // 3. [Item Logic] もちもの（Item）管理
  // --------------------------------------------------------------------------

  Future<void> getAllItem() async {
    allItems = await database.allItems;
    notifyListeners();
  }

  Future<void> addItem() async {
    if (inputName.isEmpty) return;
    final path = selectedIconPath ?? imageFile?.path ?? "icon:box";

    final item = ItemsCompanion(
      itemName: Value(inputName),
      itemImagePath: Value(path),
      isPrepared: const Value(false),
      isSelected: const Value(false),
      isChecked: const Value(false),
    );
    await database.addItem(item);

    // 登録後のクリーンアップ
    inputName = "";
    imageFile = null;
    selectedIconPath = null;

    await getAllItem();
  }

  Future<void> updateItem(int itemId) async {
    final path = selectedIconPath ?? imageFile?.path ?? "icon:box";
    final updateItem = Item(
        itemId: itemId,
        itemName: inputName,
        itemImagePath: path,
        isPrepared: false,
        isSelected: false,
        isChecked: false);
    await database.updateItem(updateItem);

    inputName = "";
    imageFile = null;
    selectedIconPath = null;

    await getAllItem();
  }

  void addSelectedItem(Item item) {
    selectedItems.add(item);
    notifyListeners();
  }

  void removeSelectedItem(Item item) {
    selectedItems.remove(item);
    notifyListeners();
  }

  void clearSelectedItem() {
    selectedItems.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedItem() async {
    for (final item in selectedItems) {
      await database.deleteItem(item);
    }
    clearSelectedItem();
    await getAllItem();
  }

  // --------------------------------------------------------------------------
  // 4. [Bag Logic] バッグ（Bag）管理
  // --------------------------------------------------------------------------

  Future<void> createBag() async {
    // 1. 現在の全アイテムの中から、ピン留めされているIDだけを抽出
    final pinnedIds = allItems
        .where((item) => pinnedItemIds.contains(item.itemId))
        .map((item) => item.itemId.toString())
        .join(',');

    final newBag = BagsCompanion(
      id: const Value.absent(),
      name: const Value(""),
      itemIds: Value(pinnedIds), // 初期状態でピン留めアイテムを紐付け
      itemImagePath: const Value("icon:hospital_b"),
    );

    final currentBagId = await database.createBag(newBag);
    currentBag = await database.getBagById(currentBagId);

    // 2. 状態をリフレッシュ
    await getBagData();
    _refreshBagItems();
    inputName = "";
    notifyListeners();
  }

  Future<void> updateBagName(String bagName) async {
    if (currentBag == null) return;
    currentBag = currentBag!.copyWith(name: bagName);
    database.updateBag(currentBag!);
  }

  Future<void> getBagData() async {
    validBags = await database.getBagData();
    notifyListeners();
  }

  Future<void> getSelectedBag(int bagId) async {
    currentBag = await database.getBagById(bagId);
    allItems = await database.allItems;
    _refreshBagItems();
    notifyListeners();
  }

  void _refreshBagItems() {
    if (currentBag == null) return;
    final idStrings = currentBag!.itemIds.split(',').where((e) => e.isNotEmpty).toList();
    final idsInBag = idStrings.map(int.parse).toSet();

    final bagItems = allItems.where((item) => idsInBag.contains(item.itemId)).toList();

    preparedItems = bagItems.where((item) => isPinned(item)).toList();
    unpreparedItems = bagItems.where((item) => !isPinned(item)).toList();
  }

  Future<void> deleteAllBag() async {
    await database.deleteAllBag();
    validBags.clear();
    notifyListeners();
  }

  void updateBagImage(String imagePath) {
    if (currentBag == null) return;
    currentBag = currentBag!.copyWith(itemImagePath: Value(imagePath));
    database.updateBag(currentBag!);
    notifyListeners();
  }

  Future<void> deleteOneBag(Bag bag) async {
    await database.deleteBag(bag);
    validBags.remove(bag);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // 5. [Preparation] 準備状態（パッキング）管理
  // --------------------------------------------------------------------------

  bool isPinned(Item item) => pinnedItemIds.contains(item.itemId);

  Future<void> toggleItemPrepared(Item item) async {
    if (unpreparedItems.contains(item)) {
      unpreparedItems.remove(item);
      preparedItems.add(item);
    } else if (preparedItems.contains(item)) {
      preparedItems.remove(item);
      unpreparedItems.add(item);
    }
    notifyListeners();
  }

  Future<void> resetPreparation() async {
    // ピン留めされていない準備済みアイテムを未準備に戻す
    final nonPinnedPrepared = preparedItems.where((item) => !isPinned(item)).toList();
    unpreparedItems.addAll(nonPinnedPrepared);
    preparedItems.removeWhere((item) => !isPinned(item));
    notifyListeners();
  }

  Future<void> resetItem() async {
    unpreparedItems.addAll(preparedItems);
    preparedItems.clear();
    notifyListeners();
  }

  Future<void> togglePin(Item item) async {
    if (isPinned(item)) {
      pinnedItemIds.remove(item.itemId);
    } else {
      pinnedItemIds.add(item.itemId);
      if (unpreparedItems.contains(item)) {
        unpreparedItems.remove(item);
        preparedItems.add(item);
      }
    }
    notifyListeners();
  }

  // 有効バッグ管理用
  Future<void> addValidBag(Bag bag) async {
    if (!selectedBags.contains(bag)) {
      selectedBags.add(bag);
      notifyListeners();
    }
  }

  Future<void> removeValidBag(Bag bag) async {
    selectedBags.remove(bag);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

}