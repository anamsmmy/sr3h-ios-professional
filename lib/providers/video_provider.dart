import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:video_player/video_player.dart';
import '../utils/constants.dart';
import '../utils/video_utils.dart';
import '../utils/permissions.dart';
import '../utils/app_settings.dart';

enum ConversionStatus {
  idle,
  ready,
  processing,
  completed,
  error
}

class VideoInfo {
  final String fileName;
  final int width;
  final int height;
  final Duration duration;
  final double fileSizeMB;
  final double fps;
  
  VideoInfo({
    required this.fileName,
    required this.width,
    required this.height,
    required this.duration,
    required this.fileSizeMB,
    required this.fps,
  });
}

class VideoProvider extends ChangeNotifier {
  File? _selectedVideo;
  VideoInfo? _videoInfo;
  ConversionStatus _status = ConversionStatus.idle;
  double _progress = 0.0;
  String _errorMessage = '';
  String? _outputPath;
  
  // Getters
  File? get selectedVideo => _selectedVideo;
  VideoInfo? get videoInfo => _videoInfo;
  ConversionStatus get status => _status;
  double get progress => _progress;
  String get errorMessage => _errorMessage;
  String? get outputPath => _outputPath;
  
  // Pick video file
  Future<void> pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        final selectedPath = result.files.single.path!;
        
        // Validate video file
        if (!VideoUtils.isValidVideoFile(selectedPath)) {
          _setError('نوع الملف غير مدعوم. يرجى اختيار ملف فيديو صحيح');
          return;
        }
        
        _selectedVideo = File(selectedPath);
        await _extractVideoInfo();
        
        if (_videoInfo != null) {
          _status = ConversionStatus.ready;
          _clearError();
        } else {
          _setError('فشل في قراءة معلومات الفيديو');
          _selectedVideo = null;
          _status = ConversionStatus.idle;
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('خطأ في اختيار الفيديو: ${e.toString()}');
    }
  }
  
  // Extract video information
  Future<void> _extractVideoInfo() async {
    if (_selectedVideo == null) return;
    
    try {
      // Get file size
      final fileStat = await _selectedVideo!.stat();
      final fileSizeMB = fileStat.size / (1024 * 1024);
      
      // Use FFprobe to get detailed video information
      final videoInfo = await VideoUtils.getVideoInfo(_selectedVideo!.path);
      
      if (videoInfo != null) {
        _videoInfo = VideoInfo(
          fileName: _selectedVideo!.path.split('/').last,
          width: videoInfo['width'] as int,
          height: videoInfo['height'] as int,
          duration: videoInfo['duration'] as Duration,
          fileSizeMB: fileSizeMB,
          fps: videoInfo['fps'] as double,
        );
      } else {
        // Fallback to video_player if FFprobe fails
        final controller = VideoPlayerController.file(_selectedVideo!);
        await controller.initialize();
        
        final size = controller.value.size;
        final duration = controller.value.duration;
        
        _videoInfo = VideoInfo(
          fileName: _selectedVideo!.path.split('/').last,
          width: size.width.toInt(),
          height: size.height.toInt(),
          duration: duration,
          fileSizeMB: fileSizeMB,
          fps: 30.0, // Default FPS
        );
        
        await controller.dispose();
      }
      
    } catch (e) {
      _setError('خطأ في قراءة معلومات الفيديو: ${e.toString()}');
    }
  }
  
  // Start video conversion
  Future<void> startConversion() async {
    if (_selectedVideo == null) return;
    
    // Check storage permissions
    final hasPermissions = await PermissionsHelper.hasStoragePermissions();
    if (!hasPermissions) {
      _setError('يرجى منح إذن الوصول للملفات من إعدادات التطبيق');
      return;
    }
    
    _status = ConversionStatus.processing;
    _progress = 0.0;
    _clearError();
    notifyListeners();
    
    try {
      // Create output directory
      final directory = await getExternalStorageDirectory();
      final outputDir = Directory('${directory!.path}/${AppConstants.outputFolderName}');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      
      // Generate output filename using VideoUtils
      _outputPath = VideoUtils.generateOutputFilename(_selectedVideo!.path, outputDir.path);
      
      // Validate command before execution
      if (!VideoUtils.validateFFmpegCommand(_selectedVideo!.path, _outputPath!)) {
        _setError('خطأ في التحقق من صحة الملفات');
        _status = ConversionStatus.error;
        notifyListeners();
        return;
      }
      
      // FFmpeg command: -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
      final command = '-itsscale 2 -i "${_selectedVideo!.path}" -c:v copy -c:a copy "$_outputPath"';
      
      await FFmpegKit.executeAsync(
        command,
        (session) async {
          final returnCode = await session.getReturnCode();
          
          if (ReturnCode.isSuccess(returnCode)) {
            _status = ConversionStatus.completed;
            _progress = 1.0;
            
            // Save conversion statistics
            await AppSettings.saveLastConversionPath(_outputPath!);
            await AppSettings.incrementConversionCount();
          } else {
            final output = await session.getOutput();
            _setError('فشل في التحويل: $output');
            _status = ConversionStatus.error;
          }
          notifyListeners();
        },
        (log) {
          // Update progress based on log output
          final logText = log.getMessage();
          if (logText.contains('time=')) {
            // Extract progress from FFmpeg output
            // This is a simplified progress calculation
            _progress = (_progress + 0.01).clamp(0.0, 0.95);
            notifyListeners();
          }
        },
        (statistics) {
          // Handle statistics if needed
        }
      );
      
    } catch (e) {
      _setError('خطأ في عملية التحويل: ${e.toString()}');
      _status = ConversionStatus.error;
      notifyListeners();
    }
  }
  
  // Reset video selection
  void resetVideo() {
    _selectedVideo = null;
    _videoInfo = null;
    _status = ConversionStatus.idle;
    _progress = 0.0;
    _outputPath = null;
    _clearError();
    notifyListeners();
  }
  
  // Helper methods
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = '';
  }
  
  // Format duration
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  
  // Format file size
  String formatFileSize(double sizeMB) {
    if (sizeMB < 1024) {
      return "${sizeMB.toStringAsFixed(1)} MB";
    } else {
      return "${(sizeMB / 1024).toStringAsFixed(1)} GB";
    }
  }
  
  // Get conversion statistics
  int getConversionCount() {
    return AppSettings.getConversionCount();
  }
  
  String? getLastConversionPath() {
    return AppSettings.getLastConversionPath();
  }
}