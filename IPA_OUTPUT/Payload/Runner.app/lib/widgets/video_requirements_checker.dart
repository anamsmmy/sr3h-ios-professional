import 'package:flutter/material.dart';
import '../providers/video_provider.dart';
import '../utils/constants.dart';
import '../utils/video_utils.dart';

class VideoRequirementsChecker extends StatelessWidget {
  final VideoInfo videoInfo;

  const VideoRequirementsChecker({
    super.key,
    required this.videoInfo,
  });

  @override
  Widget build(BuildContext context) {
    final requirements = VideoUtils.checkVideoRequirements({
      'width': videoInfo.width,
      'height': videoInfo.height,
      'fps': videoInfo.fps,
    });
    
    final isMP4 = VideoUtils.isMP4File(videoInfo.fileName);
    
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
                Icon(Icons.checklist, color: AppConstants.secondaryColor),
                SizedBox(width: 8),
                Text(
                  'فحص متطلبات الفيديو',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Requirements checklist
            _buildRequirementItem('نوع الفيديو MP4', isMP4),
            _buildRequirementItem('العرض 1080 بكسل', requirements['is1080Width'] ?? false),
            _buildRequirementItem('الارتفاع 1920 بكسل', requirements['is1920Height'] ?? false),
            _buildRequirementItem('فيديو طولي', requirements['isVertical'] ?? false),
            _buildRequirementItem('60 إطار في الثانية', requirements['is60FPS'] ?? false),
            _buildRequirementItem('نسبة العرض إلى الارتفاع مناسبة', requirements['hasGoodAspectRatio'] ?? false),
            
            const SizedBox(height: 16),
            
            // Overall status
            _buildOverallStatus(isMP4, requirements),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              requirement,
              style: TextStyle(
                fontSize: 14,
                color: isMet ? AppConstants.textColor : Colors.red.shade700,
                fontWeight: isMet ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatus(bool isMP4, Map<String, bool> requirements) {
    final allRequirementsMet = isMP4 && 
        requirements.values.every((requirement) => requirement);
    
    final metCount = (isMP4 ? 1 : 0) + 
        requirements.values.where((requirement) => requirement).length;
    final totalCount = requirements.length + 1;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: allRequirementsMet ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: allRequirementsMet ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            allRequirementsMet ? Icons.verified : Icons.warning,
            color: allRequirementsMet ? Colors.green.shade600 : Colors.orange.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allRequirementsMet ? 'الفيديو يلبي جميع المتطلبات' : 'الفيديو لا يلبي بعض المتطلبات',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: allRequirementsMet ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تم استيفاء $metCount من $totalCount متطلبات',
                  style: TextStyle(
                    fontSize: 12,
                    color: allRequirementsMet ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}