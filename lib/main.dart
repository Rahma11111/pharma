import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'splash_screen.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your existing pages
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      title: 'Pharma Link',
      theme: ThemeData(
        primaryColor: const Color(0xFF00A8A3),
        // textTheme: GoogleFonts.openSansTextTheme(),
      ),
      // home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userType;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null) {
      final type = HeaderHelper.parseJWT(storedToken);
      setState(() {
        token = storedToken;
        userType = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderWidget(userType: userType, token: token),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroSection(),
            const ServicesSection(),
            const SizedBox(height: 40),
            FooterWidget(userType: userType),
          ],
        ),
      ),
    );
  }
}

// =====================
// Header Helper
// =====================
class HeaderHelper {
  static String? parseJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);

      return data['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyApp()),
      );
    }
  }

  static void showNotification(BuildContext context, String message, {int ok = 2}) {
    Color backgroundColor;
    String displayMessage = message;

    if (ok == 2) {
      displayMessage = '⚠️ $message';
      backgroundColor = const Color(0xFFC5C75D);
    } else {
      backgroundColor = ok == 1 ? const Color(0xFF1BBB4B) : const Color(0xFFC91432);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '✖',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// =====================
// Header Widget
// =====================
class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? userType;
  final String? token;

  const HeaderWidget({super.key, this.userType, this.token});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      titleSpacing: 0,
      leadingWidth: isMobile ? 100 : 250,
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 6),
        child: Transform.scale(
          scale: 1.3,
          child: Image.asset('assets/images/img.png', fit: BoxFit.contain),
        ),
      ),
      title: isMobile ? null : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildNavItems(context),
      ),
      actions: _buildActions(context, isMobile),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    if (token == null) {
      return [
        _buildNavButton('Home', () {}),
      ];
    }

    final userType = this.userType;
    switch (userType) {
      case 'Pharmacy':
        return [
          _buildNavButton('Home', () {}),
          _buildNavButton('Search', () {}),
          _buildNavButton('History', () {}),
          _buildNavButton('Cart', () {}),
        ];
      case 'Company':
        return [
          _buildNavButton('Home', () {}),
          _buildNavButton('Orders', () {}),
          _buildNavButton('Product', () {}),
        ];
      default:
        return [
          _buildNavButton('Home', () {}),
          _buildNavButton('Company', () {}),
          _buildNavButton('Requests', () {}),
        ];
    }
  }

  Widget _buildNavButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF2C3E50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isMobile) {
    if (token == null) {
      return [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00A8A3),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A8A3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 2,
            ),
            child: const Text('Register', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ];
    }

    return [
      if (userType == 'Pharmacy' || userType == 'Company')
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF00A8A3), size: 28),
          tooltip: 'Profile',
        ),
      IconButton(
        onPressed: () => HeaderHelper.logout(context),
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFE74C3C)),
        tooltip: 'Logout',
      ),
      const SizedBox(width: 4),
    ];
  }
}

// =====================
// Footer Widget
// =====================
class FooterWidget extends StatelessWidget {
  final String? userType;

  const FooterWidget({super.key, this.userType});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2C3E50),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 30,
            runSpacing: 20,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              _buildAboutColumn(),
              _buildQuickLinksColumn(),
              _buildFollowUsColumn(),
              _buildContactColumn(),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          const Text(
            '© 2025 PharmaLink. All rights reserved.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutColumn() {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'About Pharma Link',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Pharma Link is dedicated to helping pharmacies access a wide network of medical suppliers with ease and confidence.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksColumn() {
    List<Map<String, String>> links = [
      {'text': 'Home', 'route': '/home'},
    ];

    if (userType == 'Pharmacy') {
      links.addAll([
        {'text': 'Search', 'route': '/search'},
        {'text': 'History', 'route': '/history'},
        {'text': 'Cart', 'route': '/cart'},
        {'text': 'About', 'route': '/about'},
      ]);
    } else if (userType == 'Company') {
      links.addAll([
        {'text': 'Orders', 'route': '/orders'},
        {'text': 'Product', 'route': '/products'},
        {'text': 'About', 'route': '/about'},
      ]);
    } else {
      links.add({'text': 'About', 'route': '/about'});
    }

    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Links',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: InkWell(
              onTap: () {},
              child: Text(
                link['text']!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFollowUsColumn() {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow Us',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSocialIcon('https://www.facebook.com/rahma.2025/', FontAwesomeIcons.facebook),
              const SizedBox(width: 12),
              _buildSocialIcon('http://x.com/Rah_ma', FontAwesomeIcons.twitter),
              const SizedBox(width: 12),
              _buildSocialIcon('https://www.linkedin.com/in/Rahma_hassan-899262289/', FontAwesomeIcons.linkedin),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String url, IconData icon) {
    return InkWell(
      onTap: () {},
      child: FaIcon(icon, color: Colors.white70, size: 20),
    );
  }

  Widget _buildContactColumn() {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {},
            child: const Text(
              'Email: pharmalink38@gmail.com',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {},
            child: const Text(
              'Phone: +2010101010',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================
// Hero Section
// =====================
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = Tween<double>(begin: 1.05, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      _scaleController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _scaleController.reverse();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TypingText(
                      texts: ['Welcome to Pharma Link'],
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        shadows: [Shadow(blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      cursorColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Connecting pharmacies with trusted medicine companies through our innovative platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.6,
                        shadows: [Shadow(blurRadius: 3, offset: Offset(1, 1))],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8A3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Scrollable.ensureVisible(
                          ServicesSection.globalKey.currentContext!,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.chevronDown,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Our Services',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                          height: 2.5,
                          shadows: [Shadow(blurRadius: 3, offset: Offset(1, 1))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// =====================
// Typing Text Widget
// =====================
class TypingText extends StatefulWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final Duration typingSpeed;
  final Color cursorColor;

  const TypingText({
    super.key,
    required this.texts,
    this.textStyle,
    this.typingSpeed = const Duration(milliseconds: 60),
    this.cursorColor = Colors.white,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _display = '';
  int _textIndex = 0;
  int _charIndex = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.typingSpeed, _tick);
  }

  void _tick(Timer t) {
    final current = widget.texts[_textIndex];
    if (_charIndex < current.length) {
      setState(() {
        _display += current[_charIndex];
        _charIndex++;
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _display = '';
          _charIndex = 0;
          _textIndex = (_textIndex + 1) % widget.texts.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_display, style: widget.textStyle),
        AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 3,
            height: widget.textStyle?.fontSize ?? 18,
            margin: const EdgeInsets.only(left: 6),
            color: widget.cursorColor,
          ),
        )
      ],
    );
  }
}

// =====================
// Services Section
// =====================
class ServicesSection extends StatelessWidget {
  static final globalKey = GlobalKey();
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 992;
    return Container(
      key: globalKey,
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Our Services',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, height: 1.1),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 600,
                child: Text(
                  'Discover how Pharma Link revolutionizes the way pharmacies connect with medicine suppliers',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 36),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: isWide ? 2 : 1,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.05,
                children: const [
                  ServiceCardData(
                    icon: FontAwesomeIcons.networkWired,
                    number: '01. Streamlined Connection',
                    title: 'How We Connect',
                    short: 'Direct connection between pharmacies and medicine companies',
                    bullets: [
                      'Direct supplier network',
                      'Real-time inventory updates',
                      'Automated order processing',
                      'Secure communication channels'
                    ],
                  ),
                  ServiceCardData(
                    icon: FontAwesomeIcons.cartShopping,
                    number: '02. Simplified Ordering',
                    title: 'Ordering Process',
                    short: 'Easy and efficient medicine ordering system',
                    bullets: [
                      'One-click ordering system',
                      'Bulk order management',
                      'Order history tracking',
                      'Automated reordering'
                    ],
                  ),
                  ServiceCardData(
                    icon: FontAwesomeIcons.bolt,
                    number: '03. Fast and Convenient Requests',
                    title: 'Request Processing',
                    short: 'Quick and efficient request processing system',
                    bullets: [
                      'Instant request confirmation',
                      'Priority processing options',
                      'Real-time status updates',
                      'Automated notifications'
                    ],
                  ),
                  ServiceCardData(
                    icon: FontAwesomeIcons.desktop,
                    number: '04. User-Friendly Interface',
                    title: 'Interface Features',
                    short: 'Intuitive and easy-to-use platform design',
                    bullets: [
                      'Simple navigation system',
                      'Clear visual hierarchy',
                      'Responsive design',
                      'Accessibility features'
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// Service Card & Flip Card
// =====================
class ServiceCardData extends StatelessWidget {
  final IconData icon;
  final String number;
  final String short;
  final String title;
  final List<String> bullets;

  const ServiceCardData({
    super.key,
    required this.icon,
    required this.number,
    required this.short,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: FlipServiceCard(
        front: _CardFront(
          icon: icon,
          number: number,
          short: short,
        ),
        back: _CardBack(
          title: title,
          bullets: bullets,
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final IconData icon;
  final String number;
  final String short;

  const _CardFront({required this.icon, required this.number, required this.short});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x1A000000), offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 40, color: const Color(0xFF00A8A3)),
          const SizedBox(height: 16),
          Text(number, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(short, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _CardBack({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00A8A3), Color(0xFF007A77)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Our platform includes:', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ...bullets.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('→ ', style: TextStyle(color: Colors.white)),
                Expanded(child: Text(b, style: const TextStyle(color: Colors.white))),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class FlipServiceCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipServiceCard({super.key, required this.front, required this.back});

  @override
  State<FlipServiceCard> createState() => _FlipServiceCardState();
}

class _FlipServiceCardState extends State<FlipServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isUnder = angle > pi / 2;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isUnder
                ? Transform(
              transform: Matrix4.identity()..rotateY(pi),
              alignment: Alignment.center,
              child: widget.back,
            )
                : widget.front,
          );
        },
      ),
    );
  }
}