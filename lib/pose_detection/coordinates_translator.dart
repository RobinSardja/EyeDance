import "dart:io";
import "dart:ui";

import "package:camera/camera.dart";
import "package:google_mlkit_commons/google_mlkit_commons.dart";

double translateX(
    double x,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection
) {
    double divisor = Platform.isIOS ? imageSize.width : imageSize.height;

    switch( rotation ) {
        case InputImageRotation.rotation90deg:
            return x * canvasSize.width / divisor;

        case InputImageRotation.rotation270deg:
            return canvasSize.width - x * canvasSize.width / divisor;

        case InputImageRotation.rotation0deg:
        case InputImageRotation.rotation180deg:
            switch( cameraLensDirection ) {
                case CameraLensDirection.back:
                    return x * canvasSize.width / imageSize.width;

                default:
                    return canvasSize.width - x * canvasSize.width / imageSize.width;
            }
    }
}

double translateY(
    double y,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection
 ) {
    double divisor = Platform.isIOS ? imageSize.height : imageSize.width;

    switch( rotation ) {
        case InputImageRotation.rotation90deg:
        case InputImageRotation.rotation270deg:
            return y * canvasSize.height / divisor;
            
        case InputImageRotation.rotation0deg:
        case InputImageRotation.rotation180deg:
            return y * canvasSize.height / imageSize.height;
    }
 }