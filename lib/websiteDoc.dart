
// https://chat-app-2594b.web.app/

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const PhotographerPortfolio());
}

class PhotographerPortfolio extends StatelessWidget {
  const PhotographerPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ethereal Frames',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFD4AF37), // Gold
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
      ),
      home: const PortfolioScreen(),
    );
  }
}

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _fabController;
  final ScrollController _scrollController = ScrollController();
  Timer? _testimonialTimer;
  int _testimonialIndex = 0;

  final List<String> portfolioImages = [
    'https://picsum.photos/id/1015/800/1200',
    'https://picsum.photos/id/102/800/1200',
    'https://picsum.photos/id/201/800/1200',
    'https://picsum.photos/id/251/800/1200',
    'https://picsum.photos/id/29/800/1200',
    'https://picsum.photos/id/30/800/1200',
    'https://picsum.photos/id/1016/800/1200',
    'https://picsum.photos/id/133/800/1200',
  ];

  final List<Map<String, String>> testimonials = [
    {
      'name': 'Rahul Sharma',
      'text': 'Vikram ne meri wedding ko timeless bana diya. Best photographer ever!',
      'image': 'https://picsum.photos/id/64/200/200'
    },
    {
      'name': 'Priya Mehta',
      'text': 'Pre-wedding shoot was magical. Highly recommended!',
      'image': 'https://picsum.photos/id/65/200/200'
    },
    {
      'name': 'Arjun Patel',
      'text': 'Nature & wildlife shots are next level. 10/10',
      'image': 'https://picsum.photos/id/66/200/200'
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    // Auto slide testimonials
    _testimonialTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _testimonialIndex = (_testimonialIndex + 1) % testimonials.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _fabController.dispose();
    _testimonialTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showImageDetail(String imageUrl, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => ImageDetailScreen(imageUrl: imageUrl, heroTag: heroTag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ==================== HERO SECTION (Parallax + Animation) ====================
          SliverAppBar(
            expandedHeight: size.height * 0.85,
            pinned: true,
            floating: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://picsum.photos/id/1018/1200/2000',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Center(
                    child: FadeTransition(
                      opacity: _heroController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'VIKRAM LENS',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 12,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ETHEREAL FRAMES',
                            style: TextStyle(
                              fontSize: 22,
                              letterSpacing: 8,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
                            ),
                            child: ElevatedButton(
                              onPressed: () => _scrollController.animateTo(
                                size.height * 0.9,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              ),
                              child: const Text('EXPLORE MY WORK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Icon(Icons.keyboard_arrow_down, size: 40, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // ==================== ABOUT SECTION ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: child!,
                      ),
                    ),
                    child: const Text(
                      'About Me',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFFD4AF37)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hi, I\'m Vikram — a storyteller with a camera. I capture raw emotions, timeless moments and the magic of light. Based in Indore, shooting across India & beyond.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, height: 1.6, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // ==================== PORTFOLIO SECTION ====================
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Featured Work',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final heroTag = 'image$index';
                  return GestureDetector(
                    onTap: () => _showImageDetail(portfolioImages[index], heroTag),
                    child: Hero(
                      tag: heroTag,
                      child: AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Image.network(
                                portfolioImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Text(
                                  'Shot #${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: portfolioImages.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ==================== TESTIMONIALS ====================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: testimonials.length,
                controller: PageController(viewportFraction: 0.85),
                onPageChanged: (i) => setState(() => _testimonialIndex = i),
                itemBuilder: (context, index) {
                  final t = testimonials[index];
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _testimonialIndex == index ? 1.0 : 0.6,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(radius: 32, backgroundImage: NetworkImage(t['image']!)),
                          const SizedBox(height: 16),
                          Text(
                            '"${t['text']}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 17, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Text(t['name']!, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),

          // ==================== CONTACT ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Let\'s Create Magic Together', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300)),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Your Name',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Your Message',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('SEND MESSAGE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ==================== FLOATING ACTION BUTTON (Pulse Animation) ====================
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.15).animate(_fabController),
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking request sent! 📸')),
            );
          },
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          icon: const Icon(Icons.camera),
          label: const Text('Book a Session'),
        ),
      ),
    );
  }
}

// ==================== FULL SCREEN IMAGE VIEWER (Hero Animation) ====================
class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageDetailScreen({super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, size: 32, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}