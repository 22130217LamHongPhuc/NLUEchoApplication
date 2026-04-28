import 'package:echo_nlu/features/echo_detail/controllers/echo_comment_controller.dart';
import 'package:echo_nlu/features/echo_detail/controllers/echo_detail_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/echo_detail_state.dart';

final echoDetailProvider = NotifierProvider.autoDispose<EchoDetailController, EchoDetailState>(
  () => EchoDetailController(),
);

final echoCommentsProvider = NotifierProvider<EchoCommentController, EchoCommentState>(
  () => EchoCommentController(),
);
