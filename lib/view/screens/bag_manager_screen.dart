// ==========================================================================
// File: bag_manager_screen.dart
// --------------------------------------------------------------------------
// [バッグ管理のメイン画面：一覧・詳細・削除の切り替えを担当]
//
// 【もくじ】
// 1. 状態管理 (initState) .. 広告初期化、各モードに応じたデータ取得
// 2. 中断制御 (_handleBackAction) .. 未入力時の自動削除、破棄確認ダイアログ
// 3. 保存制御 (_handleRegisterAction) .. 空チェック ＋ ★同名重複チェック
// 4. UI構築 (AppBar/Body/Bottom) .. モードごとの画面構成切り替え
// 5. 削除・作成ダイアログ .. テンプレート選択、一括削除、個別削除のUI
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/model/bag_template.dart';
import 'package:untitled1/view/parts/common_parts.dart';

import '../parts/bag_parts.dart';
import '../parts/common_ad_banner.dart';

import 'item_manager_screen.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../vm/viewmodel.dart';

enum BagMode { master, detail, delete }
enum BagDetailOpenMode { NEW, EDIT }
enum BagGridDisplayMode { ALL, CHOOSE, NORMAL }
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
  BannerAd? _screenAd;

  @override
  void initState() {
    super.initState();
    _screenAd = adManager.createBannerAd();

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
    _screenAd?.dispose();
    super.dispose();
  }

  // --- 2. 中断時の確認ロジック ---
  Future<void> _handleBackAction() async {
    final vm = context.read<ViewModel>();

    if (widget.mode != BagMode.detail || widget.detailOpenMode == BagDetailOpenMode.EDIT) {
      Navigator.pop(context);
      return;
    }

    final bag = vm.currentBag;
    final bool hasChanges = (bag?.name.isNotEmpty ?? false) || (bag?.itemIds.isNotEmpty ?? false);

    if (!hasChanges) {
      if (bag != null) await vm.deleteOneBag(bag);
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(S.of(context).warming, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(S.of(context).checkSentence1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).checkSentence3, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).checkSentence5, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldDiscard == true) {
      if (bag != null) await vm.deleteOneBag(bag);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // --- 3. 保存制御 (重複チェック統合) ---
  void _handleRegisterAction() async {
    final vm = context.read<ViewModel>();
    final bag = vm.currentBag;

    final String currentName = (bag?.name ?? '').trim();
    final bool nameEmpty = currentName.isEmpty;
    final bool itemsEmpty = (bag?.itemIds ?? '').isEmpty;

    if (nameEmpty || itemsEmpty) {
      _showGentleMessage(S.of(context).checkSentence1.replaceAll("\n", " "));
      return;
    }

    // ViewModelの重複チェック付き更新メソッドを呼ぶ
    final int result = await vm.updateBagName(currentName);
    if (result == 2) {
      _showGentleMessage(S.of(context).bagDuplicate);
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BagManagerScreen(mode: BagMode.master)),
          (route) => false,
    );
  }

  // --- 4. UI構築 ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.mode == BagMode.detail ? () => FocusScope.of(context).unfocus() : null,
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
              if (widget.mode == BagMode.detail)
                Positioned(
                  right: 16,
                  bottom: 95,
                  child: FloatingActionButton.extended(
                    elevation: 4,
                    backgroundColor: Colors.lightBlue,
                    onPressed: () => _handleRegisterAction(),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      S.of(context).register,
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
    switch (widget.mode) {
      case BagMode.delete:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
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
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87, size: 22),
            onPressed: () => _handleBackAction(),
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
    final vm = context.watch<ViewModel>();
    final s = S.of(context);

    switch (widget.mode) {
      case BagMode.delete:
        return const BagGridPart(displayCondition: BagGridDisplayMode.CHOOSE);

      case BagMode.detail:
        return Column(
          children: [
            const PackingProgressBar(),
            Expanded(
              child: BagDetailPart(
                openMode: widget.detailOpenMode ?? BagDetailOpenMode.NEW,
                bagId: widget.bagId,
              ),
            ),
          ],
        );

      case BagMode.master:
      // --- ★ここから：バッグが空のときの作成推奨メッセージ ---
        if (vm.validBags.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 親しみやすいバッグのアイコン
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.lightBlue[100]),
                  const Gap(24),
                  Text(
                    "まだバッグがありません",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Gap(12),
                  Text(
                    "右下の「バッグ作成」ボタンから、\n最初の一つを作ってみましょう！",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                  ),
                  const Gap(40),
                  // 右下のボタンに視線を誘導するアイコン
                  Transform.rotate(
                    angle: 0.8,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 48,
                      color: Colors.lightBlue[200],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // --- ここまで：バッグがある場合は通常通り表示 ---
        return const BagGridPart(displayCondition: BagGridDisplayMode.NORMAL);
    }
  }

  Widget _buildBottomArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.mode == BagMode.master)
          Padding(
            // 右端の余白を少し調整（ボタンの影が切れないように16.0〜20.0が理想的）
            padding: const EdgeInsets.only(right: 16.0, bottom: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48, // 押しやすい高さ
                child: ElevatedButton.icon(
                  onPressed: () => _showCreationTypeDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white, size: 22),
                  label: Text(
                    S.of(context).makeBag,
                    style: const TextStyle(
                      fontSize: 18, // 元の20より少し凝縮してバランス調整
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    elevation: 4, // 軽く浮かせて立体感を出す
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // ★ 角を丸くしてカプセル型にする（StadiumBorder）
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
          ),
        CommonAdBanner(ad: _screenAd),
        const Gap(10),
      ],
    );
  }

  // --- 5. 各種メッセージ・ダイアログ ---

  void _showGentleMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 20),
            const Gap(12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 24, right: 24),
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        duration: const Duration(seconds: 2),
      ),
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
              for (var bag in vm.selectedBags) { await vm.deleteOneBag(bag); }
              vm.selectedBags.clear();
              Navigator.pop(context); Navigator.pop(context);
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

  void _showCreationTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "バッグの作り方",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // 内容に合わせて高さを自動調整
          children: [
            const Text("どちらの方法で作成しますか？", style: TextStyle(fontSize: 14)),
            const Gap(20),
            // 方法1: 新しく作る
            _buildDialogButton(
              context,
              icon: Icons.add_circle_outline,
              label: "新しく空のバッグを作る",
              color: Colors.blueAccent,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const BagManagerScreen(
                        mode: BagMode.detail,
                        detailOpenMode: BagDetailOpenMode.NEW
                    )
                ));
              },
            ),
            const Gap(12),
            // 方法2: テンプレート
            _buildDialogButton(
              context,
              icon: Icons.grid_view_rounded,
              label: "テンプレートから選ぶ",
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.pop(context);
                _showTemplateSelectDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ダイアログ内の押しやすい大きなボタンを作る補助関数
  Widget _buildDialogButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(15),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showTemplateSelectDialog(BuildContext context) {
    final templates = BagTemplate.defaultTemplates;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("テンプレートを選択", textAlign: TextAlign.center),
        content: SizedBox(
          // ★ widthを指定して AlertDialog の横幅を固定する
          width: double.maxFinite,
          // ★ ConstrainedBox ではなく SizedBox + Container で高さを確保する
          child: Container(
            // 画面の高さの半分（50%）程度を上限にする
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.separated(
              // ★ shrinkWrap は false (デフォルト) に戻す
              shrinkWrap: false,
              itemCount: templates.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = templates[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey[50],
                    child: Icon(
                      IconData(t.iconCode, fontFamily: 'MaterialIcons'),
                      color: Colors.blueGrey,
                    ),
                  ),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    t.items.map((e) => e.name).join(", "),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    final vm = context.read<ViewModel>();
                    final isDuplicate = vm.validBags.any((bag) => bag.name == t.name);

                    if (isDuplicate) {
                      Navigator.pop(context);
                      _showGentleMessage(S.of(context).bagDuplicate);
                      return;
                    }

                    await vm.createBagWithTemplate(
                      name: t.name,
                      items: t.items, // 引数名を ViewModel の修正に合わせて変更
                      iconCode: t.iconCode,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "${t.name}バッグを作成しました");
                  },
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const StadiumBorder(),
            side: const BorderSide(color: Colors.blue)),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ItemManagerScreen(mode: ItemMode.master))),
        child: Text(S.of(context).item,
            style: const TextStyle(fontSize: 14, color: Colors.lightBlue)),
      ),
    );
  }

  Widget _buildDeleteMenu() {
    return PopupMenuButton<DeleteType>(
      icon: const Icon(Icons.delete, color: Colors.black),
      onSelected: (type) => type == DeleteType.Select
          ? Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const BagManagerScreen(mode: BagMode.delete)))
          : _showDeleteAllDialog(),
      itemBuilder: (_) => [
        PopupMenuItem(
            value: DeleteType.Select, child: Text(S.of(context).deleteSelected)),
        PopupMenuItem(
            value: DeleteType.All, child: Text(S.of(context).deleteAll)),
      ],
    );
  }
}