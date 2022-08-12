import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/repository/image_upload_repository.dart';

part 'image_upload_state.dart';

class ImageUploadCubit extends Cubit<ImageUploadState> {
  ImageUploadRepository imageUploadRepository;

  ImageUploadCubit({required this.imageUploadRepository})
      : super(const ImageUploadState());

  void uploadImage(List<XFile> imageFileList) async {
    emit(const ImageUploadState(uploading: true));
    List<String>? uploadedImageList = [];
    await Future.forEach(imageFileList, (XFile imageFile) async {
      await imageUploadRepository
          .getImageUrl(File(imageFile.path))
          .then((imageUrl) {
        uploadedImageList.add(imageUrl);
        emit(ImageUploadState(imageUrl: uploadedImageList));
      }) //обработка ошибки
          //можно через test поймать нужный тип и выбросить стейт в UI
          .catchError((Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          print(error.toString());
          print(stackTrace);
        }
        emit(const ImageUploadState(errorMessage: 'Неизвестная ошибка'));
      });
      emit(state.copyWith(uploading: false));
    });
  }

  void clearImages() {
    emit(const ImageUploadState(imageUrl: null));
  }
}

//альтернатива
// void uploadImage(List<XFile> imageFileList) async {
//   emit(const ImageUploadState(uploading: true));
//   List<String?>? uploadedImageList = [];
//   await Future.forEach(imageFileList, (XFile imageFile) async {
//     String imageUrl =
//         await imageUploadRepository.getImageUrl(File(imageFile.path));
//     uploadedImageList.add(imageUrl);
//     emit(ImageUploadState(imageUrl: uploadedImageList));
//   });
//   emit(state.copyWith(uploading: false));
// }
