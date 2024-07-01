import "dart:async";
import "dart:io";

import "package:flutter/material.dart";

import "package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart";

import "package:camera/camera.dart";
import "package:gal/gal.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:video_player/video_player.dart";

import "pose_detection/pose_painter.dart";

class CameraPage extends StatefulWidget {
	const CameraPage({
        super.key,
        required this.cameras,
        required this.settings
    });

    final List<CameraDescription> cameras;
    final SharedPreferences settings;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
    late int prevCam;
    late CameraController _cameraController;
    late Future<void> _initalizeControllerFuture;

    VideoPlayerController? videoController;
    Future<void>? initializeVideoPlayerFuture;

    final imagePicker = ImagePicker();

    bool isRecording = false;

    PoseDetector? poseDetector;
    bool _canProcess = true;
    bool _isBusy = false;
    CustomPaint? _customPaint;
    String? _text;
    late CameraLensDirection cameraLensDirection;

    void initPoseDetector() {
        poseDetector = PoseDetector(
            options: PoseDetectorOptions(
                model: widget.settings.getBool( "hyperAccuracy" ) ?? false ? PoseDetectionModel.accurate : PoseDetectionModel.base,
            )
        );
    }

    Future<void> _processImage( InputImage inputImage ) async {
        if( !_canProcess ) return;
        if( _isBusy ) return;
        _isBusy = true;
        setState(() {
            _text = '';
        });
        final poses = await poseDetector!.processImage(inputImage);
        if( inputImage.metadata?.size != null && inputImage.metadata?.rotation != null ) {
            final painter = PosePainter(
                poses,
                inputImage.metadata!.size,
                inputImage.metadata!.rotation,
                cameraLensDirection
            );
            _customPaint = CustomPaint( painter: painter );
        } else {
            _text = "Poses found: ${poses.length}\n\n";
            _customPaint = null;
        }
        _isBusy = false;
        if( mounted ) {
            setState(() {});
        }
    }

    void initCamera() {
        prevCam = widget.settings.getInt( "prevCam" ) ?? 0;

        _cameraController = CameraController(
            widget.cameras[ prevCam ],
            ResolutionPreset.values[ widget.settings.getInt( "resolutionPreset" ) ?? 0 ]
        );

        _initalizeControllerFuture = _cameraController.initialize();

        cameraLensDirection = _cameraController.description.lensDirection;
    }

    void initDancePreview( XFile source, bool fromCamera ) async {
        videoController = VideoPlayerController.file( File(source.path) );
        initializeVideoPlayerFuture = videoController!.initialize();

        await videoController!.setLooping(true);
        await videoController!.play();

        if( !mounted ) return;

        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => FutureBuilder(
                    future: initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                        if( snapshot.connectionState == ConnectionState.done ) {

                            return DancePreview(
                                fromCamera: fromCamera,
                                source: source,
                                settings: widget.settings,
                                videoController: videoController!
                            );

                        } else {
                            return const Center( child: CircularProgressIndicator.adaptive() );
                        }
                    }
                )
            )
        );
    }

    @override
    void initState() {
        super.initState();

        initPoseDetector();
        initCamera();
    }

    @override
    void dispose() {
        _cameraController.dispose();
        videoController?.dispose();
        poseDetector?.close();

        super.dispose();
    }

	@override
	Widget build(BuildContext context) {

		return Scaffold(
            body: Stack(
                children: [
                    Center(
                        child: FutureBuilder<void>(
                            future: _initalizeControllerFuture,
                            builder: (context, snapshot) {
                                return snapshot.connectionState == ConnectionState.done ?
                                CameraPreview(_cameraController) :
                                const Center( child: CircularProgressIndicator.adaptive() );
                            }
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () async {
                                    if( isRecording ) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text( "Gallery locked while recording" ),
                                                behavior: SnackBarBehavior.floating
                                            )
                                        );
                                    } else {
                                        try {
                                            final galleryVideo = await imagePicker.pickVideo(source: ImageSource.gallery);

                                            if( galleryVideo != null ) initDancePreview( galleryVideo, false );
                                        } catch (e) {
                                            // HANDLE ERROR
                                        }
                                    }
                                },
                                child: const Icon( Icons.photo )
                            )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () async {
                                    try {
                                        if( isRecording ) {
                                            setState( () => isRecording = false );
                            
                                            final recording = await _cameraController.stopVideoRecording();

                                            initDancePreview( recording, true );
                                        } else {
                                            setState( () => isRecording = true );
                            
                                            await _cameraController.prepareForVideoRecording();
                                            _cameraController.startVideoRecording();
                                        }
                                    } catch (e) {
                                        // HANDLE ERROR
                                    }
                                },
                                child: Icon( isRecording ? Icons.check : Icons.videocam )
                            )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () async {
                                    if( isRecording ) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text( "Flipping locked while recording" ),
                                                behavior: SnackBarBehavior.floating
                                            )
                                        );
                                    } else {
                                        try {
                                            await _cameraController.dispose();
                                            setState( () => prevCam = 1 - prevCam );
                                            widget.settings.setInt( "prevCam", prevCam );
                                            initCamera();
                                            setState( () => cameraLensDirection = _cameraController.description.lensDirection );
                                        } catch (e) {
                                            // HANDLE ERROR
                                        }
                                    }
                                },
                                child: Icon( Platform.isIOS ? Icons.flip_camera_ios : Icons.flip_camera_android )
                            )
                        )
                    )
                ] 
            )
        );
	}
}

class DancePreview extends StatefulWidget {
    const DancePreview({
        super.key,
        required this.fromCamera,
        required this.source,
        required this.settings,
        required this.videoController
    });

    final bool fromCamera;
    final XFile source;
    final SharedPreferences settings; 
    final VideoPlayerController videoController;

    @override
    State<DancePreview> createState() => _DancePreviewState();
}

class _DancePreviewState extends State<DancePreview> with TickerProviderStateMixin {

    late AnimationController linearProgressController;

    late bool enableTracking;

    @override
    void initState() {
        super.initState();

        enableTracking = widget.settings.getBool( "enableTracking" ) ?? true;

        linearProgressController = AnimationController(
            vsync: this,
            duration: widget.videoController.value.duration
        )..addListener( () {
            setState(() {});
        });
        linearProgressController.repeat();
    }

    @override
    void dispose() {
        linearProgressController.dispose();
        widget.videoController.dispose();

        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text( "Your Dance" )
            ),
            body: Stack(
                children: [
                    Center(
                        child: AspectRatio(
                            aspectRatio: widget.videoController.value.aspectRatio,
                            child: VideoPlayer( widget.videoController )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                            value: linearProgressController.value
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () {
                                    setState( () => enableTracking = !enableTracking );
                                    widget.settings.setBool( "enableTracking", enableTracking );
                                },
                                child: Icon( enableTracking ? Icons.visibility : Icons.visibility_off )
                            )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () {
                                    setState(() {
                                        if( widget.videoController.value.isPlaying ) {
                                            widget.videoController.pause();
                                            linearProgressController.stop();
                                        } else {
                                            widget.videoController.play();
                                            linearProgressController
                                                ..forward( from: linearProgressController.value )
                                                ..repeat();
                                        }
                                    });
                                },
                                child: Icon( widget.videoController.value.isPlaying ? Icons.pause : Icons.play_arrow ),
                            )
                        )
                    )
                ] 
            ),
            bottomNavigationBar: widget.fromCamera ? NavigationBar(
                onDestinationSelected: (value) async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text( value == 0 ? "Dance saved!" : "Dance discarded" ),
                            behavior: SnackBarBehavior.floating,
                        )
                    );

                    if( value == 0 ) {
                        final Directory tempDir = await getTemporaryDirectory();
                        final File newFile = File(widget.source.path).renameSync("${tempDir.path}/${DateTime.now()}.mp4");
                        await Gal.putVideo( newFile.path, album: "EyeDance" );
                    }
                },
                destinations: const [
                    NavigationDestination(
                        icon: Icon( Icons.download ),
                        label: "Save Dance"
                    ),
                    NavigationDestination(
                        icon: Icon( Icons.delete ),
                        label: "Discard"
                    )
                ]
            ) : NavigationBar(
                onDestinationSelected: (value) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text( value == 0 ? "Analyzing" : "Practice cancelled" ),
                            behavior: SnackBarBehavior.floating,
                        )
                    );
                },
                destinations: const [
                    NavigationDestination(
                        icon: Icon( Icons.timeline ),
                        label: "Analyze dance"
                    ),
                    NavigationDestination(
                        icon: Icon( Icons.refresh ),
                        label: "Choose another"
                    )
                ]
            )
        );
    }
}