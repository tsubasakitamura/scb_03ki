import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../vm/viewmodel.dart';
import '../parts/common_ad_banner.dart';
import '../parts/item_parts.dart';

enum ItemMode { master, select, edit, delete }

class ItemManagerScreen extends StatefulWidget {
  final ItemMode mode;
  final int? itemId;

  const ItemManagerScreen({Key? key, required this.mode, this.itemId})
      : super(key: key);

  @override
  State<ItemManagerScreen> createState() => _ItemManagerScreenState();
}

class _ItemManagerScreenState extends State<ItemManagerScreen> {
  BannerAd? _screenAd;

  @override
  void initState() {
    super.initState();
    _screenAd = adManager.createBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewModel>().getAllItem();
    });
  }

  @override
  void dispose() {
    _screenAd?.dispose();
    super.dispose();
  }

  Future<void> _handleBackAction() async {
    final vm = context.read<ViewModel>();
    if (widget.mode != ItemMode.edit) {
      Navigator.pop(context);
      return;
    }
    final bool isNameEmpty = vm.inputName.trim().isEmpty;
    final bool isImageNotSet = vm.imageFile == null &&
        (vm.selectedIconPath == null || vm.selectedIconPath == "icon:box");

    if (widget.itemId == null && isNameEmpty && isImageNotSet) {
      Navigator.pop(context);
      return;
    }

    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(S.of(context).warming, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(widget.itemId == null
            ? S.of(context).checkSentence6
            : S.of(context).itemDelete1
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).checkSentence4, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).checkSentence5, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldDiscard == true) {
      vm.inputName = "";
      vm.imageFile = null;
      vm.selectedIconPath = null;
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.mode == ItemMode.edit || widget.mode == ItemMode.select
          ? () => FocusScope.of(context).unfocus()
          : null,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBackAction();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(child: _buildBody()),
                    _buildBottomArea(),
                  ],
                ),
              ),
              if (widget.mode == ItemMode.edit || widget.mode == ItemMode.select)
                Positioned(
                  right: 16,
                  bottom: 95,
                  child: FloatingActionButton.extended(
                    elevation: 4,
                    backgroundColor: Colors.lightBlue,
                    onPressed: () => _handleRegisterAction(),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      widget.mode == ItemMode.select ? "このアイテムを作る" : S.of(context).addItemToList,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    final s = S.of(context);
    final vm = context.read<ViewModel>();

    switch (widget.mode) {
      case ItemMode.delete:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          title: Text(s.deleteSelected, style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => _showDeleteConfirmDialog(),
              child: Text(s.done, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            )
          ],
        );
      case ItemMode.master:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(s.itemList, style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.delete, color: Colors.black),
              onSelected: (value) {
                if (value == 'select') {
                  vm.selectedDeleteItems.clear();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.delete)));
                } else if (value == 'all') {
                  _showDeleteAllDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'select', child: Text(s.deleteSelected)),
                PopupMenuItem(value: 'all', child: Text(s.deleteAll)),
              ],
            ),
          ],
        );
      case ItemMode.select:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          title: Text(s.selectItem, style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.done, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            )
          ],
        );
      case ItemMode.edit:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _handleBackAction()),
          title: Text(widget.itemId == null ? s.itemAdd : s.itemEdit, style: const TextStyle(color: Colors.black)),
          centerTitle: true,
        );
    }
  }

  Widget _buildBody() {
    switch (widget.mode) {
      case ItemMode.master:
      case ItemMode.delete:
        return const ItemGridPart(displayMode: ItemGridDisplayMode.ALL);
      case ItemMode.select:
        return Column(
          children: [
            const Expanded(flex: 2, child: ItemGridPart(displayMode: ItemGridDisplayMode.CHOOSE)),
            const Divider(height: 1, thickness: 2),
            const Expanded(flex: 1, child: ItemEditPart()),
          ],
        );
      case ItemMode.edit:
        return ItemEditPart(itemId: widget.itemId);
    }
  }

  Widget _buildBottomArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.mode == ItemMode.master)
          Padding(
            padding: const EdgeInsets.only(right: 20.0, bottom: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.edit)));
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(S.of(context).addNew, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[400], shape: const StadiumBorder()),
                ),
              ),
            ),
          ),
        CommonAdBanner(ad: _screenAd),
        const Gap(10),
      ],
    );
  }

  void _showDeleteConfirmDialog() {
    final s = S.of(context);
    final vm = context.read<ViewModel>();
    if (vm.selectedDeleteItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.warming),
        content: Text(s.deleteSentence1),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
          TextButton(
            onPressed: () async {
              await vm.deleteSelectedItems();
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
              Fluttertoast.showToast(msg: s.deleteSentence6);
            },
            child: Text(s.ok, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.warming),
        content: Text(s.deleteSentence2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<ViewModel>().deleteAllItems();
              if (!mounted) return;
              Navigator.pop(context);
              Fluttertoast.showToast(msg: s.deleteSentence5);
            },
            child: Text(s.ok, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGentleMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleRegisterAction() async {
    final vm = context.read<ViewModel>();
    if (widget.itemId == null) {
      final result = await vm.addItem();
      if (!mounted) return;
      if (result == 1) { _showGentleMessage(S.of(context).bagNameInput); return; }
      else if (result == 2) { _showGentleMessage(S.of(context).itemDuplicate); return; }
    } else {
      if (vm.inputName.trim().isEmpty) { _showGentleMessage(S.of(context).bagNameInput); return; }
      await vm.updateItem(widget.itemId!);
    }
    if (mounted) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: S.of(context).finishAdd);
    }
  }
}