// ==========================================================================
// File: bag_parts.dart
// --------------------------------------------------------------------------
// [バッグ（Bag）に関連するUIパーツを統合管理するファイル]
//
// < 目次 >
// 1. [Enum] BagGridDisplayMode ...... 一覧の表示モード（全消去/選択/通常）
// 2. [Widget] BagGridPart ........... バッグ一覧（GridView）の表示
// 3. [Widget] BagCard ............... バッグ単体のカード表示（背景画像・削除）
// 4. [Widget] BagDetailPart ......... バッグ詳細・中身確認・名前編集・アイコン変更
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/db/database.dart';
import 'package:untitled1/generated/l10n.dart';
import 'package:untitled1/view/parts/common_parts.dart'; // さっき作った共通パーツ
import 'package:untitled1/view/parts/item_parts.dart';
import 'package:untitled1/view/screens/bag_manager_screen.dart';
import 'package:untitled1/view/screens/item_manager_screen.dart';
import 'package:untitled1/vm/viewmodel.dart';
import 'dialog_confirm.dart';

enum BagGridDisplayMode { ALL, CHOOSE, NORMAL }

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
            // 背景にアイコンまたは画像を表示
            Positioned.fill(
              child: ItemImageDisplay(path: bag.itemImagePath ?? "", size: 100),
            ),
            // 文字を読みやすくするための半透明レイヤー
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
            // チェックボックス
            if (displayCondition != BagGridDisplayMode.NORMAL)
              Positioned(
                top: -4,
                right: -4,
                child: Checkbox(
                  value: isCheck,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    if (displayCondition == BagGridDisplayMode.ALL) {
                      vm.deleteAllBag(); // 全消去のロジックはViewModel側を確認
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              // 1. アイコンプレビューと変更ボタン
              Consumer<ViewModel>(builder: (context, vm, child) {
                return InkWell(
                  onTap: () => _showIconPicker(context), // アイコン選択を開く
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ItemImageDisplay(
                        path: vm.currentBag?.itemImagePath ?? "icon:hospital_b",
                        size: 50, // 押しやすいサイズ
                      ),
                      // 編集可能であることがわかるペンマーク（任意）
                      Container(
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
              const Gap(10),

              // 2. バッグ名入力
              Expanded(
                child: TextField(
                  controller: _nameController,
                  onChanged: (val) => context.read<ViewModel>().updateBagName(val),
                  decoration: InputDecoration(
                    hintText: S.of(context).bagNameInput,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const Gap(8),

              // 3. 登録ボタン
              SizedBox(
                width: 70,
                child: TextButton(
                  onPressed: () => _goBagMasterScreen(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(S.of(context).register, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black),

        _buildSectionHeader(S.of(context).unpreparedItem, isUnprepared: true),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.lightBlue[100],
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
            itemCount: globalIconMap.length, // common_parts.dartで定義したもの
            itemBuilder: (context, index) {
              String key = globalIconMap.keys.elementAt(index);
              return InkWell(
                onTap: () {
                  // ViewModelを通じてバッグのアイコンパスを更新する
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: Colors.blue),
            ),
            onPressed: isUnprepared ? () => _confirmSelectItems() : () => _confirmReset(),
            child: Text(
              isUnprepared ? S.of(context).selection : S.of(context).reset,
              style: const TextStyle(color: Colors.lightBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _goBagMasterScreen(BuildContext context) {
    final vm = context.read<ViewModel>();
    final bag = vm.currentBag;
    final hasName = (bag?.name ?? '').trim().isNotEmpty;
    final hasItems = (bag?.itemIds ?? '').isNotEmpty;

    if (hasName && hasItems) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BagManagerScreen(mode: BagMode.master)),
            (route) => false,
      );
      return;
    }

    final isNew = widget.openMode == BagDetailOpenMode.NEW;
    final String message = isNew ? S.of(context).checkSentence1 : S.of(context).checkSentence2;
    final String continueLabel = isNew ? S.of(context).checkSentence3 : S.of(context).checkSentence4;

    showConfirmDialog(
      context: context,
      title: message,
      okLabel: S.of(context).checkSentence5,
      cancelLabel: continueLabel,
      onOk: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BagManagerScreen(mode: BagMode.master)),
              (route) => false,
        );
      },
    );
  }

  void _confirmSelectItems() {
    showConfirmDialog(
      context: context,
      title: S.of(context).warming,
      content: S.of(context).warmingSentence,
      okLabel: S.of(context).ok,       // 必須ラベルを追加
      cancelLabel: S.of(context).cancel, // 必須ラベルを追加
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
      okLabel: S.of(context).ok,       // 必須ラベルを追加
      cancelLabel: S.of(context).cancel, // 必須ラベルを追加
      onOk: () async {
        await context.read<ViewModel>().resetItem();
        Fluttertoast.showToast(msg: S.of(context).resetSentence3);
      },
    );
  }
}