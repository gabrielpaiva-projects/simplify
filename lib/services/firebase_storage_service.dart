import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  /// Faz upload de uma foto de perfil para o Firebase Storage
  /// Retorna a URL pública da imagem
  static Future<String?> uploadProfilePhoto({
    required File photo,
    required String userId,
  }) async {
    try {
      // Gera um nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(photo.path);
      final fileName = 'profile_${userId}_$timestamp$extension';
      
      // Define o caminho no Storage
      final storageRef = _storage.ref().child('profile_photos/$userId/$fileName');
      
      // Configura metadados
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Faz o upload
      final uploadTask = storageRef.putFile(photo, metadata);
      
      // Monitora o progresso (opcional - pode ser usado para mostrar uma barra de progresso)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      // Aguarda o upload completar
      final snapshot = await uploadTask;
      
      // Obtém a URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Upload completed. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }
  
  /// Faz upload de um documento (comprovante de residência) para o Firebase Storage
  /// Retorna a URL pública do documento
  static Future<String?> uploadDocument({
    required File document,
    required String userId,
    required String documentType,
  }) async {
    try {
      // Gera um nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(document.path);
      final fileName = '${documentType}_${userId}_$timestamp$extension';
      
      // Define o caminho no Storage
      final storageRef = _storage.ref().child('documents/$userId/$fileName');
      
      // Configura metadados
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'userId': userId,
          'documentType': documentType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Faz o upload
      final uploadTask = storageRef.putFile(document, metadata);
      
      // Aguarda o upload completar
      final snapshot = await uploadTask;
      
      // Obtém a URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Document upload completed. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }
  
  /// Deleta uma foto de perfil do Firebase Storage
  static Future<bool> deleteProfilePhoto(String photoUrl) async {
    try {
      // Extrai o path do Storage a partir da URL
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      print('Profile photo deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting profile photo: $e');
      return false;
    }
  }
  
  /// Deleta todos os arquivos de um usuário
  static Future<bool> deleteUserFiles(String userId) async {
    try {
      // Deleta fotos de perfil
      final profilePhotosRef = _storage.ref().child('profile_photos/$userId');
      final profilePhotosList = await profilePhotosRef.listAll();
      
      for (final item in profilePhotosList.items) {
        await item.delete();
      }
      
      // Deleta documentos
      final documentsRef = _storage.ref().child('documents/$userId');
      final documentsList = await documentsRef.listAll();
      
      for (final item in documentsList.items) {
        await item.delete();
      }
      
      print('All user files deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting user files: $e');
      return false;
    }
  }
  
  /// Obtém o tipo de conteúdo baseado na extensão do arquivo
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// Comprime uma imagem antes do upload (opcional)
  /// Pode ser usado para reduzir o tamanho do arquivo
  static Future<File?> compressImage(File imageFile) async {
    // Implementação de compressão pode ser adicionada aqui
    // usando packages como image ou flutter_image_compress
    // Por enquanto, retorna o arquivo original
    return imageFile;
  }
}