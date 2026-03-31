import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadBytes(
    Uint8List bytes,
    String folder, {
    String? fileName,
    String contentType = 'image/jpeg',
  }) async {
    final name = fileName ?? '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('$folder$name');
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(bytes, metadata);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFromUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
