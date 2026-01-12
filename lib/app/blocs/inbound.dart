import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/app/blocs/proxy_selector/proxy_selector_bloc.dart';
import 'package:vx/app/x_controller.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/logger.dart';

class InboundCubit extends Cubit<InboundMode> {
  InboundCubit(this.pref, this.xController) : super(pref.inboundMode);

  final SharedPreferences pref;
  final XController xController;

  void setInboundMode(InboundMode mode) async {
    emit(mode);
    pref.setInboundMode(mode);
    try {
      await xController.changeInboundMode();
    } catch (e) {
      logger.e('changeInboundMode error', error: e);
      snack(rootLocalizations()?.failedToChangeInboundMode);
      // await reportError(e, StackTrace.current);
    }
  }
}
