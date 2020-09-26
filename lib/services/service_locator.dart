import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get_it/get_it.dart';

class DIContainer {
  static final GetIt getIt = GetIt.instance;

  static void registerServices() {
    getIt.registerLazySingleton(() => FlutterFFmpeg());
    getIt.registerLazySingleton(() => FlutterFFprobe());
  }
}
