import 'dart:io';

import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:echo_nlu/services/audio_service.dart';
import 'package:echo_nlu/services/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/enums/echo_type.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/image_picker_service.dart';
import '../../../services/permission_service.dart';
import 'create_echo_state.dart';



class CreateEchoController extends StateNotifier<CreateEchoState> {
  final ImagePickerService imagePickerService;
  final AudioNoteService audioNoteService;
  final LocationService locationService;
  final PermissionService permissionService;
  final EchoRepository echoRepository;
  final CloudinaryService cloudinary;

  CreateEchoController({
    required this.imagePickerService,
    required this.locationService,
    required this.echoRepository,
    required this.cloudinary,
    required this.audioNoteService,
    required this.permissionService,
  }) : super(const CreateEchoState());

  void updateIsAnonymous(bool isAnonymous) {
    state = state.copyWith(isAnonymous: isAnonymous);
  }

  void updateIsCapsule(bool isCapsule) {
    state = state.copyWith(isCapsule: isCapsule);
  }

  void updateScheduledTime(DateTime? scheduledTime) {
    state = state.copyWith(scheduledTime: scheduledTime);
  }

  void updateImageFiles({required List<File> files}) {
    state = state.copyWith(
      echoType: EchoType.image,
      imageFiles: [...state.imageFiles, ...files],
    );
  }

  void startAudioRecording() async {

    final permissionGranted = await permissionService.checkMicrophonePermission();
    if(!permissionGranted) {
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Quyền truy cập microphone bị từ chối. Vui lòng cấp quyền để ghi âm.");
      return;
    }
    // state = state.copyWith(audioFile: null,durationInSeconds: 0,clearAudio: true);
    await audioNoteService.startRecording();

  }

  void stopAudioRecording() async {
    final filePath = await audioNoteService.stopRecording();
    debugPrint('Audio recording stopped, file path: $filePath');
    if(filePath != null) {
      updateAudioFile(file: File(filePath));
    } else {
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Ghi âm thất bại. Vui lòng thử lại.");
    }
  }

  void pauseAudioPlayback() async {
    await audioNoteService.pausePlayback();
  }

  void resumeAudioPlayback() async {
    await audioNoteService.resumePlayback();
  }

  void playAudio() async {
    try {
      await audioNoteService.playAudio();

      debugPrint('Audio playback started');
    } catch (e) {
      debugPrint('Error playing audio: $e');
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Không thể phát âm thanh. Vui lòng thử lại.");
    }
  }

  void stopAudioPlayback() async {
    await audioNoteService.stopPlayback();
  }


  void updateAudioFile({required file}) {
    debugPrint('Updating audio file: ${file.path}, duration: ${audioNoteService.duration()} seconds');
    state = state.copyWith(echoType: EchoType.audio, audioFile: file,
    durationInSeconds: audioNoteService.duration()
    );
  }

  void pickImage() async {
    final images = await imagePickerService.pickMultipleImages();
    updateImageFiles(files: images);
  }

  void removeImage(int index) {
    final updatedFiles = List.of(state.imageFiles)..removeAt(index);
    state = state.copyWith(imageFiles: updatedFiles);
  }

  Future<void> getNearbyLocation() async {
    state = state.copyWith(
      nearbyLocationState: state.nearbyLocationState.copyWith(
        isLoading: true,
        errorMessage: null,
      ),
    );
    final locations = await locationService.getNearbyCampusLocations();

    debugPrint('Fetched nearby locations: ${locations.map((loc) => loc.name).toList()}');

    if (locations.isEmpty) {
      state = state.copyWith(
        nearbyLocationState: state.nearbyLocationState.copyWith(
          isLoading: false,
          locations: [],
        ),
      );
    } else {
      state = state.copyWith(
        nearbyLocationState: state.nearbyLocationState.copyWith(
          isLoading: false,
          locations: locations,
          selectedLocation: locations.first,
        ),
      );
    }
  }

  void createEcho({required String title,required String content,required EchoType echoType }) async {
    try{
      if(!validCreateEchoInput(title: title)) {
        return;
      }

      state = state.copyWith(status: CreateEchoStatus.loading, errorMessage: null);

      Position currentLocation = await locationService.getCurrentLocation();

      List<Map<String, dynamic>>? images;
      Map<String, dynamic>? audio;
      //
      if (echoType == EchoType.image && state.imageFiles.isNotEmpty) {
        images = await cloudinary.uploadImages(cloudinary, state.imageFiles);
      }else if (echoType == EchoType.audio && state.audioFile != null) {
        audio = await cloudinary.uploadAudio(state.audioFile!);
      }

      debugPrint("Current location: ${currentLocation.latitude}, ${currentLocation.longitude} with accuracy ${currentLocation.accuracy}");
      debugPrint("Image URLs: $images");
      debugPrint("Audio URL: $audio");



      CreateEchoRequest request = CreateEchoRequest(
        title: title,
        content: content,
        isAnonymous: state.isAnonymous,
        isCapsule: state.isCapsule,
        unlockAt: state.scheduledTime,
        echoType: echoType,
        images: images,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        locationName: state.nearbyLocationState.selectedLocation?.name ?? '',
        gpsAccuracy: currentLocation.accuracy,
      );
      debugPrint("request : ${request.toJson()}");



      final response = await echoRepository.createEcho(request);

      if(response.success) {
        state = state.copyWith(status: CreateEchoStatus.success);
      } else {
        state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: response.message ?? "Đã có lỗi xảy ra. Vui lòng thử lại.");
      }
    }catch(e){
      debugPrint("Error creating echo: $e");
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Đã có lỗi xảy ra. Vui lòng thử lại.");
    }

  }

  @override
  Future<void> dispose() async {
      await audioNoteService.dispose();
    super.dispose();
    debugPrint('CreateEchoController disposed');
  }

  bool validCreateEchoInput({required String title}) {
    if (title.isEmpty) {
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Tiêu đề không được để trống");
      return false;
    }
    if(state.imageFiles .isEmpty && state.audioFile == null) {
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Vui lòng chọn ít nhất một hình ảnh hoặc một file âm thanh");
      return false;
    }

    if(state.nearbyLocationState.selectedLocation == null) {
      state = state.copyWith(status: CreateEchoStatus.failure, errorMessage: "Không thể xác định vị trí hiện tại. Vui lòng thử lại sau.");
      return false;
    }

    return true;

  }

  void deleteAudio() async {
    await audioNoteService.deleteAudio();
    state = state.copyWith( durationInSeconds: 0,clearAudio: true);
    debugPrint('Audio file deleted');
  }

  Future<void> refreshAudio() async {
    await audioNoteService.refreshAudio();
  }

}
