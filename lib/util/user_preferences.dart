
import 'package:disperse/util/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserPreferences { SHAPES, COLOR, MAX_RADIUS }

class UserPreferencesUtilities {

  static SharedPreferences preferences;

  static Future init() async {
    return SharedPreferences.getInstance().then((sp) => preferences = sp);
  }

  static double getMaxRadius() {
    return preferences.getDouble(UserPreferences.MAX_RADIUS.toString()) ?? Configuration.RADIUS_DEFAULT_VALUE;
  }

  static Future<bool> setMaxRadius(double value) async {
    return preferences.setDouble(UserPreferences.MAX_RADIUS.toString(), value);
  }

}
