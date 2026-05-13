class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'ITUNGIN_API_BASE_URL',
    defaultValue: 'https://itungin.my.id/api',
  );
}
