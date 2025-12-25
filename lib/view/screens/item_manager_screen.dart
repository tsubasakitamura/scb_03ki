import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/db/database.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/vm/viewmodel.dart';
import '../../generated/l10n.dart';
import '../parts/item_grid_part.dart';
import '../parts/item_parts.dart';

enum ItemMode { master, select, edit, delete, add }
enum DeleteType { Select, All }

class ItemManagerScreen extends StatefulWidget {
  final ItemMode mode;
  final Item? item; // Editモード用

  const ItemManagerScreen({Key? key, required this.mode, this.item}) : super(key: key);

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
      vm.getAllItem();
      if (widget.mode == ItemMode.delete) vm.clearSelectedItem();
      if (widget.mode == ItemMode.add || widget.mode == ItemMode.edit) vm.imageFile = null;
    });
  }

  @override
  void dispose() {
    adManager.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        floatingActionButton: widget.mode == ItemMode.master ? _buildFab() : null,
        body: Column(
          children: [
            if (widget.mode == ItemMode.edit) _buildAdContainer(), // Edit時のみ上に広告
            Expanded(child: _buildBody()),
            if (widget.mode != ItemMode.edit) _buildAdContainer(), // それ以外は下に広告
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = "";
    List<Widget> actions = [];
    Widget? leading;

    switch (widget.mode) {
      case ItemMode.master:
        title = S.of(context).itemList;
        leading = IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.lightBlue),
          onPressed: () => Navigator.pop(context),
        );
        actions = [_buildDeleteMenu()];
        break;
      case ItemMode.select:
        title = S.of(context).selectItem;
        leading = IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.lightBlue),
          onPressed: () => Navigator.pop(context),
        );
        actions = [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.add))),
            child: Text(S.of(context).addNew, style: const TextStyle(fontSize: 18, color: Colors.lightBlue)),
          )
        ];
        break;
      case ItemMode.delete:
        title = S.of(context).deleteSelected;
        leading = IconButton(
          icon: const Text("☓", style: TextStyle(color: Colors.black, fontSize: 25)),
          onPressed: () => Navigator.pop(context),
        );
        actions = [
          TextButton(onPressed: () => _showDeleteConfirmDialog(), child: Text(S.of(context).done))
        ];
        break;
      case ItemMode.add:
        title = S.of(context).itemAdd;
        leading = IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.lightBlue),
          onPressed: () => Navigator.pop(context),
        );
        break;
      case ItemMode.edit:
        title = S.of(context).itemEdit;
        leading = IconButton(
          icon: const Text("☓", style: TextStyle(color: Colors.black, fontSize: 25)),
          onPressed: () => Navigator.pop(context),
        );
        break;
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: Colors.black)),
      leading: leading,
      actions: actions,
    );
  }

  Widget _buildBody() {
    switch (widget.mode) {
      case ItemMode.master:
        return const ItemGridPart(displayMode: ItemGridDisplayMode.MASTER);
      case ItemMode.select:
        return const ItemGridPart(displayMode: ItemGridDisplayMode.SELECT);
      case ItemMode.delete:
        return const ItemGridPart(displayMode: ItemGridDisplayMode.DELETE);
      case ItemMode.add:
        return ItemAddPart(); // 後述のPartファイル
      case ItemMode.edit:
        return ItemEditPart(item: widget.item!); // 後述のPartファイル
    }
  }

  Widget _buildAdContainer() {
    return Container(
      width: adManager.bannerAd.size.width.toDouble(),
      height: adManager.bannerAd.size.height.toDouble(),
      child: AdWidget(ad: adManager.bannerAd),
    );
  }

  Widget _buildFab() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.add))),
        child: Text(S.of(context).addNewItem, style: const TextStyle(fontSize: 20.0)),
      ),
    );
  }

  Widget _buildDeleteMenu() {
    return PopupMenuButton<DeleteType>(
      icon: const Icon(Icons.delete, color: Colors.black),
      onSelected: (type) {
        if (type == DeleteType.Select) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemManagerScreen(mode: ItemMode.delete)));
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

  // --- ダイアログ類（Master/Delete画面から集約） ---
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).deleteSentence1),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () async {
              await context.read<ViewModel>().deleteSelectedItem();
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Screen
              Fluttertoast.showToast(msg: S.of(context).deleteSentence6);
            },
            child: Text(S.of(context).ok),
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
        content: Text(S.of(context).deleteSentence2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () async {
              await context.read<ViewModel>().deleteAllItem();
              await context.read<ViewModel>().getAllItem();
              Fluttertoast.showToast(msg: S.of(context).deleteSentence5);
              Navigator.pop(context);
            },
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }
}