// ==========================================================================
// File: item_parts.dart
// --------------------------------------------------------------------------
// [アイテム（Item）に関連するUIパーツを統合管理するファイル]
//
// < 目次 >
// 1. [Enum] ItemGridDisplayMode ...... アイテム一覧の表示モード
// 2. [Widget] ItemGridPart ........... アイテム一覧表示
// 3. [Widget] ItemCard ............... アイテム単体のカード表示
// 4. [Widget] ItemEditPart ........... アイテム編集・追加フォーム
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/view/parts/common_parts.dart';
import 'package:untitled1/view/screens/item_manager_screen.dart';
import 'package:untitled1/vm/viewmodel.dart';
import '../../db/database.dart';
import '../../generated/l10n.dart';

// --------------------------------------------------------------------------
// 1. [Enum] ItemGridDisplayMode
// --------------------------------------------------------------------------
enum ItemGridDisplayMode { ALL, CHOOSE, PREPARED, UNPREPARED }

// --------------------------------------------------------------------------
// 2. [Widget] ItemGridPart
// --------------------------------------------------------------------------
class ItemGridPart extends StatelessWidget {
  final ItemGridDisplayMode displayMode;

  const ItemGridPart({Key? key, required this.displayMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewModel>(
      builder: (context, vm, child) {
        final items = _getItemsByMode(vm);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ItemCard(item: items[index], displayMode: displayMode);
          },
        );
      },
    );
  }

  List<Item> _getItemsByMode(ViewModel vm) {
    switch (displayMode) {
      case ItemGridDisplayMode.ALL:
      case ItemGridDisplayMode.CHOOSE:
        return vm.allItems;
      case ItemGridDisplayMode.PREPARED:
        return vm.preparedItems;
      case ItemGridDisplayMode.UNPREPARED:
        return vm.unpreparedItems;
    }
  }
}

// --------------------------------------------------------------------------
// 3. [Widget] ItemCard (一括削除モード対応版)
// --------------------------------------------------------------------------
class ItemCard extends StatelessWidget {
  final Item item;
  final ItemGridDisplayMode displayMode;

  const ItemCard({Key? key, required this.item, required this.displayMode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ViewModel>();

    // 現在「削除モード」かどうかを確認
    final parent = context.findAncestorWidgetOfExactType<ItemManagerScreen>();
    final bool isDeleteMode = parent?.mode == ItemMode.delete;

    // 状態を監視
    final isPinned = context.select<ViewModel, bool>((v) => v.pinnedItemIds.contains(item.itemId));
    final isSelected = context.select<ViewModel, bool>((v) => v.selectedItems.contains(item));
    // ★ 削除用に選択されているか
    final isDeleteSelected = context.select<ViewModel, bool>((v) => v.selectedDeleteItems.contains(item));

    // 選択モードかどうか
    final bool isChooseMode = displayMode == ItemGridDisplayMode.CHOOSE;

    return InkWell(
      onLongPress: isDeleteMode ? null : () => _showDeleteMenu(context, vm),
      onTap: () => _handleTap(context, vm, isDeleteMode), // モードを渡す
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isDeleteSelected
              ? const BorderSide(color: Colors.redAccent, width: 3) // ★削除選択中は赤
              : (isChooseMode && isSelected)
              ? const BorderSide(color: Colors.blue, width: 3)
              : BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        elevation: (isDeleteSelected || (isChooseMode && isSelected)) ? 8 : 2,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ItemImageDisplay(path: item.itemImagePath, size: 40),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black.withValues(alpha: 0.6),
                child: Text(
                  item.itemName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // ピン留めアイコン（削除モード時は非表示にすると見やすい）
            if (!isDeleteMode)
              Positioned(
                top: 4,
                left: 4,
                child: InkWell(
                  onTap: () => vm.togglePin(item),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 22,
                      color: isPinned ? Colors.orange[700] : Colors.grey[400],
                    ),
                  ),
                ),
              ),

            // ★ 削除モード用のマイナスアイコン
            if (isDeleteMode && isDeleteSelected)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.remove_circle, size: 24, color: Colors.redAccent),
              ),

            // 選択モード時のチェック
            if (!isDeleteMode && isChooseMode && isSelected)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle, size: 24, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, ViewModel vm, bool isDeleteMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isDeleteMode) {
        // ★ 削除モードならポチポチ選択の切り替え
        vm.toggleDeleteSelection(item);
        return;
      }

      if (displayMode == ItemGridDisplayMode.CHOOSE) {
        if (vm.selectedItems.contains(item)) {
          vm.removeSelectedItem(item);
        } else {
          vm.addSelectedItem(item);
        }
      } else if (displayMode == ItemGridDisplayMode.UNPREPARED ||
          displayMode == ItemGridDisplayMode.PREPARED) {
        vm.toggleItemPrepared(item);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemManagerScreen(mode: ItemMode.edit, itemId: item.itemId),
          ),
        );
      }
    });
  }

  void _showDeleteMenu(BuildContext context, ViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${item.itemName} ${S.of(context).itemDelete1}"),
        content: Text(S.of(context).checkSentence6),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await vm.deleteOneItem(item);
              Navigator.pop(context);
            },
            child: Text(S.of(context).itemDelete0, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 4. [Widget] ItemEditPart
// --------------------------------------------------------------------------
class ItemEditPart extends StatefulWidget {
  final int? itemId;
  const ItemEditPart({Key? key, this.itemId}) : super(key: key);

  @override
  State<ItemEditPart> createState() => _ItemEditPartState();
}

class _ItemEditPartState extends State<ItemEditPart> {
  final TextEditingController _controller = TextEditingController();
  String _currentPath = "icon:box";
  Item? _targetItem;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() {
    final vm = context.read<ViewModel>();
    if (widget.itemId != null) {
      try {
        _targetItem = vm.allItems.firstWhere((e) => e.itemId == widget.itemId);
        if (_targetItem != null) {
          _controller.text = _targetItem!.itemName;
          _currentPath = _targetItem!.itemImagePath;
          vm.initIconPath(_currentPath);
          vm.updateItemName(_targetItem!.itemName);
        }
      } catch (e) {}
    } else {
      vm.initIconPath("icon:box");
      vm.updateItemName("");
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Consumer<ViewModel>(builder: (context, vm, child) {
                  final displayPath = vm.selectedIconPath ?? vm.imageFile?.path ?? _currentPath;
                  return InkWell(
                    onTap: () => _showImageSourcePicker(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ItemImageDisplay(path: displayPath, size: 60),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
                const Gap(16),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (val) => context.read<ViewModel>().updateItemName(val),
                    decoration: InputDecoration(
                      labelText: S.of(context).itemName,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            _buildIconGrid(),
          ],
        ),
      ),
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    final vm = context.read<ViewModel>();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(S.of(context).camera),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context).gallery),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text("アイコンから選ぶ"),
              onTap: () {
                Navigator.pop(context);
                _showIconPicker(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("アイコンを選択"),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildIconGrid(isDialog: true),
        ),
      ),
    );
  }

  Widget _buildIconGrid({bool isDialog = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: isDialog ? null : const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: globalIconMap.length,
      itemBuilder: (context, index) {
        String key = globalIconMap.keys.elementAt(index);
        return InkWell(
          onTap: () {
            context.read<ViewModel>().setIconPath("icon:$key");
            if (isDialog) Navigator.pop(context);
          },
          child: Icon(globalIconMap[key], size: 24, color: Colors.blueGrey),
        );
      },
    );
  }
}