import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // アイコン用に必要
import 'package:provider/provider.dart';
import '../../db/database.dart';
import '../../vm/viewmodel.dart';
import '../screens/item_manager_screen.dart';
import 'item_grid_part.dart';

// --- アイコンと画像を判別して表示する部品 ---
class ItemImageDisplay extends StatelessWidget {
  final String path;
  final double size;

  const ItemImageDisplay({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    // もし「icon:」で始まっていたらFontAwesomeアイコンを表示
    if (path.startsWith('icon:')) {
      final iconName = path.replaceFirst('icon:', '');
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Icon(_getIconData(iconName), size: size * 0.5, color: Colors.blueGrey),
      );
    }

    // そうでなければ普通の画像（ファイルまたはデフォルト画像）を表示
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

  // 文字列の名前からFontAwesomeのデータに変換
  IconData _getIconData(String name) {
    switch (name) {
      case 'suitcase': return FontAwesomeIcons.suitcase;
      case 'umbrella': return FontAwesomeIcons.umbrella;
      case 'wallet': return FontAwesomeIcons.wallet;
      case 'shirt': return FontAwesomeIcons.shirt;
      case 'laptop': return FontAwesomeIcons.laptop;
      case 'key': return FontAwesomeIcons.key;
      case 'book': return FontAwesomeIcons.book;
      case 'camera': return FontAwesomeIcons.camera;
      case 'flask': return FontAwesomeIcons.flask;
      default: return FontAwesomeIcons.box;
    }
  }
}

class ItemCard extends StatefulWidget {
  final ItemGridDisplayMode displayMode;
  final Item item;

  const ItemCard({
    required this.item,
    required this.displayMode,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool isCheck = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ViewModel>();

    if (widget.displayMode == ItemGridDisplayMode.SELECT) {
      final itemIdsStr = vm.currentBag?.itemIds ?? '';
      final ids = itemIdsStr.split(',').where((e) => e.isNotEmpty).toList();
      isCheck = ids.contains(widget.item.itemId.toString());
    } else {
      isCheck = vm.unpreparedItems.contains(widget.item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ViewModel>();
    final baseFontSize = titleFontSize(context);
    final bool pinned = viewModel.isPinned(widget.item);

    return Card(
      child: Stack(children: [
        ListTile(
          title: AutoSizeText(
            "${widget.item.itemName}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: baseFontSize),
            maxLines: 1,
            minFontSize: baseFontSize - 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final imageSize = maxWidth * 0.85;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                // ★ ここを自作の ItemImageDisplay に差し替えました
                child: Center(
                  child: ItemImageDisplay(
                    path: widget.item.itemImagePath,
                    size: imageSize,
                  ),
                ),
              );
            },
          ),
          onTap: () => _tapListTile(context),
        ),
        if (widget.displayMode == ItemGridDisplayMode.DELETE)
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Checkbox(
              value: context.watch<ViewModel>().selectedItems.contains(widget.item),
              onChanged: (value) {
                final vm = context.read<ViewModel>();
                if (value == true) {
                  vm.addSelectedItem(widget.item);
                } else {
                  vm.removeSelectedItem(widget.item);
                }
              },
            ),
          )
        else if (widget.displayMode == ItemGridDisplayMode.SELECT)
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Builder(
              builder: (context) {
                final vm = context.watch<ViewModel>();
                final pinned = vm.isPinned(widget.item);
                return Checkbox(
                  value: pinned ? true : isCheck,
                  onChanged: pinned
                      ? null
                      : (value) {
                    setState(() {
                      isCheck = value!;
                      vm.updateSelectItem(
                        selectedItem: widget.item,
                        isSelect: isCheck,
                      );
                    });
                  },
                );
              },
            ),
          ),
        if (widget.displayMode == ItemGridDisplayMode.UNPREPARED ||
            widget.displayMode == ItemGridDisplayMode.PREPARED)
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              padding: const EdgeInsets.all(2),
              iconSize: 15,
              icon: Icon(
                pinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: pinned ? Colors.indigo : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  viewModel.togglePin(widget.item);
                });
              },
            ),
          ),
      ]),
    );
  }

  void editSelectedItem(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemManagerScreen(mode: ItemMode.edit, item: item),
      ),
    );
  }

  double titleFontSize(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide < 550) return 10.0;
    if (shortestSide < 800) return 15.0;
    return 20.0;
  }

  void _tapListTile(BuildContext context) {
    final vm = context.read<ViewModel>();

    if (widget.displayMode == ItemGridDisplayMode.SELECT ||
        widget.displayMode == ItemGridDisplayMode.MASTER) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemManagerScreen(mode: ItemMode.edit, item: widget.item),
        ),
      );
      return;
    }
    if (widget.displayMode == ItemGridDisplayMode.UNPREPARED ||
        widget.displayMode == ItemGridDisplayMode.PREPARED) {
      if (vm.isPinned(widget.item)) return;
      vm.toggleItemPrepared(widget.item);
    }
  }
}