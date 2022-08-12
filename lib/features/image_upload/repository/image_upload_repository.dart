import 'dart:io';

import 'package:surf_practice_chat_flutter/features/image_upload/datasource/image_upload_data_source.dart';

/// Интерфейс репозитория для загрузки изображений
abstract class ImageUploadRepository {
  Future<String> getImageUrl(File imageFile);
}

//Реализация интерфеса для загрузки изображений
class ImageUploadRepositoryImpl implements ImageUploadRepository {
  ImageUploadDataSource imageUploadDataSource;

  ImageUploadRepositoryImpl({required this.imageUploadDataSource});

  @override
  Future<String> getImageUrl(File imageFile) async {
    final String imageUrl = await imageUploadDataSource.uploadImage(imageFile);
    return imageUrl;
  }
}
