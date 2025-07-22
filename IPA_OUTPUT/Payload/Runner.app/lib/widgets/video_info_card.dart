import 'package:flutter/material.dart';
import '../providers/video_provider.dart';
import '../utils/constants.dart';

class VideoInfoCard extends StatelessWidget {
  final VideoInfo videoInfo;

  const VideoInfoCard({
    super.key,
    required this.videoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.primaryColor),
                SizedBox(width: 8),
                Text(
                  'معلومات الفيديو',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Video info grid
            LayoutBuilder(
              builder: (context, constraints) {
                // Use different layouts based on screen width
                if (constraints.maxWidth > 600) {
                  // Wide screen - 3 columns
                  return _buildWideLayout();
                } else if (constraints.maxWidth > 400) {
                  // Medium screen - 2 columns
                  return _buildMediumLayout();
                } else {
                  // Narrow screen - 1 column
                  return _buildNarrowLayout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoItem(Icons.drive_file_rename_outline, 'اسم الملف', videoInfo.fileName)),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.aspect_ratio, 'العرض', '${videoInfo.width} بكسل')),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.height, 'الارتفاع', '${videoInfo.height} بكسل')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInfoItem(Icons.access_time, 'المدة', _formatDuration(videoInfo.duration))),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.storage, 'حجم الملف', _formatFileSize(videoInfo.fileSizeMB))),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.speed, 'معدل الإطارات', '${videoInfo.fps.toStringAsFixed(1)} FPS')),
          ],
        ),
      ],
    );
  }

  Widget _buildMediumLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoItem(Icons.drive_file_rename_outline, 'اسم الملف', videoInfo.fileName)),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.aspect_ratio, 'العرض', '${videoInfo.width} بكسل')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInfoItem(Icons.height, 'الارتفاع', '${videoInfo.height} بكسل')),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.access_time, 'المدة', _formatDuration(videoInfo.duration))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInfoItem(Icons.storage, 'حجم الملف', _formatFileSize(videoInfo.fileSizeMB))),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoItem(Icons.speed, 'معدل الإطارات', '${videoInfo.fps.toStringAsFixed(1)} FPS')),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildInfoItem(Icons.drive_file_rename_outline, 'اسم الملف', videoInfo.fileName),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.aspect_ratio, 'العرض', '${videoInfo.width} بكسل'),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.height, 'الارتفاع', '${videoInfo.height} بكسل'),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.access_time, 'المدة', _formatDuration(videoInfo.duration)),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.storage, 'حجم الملف', _formatFileSize(videoInfo.fileSizeMB)),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.speed, 'معدل الإطارات', '${videoInfo.fps.toStringAsFixed(1)} FPS'),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppConstants.primaryColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  String _formatFileSize(double sizeMB) {
    if (sizeMB < 1024) {
      return "${sizeMB.toStringAsFixed(1)} MB";
    } else {
      return "${(sizeMB / 1024).toStringAsFixed(1)} GB";
    }
  }
}