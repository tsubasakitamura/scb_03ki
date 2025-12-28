// ==========================================================================
// File: bag_parts.dart
// --------------------------------------------------------------------------
// [バッグ（Bag）に関連するUIパーツを統合管理するファイル]
//
// < 目次 >
// 1. [Widget] BagGridPart ........... バッグ一覧（GridView）の表示
// 2. [Widget] BagCard ............... バッグ単体のカード表示
// 3. [Widget] BagDetailPart ......... バッグ詳細・中身（登録ボタンをFABへ移動）
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/db/database.dart';
import 'package:untitled1/generated/l10n.dart';
import 'package:untitled1/view/parts/common_parts.dart';
import 'package:untitled1/view/parts/item_parts.dart';
import 'package:untitled1/view/screens/bag_manager_screen.dart'; // Enum参照のため
import 'package:untitled1/view/screens/item_manager_screen.dart';
import 'package:untitled1/vm/viewmodel.dart';
import 'dialog_confirm.dart';

// ==========================================
// 1. BagGridPart: バッグの一覧表示
// ==========================================
class BagGridPart extends StatelessWidget {
  final BagGridDisplayMode displayCondition;
  const BagGridPart({Key? key, required this.displayCondition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 8,
      child: Consumer<ViewModel>(
        builder: (context, vm, child) {
          final validBags = vm.validBags;
          if (validBags.isEmpty) {
            return _buildEmptyView();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: validBags.length,
            itemBuilder: (context, index) {
              final bag = validBags[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 3,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: BagCard(
                      bag: bag,
                      displayCondition: displayCondition,
                      onTap: () => _goBagDetailScreen(context, bag.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.luggage_outlined, size: 100, color: Colors.grey[300]),
          const Gap(20),
          const Text("バッグがありません\n右下のボタンから作成しましょう！",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  void _goBagDetailScreen(BuildContext context, int bagId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BagManagerScreen(
            mode: BagMode.detail,
            detailOpenMode: BagDetailOpenMode.EDIT,
            bagId: bagId),
      ),
    );
  }
}

// ==========================================
// 2. BagCard: バッグ単体のカード表示
// ==========================================
class BagCard extends StatelessWidget {
  final Bag bag;
  final VoidCallback onTap;
  final BagGridDisplayMode displayCondition;

  const BagCard({
    super.key,
    required this.bag,
    required this.onTap,
    required this.displayCondition,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModel>();
    final bool isCheck = vm.selectedBags.contains(bag);

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Stack(
          children: [
            Positioned.fill(
              child: ItemImageDisplay(path: bag.itemImagePath ?? "", size: 100),
            ),
            Container(color: Colors.black26),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  bag.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            if (displayCondition != BagGridDisplayMode.NORMAL)
              Positioned(
                top: -4,
                right: -4,
                child: Checkbox(
                  value: isCheck,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    if (displayCondition == BagGridDisplayMode.ALL) {
                      vm.deleteAllBag();
                    } else {
                      value! ? vm.addValidBag(bag) : vm.removeValidBag(bag);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).deleteSentence7),
        actions: [
          TextButton(child: Text(S.of(context).cancel), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text(S.of(context).ok),
            onPressed: () async {
              await context.read<ViewModel>().deleteOneBag(bag);
              Navigator.pop(context);
              Fluttertoast.showToast(msg: S.of(context).deleteSentence6);
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. BagDetailPart: バッグ詳細・中身確認
// ==========================================
class BagDetailPart extends StatefulWidget {
  final BagDetailOpenMode openMode;
  final int? bagId;

  const BagDetailPart({Key? key, required this.openMode, this.bagId}) : super(key: key);

  @override
  State<BagDetailPart> createState() => _BagDetailPartState();
}

class _BagDetailPartState extends State<BagDetailPart> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openMode == BagDetailOpenMode.NEW) {
        context.read<ViewModel>().createBag();
      } else {
        if (widget.bagId != null) {
          _getSelectedBag(widget.bagId!);
        }
      }
    });
  }

  void _getSelectedBag(int bagId) async {
    final vm = context.read<ViewModel>();
    await vm.getSelectedBag(bagId);
    _nameController.text = vm.currentBag?.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Consumer<ViewModel>(builder: (context, vm, child) {
                return InkWell(
                  onTap: () => _showIconPicker(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ItemImageDisplay(
                        path: vm.currentBag?.itemImagePath ?? "icon:hospital_b",
                        size: 55,
                      ),
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
                  controller: _nameController,
                  style: const TextStyle(fontSize: 18),
                  onChanged: (val) => context.read<ViewModel>().updateBagName(val),
                  decoration: InputDecoration(
                    labelText: S.of(context).bagNameInput,
                    hintText: "例：海外旅行、ジム用など",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
        _buildSectionHeader(S.of(context).unpreparedItem, isUnprepared: true),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.lightBlue[50],
            ),
            child: const ItemGridPart(displayMode: ItemGridDisplayMode.UNPREPARED),
          ),
        ),
        _buildSectionHeader(S.of(context).preparedItem, isUnprepared: false),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.white,
            ),
            child: const ItemGridPart(displayMode: ItemGridDisplayMode.PREPARED),
          ),
        ),
      ],
    );
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("バッグのアイコンを選択"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: globalIconMap.length,
            itemBuilder: (context, index) {
              String key = globalIconMap.keys.elementAt(index);
              return InkWell(
                onTap: () {
                  context.read<ViewModel>().updateBagImage("icon:$key");
                  Navigator.pop(context);
                },
                child: Icon(globalIconMap[key], size: 28, color: Colors.blueGrey),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool isUnprepared}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: isUnprepared ? () => _confirmSelectItems() : () => _confirmReset(),
            child: Text(
              isUnprepared ? S.of(context).selection : S.of(context).reset,
              style: const TextStyle(color: Colors.lightBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelectItems() {
    showConfirmDialog(
      context: context,
      title: S.of(context).warming,
      content: S.of(context).warmingSentence,
      okLabel: S.of(context).ok,
      cancelLabel: S.of(context).cancel,
      onOk: () {
        context.read<ViewModel>().resetPreparation();
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.select))
        );
      },
    );
  }

  void _confirmReset() {
    showConfirmDialog(
      context: context,
      title: S.of(context).resetSentence1,
      content: S.of(context).resetSentence2,
      okLabel: S.of(context).ok,
      cancelLabel: S.of(context).cancel,
      onOk: () async {
        await context.read<ViewModel>().resetItem();
        Fluttertoast.showToast(msg: S.of(context).resetSentence3);
      },
    );
  }


}