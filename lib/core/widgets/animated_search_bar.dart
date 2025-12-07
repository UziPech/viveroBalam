import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_design.dart';

/// Buscador expansible animado estilo iOS con Glassmorphism
/// Se expande de un círculo con lupa a una barra de búsqueda completa
class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final double expandedWidth;
  final double collapsedWidth;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'Buscar...',
    this.expandedWidth = 280,
    this.collapsedWidth = 50,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() => _isExpanded = false);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _focusNode.requestFocus();
        });
      } else {
        _controller.clear();
        _focusNode.unfocus();
        widget.onSearch('');
      }
    });
  }

  void _onSearchChanged(String value) {
    widget.onSearch(value);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: _isExpanded ? widget.expandedWidth : widget.collapsedWidth,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              // Fondo glassmorphism - blanco semi-transparente
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(_isExpanded ? 230 : 200),
                  Colors.white.withAlpha(_isExpanded ? 200 : 180),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              // Borde brillante premium
              border: Border.all(
                color: Colors.white.withAlpha(_isExpanded ? 180 : 120),
                width: 1.5,
              ),
              // Sombra suave
              boxShadow: [
                BoxShadow(
                  color: AppDesign.gray900.withAlpha(_isExpanded ? 20 : 10),
                  blurRadius: _isExpanded ? 30 : 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                // Sombra interior para profundidad
                BoxShadow(
                  color: Colors.white.withAlpha(80),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextField (solo visible cuando está expandido)
                if (_isExpanded)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: AppDesign.body.copyWith(
                          color: AppDesign.gray900,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: AppDesign.caption.copyWith(
                            color: AppDesign.gray400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),

                // Botón limpiar (solo si hay texto)
                if (_isExpanded && _controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppDesign.gray500,
                        size: 18,
                      ),
                    ),
                  ),

                // Botón de búsqueda/lupa con efecto glass
                GestureDetector(
                  onTap: _toggleSearch,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      // Efecto de hover/presionado
                      gradient: _isExpanded ? null : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withAlpha(60),
                          Colors.white.withAlpha(20),
                        ],
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isExpanded ? Icons.close_rounded : Icons.search_rounded,
                          key: ValueKey(_isExpanded),
                          color: AppDesign.gray700,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

