import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../plantas/presentation/screens/plantas_screen.dart';
import '../../../plantas/presentation/screens/config_screen.dart';
import '../../../artesanias/presentation/screens/artesanias_screen.dart';
import '../../../sustratos/presentation/screens/sustratos_screen.dart';
import '../../../../core/theme/app_design.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Definición de las pantallas
  static const List<Widget> _screens = [
    PlantasScreen(),
    ArtesaniasScreen(),
    SustratosScreen(),
    ConfigScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 800) {
      return _buildWideLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildWideLayout() {
    return Scaffold(
      backgroundColor: AppDesign.background,
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: AppDesign.surface,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            indicatorColor: AppDesign.gray900,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.local_florist_outlined, color: AppDesign.gray400),
                selectedIcon: Icon(Icons.local_florist, color: Colors.white),
                label: Text('Plantas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emoji_objects_outlined, color: AppDesign.gray400),
                selectedIcon: Icon(Icons.emoji_objects, color: Colors.white),
                label: Text('Artesanías'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grass_outlined, color: AppDesign.gray400),
                selectedIcon: Icon(Icons.grass, color: Colors.white),
                label: Text('Sustratos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined, color: AppDesign.gray400),
                selectedIcon: Icon(Icons.settings, color: Colors.white),
                label: Text('Ajustes'),
              ),
            ],
          ),
          Container(width: 1, color: AppDesign.gray100),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppDesign.background,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: _screens,
          ),
          Positioned(
            left: AppDesign.screenPadding,
            right: AppDesign.screenPadding,
            bottom: AppDesign.space24,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDesign.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.space8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(AppDesign.radiusPill),
            border: Border.all(color: Colors.white.withAlpha(150), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.local_florist_outlined, Icons.local_florist_rounded, 'Plantas', 0),
              _buildNavItem(Icons.emoji_objects_outlined, Icons.emoji_objects_rounded, 'Artesanías', 1),
              _buildNavItem(Icons.grass_outlined, Icons.grass_rounded, 'Sustratos', 2),
              _buildNavItem(Icons.settings_outlined, Icons.settings_rounded, 'Ajustes', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData selectedIcon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? AppDesign.space16 : AppDesign.space12,
          vertical: AppDesign.space10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppDesign.gray900 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDesign.radiusPill),
          border: isSelected ? Border.all(color: AppDesign.gray700, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.white : AppDesign.gray500,
              size: 22,
            ),
            // Solo mostrar texto si está seleccionado Y hay espacio
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label.length > 6 ? label.substring(0, 6) : label,
                style: AppDesign.footnote.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

