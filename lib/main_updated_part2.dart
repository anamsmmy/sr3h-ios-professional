  void _showImportantTips() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'نصائح هامة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTipRow('🔹 لا تحرر الفيديو بعد التحويل أو تعدل عليه، حتى في TikTok'),
                  const SizedBox(height: 12),
                  _buildTipRow(
                      '🔹 رفع الفيديو الى TikTok من متصفح "Google Chrome" كـ"موقع مصمم للكمبيوتر"'),
                  const SizedBox(height: 12),
                  _buildTipRow('🔹 قبل رفع الفيديو إلى حسابك على TikTok، اختر دولة "اليابان"'),
                  const SizedBox(height: 12),
                  _buildTipRow('🔹 شغل VPN قبل رفع الفيديو، مثل التطبيق المجاني (Psiphon)'),
                  const SizedBox(height: 12),
                  _buildTipRow('🔹 أحيانًا TikTok يقرأ معلومات الشريحة SIM Card ليتعرف على بلدك'),
                  const SizedBox(height: 12),
                  _buildTipRow('✅ إذا لم تنجح الطريقة، أخرج الشريحة واعتمد على شبكة WiFi فقط'),
                ],
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickVideoFile();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipRow(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Future<void> _pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedVideoPath = result.files.single.path;
          _selectedVideoName = result.files.single.name;
          _isConverted = false; // إعادة تعيين حالة التحويل
          _convertedVideoPath = null;
          _conversionSuccessMessage = ''; // إخفاء رسالة النجاح السابقة
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار الفيديو: '),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في اختيار الفيديو. يرجى المحاولة مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    _showImportantTips();
  }

  Future<void> _startConversion() async {
    if (_selectedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار ملف فيديو أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _conversionProgress = 'جاري التحضير للتحويل...';
      _conversionProgressPercent = 0.1;
    });

    try {
      // إنشاء مجلد SR3H في المعرض الرئيسي
      Directory? directory;
      if (Platform.isAndroid) {
        // محاولة إنشاء المجلد في DCIM (المعرض الرئيسي)
        directory = Directory('/storage/emulated/0/DCIM/SR3H');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        // إذا فشل DCIM، جرب Movies
        if (!await directory.exists()) {
          directory = Directory('/storage/emulated/0/Movies/SR3H');
          await directory.create(recursive: true);
        }
        
        // إذا فشل Movies، جرب Pictures
        if (!await directory.exists()) {
          directory = Directory('/storage/emulated/0/Pictures/SR3H');
          await directory.create(recursive: true);
        }
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        directory = Directory('/SR3H');
        await directory.create(recursive: true);
      }

      // Create output filename with random number
      final random = Random();
      final randomNumber = random.nextInt(999999) + 100000; // 6-digit random number
      final outputPath = '/SR3H-.mp4';

      setState(() {
        _conversionProgress = 'جاري معالجة الفيديو...';
        _conversionProgressPercent = 0.2;
      });

      // The exact FFmpeg command requested
      final command = '-itsscale 2 -i "" -c:v copy -c:a copy ""';

      print('🎬 تطبيق أمر FFmpeg: ');

      await FFmpegKit.executeAsync(command, (ffmpeg.Session session) async {
        final returnCode = await session.getReturnCode();

        setState(() {
          _isConverting = false;
          _conversionProgress = '';
          _conversionProgressPercent = 1.0;
        });

        if (ReturnCode.isSuccess(returnCode)) {
          // Check if output file exists
          final outputFile = File(outputPath);
          if (await outputFile.exists()) {
            final fileSizeMB = (await outputFile.length()) / (1024 * 1024);

            setState(() {
              _isConverted = true;
              _convertedVideoPath = outputPath;
            });

            final outputFileName = outputPath.split('/').last;
            setState(() {
              _conversionSuccessMessage = '✅ تم تحويل الفيديو بنجاح!\n'
                  'الملف: \n'
                  'الحجم:  MB\n'
                  '📱 تم حفظ الفيديو في المعرض - ألبوم SR3H\n'
                  '🎬 اضغط "استعراض التحويلات" لفتح المعرض';
            });
          } else {
            throw Exception('الملف المحول غير موجود');
          }
        } else {
          final logs = await session.getAllLogs();
          String errorMessage = 'فشل في تحويل الفيديو';
          if (logs.isNotEmpty) {
            errorMessage += '\nالخطأ: ';
          }
          throw Exception(errorMessage);
        }
      }, (Log log) {
        // Update progress based on log messages
        final message = log.getMessage();
        setState(() {
          if (message.contains('time=')) {
            _conversionProgress = 'جاري المعالجة... ';
            _conversionProgressPercent = 0.6;
          } else if (message.contains('frame=')) {
            _conversionProgress = 'معالجة الإطارات...';
            _conversionProgressPercent = 0.4;
          }
        });
      }, (Statistics statistics) {
        // Update progress based on statistics
        if (statistics.getTime() > 0) {
          setState(() {
            _conversionProgressPercent = 0.8;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isConverting = false;
        _conversionProgress = '';
        _conversionProgressPercent = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحويل: '),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _openSR3HFolder() async {
    try {
      // محاولة فتح تطبيق المعرض مباشرة
      final galleryUri = Uri.parse('content://media/external/video/media');
      
      if (await canLaunchUrl(galleryUri)) {
        await launchUrl(galleryUri, mode: LaunchMode.externalApplication);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم فتح المعرض - ابحث عن ألبوم SR3H'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // محاولة فتح مدير الملفات كبديل
        final fileManagerUri = Uri.parse('content://com.android.externalstorage.documents/document/primary%3ADCIM%2FSR3H');
        
        if (await canLaunchUrl(fileManagerUri)) {
          await launchUrl(fileManagerUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('لا يمكن فتح المعرض');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('افتح تطبيق المعرض وابحث عن ألبوم SR3H'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
