import 'words.dart';

enum Style {
  // style: 1    This is flowing text, or prose. See most verses in the NT.
  prose,
  // style: 2    This is poetry. See Psalms, Proverbs.
  poetry,
  // style: 3    This is poetry with no small vertical space at the end of the verse. See Ezra 2
  poetryNoPostGap,
  // style: 4    This is poetry with an extra linebreak before the verse. See Judges 5:6.
  poetryPreGap,
  // style: 5    This is poetry with an extra linebreak before the verse and no vertical space after the verse. See Ezra 2:36.
  poetryPreGapNoPostGap,
  // style: 6    This is list style. It's similar to poetry... I can explain later if you want to go there.
  list,
  // style: 7    This is list style with no small vertical space at the end of the verse.
  listNoPostGap,
  // style: 8    This is list style with an extra linebreak before the verse.
  listPreGap,
  // style: 9    This is list style with an extra linebreak before the verse and no vertical space after the verse.
  listPreGapNoPostGap,
}

extension Classify on Style {
  String get className {
    switch (this) {
      case Style.prose:
        return 'prose';
      case Style.poetry:
        return 'poetry';
      case Style.poetryNoPostGap:
        return 'poetry no-post-gap';
      case Style.poetryPreGap:
        return 'poetry pre-gap';
      case Style.poetryPreGapNoPostGap:
        return 'poetry pre-gap-no-post-gap';
      case Style.list:
        return 'list';
      case Style.listNoPostGap:
        return 'list no-post-gap';
      case Style.listPreGap:
        return 'list pre-gap';
      case Style.listPreGapNoPostGap:
        return 'list pre-gap-no-post-gap';
    }
  }
}

enum ViewMode {
  paragraph,
  verseBreak,
  reading,
}

extension ViewModeConverter on ViewMode {
  int get toInt {
    switch (this) {
      case ViewMode.paragraph:
        return 1;
      case ViewMode.verseBreak:
        return 2;
      case ViewMode.reading:
        return 3;
    }
  }
}

extension StyleConverter on Style {
  int get toInt {
    switch (this) {
      case Style.poetry:
        return 2;
      case Style.poetryNoPostGap:
        return 3;
      case Style.poetryPreGap:
        return 4;
      case Style.poetryPreGapNoPostGap:
        return 5;
      case Style.list:
        return 6;
      case Style.listNoPostGap:
        return 7;
      case Style.listPreGap:
        return 8;
      case Style.listPreGapNoPostGap:
        return 9;
      case Style.prose:
        return 1;
    }
  }
}

extension EnumConverter on int {
  Style get toStyle {
    switch (this) {
      case 2:
        return Style.poetry;
      case 3:
        return Style.poetryNoPostGap;
      case 4:
        return Style.poetryPreGap;
      case 5:
        return Style.poetryPreGapNoPostGap;
      case 6:
        return Style.list;
      case 7:
        return Style.listNoPostGap;
      case 8:
        return Style.listPreGap;
      case 9:
        return Style.listPreGapNoPostGap;
      case 1:
      default:
        return Style.prose;
    }
  }

  ViewMode get toViewMode {
    switch (this) {
      case 1:
        return ViewMode.paragraph;
      case 2:
        return ViewMode.verseBreak;
      case 3:
        return ViewMode.reading;
      default:
        return ViewMode.paragraph;
    }
  }
}

class Verse {
  final String book;
  final int chapter;
  final int verse;
  final String? heading;
  final bool microheading;
  final bool paragraph;
  final Style style;
  final String? footnotes;
  final String versetext;

  // TODO: add commentary check
  bool get hasCommentary => false;

  const Verse({
    required this.book,
    required this.chapter,
    required this.verse,
    this.heading,
    this.footnotes,
    required this.microheading,
    required this.paragraph,
    required this.style,
    required this.versetext,
  });

  Verse.fromJson(Map<String, dynamic> json)
      : book = json['book'],
        chapter = json['chapter'],
        verse = json['verse'],
        heading = json['heading'],
        footnotes = json['footnotes'],
        microheading = json['microheading'] == 1,
        paragraph = json['paragraph'] == 1,
        versetext = json['versetext'],
        style = (json['style'] as int).toStyle;

  Map<String, dynamic> get json => {
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'heading': heading,
        'footnotes': footnotes,
        'microheading': microheading ? 1 : 0,
        'paragraph': paragraph ? 1 : 0,
        'versetext': versetext,
        'style': style.toInt,
      };

  WordMap get words => Words.fromVerse(this);

  String get styledHeading {
    if (this.heading == null) return '';

    final heading = this.heading!.replaceAll('[br]', '<br/>');
    return '<p class="${microheading ? 'microheading' : 'heading'}">$heading</p>';
  }

  String raw({
    ViewMode viewMode = ViewMode.paragraph,
    bool linkCommentary = true,
  }) {
    if (viewMode == ViewMode.reading) return versetext;

    // Generate a verse number link to commentary
    final commentaryLink = hasCommentary && linkCommentary
        ? '<sup><commentary-link verse=$verse/></sup>'
        : '<sup>$verse</sup>';

    return '$commentaryLink $versetext';
  }

  bool get isPoetry {
    switch (style) {
      case Style.poetry:
      case Style.poetryNoPostGap:
      case Style.poetryPreGap:
      case Style.poetryPreGapNoPostGap:
        return true;
      default:
        return false;
    }
  }
}
