class Configuration {
  /// Width of the border of each of the settings filled buttons
  static const double SETTINGS_STROKE_WIDTH = 6;

  /// Minimum value for the slider radius
  static const double MIN_RADIUS_VALUE = 25;

  /// Maximum value for the slider radius
  static const double MAX_RADIUS_VALUE = 200;

  /// Default value for the radius
  static const double RADIUS_DEFAULT_VALUE = 50;

  /// Value to add to each base color (RGB) to form the end of the gradient
  static const int GRADIENT_END = 80;

  /// Period between each spawn of items in case of a long touch (same position or drag)
  static const int PERIOD_DRAG_DETECTION = 300;

  /// Time in milliseconds for the enlarge animation to finish
  static const int ENLARGE_ANIMATION_TIME = 1000;

  /// Time in milliseconds for the disperse animation to finish
  static const int DISPERSE_ANIMATION_TIME = 1000;

  /// Time in milliseconds to wait after last replay event start time before popping
  static const int AFTER_REPLAY_WAIT_TIME =
      ENLARGE_ANIMATION_TIME + DISPERSE_ANIMATION_TIME + 1000;

  /// Size of the titles in the settings
  static const double TITLE_SIZE = 32;

  // Filled in at the start of the application
  static double screenWidth, screenHeight;
}
