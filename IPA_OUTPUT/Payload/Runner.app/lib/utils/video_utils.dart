import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information.dart';

class VideoUtils {
  
  /// Get detailed video information using FFprobe
  static Future<Map<String, dynamic>?> getVideoInfo(String videoPath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(videoPath);
      final information = session.getMediaInformation();
      
      if (information == null) return null;
      
      final properties = information.getAllProperties();
      final streams = information.getStreams();
      
      if (streams.isEmpty) return null;
      
      final videoStream = streams.firstWhere(
        (stream) => stream.getAllProperties()['codec_type'] == 'video',
        orElse: () => streams.first,
      );
      
      final videoProps = videoStream.getAllProperties();
      final duration = information.getDuration();
      final size = information.getSize();
      
      return {
        'width': int.tryParse(videoProps['width']?.toString() ?? '0') ?? 0,
        'height': int.tryParse(videoProps['height']?.toString() ?? '0') ?? 0,
        'duration': duration != null ? Duration(milliseconds: (duration * 1000).toInt()) : Duration.zero,
        'fps': _parseFps(videoProps['r_frame_rate']?.toString()),
        'codec': videoProps['codec_name']?.toString() ?? 'unknown',
        'bitrate': int.tryParse(information.getBitrate()?.toString() ?? '0') ?? 0,
        'size': size ?? 0,
      };
    } catch (e) {
      print('Error getting video info: $e');
      return null;
    }
  }
  
  /// Parse frame rate from FFprobe output
  static double _parseFps(String? fpsString) {
    if (fpsString == null || fpsString.isEmpty) return 30.0;
    
    try {
      if (fpsString.contains('/')) {
        final parts = fpsString.split('/');
        if (parts.length == 2) {
          final numerator = double.tryParse(parts[0]) ?? 30.0;
          final denominator = double.tryParse(parts[1]) ?? 1.0;
          return denominator != 0 ? numerator / denominator : 30.0;
        }
      }
      return double.tryParse(fpsString) ?? 30.0;
    } catch (e) {
      return 30.0;
    }
  }
  
  /// Check if video meets recommended requirements
  static Map<String, bool> checkVideoRequirements(Map<String, dynamic> videoInfo) {
    return {
      'isMP4': true, // We'll check file extension separately
      'isVertical': (videoInfo['height'] as int) > (videoInfo['width'] as int),
      'is1080Width': (videoInfo['width'] as int) == 1080,
      'is1920Height': (videoInfo['height'] as int) == 1920,
      'is60FPS': (videoInfo['fps'] as double) >= 59.0,
      'hasGoodAspectRatio': _checkAspectRatio(videoInfo['width'] as int, videoInfo['height'] as int),
    };
  }
  
  /// Check if aspect ratio is close to 9:16 (vertical video)
  static bool _checkAspectRatio(int width, int height) {
    if (width == 0 || height == 0) return false;
    
    final aspectRatio = height / width;
    const targetRatio = 16.0 / 9.0; // 1.777...
    const tolerance = 0.1;
    
    return (aspectRatio - targetRatio).abs() <= tolerance;
  }
  
  /// Format file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Format duration in human readable format
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }
  
  /// Check if file is a valid video file
  static bool isValidVideoFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    const validExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', '3gp'];
    return validExtensions.contains(extension);
  }
  
  /// Check if file is MP4
  static bool isMP4File(String filePath) {
    return filePath.toLowerCase().endsWith('.mp4');
  }
  
  /// Generate output filename with SR3H suffix
  static String generateOutputFilename(String inputPath, String outputDir) {
    final file = File(inputPath);
    final nameWithoutExtension = file.uri.pathSegments.last.replaceAll('.mp4', '');
    return '$outputDir/$nameWithoutExtension-SR3H.mp4';
  }
  
  /// Validate FFmpeg command before execution
  static bool validateFFmpegCommand(String inputPath, String outputPath) {
    try {
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      
      // Check if input file exists
      if (!inputFile.existsSync()) return false;
      
      // Check if output directory exists, create if not
      final outputDir = outputFile.parent;
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}