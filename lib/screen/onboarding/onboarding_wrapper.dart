import 'package:flutter/material.dart';

// --- MAIN WRAPPER COMPONENT ---

class OnboardingWrapper extends StatefulWidget {
  // Callback ini akan dipanggil setelah user selesai onboarding (menekan tombol Login/Done di halaman terakhir)
  final VoidCallback onOnboardingComplete;

  const OnboardingWrapper({super.key, required this.onOnboardingComplete});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool _isLastPage = false;

  // Warna-warna yang digunakan di halaman sebelumnya
  final Color _primaryColor = const Color(0xFF2962FF); // Biru terang untuk tombol
  final Color _titleColor = const Color(0xFF1A237E); // Biru gelap untuk judul

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
          _isLastPage = (_currentPage == 2); // Indeks halaman terakhir
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk melompat ke halaman berikutnya
  void _nextPage() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      // Panggil callback yang dikirim dari main/parent widget
      _markOnboardingComplete();
    }
  }

  // Fungsi untuk melompat ke halaman terakhir/login
  void _skipOnboarding() {
    _pageController.jumpToPage(2);
  }

  // Fungsi yang dipanggil saat onboarding selesai
  void _markOnboardingComplete() {
    // TODO: Di aplikasi nyata, Anda akan menyimpan status ini di SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('hasSeenOnboarding', true);
    // });

    // Panggil callback untuk navigasi ke halaman Home/Login
    widget.onOnboardingComplete();
  }

  // Widget Indikator Halaman (Dot Indicator)
  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? _primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. PageView: Menampilkan halaman-halaman onboarding
          PageView(
            controller: _pageController,
            children: [
              _OnboardingPage1(onNext: _nextPage, titleColor: _titleColor, buttonColor: _primaryColor),
              _OnboardingPage2(onNext: _nextPage, titleColor: _titleColor, buttonColor: _primaryColor),
              _OnboardingPage3(onLogin: _markOnboardingComplete, titleColor: _titleColor, buttonColor: _primaryColor),
            ],
          ),

          // 2. Kontrol Bawah (Indicator dan Tombol Skip/Next)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Skip (Hanya terlihat di Page 1 & 2)
                Opacity(
                  opacity: _isLastPage ? 0.0 : 1.0,
                  child: TextButton(
                    onPressed: _isLastPage ? null : _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),
                ),

                // Indikator Dot
                Row(
                  children: List.generate(3, _buildIndicator),
                ),

                // Tombol Next/Done/Login
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _isLastPage ? _markOnboardingComplete : _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: _primaryColor,
                      elevation: 0,
                    ),
                    child: Text(
                      _isLastPage ? "Login" : "Next",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
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

// --- ONBOARDING PAGE 1 (PRIVATE) ---
class _OnboardingPage1 extends StatelessWidget {
  final VoidCallback? onNext;
  final Color titleColor;
  final Color buttonColor;

  const _OnboardingPage1({required this.onNext, required this.titleColor, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar Ilustrasi
            SizedBox(
              height: 250,
              // Asumsi Path: assets/images/onboarding1.png
              child: Image.asset(
                'assets/images/onboarding1.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Placeholder(fallbackHeight: 250, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 40),

            // Judul
            Text(
              "Fund your budget",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi
            const Text(
              "Simply by allocating your budget, you can start maximizing your income. "
                  "Budgetin helps you manage all your sources of income, whether single or multiple.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 80), // Tambahan margin bawah agar tidak bertabrakan dengan tombol bottom
          ],
        ),
      ),
    );
  }
}

// --- ONBOARDING PAGE 2 (PRIVATE) ---
class _OnboardingPage2 extends StatelessWidget {
  final VoidCallback? onNext;
  final Color titleColor;
  final Color buttonColor;

  const _OnboardingPage2({required this.onNext, required this.titleColor, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar ilustrasi
            SizedBox(
              height: 250,
              // Asumsi Path: assets/images/onboarding2.png
              child: Image.asset(
                'assets/images/onboarding2.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Placeholder(fallbackHeight: 250, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 40),

            // Judul
            Text(
              "Make a budget",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi
            const Text(
              "Manage your monthly budget wisely so that your finances remain under control "
                  "and every expense can be carefully monitored.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// --- ONBOARDING PAGE 3 (PRIVATE) ---
class _OnboardingPage3 extends StatelessWidget {
  final VoidCallback? onLogin;
  final Color titleColor;
  final Color buttonColor;

  const _OnboardingPage3({required this.onLogin, required this.titleColor, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar ilustrasi
            SizedBox(
              height: 250,
              // Asumsi Path: assets/images/onboarding3.png
              child: Image.asset(
                'assets/images/onboarding3.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Placeholder(fallbackHeight: 250, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 40),

            // Judul
            Text(
              "Organize your Spending",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi
            const Text(
              "Create spending categories to organize your expenses.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}