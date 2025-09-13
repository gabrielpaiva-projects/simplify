import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  static final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: false,
    ),
  );

  /// Valida se a imagem contém pelo menos um rosto detectável
  /// Retorna true se encontrar um rosto válido, false caso contrário
  static Future<FaceValidationResult> validateFaceInImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return FaceValidationResult(
          isValid: false,
          message: 'Nenhum rosto foi detectado na imagem. Por favor, tire uma nova foto com seu rosto bem visível.',
        );
      }

      if (faces.length > 1) {
        return FaceValidationResult(
          isValid: false,
          message: 'Múltiplos rostos detectados. Por favor, tire uma foto apenas com seu rosto.',
        );
      }

      final face = faces.first;
      
      // Verificações adicionais de qualidade
      final boundingBox = face.boundingBox;
      
      // Verificar se o rosto não é muito pequeno (menos de 100x100 pixels)
      if (boundingBox.width < 100 || boundingBox.height < 100) {
        return FaceValidationResult(
          isValid: false,
          message: 'Rosto muito pequeno na imagem. Por favor, aproxime-se mais da câmera.',
        );
      }

      // Verificar se há landmarks faciais básicos detectados
      if (face.landmarks.isEmpty) {
        return FaceValidationResult(
          isValid: false,
          message: 'Não foi possível detectar características faciais claramente. Certifique-se de que seu rosto está bem iluminado.',
        );
      }

      // Verificar probabilidade de sorriso e olhos abertos (se disponível)
      double? leftEyeOpenProbability = face.leftEyeOpenProbability;
      double? rightEyeOpenProbability = face.rightEyeOpenProbability;

      if (leftEyeOpenProbability != null && rightEyeOpenProbability != null) {
        if (leftEyeOpenProbability < 0.1 || rightEyeOpenProbability < 0.1) {
          return FaceValidationResult(
            isValid: false,
            message: 'Por favor, mantenha os olhos abertos para uma melhor detecção.',
          );
        }
      }

      return FaceValidationResult(
        isValid: true,
        message: 'Rosto detectado com sucesso!',
        detectedFace: face,
      );

    } catch (e) {
      return FaceValidationResult(
        isValid: false,
        message: 'Erro ao processar a imagem: ${e.toString()}',
      );
    }
  }

  /// Libera os recursos do detector de faces
  static void dispose() {
    _faceDetector.close();
  }
}

/// Resultado da validação de rosto
class FaceValidationResult {
  final bool isValid;
  final String message;
  final Face? detectedFace;

  FaceValidationResult({
    required this.isValid,
    required this.message,
    this.detectedFace,
  });
}