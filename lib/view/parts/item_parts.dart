import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/db/database.dart';
import 'package:untitled1/generated/l10n.dart';
import 'package:untitled1/vm/viewmodel.dart';
import 'button_with_icon.dart';

// --- アイコンと画像を判別して表示する共通部品 ---
class ItemImageDisplay extends StatelessWidget {
  final String path;
  final double size;

  const ItemImageDisplay({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('icon:')) {
      final iconName = path.replaceFirst('icon:', '');
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Icon(_getIconData(iconName), size: size * 0.5, color: Colors.blueGrey),
      );
    }

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: path.isEmpty
              ? const AssetImage("assets/images/gray.png") as ImageProvider
              : FileImage(File(path)),
        ),
      ),
    );
  }

  // ★ ここに「病院」「仕事」などの新しいアイコン定義をすべて入れました
  IconData _getIconData(String name) {
    switch (name) {
      case 'medical': return FontAwesomeIcons.fileMedical;
      case 'pills': return FontAwesomeIcons.pills;
      case 'hospital': return FontAwesomeIcons.hospital;
      case 'mask': return FontAwesomeIcons.maskFace;
      case 'briefcase': return FontAwesomeIcons.briefcase;
      case 'school': return FontAwesomeIcons.graduationCap;
      case 'laptop': return FontAwesomeIcons.laptop;
      case 'pen': return FontAwesomeIcons.penNib;
      case 'umbrella': return FontAwesomeIcons.umbrella;
      case 'wallet': return FontAwesomeIcons.wallet;
      case 'key': return FontAwesomeIcons.key;
      case 'mobile': return FontAwesomeIcons.mobileScreen;
      case 'camera': return FontAwesomeIcons.camera;
      case 'ticket': return FontAwesomeIcons.ticket;
      case 'bottle': return FontAwesomeIcons.bottleWater;
      case 'map': return FontAwesomeIcons.mapLocationDot;
      case 'shopping': return FontAwesomeIcons.bagShopping;
      case 'travel': return FontAwesomeIcons.suitcaseRolling;
      case 'baby': return FontAwesomeIcons.babyCarriage;
      case 'pet': return FontAwesomeIcons.paw;
      case 'id': return FontAwesomeIcons.idCard;
      case 'book': return FontAwesomeIcons.book;
      case 'glasses': return FontAwesomeIcons.glasses;
      case 'bicycle': return FontAwesomeIcons.bicycle;
      default: return FontAwesomeIcons.box;
    }
  }
}

// --- ItemAddPart ---
class ItemAddPart extends StatefulWidget {
  const ItemAddPart({Key? key}) : super(key: key);
  @override
  State<ItemAddPart> createState() => _ItemAddPartState();
}

class _ItemAddPartState extends State<ItemAddPart> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          Consumer<ViewModel>(builder: (context, vm, child) {
            String displayPath = "";
            if (vm.imageFile != null) displayPath = vm.imageFile!.path;
            else if (vm.selectedIconPath != null) displayPath = vm.selectedIconPath!;
            return ItemImageDisplay(path: displayPath, size: 300);
          }),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _showPickImageDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
            child: Text(S.of(context).selectImage),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _textController,
              maxLength: 10,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: S.of(context).itemName,
                counterText: S.of(context).tenWord,
              ),
            ),
          ),
          ButtonWithIcon(
            onPressed: _textController.text.isEmpty ? null : () => _onAdd(context),
            icon: const Icon(Icons.add_circle_outline),
            label: S.of(context).addItemToList,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _onAdd(BuildContext context) async {
    final vm = context.read<ViewModel>();
    String finalPath = vm.imageFile?.path ?? vm.selectedIconPath ?? "";
    await vm.addItem(_textController.text, finalPath);
    Fluttertoast.showToast(msg: S.of(context).finishAdd);
    _textController.clear();
    setState(() {});
  }

  void _showPickImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).selectImage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(S.of(context).camera),
              onTap: () { context.read<ViewModel>().pickImage(ImageSource.camera); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(S.of(context).gallery),
              onTap: () { context.read<ViewModel>().pickImage(ImageSource.gallery); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.icons),
              title: const Text("アイコンから選ぶ"),
              onTap: () { Navigator.pop(context); _showIconPicker(context); },
            ),
          ],
        ),
      ),
    );
  }

  // ★ ここが「アイコン選択ダイアログ」です！
  void _showIconPicker(BuildContext context) {
    final Map<String, IconData> iconMap = {
      'medical': FontAwesomeIcons.fileMedical, 'pills': FontAwesomeIcons.pills,
      'hospital': FontAwesomeIcons.hospital, 'mask': FontAwesomeIcons.maskFace,
      'briefcase': FontAwesomeIcons.briefcase, 'school': FontAwesomeIcons.graduationCap,
      'laptop': FontAwesomeIcons.laptop, 'pen': FontAwesomeIcons.penNib,
      'umbrella': FontAwesomeIcons.umbrella, 'wallet': FontAwesomeIcons.wallet,
      'key': FontAwesomeIcons.key, 'mobile': FontAwesomeIcons.mobileScreen,
      'camera': FontAwesomeIcons.camera, 'ticket': FontAwesomeIcons.ticket,
      'bottle': FontAwesomeIcons.bottleWater, 'map': FontAwesomeIcons.mapLocationDot,
      'shopping': FontAwesomeIcons.bagShopping, 'travel': FontAwesomeIcons.suitcaseRolling,
      'baby': FontAwesomeIcons.babyCarriage, 'pet': FontAwesomeIcons.paw,
      'id': FontAwesomeIcons.idCard, 'book': FontAwesomeIcons.book,
      'glasses': FontAwesomeIcons.glasses, 'bicycle': FontAwesomeIcons.bicycle,
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("アイコンを選択"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 1行に4つ並べる
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: iconMap.length,
            itemBuilder: (context, index) {
              String key = iconMap.keys.elementAt(index);
              return InkWell(
                onTap: () {
                  context.read<ViewModel>().setIconPath("icon:$key");
                  Navigator.pop(context);
                },
                child: Icon(iconMap[key], size: 28, color: Colors.blueGrey),
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- ItemEditPart (編集画面用) ---
class ItemEditPart extends StatefulWidget {
  final Item item;
  const ItemEditPart({Key? key, required this.item}) : super(key: key);
  @override
  State<ItemEditPart> createState() => _ItemEditPartState();
}

class _ItemEditPartState extends State<ItemEditPart> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.itemName);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewModel>(builder: (context, vm, child) {
      String displayPath = widget.item.itemImagePath;
      if (vm.imageFile != null) displayPath = vm.imageFile!.path;
      else if (vm.selectedIconPath != null) displayPath = vm.selectedIconPath!;

      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            ItemImageDisplay(path: displayPath, size: 200),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showPickImageDialog(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: Text(S.of(context).selectImage),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _textController,
                maxLength: 10,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: S.of(context).itemName,
                  counterText: S.of(context).tenWord,
                ),
              ),
            ),
            ButtonWithIcon(
                onPressed: _textController.text.trim().isEmpty ? null : () => _onUpdate(context),
                icon: const Icon(Icons.add_circle_outline),
                label: S.of(context).itemChange,
                color: Colors.blue),
            const SizedBox(height: 10),
            ButtonWithIcon(
                onPressed: () => _onDelete(context),
                icon: const Icon(Icons.delete),
                label: S.of(context).itemDelete0,
                color: Colors.black54),
          ],
        ),
      );
    });
  }

  void _onUpdate(BuildContext context) async {
    final vm = context.read<ViewModel>();
    String finalPath = widget.item.itemImagePath;
    if (vm.imageFile != null) finalPath = vm.imageFile!.path;
    else if (vm.selectedIconPath != null) finalPath = vm.selectedIconPath!;
    await vm.updateEditItem(widget.item, _textController.text, finalPath);
    Navigator.pop(context);
  }

  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).itemDelete1),
        actions: [
          TextButton(
            child: Text(S.of(context).ok),
            onPressed: () async {
              final vm = context.read<ViewModel>();
              await vm.deleteEditItem(widget.item);
              await vm.getAllItem();
              Navigator.pop(context);
              Navigator.pop(context);
              Fluttertoast.showToast(msg: S.of(context).itemDelete2);
            },
          ),
          TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showPickImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).selectImage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.orangeAccent),
              title: Text(S.of(context).camera),
              onTap: () { context.read<ViewModel>().pickImage(ImageSource.camera); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.lightBlueAccent),
              title: Text(S.of(context).gallery),
              onTap: () { context.read<ViewModel>().pickImage(ImageSource.gallery); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.icons),
              title: const Text("アイコンから選ぶ"),
              onTap: () { Navigator.pop(context); _showIconPicker(context); },
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext context) {
    final Map<String, IconData> iconMap = {
      'medical': FontAwesomeIcons.fileMedical, 'pills': FontAwesomeIcons.pills,
      'hospital': FontAwesomeIcons.hospital, 'mask': FontAwesomeIcons.maskFace,
      'briefcase': FontAwesomeIcons.briefcase, 'school': FontAwesomeIcons.graduationCap,
      'laptop': FontAwesomeIcons.laptop, 'pen': FontAwesomeIcons.penNib,
      'umbrella': FontAwesomeIcons.umbrella, 'wallet': FontAwesomeIcons.wallet,
      'key': FontAwesomeIcons.key, 'mobile': FontAwesomeIcons.mobileScreen,
      'camera': FontAwesomeIcons.camera, 'ticket': FontAwesomeIcons.ticket,
      'bottle': FontAwesomeIcons.bottleWater, 'map': FontAwesomeIcons.mapLocationDot,
      'shopping': FontAwesomeIcons.bagShopping, 'travel': FontAwesomeIcons.suitcaseRolling,
      'baby': FontAwesomeIcons.babyCarriage, 'pet': FontAwesomeIcons.paw,
      'id': FontAwesomeIcons.idCard, 'book': FontAwesomeIcons.book,
      'glasses': FontAwesomeIcons.glasses, 'bicycle': FontAwesomeIcons.bicycle,
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("アイコンを選択"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: iconMap.length,
            itemBuilder: (context, index) {
              String key = iconMap.keys.elementAt(index);
              return InkWell(
                onTap: () {
                  context.read<ViewModel>().setIconPath("icon:$key");
                  Navigator.pop(context);
                },
                child: Icon(iconMap[key], size: 28, color: Colors.blueGrey),
              );
            },
          ),
        ),
      ),
    );
  }
}