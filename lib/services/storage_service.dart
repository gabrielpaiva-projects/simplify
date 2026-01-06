import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadProfileImage(File imageFile, {String? userId}) async {
    try {
      String? targetUserId = userId;
      if (targetUserId == null) {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Usuário não autenticado e userId não fornecido');
        }
        targetUserId = currentUser.uid;
      }

      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      final String fileName = 'profile_image_${targetUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child(fileName);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': targetUserId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'profile_image',
        },
      );

      print('Iniciando upload da imagem: ${imageFile.path}');
      print('Tamanho do arquivo: ${await imageFile.length()} bytes');

      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Upload concluído com sucesso. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Erro detalhado ao fazer upload da imagem: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  static Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Erro ao deletar imagem: $e');
      return false;
    }
  }

  static Future<String?> uploadAddressProof(File file, {String? userId}) async {
    try {
      String? targetUserId = userId;
      if (targetUserId == null) {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Usuário não autenticado e userId não fornecido');
        }
        targetUserId = currentUser.uid;
      }

      if (!await file.exists()) {
        throw Exception('Arquivo de comprovante não encontrado');
      }

      final String extension = file.path.split('.').last.toLowerCase();
      final String fileName = 'address_proof_${targetUserId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      final Reference storageRef = _storage
          .ref()
          .child('address_proofs')
          .child(fileName);

      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'userId': targetUserId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'address_proof',
        },
      );

      print('Iniciando upload do comprovante: ${file.path}');
      print('Tamanho do arquivo: ${await file.length()} bytes');

      final UploadTask uploadTask = storageRef.putFile(file, metadata);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress (comprovante): ${(progress * 100).toStringAsFixed(2)}%');
      });
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Upload do comprovante concluído com sucesso. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Erro detalhado ao fazer upload do comprovante: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
