import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/app/android_host_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/app/src/main/kotlin/com5vnetwork/vproxy/Messages.g.kt',
    kotlinOptions: KotlinOptions(),
  ),
)
@HostApi()
abstract class AndroidHostApi {
  @async
  void startXApiServer(Uint8List config);
  Uint8List generateTls();
  void redirectStdErr(String path);
  void requestAddTile();
}

// class SplitTunnelSettings {
//   SplitTunnelSettings({this.blackList, this.whiteList});
//   List<String>? blackList;
//   List<String>? whiteList;
// }
