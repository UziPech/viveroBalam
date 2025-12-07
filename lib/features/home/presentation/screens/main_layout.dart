import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../plantas/presentation/screens/plantas_screen.dart';
import '../../../plantas/presentation/screens/config_screen.dart';
import '../../../../core/theme/app_design.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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

    // Pantallas grandes: NavigationRail
    if (screenWidth > 800) {
      return _buildWideLayout();
    }

    // Pantallas pequeñas: Navbar flotante con LiquidGlass
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
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            indicatorColor: AppDesign.gray900,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.local_florist_outlined, color: AppDesign.gray400),
                selectedIcon: Icon(Icons.local_florist, color: Colors.white),
                label: Text('Catálogo'),
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
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                PlantasScreen(),
                ConfigScreen(),
              ],
            ),
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
          // Contenido
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [
              PlantasScreen(),
              ConfigScreen(),
            ],
          ),

          // Navbar flotante LiquidGlass
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
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.space8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(220), // Fondo blanco translúcido
            borderRadius: BorderRadius.circular(AppDesign.radiusPill),
            border: Border.all(
              color: Colors.white.withAlpha(150),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.local_florist_outlined,
                selectedIcon: Icons.local_florist_rounded,
                label: 'Catálogo',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'Ajustes',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? AppDesign.space20 : AppDesign.space16,
          vertical: AppDesign.space12,
        ),
        decoration: BoxDecoration(
          // Burbuja oscura cuando está seleccionado (estilo Apple Music)
          color: isSelected ? AppDesign.gray900 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDesign.radiusPill),
          // Efecto de borde brillante en la burbuja seleccionada
          border: isSelected
              ? Border.all(
                  color: AppDesign.gray700,
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.white : AppDesign.gray500,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: AppDesign.space8),
              Text(
                label,
                style: AppDesign.bodyBold.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
