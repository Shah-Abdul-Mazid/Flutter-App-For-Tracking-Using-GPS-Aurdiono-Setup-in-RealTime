import 'package:flutter/material.dart';
import 'package:TrackMyBus/src/common_widgets/background_scaffold.dart';

Widget buildScreenWithBackground({
  required Widget content,
  PreferredSizeWidget? appBar,
  double overlayOpacity = 0.5,
}) {
  return BackgroundScaffold(
    appBar: appBar,
    overlayOpacity: overlayOpacity,
    child: content,
  );
}