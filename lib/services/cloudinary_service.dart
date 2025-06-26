import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const _cloudName = 'dskf6wstr';
  static const _uploadPreset = 'tixly_unsigned';

  final _api = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String> uploadImage(String filePath) async{
   final res = await _api.uploadFile(
     CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Image),
   );
   return res.secureUrl;
  }
}