abstract class AppConst {
  AppConst._();

  //название приложения
  static const String appName = 'Surf Chat App';

  //обычно ключ задаю через --dart-define и String.fromEnvironment,
  //для простоты пусть останется тут
  static const String freeImageApiKey = '6d207e02198a847aa98d0a2a901485a5';

  //константы http-запроса
  static const String freeImageApiHost = 'freeimage.host';
  static const String freeImageUploadPath = '/api/1/upload';
  static const String freeImageApiKeyKeyName = 'key';
  static const String freeImageBodyImageKey = 'image';

  //константы маршрутов
  static const String loginRoute = '/';
  static const String topicsRoute = '/topics';
  static const String createTopicsRoute = '/topics/createTopic';
  static const String chatRoute = '/chat';
}
