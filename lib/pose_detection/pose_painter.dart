import "package:flutter/material.dart";

import "package:camera/camera.dart";

import "package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart";

import "coordinates_translator.dart";

class PosePainter extends CustomPainter {
    PosePainter(
        this.poses,
        this.imageSize,
        this.rotation,
        this.cameraLensDirection
    );

    final List<Pose> poses;
    final Size imageSize;
    final InputImageRotation rotation;
    final CameraLensDirection cameraLensDirection;

    final unwantedPoints = {
        PoseLandmarkType.nose,
        PoseLandmarkType.leftEyeInner,
        PoseLandmarkType.leftEye,
        PoseLandmarkType.leftEyeOuter,
        PoseLandmarkType.rightEyeInner,
        PoseLandmarkType.rightEye,
        PoseLandmarkType.rightEyeOuter,
        PoseLandmarkType.leftEar,
        PoseLandmarkType.rightEar,
        PoseLandmarkType.leftMouth,
        PoseLandmarkType.rightMouth,
        PoseLandmarkType.leftPinky,
        PoseLandmarkType.rightPinky,
        PoseLandmarkType.leftIndex,
        PoseLandmarkType.rightIndex,
        PoseLandmarkType.leftThumb,
        PoseLandmarkType.rightThumb,
        PoseLandmarkType.leftHeel,
        PoseLandmarkType.rightHeel,
        PoseLandmarkType.leftFootIndex,
        PoseLandmarkType.rightFootIndex
    };

    @override
    void paint( Canvas canvas, Size size ) {
        final paint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.0
            ..color = Colors.red;

        for( final pose in poses ) {
            pose.landmarks.forEach( (_, landmark ) {

                if( unwantedPoints.contains(landmark.type) ) return;

                canvas.drawCircle(
                    Offset(
                        translateX(
                            landmark.x,
                            size,
                            imageSize,
                            rotation,
                            cameraLensDirection
                        ),
                        translateY(
                            landmark.y,
                            size,
                            imageSize,
                            rotation,
                            cameraLensDirection
                        )
                    ),
                    1,
                    paint
                );
            });

            void paintLine( PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType ) {
                final PoseLandmark joint1 = pose.landmarks[type1]!;
                final PoseLandmark joint2 = pose.landmarks[type2]!;

                canvas.drawLine(
                    Offset(
                        translateX(
                            joint1.x,
                            size,
                            imageSize,
                            rotation,
                            cameraLensDirection
                        ),
                        translateY(
                            joint1.y,
                            size,
                            imageSize,
                            rotation,
                            cameraLensDirection
                        )
                    ),
                    Offset(
                        translateX(
                            joint2.x,
                            size,
                            imageSize,
                            rotation,
                            cameraLensDirection
                        ),
                        translateY(
                            joint2.y,
                            size,
                            imageSize,
                            rotation,
                            cameraLensDirection
                        )
                    ),
                    paintType
                );
            }

            // draw arms
            paintLine( PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, paint );
            paintLine( PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paint );
            paintLine( PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, paint );
            paintLine( PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paint );

            // draw body
            paintLine( PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint );
            paintLine( PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint );
            paintLine( PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint );
            paintLine( PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint );

            // draw legs
            paintLine( PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paint );
            paintLine( PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paint );
            paintLine( PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paint );
            paintLine( PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paint );
        }
    }

    @override
    bool shouldRepaint( covariant PosePainter oldDelegate ) {
        return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
    }
}