import 'package:flutter/material.dart';

import '../models/appendices.dart';
import '../models/bible.dart';
import '../models/commentary.dart';
import 'stored_state.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class GlobalState with ChangeNotifier {
  GlobalState(this._store);

  // Make SettingsService a private variable so it is not used directly.
  final StoredState _store;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Make user font a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late TextStyle _textStyle;

  // Make user font size a private variable so it is not updated directly
  // without also persisting the changes with the SettingsService.
  late double _textSize;

  // Make user resource private so it is not updated directly without
  // also persisting and updating the render
  late Resource? _resource;

  // Make the bible data private so it is not updated directly without also
  // persisting the changes.
  Bible? _bible;

  Appendices? _appendix;

  Commentary? _commentary;

  BiblePath? get path =>
      _book != null ? BiblePath(_book!, _chapter, _verse) : null;

  // Make the book name private so it is not updated directly without also
  // persisting the changes.
  late String? _book;

  // Make the chapter private so it is not updated directly without also
  // persisting the changes.
  late int? _chapter;

  // Make the verse private so it is not updated directly without also
  // persisting the changes.
  late int? _verse;

  // Allow Widgets to read the user's preferred TextStyle.
  TextStyle get textStyle => _textStyle;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  // Allow Widgets to read the user's preferred Text Size
  double get textSize => _textSize;

  // Allow Widgets to get bible data.
  Bible? get bible => _bible;

  Appendices? get appendix => _appendix;

  Commentary? get commentary => _commentary;

  Resource? get resource => _resource;

  String? get book => _book;

  int? get chapter => _chapter;

  int? get verse => _verse;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  loadSettings() {
    _themeMode = _store.themeMode;
    _textStyle = _store.textStyle;
    _textSize = _store.textSize;
    _resource = _store.resource;
    _book = _store.bookName;
    _chapter = _store.chapter;
    _verse = _store.verse;
    // Load the bible data asynchronously
    Commentary.load.then((v) {
      _commentary = v;
      notifyListeners();
    });
    Bible.load.then((value) {
      _bible = value;
      notifyListeners();
    });
    Appendices.load.then((v) {
      _appendix = v;
      notifyListeners();
    });

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the textStyle
  updateTextStyle(TextStyle? newTextStyle) {
    if (newTextStyle == null) return;

    if (newTextStyle == _textStyle) return;

    _textStyle = newTextStyle;

    notifyListeners();

    // Persist data
    _store.updateTextStyle(newTextStyle);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  updateThemeMode(ThemeMode? newThemeMode) {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    _store.updateThemeMode(newThemeMode);
  }

  /// Update and persist the Text Size based on the user's selection.
  increaseTextSize([double amount = 2]) {
    _textSize += amount;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    _store.updateTextSize(_textSize);
  }

  decreaseTextSize([double amount = 2]) {
    _textSize -= amount;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    _store.updateTextSize(_textSize);
  }

  resetTextSize() {
    _textSize = defaultTextSize;
  }

  updateResource([Resource? resource]) {
    if (_resource == resource) return;
    _resource = resource;
    if (resource == null) {
      updateBookName();
      updateChapter();
      updateVerse();
    }
    notifyListeners();
    _store.updateResource(resource);
  }

  updateBookName([String? book]) {
    if (_book == book) return;
    _book = book;
    if (book == null) {
      updateChapter();
      updateVerse();
    }
    notifyListeners();
    _store.updateBookName(book);
  }

  updateChapter([int? chapter]) {
    if (_chapter == chapter) return;
    _chapter = chapter;
    if (chapter == null) {
      updateVerse();
    }
    notifyListeners();
    _store.updateChapter(chapter);
  }

  updateVerse([int? verse]) {
    if (_verse == verse) return;
    _verse = verse;
    notifyListeners();
    _store.updateVerse(verse);
  }
}
