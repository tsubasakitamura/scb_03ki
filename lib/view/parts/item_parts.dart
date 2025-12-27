// ==========================================================================
// File: item_parts.dart
// --------------------------------------------------------------------------
// [もちもの（Item）に関連するUIパーツを統合管理するファイル]
//
// < 目次 >
// 1. [Enum] ItemGridDisplayMode ...... 表示モードの定義（選択/用意/マスタ等）
// 2. [Widget] ItemGridPart ........... もちもの一覧のグリッドレイアウト
// 3. [Widget] ItemCard ............... もちもの単体のカード表示（ピン・チェック対応）
// 4. [Widget] ItemAddPart ............ 新規登録用フォーム
// 5. [Widget] ItemEditPart ........... 既存データの編集・削除用フォーム
// 6. [Helper] 共通ダイアログ ........... 画像選択・アイコン選択のポップアップ
// =========================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/db/database.dart';
import 'package:untitled1/generated/l10n.dart';
import 'package:untitled1/view/parts/common_parts.dart'; // 共通パーツを使用
import 'package:untitled1/view/screens/item_manager_screen.dart';
import 'package:untitled1/vm/viewmodel.dart';
import 'button_with_icon.dart';

enum ItemGridDisplayMode { SELECT, MASTER, DELETE, PREPARED, UNPREPARED }

// ==========================================
// 1. ItemGridPart: もちもの一覧（グリッド表示）
// ==========================================
class ItemGridPart extends StatelessWidget {
  final ItemGridDisplayMode displayMode;
  const ItemGridPart({super.key, required this.displayMode});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModel>();
    List<Item> items;

    switch (displayMode) {
      case ItemGridDisplayMode.UNPREPARED:
        items = vm.unpreparedItems;
        break;
      case ItemGridDisplayMode.PREPARED:
        final allPrepared = vm.preparedItems;
        final pinned = allPrepared.where((item) => vm.isPinned(item)).toList();
        final normal = allPrepared.where((item) => !vm.isPinned(item)).toList();
        items = [...pinned, ...normal];
        break;
      default:
        items = vm.allItems;
    }

    if (items.isEmpty) {
      return Center(child: Text(S.of(context).noItem, style: const TextStyle(fontSize: 20.0)));
    }

    return Scrollbar(
      thickness: 8,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => ItemCard(item: items[index], displayMode: displayMode),
      ),
    );
  }
}

// ==========================================
// 2. ItemCard: もちもの単体カード
// ==========================================
class ItemCard extends StatelessWidget {
  final ItemGridDisplayMode displayMode;
  final Item item;
  const ItemCard({super.key, required this.item, required this.displayMode});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModel>();
    final bool pinned = vm.isPinned(item);

    // チェック状態の判定
    bool isCheck = false;
    if (displayMode == ItemGridDisplayMode.DELETE) {
      isCheck = vm.selectedItems.contains(item);
    } else if (displayMode == ItemGridDisplayMode.SELECT) {
      final ids = (vm.currentBag?.itemIds ?? '').split(',').where((e) => e.isNotEmpty);
      isCheck = ids.contains(item.itemId.toString());
    }

    return Card(
      child: Stack(children: [
        ListTile(
          title: AutoSizeText(
            item.itemName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(child: ItemImageDisplay(path: item.itemImagePath, size: 60)),
          ),
          onTap: () => _tapListTile(context, vm),
        ),
        // 右上のチェックボックス
        if (displayMode == ItemGridDisplayMode.DELETE || displayMode == ItemGridDisplayMode.SELECT)
          Positioned(
            top: -5, right: -5,
            child: Checkbox(
              value: (displayMode == ItemGridDisplayMode.SELECT && pinned) ? true : isCheck,
              onChanged: (displayMode == ItemGridDisplayMode.SELECT && pinned) ? null : (val) {
                if (displayMode == ItemGridDisplayMode.DELETE) {
                  val! ? vm.addSelectedItem(item) : vm.removeSelectedItem(item);
                } else {
                  vm.updateSelectItem(selectedItem: item, isSelect: val!);
                }
              },
            ),
          ),
        // 左上のピン留めボタン
        if (displayMode == ItemGridDisplayMode.UNPREPARED || displayMode == ItemGridDisplayMode.PREPARED)
          Positioned(
            top: 0, left: 0,
            child: InkWell(
              onTap: () => vm.togglePin(item),
              child: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18, color: pinned ? Colors.indigo : Colors.grey),
            ),
          ),
      ]),
    );
  }

  void _tapListTile(BuildContext context, ViewModel vm) {
    if (displayMode == ItemGridDisplayMode.UNPREPARED || displayMode == ItemGridDisplayMode.PREPARED) {
      if (!vm.isPinned(item)) vm.toggleItemPrepared(item);
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ItemManagerScreen(mode: ItemMode.edit, item: item),
      ));
    }
  }
}

// ==========================================
// 3. ItemAddPart & ItemEditPart (登録・編集)
// ==========================================
class ItemAddPart extends StatefulWidget {
  const ItemAddPart({super.key});
  @override
  State<ItemAddPart> createState() => _ItemAddPartState();
}

class _ItemAddPartState extends State<ItemAddPart> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModel>();
    String displayPath = vm.imageFile?.path ?? vm.selectedIconPath ?? "";

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          ItemImageDisplay(path: displayPath, size: 200),
          ElevatedButton(
            onPressed: () => _showPickImageDialog(context, vm),
            child: Text(S.of(context).selectImage),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(controller: _textController, decoration: InputDecoration(labelText: S.of(context).itemName)),
          ),
          ButtonWithIcon(
            onPressed: _textController.text.isEmpty ? null : () async {
              await vm.addItem(_textController.text, displayPath);
              _textController.clear();
              Fluttertoast.showToast(msg: S.of(context).finishAdd);
            },
            icon: const Icon(Icons.add_circle_outline),
            label: S.of(context).addItemToList,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class ItemEditPart extends StatefulWidget {
  final Item item;
  const ItemEditPart({super.key, required this.item});
  @override
  State<ItemEditPart> createState() => _ItemEditPartState();
}

class _ItemEditPartState extends State<ItemEditPart> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.itemName);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModel>();
    String displayPath = vm.imageFile?.path ?? vm.selectedIconPath ?? widget.item.itemImagePath;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          ItemImageDisplay(path: displayPath, size: 200),
          ElevatedButton(
            onPressed: () => _showPickImageDialog(context, vm),
            child: Text(S.of(context).selectImage),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(controller: _textController, decoration: InputDecoration(labelText: S.of(context).itemName)),
          ),
          ButtonWithIcon(
            onPressed: () async {
              await vm.updateEditItem(widget.item, _textController.text, displayPath);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: S.of(context).itemChange,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          ButtonWithIcon(
            onPressed: () => _confirmDelete(context, vm),
            icon: const Icon(Icons.delete),
            label: S.of(context).itemDelete0,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ViewModel vm) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(S.of(context).itemDelete1),
      actions: [
        TextButton(child: Text(S.of(context).cancel), onPressed: () => Navigator.pop(context)),
        TextButton(child: Text(S.of(context).ok), onPressed: () async {
          await vm.deleteEditItem(widget.item);
          Navigator.pop(context); Navigator.pop(context);
        }),
      ],
    ));
  }
}

// --- 共通ダイアログ：画像/アイコン選択 ---
void _showPickImageDialog(BuildContext context, ViewModel vm) {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: Text(S.of(context).selectImage),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(leading: const Icon(Icons.photo_camera), title: Text(S.of(context).camera), onTap: () { vm.pickImage(ImageSource.camera); Navigator.pop(context); }),
        ListTile(leading: const Icon(Icons.photo), title: Text(S.of(context).gallery), onTap: () { vm.pickImage(ImageSource.gallery); Navigator.pop(context); }),
        ListTile(leading: const Icon(FontAwesomeIcons.icons), title: const Text("アイコンから選ぶ"), onTap: () { Navigator.pop(context); _showIconPicker(context, vm); }),
      ],
    ),
  ));
}

void _showIconPicker(BuildContext context, ViewModel vm) {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: const Text("アイコンを選択"),
    content: SizedBox(
      width: double.maxFinite,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: globalIconMap.length,
        itemBuilder: (context, index) {
          String key = globalIconMap.keys.elementAt(index);
          return InkWell(
            onTap: () { vm.setIconPath("icon:$key"); Navigator.pop(context); },
            child: Icon(globalIconMap[key], size: 28, color: Colors.blueGrey),
          );
        },
      ),
    ),
  ));
}