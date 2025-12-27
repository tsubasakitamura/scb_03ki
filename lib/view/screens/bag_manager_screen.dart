// ==========================================================================
// File: bag_manager_screen.dart
// --------------------------------------------------------------------------
// [バッグ管理のメイン画面：一覧・詳細・削除の切り替えを担当]
//
// < 目次 >
// 1. [Enum] 画面モード定義 ........... BagMode, BagDetailOpenMode 等の定義
// 2. [Widget] BagManagerScreen ...... メインの画面構成（Scaffold）
// 3. [Build] UI構成メソッド ........... AppBar, Body, BottomArea 等の生成
// 4. [Action] アクションボタン ........ 削除メニュー, アイテムボタン等
// 5. [Dialog] ダイアログ表示 .......... 削除確認・全消去確認
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/view/parts/bag_parts.dart';
import 'item_manager_screen.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../vm/viewmodel.dart';
import '../parts/common_ad_banner.dart';

// --- 列挙型の定義（ここに追加することでエラーを解消します） ---
enum BagMode { master, detail, delete }
enum BagDetailOpenMode { NEW, EDIT }
enum DeleteType { Select, All }

class BagManagerScreen extends StatefulWidget {
  final BagMode mode;
  final BagDetailOpenMode? detailOpenMode;
  final int? bagId;

  const BagManagerScreen({
    Key? key,
    required this.mode,
    this.detailOpenMode,
    this.bagId,
  }) : super(key: key);

  @override
  State<BagManagerScreen> createState() => _BagManagerScreenState();
}

class _BagManagerScreenState extends State<BagManagerScreen> {
  @override
  void initState() {
    super.initState();
    adManager.initBannerAd();
    adManager.loadBannerAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ViewModel>();
      if (widget.mode == BagMode.master) {
        vm.getBagData();
      }
      if (widget.mode == BagMode.delete) {
        vm.clearSelectBag();
      }
    });
  }

  @override
  void dispose() {
    adManager.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.mode == BagMode.detail ? () => FocusScope.of(context).unfocus() : null,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildBody()),
              _buildBottomArea(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    switch (widget.mode) {
      case BagMode.delete:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Text("☓", style: TextStyle(color: Colors.black, fontSize: 25)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(S.of(context).deleteSelected, style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () => _showDeleteConfirmDialog(),
                child: Text(S.of(context).done, style: const TextStyle(color: Colors.blue))
            )
          ],
        );
      case BagMode.detail:
        return null;
      case BagMode.master:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(S.of(context).bagList, style: const TextStyle(color: Colors.black87)),
          centerTitle: true,
          leadingWidth: 100,
          leading: _buildItemButton(),
          actions: [_buildDeleteMenu()],
        );
    }
  }

  Widget _buildBody() {
    switch (widget.mode) {
      case BagMode.delete:
        return const BagGridPart(displayCondition: BagGridDisplayMode.CHOOSE);
      case BagMode.detail:
        return BagDetailPart(
            openMode: widget.detailOpenMode ?? BagDetailOpenMode.NEW,
            bagId: widget.bagId
        );
      case BagMode.master:
        return const BagGridPart(displayCondition: BagGridDisplayMode.NORMAL);
    }
  }

  Widget _buildBottomArea() {
    return Column(
      children: [
        if (widget.mode == BagMode.master)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BagManagerScreen(
                            mode: BagMode.detail,
                            detailOpenMode: BagDetailOpenMode.NEW
                        )
                    ),
                  );
                },
                child: Text(S.of(context).makeBag, style: const TextStyle(fontSize: 20, color: Colors.lightBlue)),
              ),
            ),
          ),
        CommonAdBanner(),
        const Gap(10),
      ],
    );
  }

  Widget _buildItemButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const StadiumBorder(),
          side: const BorderSide(color: Colors.blue),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.master))
          );
        },
        child: Text(S.of(context).item, style: const TextStyle(fontSize: 14, color: Colors.lightBlue)),
      ),
    );
  }

  Widget _buildDeleteMenu() {
    return PopupMenuButton<DeleteType>(
      icon: const Icon(Icons.delete, color: Colors.black),
      onSelected: (type) {
        if (type == DeleteType.Select) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BagManagerScreen(mode: BagMode.delete))
          );
        } else {
          _showDeleteAllDialog();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: DeleteType.Select, child: Text(S.of(context).deleteSelected)),
        PopupMenuItem(value: DeleteType.All, child: Text(S.of(context).deleteAll)),
      ],
    );
  }

  void _showDeleteConfirmDialog() {
    final vm = context.read<ViewModel>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).deleteSentence3),
        actions: [
          TextButton(child: Text(S.of(context).cancel), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text(S.of(context).ok),
            onPressed: () async {
              await vm.deleteSelectBag();
              Navigator.pop(context);
              Navigator.pop(context);
              Fluttertoast.showToast(msg: S.of(context).deleteSentence6);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).deleteAll),
        content: Text(S.of(context).deleteSentence4),
        actions: [
          TextButton(child: Text(S.of(context).cancel), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text(S.of(context).ok),
            onPressed: () async {
              await context.read<ViewModel>().deleteAllBag();
              Navigator.pop(context);
              Fluttertoast.showToast(msg: S.of(context).deleteSentence5);
            },
          ),
        ],
      ),
    );
  }
}