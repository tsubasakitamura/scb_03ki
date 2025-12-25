import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/view/parts/bag_card.dart';
import 'package:untitled1/view/screens/bag_manager_screen.dart';
import 'package:untitled1/vm/viewmodel.dart';

enum BagGridDisplayMode {
  ALL,
  CHOOSE,
  NORMAL,
}

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

          // バッグが空の場合の表示
          if (validBags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.luggage_outlined, size: 100, color: Colors.grey[300]),
                  const Gap(20),
                  Text(
                    "バッグがありません\n右下のボタンから作成しましょう！",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            );
          }

          return GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 100),
              childAnimationBuilder: (widget) => FadeInAnimation(child: widget),
              children: List<Widget>.generate(
                validBags.length,
                    (index) {
                  final bag = validBags[index];
                  return AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 100),
                    child: BagCard(
                      bag: bag,
                      onTap: () {
                        _goBagDetailScreen(
                          context,
                          openMode: BagDetailOpenMode.EDIT,
                          bagId: bag.id,
                        );
                      },
                      displayCondition: displayCondition,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _goBagDetailScreen(BuildContext context,
      {required BagDetailOpenMode openMode, required int bagId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BagManagerScreen(
            mode: BagMode.detail,
            detailOpenMode: openMode,
            bagId: bagId
        ),
      ),
    );
  }
}