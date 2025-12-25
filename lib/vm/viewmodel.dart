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

  // --- 追加：アイコン管理用の変数 ---
  String? selectedIconPath;

  ViewModel({required this.db});

  //有効なBag(名前もアイテムも入ってるもののみ)
  List<Bag> validBags = [];

  //選択されたバッグを保存
  List<Bag> selectedBags = [];

  //もちもの全部（どのバッグに属しているかにかかわらず）
  List<Item> allItems = [];

  //選択状態を管理
  final Set<Item> selectedItems = {};

  //まだ用意していないもちもの（特定のバッグ）
  List<Item> unpreparedItems = [];

  //用意済みのもちもの（特定のバッグ）
  List<Item> preparedItems = [];

  File? imageFile;

  //今HomeScreen（Bag登録画面）で扱っているBagのid
  Bag? currentBag;

  List<Bag> allBags = [];

  final Set<int> pinnedItemIds = {};

  bool isPinned(Item item) => pinnedItemIds.contains(item.itemId);

  // --- 追加：アイコンパスをセットするメソッド ---
  void setIconPath(String path) {
    selectedIconPath = path;
    imageFile = null; // アイコンを選んだら画像ファイルはリセット
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    // 画像を選び始めるので、既存の選択状態をリセット
    imageFile = null;
    selectedIconPath = null; // ★追加：アイコン選択をリセット
    notifyListeners();

    final imagePicker = ImagePicker();
    final XFile? _image = await imagePicker.pickImage(
      source: source,
      imageQuality: 15,
    );
    if (_image == null) {
      return;
    }

    final tempImageFile = File(_image.path);

    final appDirectory = await getApplicationDocumentsDirectory();
    final String inAppPath = appDirectory.path;
    final itemImageName = basename(_image.path);
    final File _savedImage = await tempImageFile.copy('$inAppPath/$itemImageName');

    imageFile = _savedImage;

    notifyListeners();
  }

  Future<void> updateSelectItem(
      {required Item selectedItem, required bool isSelect}) async {
    if (currentBag == null) return;

    if (!isSelect && isPinned(selectedItem)) {
      return;
    }
    final strItemIdsUpdated = _updateItemIds(selectedItem.itemId, isSelect);
    currentBag = currentBag!.copyWith(itemIds: strItemIdsUpdated);
    await database.updateBag(currentBag!);

    allItems = await database.allItems;

    final idStrings =
    currentBag!.itemIds.split(',').where((e) => e.isNotEmpty).toList();
    final idsInBag = idStrings.map(int.parse).toSet();

    final bagItems =
    allItems.where((item) => idsInBag.contains(item.itemId)).toList();

    preparedItems = bagItems.where((item) => isPinned(item)).toList();
    unpreparedItems = bagItems.where((item) => !isPinned(item)).toList();

    notifyListeners();
  }

  String _updateItemIds(int selectedItemId, bool isSelected) {
    final itemIdsBeforeChanged = currentBag!.itemIds;
    final strItemIds = currentBag!.itemIds.split(",");
    final List<int> itemIds =
    (itemIdsBeforeChanged != "" && strItemIds.isNotEmpty)
        ? strItemIds.map((strItemId) {
      return int.parse(strItemId);
    }).toList()
        : [];
    if (isSelected) {
      itemIds.add(selectedItemId);
    } else {
      itemIds.removeWhere((itemId) => itemId == selectedItemId);
    }
    itemIds.sort((a, b) => a.compareTo(b));
    final strItemIdsUpdated = itemIds
        .toSet()
        .toList()
        .map((itemId) => itemId.toString())
        .toList()
        .join(",");
    return strItemIdsUpdated;
  }

  Future<void> deleteAllItem() async {
    await database.deleteAllItems();
    getAllItem();
    notifyListeners();
  }

  Future<void> getAllItem() async {
    allItems = await database.allItems;
    notifyListeners();
  }

  Future<void> resetItem() async {
    unpreparedItems.addAll(preparedItems);
    preparedItems.clear();
    allItems = await database.allItems;
    notifyListeners();
  }

  Future<void> addItem(String itemName, String itemImagePath) async {
    final item = ItemsCompanion(
      itemName: Value(itemName.toString()),
      itemImagePath: Value(itemImagePath),
      isPrepared: Value(false),
      isSelected: Value(false),
      isChecked: Value(false),
    );
    await database.addItem(item);

    // ★追加：保存が終わったのでリセット
    imageFile = null;
    selectedIconPath = null;

    getAllItem();
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

  void clearSelectedItem() {
    selectedItems.clear();
  }

  Future<void> deleteSelectedItem() async {
    for (final item in selectedItems) {
      await database.deleteItem(item);
    }
    clearSelectedItem();
    await getAllItem();
  }

  Future<void> updateEditItem(
      item, String itemName, String itemImagePath) async {
    var updateItem = Item(
        itemId: item.itemId,
        itemName: itemName,
        itemImagePath: itemImagePath,
        isPrepared: false,
        isSelected: false,
        isChecked: false);
    await database.updateItem(updateItem);

    // ★追加：更新が終わったのでリセット
    imageFile = null;
    selectedIconPath = null;

    getAllItem();
    notifyListeners();
  }

  Future<void> deleteEditItem(item) async {
    var deleteItem = Item(
        itemId: item.itemId,
        itemName: item.itemName,
        itemImagePath: item.itemImagePath,
        isPrepared: false,
        isSelected: false,
        isChecked: false);
    await database.deleteItem(deleteItem);

    // ★追加：削除後の状態をクリーンにする
    imageFile = null;
    selectedIconPath = null;

    getAllItem();
    notifyListeners();
  }

  Future<void> createBag() async {
    final newBag = BagsCompanion(
      id: Value.absent(),
      name: Value(""),
      itemIds: Value(""),
    );
    final currentBagId = await database.createBag(newBag);
    currentBag = await database.getBagById(currentBagId);

    unpreparedItems.clear();
    preparedItems.clear();
    pinnedItemIds.clear();
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

    final idStrings = currentBag!.itemIds
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();
    final idsInBag = idStrings.map(int.parse).toSet();

    final bagItems =
    allItems.where((item) => idsInBag.contains(item.itemId)).toList();

    preparedItems =
        bagItems.where((item) => isPinned(item)).toList();
    unpreparedItems =
        bagItems.where((item) => !isPinned(item)).toList();

    notifyListeners();
  }

  Future<void> deleteAllBag() async {
    await database.deleteAllBag();
    validBags.clear();
    notifyListeners();
  }

  Future<void> deleteSelectBag() async {
    for (var bag in selectedBags) {
      await database.deleteBag(bag);
      validBags.remove(bag);
    }
    selectedBags.clear();
    notifyListeners();
  }

  Future<void> getAllIBag() async {
    allBags = await database.allBags;
    notifyListeners();
  }

  Future<void> resetPreparation() async {
    final pinnedPrepared = preparedItems
        .where((item) => pinnedItemIds.contains(item.itemId))
        .toList();
    final nonPinnedPrepared = preparedItems
        .where((item) => !pinnedItemIds.contains(item.itemId))
        .toList();

    unpreparedItems = [...unpreparedItems, ...nonPinnedPrepared];
    preparedItems = pinnedPrepared;

    notifyListeners();
  }

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

  Future<void> clearSelectBag() async {
    selectedBags.clear();
    notifyListeners();
  }

  Future<void> deleteOneBag(Bag bag) async {
    await database.deleteBag(bag);
    validBags.remove(bag);
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
}