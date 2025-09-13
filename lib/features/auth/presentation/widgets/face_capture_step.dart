import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';

class FaceCaptureStep extends StatefulWidget {
  final AnimationController animationController;
  final GlobalKey<FormState> formKey;
  final Function(File?) onPhotoChanged;
  final File? initialPhoto;

  const FaceCaptureStep({
    super.key,
    required this.animationController,
    required this.formKey,
    required this.onPhotoChanged,
    this.initialPhoto,
  });

  @override
  State<FaceCaptureStep> createState() => _FaceCaptureStepState();
}

class _FaceCaptureStepState extends State<FaceCaptureStep> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  File? _capturedPhoto;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isFrontCamera = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _capturedPhoto = widget.initialPhoto;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera disponível';
          _isInitializing = false;
        });
        return;
      }

      // Procura pela câmera frontal
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao inicializar câmera: $e';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });

    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == 
        (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _cameras!.first,
    );

    final oldController = _cameraController;
    
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao trocar câmera: $e';
      });
    }

    await oldController?.dispose();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File photoFile = File(photo.path);
      
      setState(() {
        _capturedPhoto = photoFile;
        _isCapturing = false;
      });
      
      widget.onPhotoChanged(photoFile);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao capturar foto: $e';
        _isCapturing = false;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
    widget.onPhotoChanged(null);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (widget.animationController.value * 0.1),
          child: Opacity(
            opacity: widget.animationController.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Title
                    const Text(
                      'Foto do Rosto',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      'Tire uma foto do seu rosto para o seu perfil profissional',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Importante',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Esta foto será exibida para os clientes no seu perfil profissional. Certifique-se de estar em um ambiente bem iluminado.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Camera or captured photo
                    _buildCameraSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Instructions
                    if (_capturedPhoto == null && !_isInitializing && _errorMessage == null)
                      _buildInstructions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraSection() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_isInitializing) {
      return _buildLoadingWidget();
    }

    if (_capturedPhoto != null) {
      return _buildCapturedPhotoWidget();
    }

    return _buildCameraPreview();
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeCamera,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
            const SizedBox(height: 16),
            Text(
              'Inicializando câmera...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedPhotoWidget() {
    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _capturedPhoto!,
                  fit: BoxFit.cover,
                ),
                // Success overlay
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retakePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tirar Nova Foto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Photo is already saved via callback
                },
                icon: const Icon(Icons.check),
                label: const Text('Usar Esta Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildLoadingWidget();
    }

    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera preview
                CameraPreview(_cameraController!),
                
                // Face guide overlay
                CustomPaint(
                  painter: FaceGuidePainter(),
                ),
                
                // Camera switch button
                if (_cameras != null && _cameras!.length > 1)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      onPressed: _switchCamera,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                
                // Capture button
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isCapturing ? null : _capturePhoto,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 4,
                          ),
                        ),
                        child: _isCapturing
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryGreen,
                                  ),
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: AppColors.primaryGreen,
                                size: 32,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        // Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dicas para uma boa foto:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTip('Posicione seu rosto dentro do círculo'),
              _buildTip('Mantenha uma expressão neutra e profissional'),
              _buildTip('Certifique-se de que o ambiente está bem iluminado'),
              _buildTip('Evite usar óculos escuros ou acessórios que cubram o rosto'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for face guide overlay
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2 - 20);
    final radius = size.width * 0.35;

    // Draw oval for face guide
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 1.5,
      height: radius * 2,
    );
    
    canvas.drawOval(rect, paint);

    // Draw corner markers
    final markerPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const markerLength = 30.0;
    
    // Top-left
    canvas.drawLine(
      Offset(rect.left - 10, rect.top),
      Offset(rect.left - 10 + markerLength, rect.top),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.left - 10, rect.top),
      Offset(rect.left - 10, rect.top + markerLength),
      markerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right + 10 - markerLength, rect.top),
      Offset(rect.right + 10, rect.top),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.right + 10, rect.top),
      Offset(rect.right + 10, rect.top + markerLength),
      markerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left - 10, rect.bottom - markerLength),
      Offset(rect.left - 10, rect.bottom),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.left - 10, rect.bottom),
      Offset(rect.left - 10 + markerLength, rect.bottom),
      markerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right + 10, rect.bottom - markerLength),
      Offset(rect.right + 10, rect.bottom),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.right + 10 - markerLength, rect.bottom),
      Offset(rect.right + 10, rect.bottom),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}