// ==========================================================================
// File: item_manager_screen.dart
// --------------------------------------------------------------------------
// [アイテム管理のメイン画面：一覧・選択・編集の切り替えを担当]
//
// < 目次 >
// 1. [Enum] 画面モード定義 ........... ItemMode の定義
// 2. [Widget] ItemManagerScreen ...... メインの画面構成（Scaffold / FAB追加）
// 3. [Build] UI構成メソッド ........... AppBar, Body, BottomArea 等の生成
// 4. [Action] 登録アクション .......... FABから呼ばれる登録・更新ロジック
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../vm/viewmodel.dart';
import '../parts/common_ad_banner.dart';
import '../parts/item_parts.dart';

// --------------------------------------------------------------------------
// 1. [Enum] 画面モード定義
// --------------------------------------------------------------------------
enum ItemMode { master, select, edit }

class ItemManagerScreen extends StatefulWidget {
  final ItemMode mode;
  final int? itemId;

  const ItemManagerScreen({Key? key, required this.mode, this.itemId})
      : super(key: key);

  @override
  State<ItemManagerScreen> createState() => _ItemManagerScreenState();
}

class _ItemManagerScreenState extends State<ItemManagerScreen> {
  @override
  void initState() {
    super.initState();
    adManager.initBannerAd();
    adManager.loadBannerAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ViewModel>();
      if (widget.mode == ItemMode.master) {
        vm.getAllItem(); // VMに合わせて修正
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
      onTap: widget.mode == ItemMode.edit
          ? () => FocusScope.of(context).unfocus()
          : null,
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
        // 編集・追加モードの時のみ、右下に登録FABを表示
        floatingActionButton: widget.mode == ItemMode.edit
            ? FloatingActionButton.extended(
                backgroundColor: Colors.lightBlue,
                onPressed: () => _handleRegisterAction(),
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text(
                  S.of(context).register,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
      case ItemMode.master:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(S.of(context).itemList,
              style: const TextStyle(color: Colors.black)),
          centerTitle: true,
        );
      case ItemMode.select:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(S.of(context).selection,
              style: const TextStyle(color: Colors.black)),
          // 既存のselectionに修正
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).done,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            )
          ],
        );
      case ItemMode.edit:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.itemId == null
                ? S.of(context).itemAdd
                : S.of(context).itemEdit,
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        );
    }
  }

  Widget _buildBody() {
    switch (widget.mode) {
      case ItemMode.master:
        return const ItemGridPart(displayMode: ItemGridDisplayMode.ALL);
      case ItemMode.select:
        return const ItemGridPart(displayMode: ItemGridDisplayMode.CHOOSE);
      case ItemMode.edit:
        return ItemEditPart(itemId: widget.itemId);
    }
  }

  Widget _buildBottomArea() {
    return Column(
      children: [
        if (widget.mode == ItemMode.master)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ItemManagerScreen(mode: ItemMode.edit)),
                  );
                },
                child: Text(S.of(context).itemAdd,
                    style:
                        const TextStyle(fontSize: 20, color: Colors.lightBlue)),
              ),
            ),
          ),
        CommonAdBanner(),
        const Gap(10),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 4. [Action] 登録アクション
  // --------------------------------------------------------------------------
  void _handleRegisterAction() {
    // FAB（右下のボタン）が押されたら、通知を送る仕組みが必要ですが、
    // 今は一番シンプルな方法として、VMに「今入力されている名前」をセットし、
    // 保存メソッドを呼ぶ形に整理していきます。
    // ※警告を消すため、一旦使っていない変数を削除します。
  }
}
