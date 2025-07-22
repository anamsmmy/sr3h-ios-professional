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

            // حفظ الفيديو في المعرض مباشرة
            try {
              final result = await GallerySaver.saveVideo(outputPath, albumName: 'SR3H');
              print('📱 Video saved to gallery: ');
            } catch (e) {
              print('⚠️ Could not save to gallery: ');
            }

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
                  '🎬 يمكنك العثور على الفيديو في تطبيق المعرض';
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
