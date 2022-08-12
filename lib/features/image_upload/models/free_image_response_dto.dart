// To parse this JSON data, do
//
//     final imgbbResponseModel = imgbbResponseModelFromJson(jsonString);

import 'dart:convert';

//примеры ответов в конце файла

//модель ответа на загрузку изображения
class FreeImageResponseDto {
  FreeImageResponseDto({this.imageData, this.failureData, this.successData});

  //данные изображения
  ImageDataDto? imageData;

  //данные в случае успешного ответа
  SuccessDataDto? successData;

  //данные в случае ошибки
  FailureDataDto? failureData;

  factory FreeImageResponseDto.fromJson(Map<String, dynamic> json) =>
      FreeImageResponseDto(
        imageData: json["image"] == null
            ? null
            : ImageDataDto.fromJson(json["image"] as Map<String, dynamic>),
        successData: json["success"] == null
            ? null
            : SuccessDataDto.fromJson(json["success"] as Map<String, dynamic>),
        failureData: json['error'] == null
            ? null
            : FailureDataDto.fromJson(json["error"] as Map<String, dynamic>),
      );
}

//класс успешного ответа
class SuccessDataDto {
  SuccessDataDto({
    required this.message,
    required this.code,
  });

  final String message;
  final int code;

  factory SuccessDataDto.fromJson(Map<String, dynamic> json) => SuccessDataDto(
        code: json["code"],
        message: json["message"],
      );
}

//класс неуспешного ответа
class FailureDataDto {
  FailureDataDto({
    required this.code,
    required this.message,
    required this.context,
  });

  final int code;
  final String message;
  final String context;

  factory FailureDataDto.fromJson(Map<String, dynamic> json) => FailureDataDto(
      code: json["code"], message: json["message"], context: json["context"]);
}

//класс данных изображения
class ImageDataDto {
  ImageDataDto({
    required this.displayUrl,
  });

  //ссылка для отображения
  final String displayUrl;

  factory ImageDataDto.fromJson(Map<String, dynamic> json) => ImageDataDto(
        displayUrl: json["display_url"],
      );
}
//success
// {
// "status_code": 200,
// "success": {
// "message": "image uploaded",
// "code": 200
// },
// "image": {
// "name": "example",
// "extension": "png",
// "size": 53237,
// "width": 1151,
// "height": 898,
// "date": "2014-06-04 15:32:33",
// "date_gmt": "2014-06-04 19:32:33",
// "storage_id": null,
// "description": null,
// "nsfw": "0",
// "md5": "c684350d722c956c362ab70299735830",
// "storage": "datefolder",
// "original_filename": "example.png",
// "original_exifdata": null,
// "views": "0",
// "id_encoded": "L",
// "filename": "example.png",
// "ratio": 1.2817371937639,
// "size_formatted": "52 KB",
// "mime": "image/png",
// "bits": 8,
// "channels": null,
// "url": "http://freeimage.host/images/2014/06/04/example.png",
// "url_viewer": "http://freeimage.host/image/L",
// "thumb": {
// "filename": "example.th.png",
// "name": "example.th",
// "width": 160,
// "height": 160,
// "ratio": 1,
// "size": 17848,
// "size_formatted": "17.4 KB",
// "mime": "image/png",
// "extension": "png",
// "bits": 8,
// "channels": null,
// "url": "http://freeimage.host/images/2014/06/04/example.th.png"
// },
// "medium": {
// "filename": "example.md.png",
// "name": "example.md",
// "width": 500,
// "height": 390,
// "ratio": 1.2820512820513,
// "size": 104448,
// "size_formatted": "102 KB",
// "mime": "image/png",
// "extension": "png",
// "bits": 8,
// "channels": null,
// "url": "http://freeimage.host/images/2014/06/04/example.md.png"
// },
// "views_label": "views",
// "display_url": "http://freeimage.host/images/2014/06/04/example.md.png",
// "how_long_ago": "moments ago"
// },
// "status_txt": "OK"
// }
// }

//failure
// {
// "status_code": 400,
// "error": {
// "message": "Empty upload source.",
// "code": 130,
// "context": "Exception"
// },
// "status_txt": "Bad Request"
// }
