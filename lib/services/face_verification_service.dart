import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceVerificationService {
  static final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// Verifica se a imagem contém um rosto válido
  /// Retorna um FaceVerificationResult com o status da verificação
  static Future<FaceVerificationResult> verifyFace(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return FaceVerificationResult(
          isValid: false,
          message: 'Nenhum rosto detectado na imagem. Por favor, tire outra foto.',
        );
      }

      if (faces.length > 1) {
        return FaceVerificationResult(
          isValid: false,
          message: 'Múltiplos rostos detectados. Por favor, certifique-se de que apenas você está na foto.',
        );
      }

      final face = faces.first;

      // Verificações de qualidade
      final qualityChecks = await _performQualityChecks(face);
      
      if (!qualityChecks.isValid) {
        return qualityChecks;
      }

      // Verificação de pose (rosto de frente)
      final poseChecks = _checkFacePose(face);
      
      if (!poseChecks.isValid) {
        return poseChecks;
      }

      // Verificação de tamanho do rosto
      final sizeCheck = _checkFaceSize(face, inputImage);
      
      if (!sizeCheck.isValid) {
        return sizeCheck;
      }

      return FaceVerificationResult(
        isValid: true,
        message: 'Foto verificada com sucesso!',
        confidence: _calculateConfidence(face),
      );
    } catch (e) {
      return FaceVerificationResult(
        isValid: false,
        message: 'Erro ao verificar a foto: $e',
      );
    }
  }

  static Future<FaceVerificationResult> _performQualityChecks(Face face) async {
    // Verifica se os olhos estão abertos
    if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
      final leftEyeOpen = face.leftEyeOpenProbability! > 0.5;
      final rightEyeOpen = face.rightEyeOpenProbability! > 0.5;
      
      if (!leftEyeOpen || !rightEyeOpen) {
        return FaceVerificationResult(
          isValid: false,
          message: 'Por favor, mantenha os olhos abertos na foto.',
        );
      }
    }

    // Verifica se está sorrindo demais (queremos uma expressão neutra/profissional)
    if (face.smilingProbability != null && face.smilingProbability! > 0.8) {
      return FaceVerificationResult(
        isValid: false,
        message: 'Por favor, mantenha uma expressão neutra e profissional.',
      );
    }

    return FaceVerificationResult(isValid: true, message: '');
  }

  static FaceVerificationResult _checkFacePose(Face face) {
    // Verifica rotação da cabeça
    if (face.headEulerAngleY != null) {
      final yAngle = face.headEulerAngleY!;
      
      // Verifica se o rosto está muito de lado (tolerância de 30 graus)
      if (yAngle.abs() > 30) {
        return FaceVerificationResult(
          isValid: false,
          message: 'Por favor, posicione seu rosto de frente para a câmera.',
        );
      }
    }

    if (face.headEulerAngleZ != null) {
      final zAngle = face.headEulerAngleZ!;
      
      // Verifica se a cabeça está muito inclinada (tolerância de 20 graus)
      if (zAngle.abs() > 20) {
        return FaceVerificationResult(
          isValid: false,
          message: 'Por favor, mantenha sua cabeça reta.',
        );
      }
    }

    if (face.headEulerAngleX != null) {
      final xAngle = face.headEulerAngleX!;
      
      // Verifica se a cabeça está muito para cima ou para baixo (tolerância de 25 graus)
      if (xAngle.abs() > 25) {
        return FaceVerificationResult(
          isValid: false,
          message: 'Por favor, olhe diretamente para a câmera.',
        );
      }
    }

    return FaceVerificationResult(isValid: true, message: '');
  }

  static FaceVerificationResult _checkFaceSize(Face face, InputImage image) {
    final boundingBox = face.boundingBox;
    
    // Calcula a proporção do rosto em relação à imagem
    final imageWidth = image.metadata?.size.width ?? 1;
    final imageHeight = image.metadata?.size.height ?? 1;
    
    final faceWidth = boundingBox.width;
    final faceHeight = boundingBox.height;
    
    final faceAreaRatio = (faceWidth * faceHeight) / (imageWidth * imageHeight);
    
    // O rosto deve ocupar entre 10% e 60% da imagem
    if (faceAreaRatio < 0.1) {
      return FaceVerificationResult(
        isValid: false,
        message: 'Por favor, aproxime-se mais da câmera.',
      );
    }
    
    if (faceAreaRatio > 0.6) {
      return FaceVerificationResult(
        isValid: false,
        message: 'Por favor, afaste-se um pouco da câmera.',
      );
    }

    return FaceVerificationResult(isValid: true, message: '');
  }

  static double _calculateConfidence(Face face) {
    double confidence = 0.5; // Base confidence
    
    // Adiciona confiança baseada em probabilidades
    if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
      final eyesOpen = (face.leftEyeOpenProbability! + face.rightEyeOpenProbability!) / 2;
      confidence += eyesOpen * 0.2;
    }
    
    // Reduz confiança se estiver sorrindo muito
    if (face.smilingProbability != null) {
      confidence += (1 - face.smilingProbability!) * 0.1;
    }
    
    // Adiciona confiança baseada na pose
    if (face.headEulerAngleY != null) {
      final yAngleScore = 1 - (face.headEulerAngleY!.abs() / 90);
      confidence += yAngleScore * 0.1;
    }
    
    if (face.headEulerAngleZ != null) {
      final zAngleScore = 1 - (face.headEulerAngleZ!.abs() / 90);
      confidence += zAngleScore * 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Libera recursos do detector
  static void dispose() {
    _faceDetector.close();
  }
}

class FaceVerificationResult {
  final bool isValid;
  final String message;
  final double? confidence;

  FaceVerificationResult({
    required this.isValid,
    required this.message,
    this.confidence,
  });

  @override
  String toString() {
    return 'FaceVerificationResult(isValid: $isValid, message: $message, confidence: $confidence)';
  }
}