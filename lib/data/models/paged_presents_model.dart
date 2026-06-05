
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';

class PagedPresents {
  final List<LrPresetModel> presents;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  PagedPresents({
    required this.presents,
    required this.lastDoc,
    required this.hasMore,
  });
}
