import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../widgets/lang_toggle_button.dart';
import '../../widgets/news_state_scaffold.dart';
import '../../widgets/speed_dial_fab.dart';


import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';


part 'daily_news_hbb_details_page.part.dart';
part 'daily_news_hbb_content.part.dart';
part 'daily_news_hbb_model.part.dart';


part 'cards/post_details.part.dart';
part 'cards/post_cards.part.dart';
part 'cards/post_card_variants.part.dart';
part 'cards/card_surface.part.dart';
part 'cards/post_text_block.part.dart';
part 'cards/post_date.part.dart';
part 'cards/post_image.part.dart';


part 'daily_news_hbb_category_button.part.dart';





//archivo principal, es el punto de entrada de la screen


class DailyNewsHbb extends StatelessWidget {
  const DailyNewsHbb({super.key});

  static const String _title = 'HBB • Tabloid';

  static const String _postsCollection = 'posts';
  static const String _orderByField = 'createdAtClient';

  static const EdgeInsets _gridPadding = EdgeInsets.symmetric(horizontal: 16);
  static const SliverGridDelegate _gridDelegate =
  SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.72,
  );

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection(_postsCollection)
        .orderBy(_orderByField, descending: true)
        .limit(60)
        .snapshots();

    return _HbbStreamView(
      title: _title,
      stream: stream,
    );
  }
}
