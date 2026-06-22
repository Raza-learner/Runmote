import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_image_data.freezed.dart';
part 'chat_image_data.g.dart';

@freezed
class ChatImageData with _$ChatImageData {
  const factory ChatImageData({
    required String base64,
    @Default('image/jpeg') String mimeType,
  }) = _ChatImageData;

  factory ChatImageData.fromJson(Map<String, dynamic> json) =>
      _$ChatImageDataFromJson(json);
}
