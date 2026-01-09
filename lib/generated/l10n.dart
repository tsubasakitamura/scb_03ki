// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Register this item`
  String get addItemToList {
    return Intl.message(
      'Register this item',
      name: 'addItemToList',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get addNew {
    return Intl.message(
      'Create New',
      name: 'addNew',
      desc: '',
      args: [],
    );
  }

  /// `New Item`
  String get addNewItem {
    return Intl.message(
      'New Item',
      name: 'addNewItem',
      desc: '',
      args: [],
    );
  }

  /// `A bag with this name already exists.`
  String get bagDuplicate {
    return Intl.message(
      'A bag with this name already exists.',
      name: 'bagDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Bag List`
  String get bagList {
    return Intl.message(
      'Bag List',
      name: 'bagList',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the item name.`
  String get bagNameInput {
    return Intl.message(
      'Please enter the item name.',
      name: 'bagNameInput',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `To register a bag, please provide both a 'Name' and 'Items'.\nIf you go back now, it won't be saved. Is that okay?`
  String get checkSentence1 {
    return Intl.message(
      'To register a bag, please provide both a \'Name\' and \'Items\'.\nIf you go back now, it won\'t be saved. Is that okay?',
      name: 'checkSentence1',
      desc: '',
      args: [],
    );
  }

  /// `The name or items are empty.\nIf you go back now, the bag will be deleted. Is that okay?`
  String get checkSentence2 {
    return Intl.message(
      'The name or items are empty.\nIf you go back now, the bag will be deleted. Is that okay?',
      name: 'checkSentence2',
      desc: '',
      args: [],
    );
  }

  /// `Continue Registering`
  String get checkSentence3 {
    return Intl.message(
      'Continue Registering',
      name: 'checkSentence3',
      desc: '',
      args: [],
    );
  }

  /// `Continue Editing`
  String get checkSentence4 {
    return Intl.message(
      'Continue Editing',
      name: 'checkSentence4',
      desc: '',
      args: [],
    );
  }

  /// `Go Back Without Saving`
  String get checkSentence5 {
    return Intl.message(
      'Go Back Without Saving',
      name: 'checkSentence5',
      desc: '',
      args: [],
    );
  }

  /// `Changes will not be saved. Are you sure you want to go back?`
  String get checkSentence6 {
    return Intl.message(
      'Changes will not be saved. Are you sure you want to go back?',
      name: 'checkSentence6',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get deleteAll {
    return Intl.message(
      'Delete All',
      name: 'deleteAll',
      desc: '',
      args: [],
    );
  }

  /// `Delete Selected`
  String get deleteSelected {
    return Intl.message(
      'Delete Selected',
      name: 'deleteSelected',
      desc: '',
      args: [],
    );
  }

  /// `Delete selected items?`
  String get deleteSentence1 {
    return Intl.message(
      'Delete selected items?',
      name: 'deleteSentence1',
      desc: '',
      args: [],
    );
  }

  /// `Delete all items?`
  String get deleteSentence2 {
    return Intl.message(
      'Delete all items?',
      name: 'deleteSentence2',
      desc: '',
      args: [],
    );
  }

  /// `Delete selected bags?`
  String get deleteSentence3 {
    return Intl.message(
      'Delete selected bags?',
      name: 'deleteSentence3',
      desc: '',
      args: [],
    );
  }

  /// `Delete all bags?`
  String get deleteSentence4 {
    return Intl.message(
      'Delete all bags?',
      name: 'deleteSentence4',
      desc: '',
      args: [],
    );
  }

  /// `All items deleted.`
  String get deleteSentence5 {
    return Intl.message(
      'All items deleted.',
      name: 'deleteSentence5',
      desc: '',
      args: [],
    );
  }

  /// `Deleted selected items.`
  String get deleteSentence6 {
    return Intl.message(
      'Deleted selected items.',
      name: 'deleteSentence6',
      desc: '',
      args: [],
    );
  }

  /// `Delete this bag?`
  String get deleteSentence7 {
    return Intl.message(
      'Delete this bag?',
      name: 'deleteSentence7',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Saved!`
  String get finishAdd {
    return Intl.message(
      'Saved!',
      name: 'finishAdd',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get item {
    return Intl.message(
      'Items',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `Add Item`
  String get itemAdd {
    return Intl.message(
      'Add Item',
      name: 'itemAdd',
      desc: '',
      args: [],
    );
  }

  /// `Update Details`
  String get itemChange {
    return Intl.message(
      'Update Details',
      name: 'itemChange',
      desc: '',
      args: [],
    );
  }

  /// `Delete Item`
  String get itemDelete0 {
    return Intl.message(
      'Delete Item',
      name: 'itemDelete0',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to discard this?`
  String get itemDelete1 {
    return Intl.message(
      'Are you sure you want to discard this?',
      name: 'itemDelete1',
      desc: '',
      args: [],
    );
  }

  /// `Deleted.`
  String get itemDelete2 {
    return Intl.message(
      'Deleted.',
      name: 'itemDelete2',
      desc: '',
      args: [],
    );
  }

  /// `This item is already on the list.`
  String get itemDuplicate {
    return Intl.message(
      'This item is already on the list.',
      name: 'itemDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Edit Item`
  String get itemEdit {
    return Intl.message(
      'Edit Item',
      name: 'itemEdit',
      desc: '',
      args: [],
    );
  }

  /// `Item List`
  String get itemList {
    return Intl.message(
      'Item List',
      name: 'itemList',
      desc: '',
      args: [],
    );
  }

  /// `Item Name`
  String get itemName {
    return Intl.message(
      'Item Name',
      name: 'itemName',
      desc: '',
      args: [],
    );
  }

  /// `Create Bag`
  String get makeBag {
    return Intl.message(
      'Create Bag',
      name: 'makeBag',
      desc: '',
      args: [],
    );
  }

  /// `No items yet.`
  String get noItem {
    return Intl.message(
      'No items yet.',
      name: 'noItem',
      desc: '',
      args: [],
    );
  }

  /// `Execute`
  String get ok {
    return Intl.message(
      'Execute',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Packed`
  String get preparedItem {
    return Intl.message(
      'Packed',
      name: 'preparedItem',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get register {
    return Intl.message(
      'Save',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Reset to unpacked state?`
  String get resetSentence1 {
    return Intl.message(
      'Reset to unpacked state?',
      name: 'resetSentence1',
      desc: '',
      args: [],
    );
  }

  /// `Move all 'Packed' items to the 'Not Packed' list?`
  String get resetSentence2 {
    return Intl.message(
      'Move all \'Packed\' items to the \'Not Packed\' list?',
      name: 'resetSentence2',
      desc: '',
      args: [],
    );
  }

  /// `Reset to unpacked state.`
  String get resetSentence3 {
    return Intl.message(
      'Reset to unpacked state.',
      name: 'resetSentence3',
      desc: '',
      args: [],
    );
  }

  /// `Select Photo`
  String get selectImage {
    return Intl.message(
      'Select Photo',
      name: 'selectImage',
      desc: '',
      args: [],
    );
  }

  /// `Select Items`
  String get selectItem {
    return Intl.message(
      'Select Items',
      name: 'selectItem',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get selection {
    return Intl.message(
      'Select',
      name: 'selection',
      desc: '',
      args: [],
    );
  }

  /// `Within 10 characters, please.`
  String get tenWord {
    return Intl.message(
      'Within 10 characters, please.',
      name: 'tenWord',
      desc: '',
      args: [],
    );
  }

  /// `Not Packed Yet`
  String get unpreparedItem {
    return Intl.message(
      'Not Packed Yet',
      name: 'unpreparedItem',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get warming {
    return Intl.message(
      'Confirmation',
      name: 'warming',
      desc: '',
      args: [],
    );
  }

  /// `All items except pinned ones will be moved to 'Not Packed'.`
  String get warmingSentence {
    return Intl.message(
      'All items except pinned ones will be moved to \'Not Packed\'.',
      name: 'warmingSentence',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
