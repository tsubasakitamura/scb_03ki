import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/view/parts/item_grid_part.dart';
import 'package:untitled1/view/screens/bag_manager_screen.dart';
import '../screens/item_manager_screen.dart';
import '../../generated/l10n.dart';
import '../../vm/viewmodel.dart';
import 'dialog_confirm.dart';

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
              SizedBox(
                width: 80,
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
              const Gap(8),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  onChanged: (val) => context.read<ViewModel>().updateBagName(val),
                  decoration: InputDecoration(
                    hintText: S.of(context).bagNameInput,
                    prefixIcon: const Icon(Icons.edit),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
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