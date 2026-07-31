import 'platform_utils.dart';

class PlatformUtilsImpl extends PlatformUtils {
  static bool get isMobile => true;
  static bool get isWeb => false;
  static bool get isDesktop => false;
}
