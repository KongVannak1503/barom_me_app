import 'platform_utils.dart';

class PlatformUtilsImpl extends PlatformUtils {
  static bool get isMobile => false;
  static bool get isWeb => false;
  static bool get isDesktop => true;
}
