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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
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
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 4,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: ItemCard(item: items[index], displayMode: displayMode),
                ),
              ),
            );
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
// 3. [Widget] ItemCard
// --------------------------------------------------------------------------
class ItemCard extends StatelessWidget {
  final Item item;
  final ItemGridDisplayMode displayMode;

  const ItemCard({Key? key, required this.item, required this.displayMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModel>();
    final isSelected = vm.selectedItems.contains(item);

    return InkWell(
      onTap: () => _handleTap(context, vm),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: _getCardColor(isSelected),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ItemImageDisplay(path: item.itemImagePath , size: 35),
                const Gap(4),
                Text(item.itemName, // VMに合わせて itemName に修正
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            Positioned(
              top: 2,
              left: 2,
              child: GestureDetector(
                onTap: () => vm.togglePin(item), // タップでピン状態を切り替え
                child: Icon(
                  vm.isPinned(item) ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 16,
                  // ピン留め時はオレンジ、未設定時は薄いグレー
                  color: vm.isPinned(item)
                      ? Colors.orange
                      : Colors.grey.withValues(alpha: 0.4),
                ),
              ),
            ),

            if (displayMode == ItemGridDisplayMode.CHOOSE && isSelected)
              const Positioned(top: 2, right: 2, child: Icon(Icons.check_circle, size: 18, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(bool isSelected) {
    if (displayMode == ItemGridDisplayMode.CHOOSE && isSelected) return Colors.blue[50]!;
    return Colors.white;
  }

  void _handleTap(BuildContext context, ViewModel vm) {
    if (displayMode == ItemGridDisplayMode.CHOOSE) {
      if (vm.selectedItems.contains(item)) {
        vm.removeSelectedItem(item);
      } else {
        vm.addSelectedItem(item);
      }
    } else if (displayMode == ItemGridDisplayMode.UNPREPARED || displayMode == ItemGridDisplayMode.PREPARED) {
      vm.toggleItemPrepared(item); // VMに合わせて修正
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemManagerScreen(mode: ItemMode.edit, itemId: item.itemId)),
      );
    }
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

  void _initLoad() async {
    final vm = context.read<ViewModel>();
    if (widget.itemId != null) {
      // getOneItem が VM にないため、allItems から検索
      _targetItem = vm.allItems.firstWhere((e) => e.itemId == widget.itemId);
      if (_targetItem != null) {
        _controller.text = _targetItem!.itemName;
        _currentPath = _targetItem!.itemImagePath ;
        vm.setIconPath(_currentPath);
      }
    } else {
      vm.setIconPath("icon:box");
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
                    onTap: () => _showIconPicker(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ItemImageDisplay(path: displayPath, size: 60),
                        Container(
                          padding: const EdgeInsets.all(2),
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
                    decoration: InputDecoration(
                      labelText: S.of(context).itemName,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            // アイコン登録用ボタン（暫定：FABから呼び出すためのブリッジ）
            ElevatedButton(
              onPressed: _onSave,
              child: const Text("内容を確定（テスト用）"),
            ),
            const Gap(20),
            _buildIconGrid(),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final vm = context.read<ViewModel>();
    final name = _controller.text;

    if (name.isEmpty) return;

    vm.updateItemName(name);

    if (widget.itemId == null) {
      vm.addItem();
    } else {
      vm.updateItem(widget.itemId!);
    }
    Navigator.pop(context);
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