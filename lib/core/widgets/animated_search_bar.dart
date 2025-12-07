import 'package:flutter/material.dart';
import '../theme/app_design.dart';

/// Buscador expansible animado estilo iOS
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
    // Si pierde el foco y no hay texto, colapsar
    if (!_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() => _isExpanded = false);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        // Enfocar el TextField cuando se expande
        Future.delayed(const Duration(milliseconds: 200), () {
          _focusNode.requestFocus();
        });
      } else {
        // Limpiar y quitar foco cuando se colapsa
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
      decoration: BoxDecoration(
        color: AppDesign.gray50,
        borderRadius: BorderRadius.circular(25),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: AppDesign.gray900.withAlpha(8),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // TextField (solo visible cuando está expandido)
          if (_isExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  style: AppDesign.body,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppDesign.caption,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.close_rounded,
                  color: AppDesign.gray400,
                  size: 20,
                ),
              ),
            ),

          // Botón de búsqueda/lupa
          GestureDetector(
            onTap: _toggleSearch,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.transparent : AppDesign.gray50,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isExpanded ? Icons.close_rounded : Icons.search_rounded,
                    key: ValueKey(_isExpanded),
                    color: AppDesign.gray600,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
