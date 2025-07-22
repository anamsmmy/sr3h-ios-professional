  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حول التطبيق',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تطبيق سرعة لتصحيح معلومات الفيديو ليصبح 60 فريم على التيك توك',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'اسم المطور: منصة سرعة',
                    style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الموقع الإلكتروني: www.SR3H.com',
                    style: TextStyle(fontFamily: 'Tajawal', color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الإصدار: 2.0.7',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 16),
                  if (_isAuthenticated) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حالة التفعيل: مفعل ✅',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'البريد المفعل: ',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    '© 2025 جميع الحقوق محفوظة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'نصائح قبل التحويل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTipItem('أن يكون نوع الفيديو MP4'),
              _buildTipItem('عرض الفيديو 1080 بكسل'),
              _buildTipItem('ارتفاع الفيديو 1920 بكسل'),
              _buildTipItem('أن يكون الفيديو طولي'),
              _buildTipItem('أن يكون الفيديو 60 إطار في الثانية'),
              _buildTipItem('أن لا يحتوي الفيديو على شعار أو حقوق مكتوبة'),
              _buildTipItem('لأن الخوارزمية قد تحجبه من الاقتراحات'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '💡 نصيحة: تجنب وجود فراغات سوداء في الأعلى أو الأسفل',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '🎬 نستخدم تقنية متقدمة لمعالجة الفيديو بجودة عالية',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'محوّل سرعة',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'حول التطبيق',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo - أكبر حجماً
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 300,
                    width: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_library,
                            size: 160,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'محوّل سرعة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          Text(
                            'الإصدار 2.0.7',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (!_isAuthenticated) ...[
                const Text(
                  'تفعيل التطبيق',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'أدخل بريدك الإلكتروني للتحقق من الاشتراك',
                  style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    labelStyle: TextStyle(fontFamily: 'Tajawal'),
                    hintText: 'test@example.com',
                    hintStyle: TextStyle(fontFamily: 'Tajawal'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'Tajawal'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تفعيل التطبيق',
                          style: TextStyle(fontSize: 18, fontFamily: 'Tajawal'),
                        ),
                ),

                // عرض رسائل التفعيل
                if (_message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isAuthenticated ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isAuthenticated ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _isAuthenticated ? Colors.green.shade700 : Colors.red.shade700,
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ] else ...[
                const Text(
                  'مرحباً بك في محوّل سرعة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          _selectedVideoPath != null ? Icons.video_library : Icons.video_file,
                          size: 48,
                          color: _selectedVideoPath != null ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedVideoPath != null ? 'معلومات الفيديو' : 'اختيار الفيديو',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedVideoName != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              _selectedVideoName!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                                fontFamily: 'Tajawal',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_isConverting) ...[
                          LinearProgressIndicator(
                            value: _conversionProgressPercent,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _conversionProgress,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isConverting ? null : _pickVideo,
                                icon: const Text('🎬', style: TextStyle(fontSize: 20)),
                                label: Text(
                                  _selectedVideoPath != null ? 'تغيير الفيديو' : 'اختر ملف فيديو',
                                  style: const TextStyle(fontFamily: 'Tajawal'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedVideoPath != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isConverting
                                      ? null
                                      : (_isConverted ? _openSR3HFolder : _startConversion),
                                  icon: _isConverting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(_isConverted ? Icons.folder_open : Icons.play_arrow),
                                  label: Text(
                                    _isConverting
                                        ? 'جاري التحويل...'
                                        : (_isConverted ? 'استعراض التحويلات' : 'بدء التحويل'),
                                    style: const TextStyle(fontFamily: 'Tajawal'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isConverted ? Colors.orange : Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tips Card - يظهر دائماً بعد التفعيل
                _buildTipsCard(),
              ],

              // رسالة نجاح التحويل
              if (_conversionSuccessMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _conversionSuccessMessage,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _conversionSuccessMessage = '';
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Footer مع رابط الموقع
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'محوّل سرعة - تحويل الفيديو إلى 60 إطار',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'الإصدار 2.0.7',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'نرحب باقتراحاتكم و ملاحظاتكم من خلال منصة سرعة:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'www.SR3H.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'شكرا لدعمكم لنا، وثقتكم بنا',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
