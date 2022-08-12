import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:surf_practice_chat_flutter/common/app_const.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/models/free_image_response_dto.dart';

///Интерфейс для сервиса загрузки изображений
///
abstract class ImageUploadDataSource {
  Future<String> uploadImage(File imageFile);
}

//Имплементация на базе сервиса freeimage.host
class FreeImageUploadDataSource implements ImageUploadDataSource {
  // http клиент передается зависимостью
  final http.Client client;

  FreeImageUploadDataSource({required this.client});

  @override
  Future<String> uploadImage(File imageFile) async {
    //конвертация в  base64 строку
    final String base64Image = base64Encode(imageFile.readAsBytesSync());

    //параметры запроса
    final Map<String, dynamic> parameters = <String, dynamic>{
      //обязательный параметр-ключ доступа к API
      AppConst.freeImageApiKeyKeyName: AppConst.freeImageApiKey,
      //для скрытия ключа при публикации обычно использую dart-define
      //AppConst.freeImageApiKeyKeyName:const String.fromEnvironment('API_KEY', defaultValue: ' '),
    };
    //формирование строки запроса из хоста, пути и параметров
    //можно подменять хост для тестирования
    final Uri uri = Uri.https(
        AppConst.freeImageApiHost, AppConst.freeImageUploadPath, parameters);
    //тело запроса с изображением
    final Map<String, dynamic> body = <String, dynamic>{
      AppConst.freeImageBodyImageKey: base64Image
    };
    http.Response response = await client.post(uri, body: body);

    if (response.statusCode == 200) {
      //декодирование тела запроса в json
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      //первод json в объект данных дата слоя
      final FreeImageResponseDto freeImageResponseDto =
          FreeImageResponseDto.fromJson(json);
      return freeImageResponseDto.imageData?.displayUrl ?? '';
    } else {
      //все остальные исключения без конкретизации
      //но с указанием кода ошибки и сообщения от сервера
      throw Exception(
          'statusCode: ${response.statusCode}, responseBody: ${response.body}');
    }
  }
}
