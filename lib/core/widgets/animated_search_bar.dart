import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_design.dart';
import '../theme/app_colors.dart';

/// Buscador expansible animado con efecto Liquid Glass
/// Se expande de un círculo con lupa a una barra de búsqueda completa
class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final double expandedWidth;
  final double collapsedSize;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'Buscar...',
    this.expandedWidth = 280,
    this.collapsedSize = 56,
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
    setState(() {}); // Rebuild para mostrar/ocultar botón limpiar
    widget.onSearch(value);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: _isExpanded ? widget.expandedWidth : widget.collapsedSize,
      height: widget.collapsedSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.collapsedSize / 2),
        child: BackdropFilter(
          // Más blur cuando está expandido para efecto más premium
          filter: ImageFilter.blur(
            sigmaX: _isExpanded ? 25 : 15, 
            sigmaY: _isExpanded ? 25 : 15,
          ),
          child: Container(
            decoration: BoxDecoration(
              // Fondo Liquid Glass
              color: AppColors.liquidGlassBackground,
              borderRadius: BorderRadius.circular(widget.collapsedSize / 2),
              // Borde brillante
              border: Border.all(
                color: AppColors.liquidGlassBorder,
                width: 1.5,
              ),
              // Gradiente más visible cuando expandido
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 255, 255, _isExpanded ? 0.4 : 0.3),
                  Color.fromRGBO(255, 255, 255, _isExpanded ? 0.15 : 0.1),
                ],
              ),
              // Sombra premium
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.12),
                  blurRadius: _isExpanded ? 30 : 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
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
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppDesign.gray500,
                        size: 20,
                      ),
                    ),
                  ),

                // Botón de búsqueda/lupa
                GestureDetector(
                  onTap: _toggleSearch,
                  child: Container(
                    width: widget.collapsedSize - 3,
                    height: widget.collapsedSize - 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.collapsedSize / 2),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isExpanded ? Icons.close_rounded : Icons.search_rounded,
                          key: ValueKey(_isExpanded),
                          color: AppDesign.gray700,
                          size: 24,
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
