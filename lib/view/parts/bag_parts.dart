// ==========================================================================
// File: bag_parts.dart
// --------------------------------------------------------------------------
// 【もくじ】
// 1. BagGridPart ....... バッグの一覧グリッド表示
// 2. BagCard ........... バッグ単体のカード
// 3. BagDetailPart ..... バッグの詳細編集画面
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/db/database.dart';
import 'package:untitled1/generated/l10n.dart';
import 'package:untitled1/view/parts/common_parts.dart';
import 'package:untitled1/view/parts/item_parts.dart';
import 'package:untitled1/view/screens/bag_manager_screen.dart';
import 'package:untitled1/view/screens/item_manager_screen.dart';
import 'package:untitled1/vm/viewmodel.dart';
import 'dialog_confirm.dart';

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
            return Center(child: Icon(Icons.luggage_outlined, size: 100, color: Colors.grey[300]));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
            ),
            itemCount: validBags.length,
            itemBuilder: (context, index) {
              final bag = validBags[index];
              return AnimationConfiguration.staggeredGrid(
                position: index, duration: const Duration(milliseconds: 375), columnCount: 3,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: BagCard(
                      bag: bag, displayCondition: displayCondition,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BagManagerScreen(mode: BagMode.detail, detailOpenMode: BagDetailOpenMode.EDIT, bagId: bag.id))),
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
}

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
      onLongPress: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(S.of(context).deleteSentence7),
          actions: [
            TextButton(
              child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(S.of(context).ok, style: const TextStyle(color: Colors.red)),
              onPressed: () async {
                await context.read<ViewModel>().deleteOneBag(bag);
                Navigator.pop(context);
                Fluttertoast.showToast(msg: S.of(context).deleteSentence6);
              },
            ),
          ],
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // 境界線を薄く入れることで、白い背景でもカードの形をはっきりさせます
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
        elevation: 3,
        color: Colors.white, // ★ここを確実に白に設定
        child: Stack(
          children: [
            // 1. アイコン・画像表示エリア
            Positioned.fill(
              child: Container(
                color: Colors.white, // ★背景色を強制的に白で統一
                child: bag.iconCode != null
                    ? Icon(
                  IconData(bag.iconCode!, fontFamily: 'MaterialIcons'),
                  size: 48, // 少し大きくして見やすく
                  color: Colors.blueGrey[700],
                )
                    : Center(
                  child: ItemImageDisplay(
                    path: bag.itemImagePath ?? "",
                    size: 110,
                  ),
                ),
              ),
            ),

            // 2. 下部の文字帯（デザインを洗練させつつ視認性を確保）
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                // 透過度を調整し、真っ黒すぎない高級感のあるグレーに
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
                child: Text(
                  bag.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // シニア向けに少し大きく
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // 3. 選択用チェックボックス（削除・整理モード時）
            if (displayCondition != BagGridDisplayMode.NORMAL)
              Positioned(
                top: 4,
                right: 4,
                child: Transform.scale(
                  scale: 1.3, // さらに大きく押しやすく
                  child: Checkbox(
                    value: isCheck,
                    activeColor: Colors.blueAccent,
                    shape: const CircleBorder(), // 丸型にして「選択」感を強調
                    side: const BorderSide(color: Colors.blueGrey, width: 1.5),
                    onChanged: (value) =>
                    value! ? vm.addValidBag(bag) : vm.removeValidBag(bag),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
      } else if (widget.bagId != null) {
        context.read<ViewModel>().getSelectedBag(widget.bagId!).then((_) {
          _nameController.text = context.read<ViewModel>().currentBag?.name ?? "";
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white, padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Consumer<ViewModel>(builder: (context, vm, _) => InkWell(
                onTap: () => _showImageSelector(context),
                child: vm.currentBag?.iconCode != null
                    ? CircleAvatar(radius: 27, child: Icon(IconData(vm.currentBag!.iconCode!, fontFamily: 'MaterialIcons')))
                    : ItemImageDisplay(path: vm.currentBag?.itemImagePath ?? "icon:hospital_b", size: 55),
              )),
              const Gap(16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  onChanged: (val) => context.read<ViewModel>().setTemporaryBagName(val),
                  decoration: InputDecoration(labelText: S.of(context).bagNameInput, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        _buildSection(S.of(context).unpreparedItem, true),
        Expanded(child: const ItemGridPart(displayMode: ItemGridDisplayMode.UNPREPARED)),
        _buildSection(S.of(context).preparedItem, false),
        Expanded(child: const ItemGridPart(displayMode: ItemGridDisplayMode.PREPARED)),
      ],
    );
  }

  Widget _buildSection(String title, bool isUn) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton(
          onPressed: isUn ? () => _confirmSelect() : () => _confirmReset(),
          child: Text(isUn ? S.of(context).selection : S.of(context).reset),
        )
      ]),
    );
  }

  void _confirmSelect() async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.select))
    );

    // アイテム選択画面から戻ってきた後、ViewModelの保存処理を呼ぶ
    if (mounted) {
      context.read<ViewModel>().saveSelectedItemsToBag();
    }
  }

  void _confirmReset() {
    showConfirmDialog(context: context, title: S.of(context).resetSentence1, content: S.of(context).resetSentence2, okLabel: S.of(context).ok, cancelLabel: S.of(context).cancel, onOk: () => context.read<ViewModel>().resetItem());
  }

  void _showImageSelector(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: Text(S.of(context).camera), onTap: () { Navigator.pop(_); _pick(ImageSource.camera); }),
      ListTile(leading: const Icon(Icons.photo_library), title: Text(S.of(context).gallery), onTap: () { Navigator.pop(_); _pick(ImageSource.gallery); }),
    ])));
  }

  void _pick(ImageSource s) async {
    final p = await ImagePicker().pickImage(source: s);
    if (p != null) context.read<ViewModel>().updateBagImage(p.path);
  }

}