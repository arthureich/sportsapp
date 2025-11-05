import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String folderPath) async {
    try {
      final String fileExtension = p.extension(imageFile.path);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      final Reference ref = _storage.ref('$folderPath/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;

    } catch (e) {
      if (kDebugMode) {
        print("Erro no upload da imagem: $e");
      }
      rethrow;
    }
  }
}