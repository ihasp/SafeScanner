import 'package:mobile_scanner/mobile_scanner.dart';

import '../../settings/models/app_settings.dart';

class CameraService {
  MobileScannerController createController({
    required AppCameraFacing cameraFacing,
  }) {
    return MobileScannerController(
      facing: cameraFacing == AppCameraFacing.front
          ? CameraFacing.front
          : CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }
}
