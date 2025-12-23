/// API endpoint constants for the Lighten Up application
/// Update baseUrl with your actual backend URL
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Update this with your backend URL
  static const String baseUrl = 'https://api.lightenup.example.com';
  static const String wsBaseUrl = 'wss://api.lightenup.example.com';

  // API version
  static const String apiVersion = '/api/v1';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ========== Authentication ==========
  static const String login = '$apiVersion/auth/login';
  static const String logout = '$apiVersion/auth/logout';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String verifyPin = '$apiVersion/auth/verify-pin';
  static const String changePassword = '$apiVersion/auth/change-password';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // ========== Users ==========
  static const String users = '$apiVersion/users';
  static String userById(String id) => '$users/$id';
  static String userProfile(String id) => '$users/$id/profile';
  static const String currentUser = '$users/me';
  static const String updateProfile = '$users/me/profile';
  static const String userPreferences = '$users/me/preferences';

  // ========== Messages ==========
  static const String messages = '$apiVersion/messages';
  static String messageById(String id) => '$messages/$id';
  static const String sendMessage = '$messages/send';
  static const String markAsRead = '$messages/read';
  static String messageThread(String threadId) => '$messages/thread/$threadId';
  static const String unreadCount = '$messages/unread/count';
  static const String searchMessages = '$messages/search';

  // ========== Notifications ==========
  static const String notifications = '$apiVersion/notifications';
  static String notificationById(String id) => '$notifications/$id';
  static const String unreadNotifications = '$notifications/unread';
  static const String markNotificationRead = '$notifications/mark-read';
  static const String notificationSettings = '$notifications/settings';
  static const String dismissNotification = '$notifications/dismiss';

  // ========== Alerts ==========
  static const String alerts = '$apiVersion/alerts';
  static String alertById(String id) => '$alerts/$id';
  static const String activeAlerts = '$alerts/active';
  static const String acknowledgeAlert = '$alerts/acknowledge';
  static const String alertHistory = '$alerts/history';
  static const String alertSettings = '$alerts/settings';

  // ========== Patients ==========
  static const String patients = '$apiVersion/patients';
  static String patientById(String id) => '$patients/$id';
  static String patientMessages(String patientId) =>
      '$patients/$patientId/messages';
  static String patientAlerts(String patientId) =>
      '$patients/$patientId/alerts';
  static const String searchPatients = '$patients/search';

  // ========== Staff ==========
  static const String staff = '$apiVersion/staff';
  static String staffById(String id) => '$staff/$id';
  static const String staffOnline = '$staff/online';
  static const String staffSchedule = '$staff/schedule';
  static String staffAvailability(String staffId) =>
      '$staff/$staffId/availability';

  // ========== Activity/Analytics ==========
  static const String activity = '$apiVersion/activity';
  static const String dailySummary = '$activity/summary/daily';
  static const String weeklySummary = '$activity/summary/weekly';
  static const String monthlySummary = '$activity/summary/monthly';
  static String activityByDate(String date) => '$activity/date/$date';
  static const String activityStats = '$activity/stats';

  // ========== Settings ==========
  static const String settings = '$apiVersion/settings';
  static const String soundSettings = '$settings/sound';
  static const String privacySettings = '$settings/privacy';
  static const String notificationPreferences = '$settings/notifications';
  static const String themeSettings = '$settings/theme';

  // ========== WebSocket Endpoints ==========
  static const String wsMessages = '$wsBaseUrl/ws/messages';
  static const String wsNotifications = '$wsBaseUrl/ws/notifications';
  static const String wsAlerts = '$wsBaseUrl/ws/alerts';
  static const String wsPresence = '$wsBaseUrl/ws/presence';

  // ========== File Upload ==========
  static const String uploadFile = '$apiVersion/files/upload';
  static const String downloadFile = '$apiVersion/files/download';
  static String deleteFile(String fileId) => '$apiVersion/files/$fileId';

  // ========== Health Check ==========
  static const String healthCheck = '$apiVersion/health';
  static const String version = '$apiVersion/version';
}
