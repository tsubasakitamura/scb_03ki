import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled1/model/bag_template.dart';

import '../db/database.dart';
import '../main.dart';

class ViewModel extends ChangeNotifier {
  final MyDatabase db;
  ViewModel({required this.db});

  // --- プロパティ管理 ---
  List<Bag> validBags = [];
  List<Bag> selectedBags = [];
  Bag? currentBag;

  List<Item> allItems = [];
  final Set<Item> selectedItems = {};
  List<Item> unpreparedItems = [];
  List<Item> preparedItems = [];
  final Set<int> pinnedItemIds = {};

  String inputName = "";
  File? imageFile;
  String? selectedIconPath;

  // ★ 削除モードで選択されたアイテムを保持するリスト
  List<Item> selectedDeleteItems = [];

  double get packingProgress {
    final total = unpreparedItems.length + preparedItems.length;
    if (total == 0) return 0.0;
    return preparedItems.length / total;
  }

  // --- アイコン・画像・入力管理 ---
  void setIconPath(String path) {
    selectedIconPath = path;
    imageFile = null;
    notifyListeners();
  }

  void initIconPath(String path) {
    selectedIconPath = path;
    imageFile = null;
  }

  void updateItemName(String name) {
    inputName = name;
  }

  Future<void> pickImage(ImageSource source) async {
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
    selectedIconPath = null;
    notifyListeners();
  }

  // --- アイテム操作ロジック ---
  void togglePin(Item item) {
    if (pinnedItemIds.contains(item.itemId)) {
      pinnedItemIds.remove(item.itemId);
    } else {
      pinnedItemIds.add(item.itemId);
    }
    notifyListeners();
  }

  void addSelectedItem(Item item) {
    selectedItems.add(item);
    notifyListeners();
  }

  void removeSelectedItem(Item item) {
    selectedItems.remove(item);
    notifyListeners();
  }

  // ★ 削除選択の切り替え
  void toggleDeleteSelection(Item item) {
    if (selectedDeleteItems.contains(item)) {
      selectedDeleteItems.remove(item);
    } else {
      selectedDeleteItems.add(item);
    }
    notifyListeners();
  }

  // --- バッグ選択ロジック ---
  void addValidBag(Bag bag) {
    if (!selectedBags.contains(bag)) {
      selectedBags.add(bag);
      notifyListeners();
    }
  }

  void removeValidBag(Bag bag) {
    selectedBags.remove(bag);
    notifyListeners();
  }

  // --- データベース連携 (アイテム) ---
  Future<void> getAllItem() async {
    // 既存の database ではなく db を使う形で統一（エラー回避）
    allItems = await db.select(db.items).get();
    notifyListeners();
  }

  Future<int> addItem() async {
    final trimmedName = inputName.trim();
    if (trimmedName.isEmpty) return 1;
    if (allItems.any((item) => item.itemName == trimmedName)) return 2;

    final path = imageFile?.path ?? selectedIconPath ?? "icon:box";

    final newId = await db.addItem(ItemsCompanion(
      itemName: Value(trimmedName),
      itemImagePath: Value(path),
    ));

    inputName = "";
    imageFile = null;
    selectedIconPath = null;

    await getAllItem();

    try {
      final newItem = allItems.firstWhere((item) => item.itemId == newId);
      addSelectedItem(newItem);
    } catch (e) {}

    return 0;
  }

  Future<void> updateItem(int itemId) async {
    final path = selectedIconPath ?? imageFile?.path ?? "icon:box";
    final updateItem = Item(
      itemId: itemId,
      itemName: inputName,
      itemImagePath: path,
    );
    // database -> db
    await (db.update(db.items)..where((t) => t.itemId.equals(itemId))).write(
        ItemsCompanion(
          itemName: Value(updateItem.itemName),
          itemImagePath: Value(updateItem.itemImagePath),
        )
    );
    inputName = "";
    imageFile = null;
    selectedIconPath = null;
    await getAllItem();
  }

  // --- バッグ操作ロジック ---
  void setTemporaryBagName(String name) {
    if (currentBag == null) return;
    currentBag = currentBag!.copyWith(name: name);
  }

  Future<int> updateBagName(String bagName) async {
    if (currentBag == null) return 0;
    final trimmedName = bagName.trim();
    if (trimmedName.isEmpty) return 1;

    final isDuplicate = validBags.any((bag) =>
    bag.name.toLowerCase() == trimmedName.toLowerCase() &&
        bag.id != currentBag!.id);
    if (isDuplicate) return 2;

    currentBag = currentBag!.copyWith(name: trimmedName);
    await db.updateBag(currentBag!);
    await getBagData();
    notifyListeners();
    return 0;
  }

  Future<void> createBag() async {
    final pinnedIds = allItems
        .where((item) => pinnedItemIds.contains(item.itemId))
        .map((item) => item.itemId.toString())
        .join(',');

    final newBag = BagsCompanion(
      id: const Value.absent(),
      name: const Value(""),
      itemIds: Value(pinnedIds),
      preparedItemIds: const Value(""),
      itemImagePath: const Value("icon:hospital_b"),
    );

    final currentBagId = await db.createBag(newBag);
    currentBag = await db.getBagById(currentBagId);
    await getBagData();
    _refreshBagItems();
    notifyListeners();
  }

  Future<void> getBagData() async {
    validBags = await db.getBagData();
    notifyListeners();
  }

  Future<void> getSelectedBag(int bagId) async {
    currentBag = await db.getBagById(bagId);
    allItems = await db.select(db.items).get();
    _refreshBagItems();
    notifyListeners();
  }

  void _refreshBagItems() {
    if (currentBag == null) return;
    final idStrings = currentBag!.itemIds.split(',').where((e) => e.isNotEmpty).toList();
    final idsInBag = idStrings.map(int.parse).toSet();
    final preparedIdStrings = currentBag!.preparedItemIds.split(',').where((e) => e.isNotEmpty).toList();
    final preparedIdsInBag = preparedIdStrings.map(int.parse).toSet();

    final bagItems = allItems.where((item) => idsInBag.contains(item.itemId)).toList();
    preparedItems = bagItems.where((item) => preparedIdsInBag.contains(item.itemId)).toList();
    unpreparedItems = bagItems.where((item) => !preparedIdsInBag.contains(item.itemId)).toList();

    selectedItems.clear();
    selectedItems.addAll(bagItems);
  }

  Future<void> saveSelectedItemsToBag() async {
    if (currentBag == null) return;
    final Set<int> newSelectedIds = selectedItems.map((item) => item.itemId).toSet();
    final String newPreparedIds = preparedItems
        .where((item) => newSelectedIds.contains(item.itemId))
        .map((item) => item.itemId.toString())
        .join(',');
    final String newIds = selectedItems.map((item) => item.itemId.toString()).join(',');
    currentBag = currentBag!.copyWith(
        itemIds: newIds,
        preparedItemIds: newPreparedIds
    );
    await db.updateBag(currentBag!);
    _refreshBagItems();
    notifyListeners();
  }

  void updateBagImage(String imagePath) {
    if (currentBag == null) return;
    currentBag = currentBag!.copyWith(itemImagePath: Value(imagePath), iconCode: const Value(null));
    db.updateBag(currentBag!);
    notifyListeners();
  }

  Future<void> deleteOneBag(Bag bag) async {
    await db.deleteBag(bag);
    validBags.remove(bag);
    notifyListeners();
  }

  Future<void> deleteAllBag() async {
    await db.deleteAllBag();
    validBags.clear();
    notifyListeners();
  }

  // --- パッキング進捗管理 ---
  Future<void> toggleItemPrepared(Item item) async {
    if (currentBag == null) return;
    if (unpreparedItems.contains(item)) {
      unpreparedItems.remove(item);
      preparedItems.add(item);
    } else {
      preparedItems.remove(item);
      unpreparedItems.add(item);
    }
    final String newPreparedIds = preparedItems.map((e) => e.itemId.toString()).join(',');
    currentBag = currentBag!.copyWith(preparedItemIds: newPreparedIds);
    await db.updateBag(currentBag!);
    notifyListeners();
  }

  Future<void> resetItem() async {
    if (currentBag == null) return;
    unpreparedItems.addAll(preparedItems);
    preparedItems.clear();
    currentBag = currentBag!.copyWith(preparedItemIds: "");
    await db.updateBag(currentBag!);
    notifyListeners();
  }

  // --- テンプレート機能 ---
  Future<void> createBagWithTemplate({
    required String name,
    required List<TemplateItem> items,
    required int iconCode,
  }) async {
    List<int> registeredIds = [];
    for (var item in items) {
      int id = await getOrCreateItemId(item.name, item.imagePath);
      registeredIds.add(id);
    }
    final newBag = BagsCompanion(
      name: Value(name),
      itemIds: Value(registeredIds.join(',')),
      preparedItemIds: const Value(""),
      iconCode: Value(iconCode),
    );
    await db.createBag(newBag);
    await getBagData();
    notifyListeners();
  }

  Future<int> getOrCreateItemId(String name, String imagePath) async {
    final existing = await (db.select(db.items)..where((t) => t.itemName.equals(name))).getSingleOrNull();
    if (existing != null) return existing.itemId;
    return await db.addItem(ItemsCompanion(itemName: Value(name), itemImagePath: Value(imagePath)));
  }

  void refresh() => notifyListeners();

  // --- ★ 削除系メソッド (省略なし) ---

  Future<void> deleteOneItem(Item item) async {
    await (db.delete(db.items)..where((t) => t.itemId.equals(item.itemId))).go();
    await getAllItem();
    notifyListeners();
  }

  Future<void> deleteSelectedItems() async {
    for (var item in selectedDeleteItems) {
      await (db.delete(db.items)..where((t) => t.itemId.equals(item.itemId))).go();
    }
    selectedDeleteItems.clear();
    await getAllItem();
    notifyListeners();
  }

  Future<void> deleteAllItems() async {
    await (db.delete(db.items)).go();
    await getAllItem();
    notifyListeners();
  }
}