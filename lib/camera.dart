import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:camera/camera.dart';
import 'package:rakhsa/features/chatV2/presentation/provider/camera.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/location.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';


import 'package:rakhsa/websockets.dart';
import 'package:video_compress/video_compress.dart';

import 'common/constants/remote_data_source_consts.dart';

class CameraPage extends StatefulWidget {
  final String location;
  final String country;
  final String lat;
  final String lng;
  
  const CameraPage({
    required this.location,
    required this.country,
    required this.lat,
    required this.lng,
    super.key
  });

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  late WebSocketsService webSocketsService;
  late UploadMediaNotifier uploadMediaNotifier;
  late CameraProvider cameraProvider;

  bool loading = false;

  bool isRecording = false;
  bool isVideoMode = false;  

  int recordTimeLeft = 10; 

  @override
  void initState() {
    super.initState();

    webSocketsService = context.read<WebSocketsService>();
    uploadMediaNotifier = context.read<UploadMediaNotifier>();
    cameraProvider = context.read<CameraProvider>();

    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    
    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(cameras![0], ResolutionPreset.high);
      await controller!.initialize();

      startVideoRecording();
      setState(() {});
    }
  }

  void toggleMode() {
    setState(() => isVideoMode = !isVideoMode);
  }

  Future<void> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      final image = await controller!.takePicture();
      File file = File(image.path);

      setState(() => loading = true);

      final fileName = file.path.split('/').last;
      var formData = FormData.fromMap({
        'files': [
          await MultipartFile.fromFile(file.path,
                filename: fileName,)
        ],
        'folder': 'AMULET-SOS',
        'app': 'AMULET'
      });
      final res = await locator<Dio>().request('${RemoteDataSourceConsts.uploadMedia}/api/v1/media',
        data: formData,
        options: Options(
          method: 'PUT',
        ),
      );
      debugPrint("PROG :  ${res.data}");
      Map<String, dynamic> data = res.data;
  
      setState(() => loading = false);

      final position = await determinePosition();

      await cameraProvider.createTicket(
        description: "Butuh pertolongan",
        media_link: data["data"][0]["url"],
        media_type: data["data"][0]["type"],
        latitude: position.latitude.toString(), 
        longitude: position.longitude.toString(),
      );
      
      if(mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> startVideoRecording() async {
    if (controller == null || isRecording) return;

    try {
      await controller!.startVideoRecording();

      setState(() {
        isRecording = true;
        recordTimeLeft = 10;
      });

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (recordTimeLeft == 0) {
          stopVideoRecording();
          timer.cancel();
        } else {
          setState(() {
            recordTimeLeft--;
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> stopVideoRecording() async {
    if (controller == null || !isRecording) return;

    try {
      XFile video = await controller!.stopVideoRecording();
      File file = File(video.path);

      setState(() => loading = true);
      print("Video : ${file.path}");


      final fileName = file.path.split('/').last;
      var formData = FormData.fromMap({
        'files': [
          await MultipartFile.fromFile(file.path, filename: fileName,)
        ],
        'folder': 'AMULET-SOS',
        'app': 'AMULET'
      });
      final res = await locator<Dio>().request('${RemoteDataSourceConsts.uploadMedia}/api/v1/media',
        data: formData,
        options: Options(
          method: 'PUT',
        ),
      );
      debugPrint("PROG :  ${res.data}");
      Map<String, dynamic> data = res.data;
  
      setState(() => loading = false);

      final position = await determinePosition();

      await cameraProvider.createTicket(
        description: "Butuh pertolongan",
        media_link: data["data"][0]["url"],
        media_type: data["data"][0]["type"],
        latitude: position.latitude.toString(), 
        longitude: position.longitude.toString(),
      );

      if(mounted) {
        Navigator.pop(context);
      }

      setState(() => isRecording = false);
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: ColorResources.white,
          borderRadius: BorderRadius.circular(50.0)
        ),
        child: const CircularProgressIndicator()
      ),
      child: Scaffold(
        body: controller == null || !controller!.value.isInitialized
        ? const Center(
            child: CircularProgressIndicator()
          )
        : Stack(
            clipBehavior: Clip.none,
            children: [
      
            CameraPreview(controller!),
      
            Positioned(
              bottom: 20,
              left: 0.0,
              right: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
      
                  // isVideoMode 
                  // ? IconButton(
                  //     icon: Icon(
                  //     isRecording 
                  //     ? Icons.stop 
                  //     : Icons.fiber_manual_record,
                  //       color: Colors.red,
                  //       size: 30,
                  //     ),
                  //     onPressed: isVideoMode
                  //     ? (isRecording ? stopVideoRecording : startVideoRecording)
                  //     : null,
                  //   ) 
                  // : 

                  // isRecording 
                  // ? const SizedBox() 
                  // : IconButton(
                  //     icon: const Icon(
                  //       Icons.camera_alt,
                  //       color: Colors.white,
                  //       size: 28,
                  //     ),
                  //     onPressed: takePicture,
                  //   ),

                  // const SizedBox(width: 20.0),

                  IconButton(
                    icon: const Icon(Icons.videocam,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: (isRecording ? stopVideoRecording : startVideoRecording),
                  ),
      
                  if (isRecording)
                    Text('$recordTimeLeft s',
                      style: robotoRegular.copyWith(
                        color: Colors.white, 
                        fontSize: Dimensions.fontSizeLarge
                      ),
                    ),

                ],
              ),
            ),
      
            // Positioned(
            //   top: 50,
            //   right: 20,
            //   child: IconButton(
            //     icon: Icon(
            //       isVideoMode ? Icons.camera : Icons.videocam,
            //       color: Colors.white,
            //       size: 30,
            //     ),
            //     onPressed: toggleMode,
            //   ),
            // ),
      
            // Positioned(
            //   top: 50,
            //   left: 20,
            //   child: Text(
            //     isVideoMode ? "Video Mode" : "Photo Mode",
            //     style: robotoRegular.copyWith(
            //       color: Colors.white,
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
      
          ],
        ),
      ),
    );
  }
}
