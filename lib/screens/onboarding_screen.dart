import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'images/first_screen.jpeg',
      'title': 'Benvenuto su Tixly',
      'subtitle': 'Il tuo wallet digitale per eventi, concerti e ricordi.',
    },
    {
      'image': 'images/second_screen.jpeg',
      'title': 'Tutti i tuoi biglietti in un solo posto',
      'subtitle': 'Nessuna stampa solo un tap.',
    },
    {
      'image': 'images/third_screen.jpeg',
      'title': 'Vivi. Condividi. Ricorda',
      'subtitle': 'Crea il tuo diario degli eventi live.',
    },
  ];

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onBoardingSeen', true);
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (_, index) {
              final page = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    page['image']!,
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withOpacity(0.5)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            page['title']!,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page['subtitle']!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // 🔘 Indicatori
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                                  (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🟣 Pulsante
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                                _currentPage == _pages.length - 1 ? 'Inizia' : 'Avanti'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
