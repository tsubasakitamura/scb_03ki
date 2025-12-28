// ==========================================================================
// File: bag_manager_screen.dart
// --------------------------------------------------------------------------
// [バッグ管理のメイン画面：一覧・詳細・削除の切り替えを担当]
//
// < 目次 >
// 1. [Enum] 画面モード定義 ........... BagMode, BagDetailOpenMode 等の定義
// 2. [Widget] BagManagerScreen ...... メインの画面構成（Scaffold / FAB追加）
// 3. [Build] UI構成メソッド ........... AppBar, Body, BottomArea 等の生成
// 4. [Action] アクションボタン ........ 削除メニュー, アイテムボタン等
// 5. [Dialog] ダイアログ表示 .......... 削除確認・全消去確認
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/view/parts/common_parts.dart';

// パーツ類のインポート
import '../parts/bag_parts.dart';
import '../parts/common_ad_banner.dart';
import '../parts/dialog_confirm.dart';

import 'item_manager_screen.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../vm/viewmodel.dart';

enum BagMode { master, detail, delete }
enum BagDetailOpenMode { NEW, EDIT }
enum BagGridDisplayMode { ALL, CHOOSE, NORMAL } // ここに移動
enum DeleteType { Select, All }

// --------------------------------------------------------------------------
// 2. [Widget] BagManagerScreen
// --------------------------------------------------------------------------
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
        vm.selectedBags.clear();
        vm.refresh();
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
        // --- 修正点：詳細画面の時のみ右下にFABを表示 ---
        floatingActionButton: widget.mode == BagMode.detail
            ? FloatingActionButton.extended(
          backgroundColor: Colors.lightBlue,
          onPressed: () => _handleRegisterAction(),
          icon: const Icon(Icons.check, color: Colors.white),
          label: Text(
            S.of(context).register,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
            : null,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 3. [Build] UI構成メソッド
  // --------------------------------------------------------------------------
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
      // 詳細画面ではAppBarの左側を「戻る（中断）」として機能させる
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.detailOpenMode == BagDetailOpenMode.NEW
                ? S.of(context).makeBag
                : S.of(context).itemEdit,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          centerTitle: true,
        );
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
      // --- ここを Column に書き換え ---
        return Column(
          children: [
            const PackingProgressBar(), // 先ほど作成した進捗ゲージ
            Expanded(
              child: BagDetailPart(
                openMode: widget.detailOpenMode ?? BagDetailOpenMode.NEW,
                bagId: widget.bagId,
              ),
            ),
          ],
        );
    // ------------------------------

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

  // --------------------------------------------------------------------------
  // 4. [Action] アクションボタン & 登録ロジック
  // --------------------------------------------------------------------------

  // FABから呼ばれる登録処理（BagDetailPartから移動・統合）
  void _handleRegisterAction() {
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

    final isNew = widget.detailOpenMode == BagDetailOpenMode.NEW;
    final String message = isNew ? S.of(context).checkSentence1 : S.of(context).checkSentence2;
    final String continueLabel = isNew ? S.of(context).checkSentence3 : S.of(context).checkSentence4;

    showConfirmDialog(
      context: context,
      title: message,
      content: "",
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

  // --------------------------------------------------------------------------
  // 5. [Dialog] ダイアログ表示
  // --------------------------------------------------------------------------
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
              for (var bag in vm.selectedBags) {
                await vm.deleteOneBag(bag);
              }
              vm.selectedBags.clear();
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