part of 'image_upload_cubit.dart';

class ImageUploadState extends Equatable {
  final List<String>? imageUrl;
  final bool? uploading;
  final String? errorMessage;

  const ImageUploadState({this.imageUrl, this.uploading, this.errorMessage});

  ImageUploadState copyWith(
          {List<String>? imageUrl, bool? uploading, String? errorMessage}) =>
      ImageUploadState(
        imageUrl: imageUrl ?? this.imageUrl,
        uploading: uploading ?? this.uploading,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [imageUrl, uploading, errorMessage];
}
