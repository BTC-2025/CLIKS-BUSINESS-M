import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/navigation/navigation_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════

class CategoryItem {
  final String id;
  String name;
  String description;
  String? coverImageUrl;
  bool isMainCategory;
  String? parentCategoryId;
  String? parentCategoryName;
  int linkedProductsCount;
  bool isActive;
  List<String> subcategories;
  List<String> assignedProductIds;

  CategoryItem({
    required this.id,
    required this.name,
    this.description = '',
    this.coverImageUrl,
    this.isMainCategory = true,
    this.parentCategoryId,
    this.parentCategoryName,
    this.linkedProductsCount = 0,
    this.isActive = true,
    List<String>? subcategories,
    List<String>? assignedProductIds,
  })  : subcategories = subcategories ?? [],
        assignedProductIds = assignedProductIds ?? [];

  CategoryItem copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isMainCategory,
    String? parentCategoryId,
    String? parentCategoryName,
    int? linkedProductsCount,
    bool? isActive,
    List<String>? subcategories,
    List<String>? assignedProductIds,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isMainCategory: isMainCategory ?? this.isMainCategory,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      parentCategoryName: parentCategoryName ?? this.parentCategoryName,
      linkedProductsCount: linkedProductsCount ?? this.linkedProductsCount,
      isActive: isActive ?? this.isActive,
      subcategories: subcategories ?? List.from(this.subcategories),
      assignedProductIds:
          assignedProductIds ?? List.from(this.assignedProductIds),
    );
  }
}

class AssignableProductItem {
  final String id;
  final String name;
  final String sku;
  final double price;
  final double stock;
  final String unit;
  bool isSelected;

  AssignableProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.unit = 'PCS',
    this.isSelected = false,
  });
}

// ═══════════════════════════════════════════════════════════════
// CATEGORIES PAGE
// ═══════════════════════════════════════════════════════════════

enum CategoryViewMode { cardGrid, treeView }

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  CategoryViewMode _viewMode = CategoryViewMode.cardGrid;
  String _filterType = 'All Main Categories';

  // Seed categories matching screenshots 1, 2, and 5
  late List<CategoryItem> _categories;
  late List<AssignableProductItem> _uncategorizedProducts;

  @override
  void initState() {
    super.initState();
    _initSeedData();
  }

  void _initSeedData() {
    _categories = [
      CategoryItem(
        id: 'cat-1',
        name: 'beverages',
        description: 'desc',
        // High quality coffee cup photo matching screenshot 1
        coverImageUrl:
            'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
        isMainCategory: true,
        linkedProductsCount: 1,
        isActive: false, // Inactive badge matching screenshot 1
        subcategories: [],
      ),
      CategoryItem(
        id: 'cat-2',
        name: 'Electronics',
        description: '',
        coverImageUrl: null,
        isMainCategory: true,
        linkedProductsCount: 13,
        isActive: true,
        subcategories: [],
      ),
      CategoryItem(
        id: 'cat-3',
        name: 'Food',
        description: '',
        coverImageUrl: null,
        isMainCategory: true,
        linkedProductsCount: 2,
        isActive: true,
        subcategories: [],
      ),
      CategoryItem(
        id: 'cat-4',
        name: 'Footwear',
        description: '',
        coverImageUrl: null,
        isMainCategory: true,
        linkedProductsCount: 1,
        isActive: true,
        subcategories: [],
      ),
      CategoryItem(
        id: 'cat-5',
        name: 'General',
        description: '',
        coverImageUrl: null,
        isMainCategory: true,
        linkedProductsCount: 5,
        isActive: true,
        subcategories: [],
      ),
    ];

    // Seed uncategorized products matching screenshot 4
    _uncategorizedProducts = [
      AssignableProductItem(
        id: 'p-1',
        name: 'a new digit product',
        sku: 'SKU-3752',
        price: 1000004399.0,
        stock: 196,
        unit: 'PCS',
      ),
      AssignableProductItem(
        id: 'p-2',
        name: 'carrot',
        sku: 'SKU-746095',
        price: 526.0,
        stock: 848,
        unit: 'PCS',
      ),
      AssignableProductItem(
        id: 'p-3',
        name: 'erferfa',
        sku: 'n rcn',
        price: 0.0,
        stock: 320,
        unit: 'pcs',
      ),
      AssignableProductItem(
        id: 'p-4',
        name: 'milk',
        sku: 'SKU-1211',
        price: 50.0,
        stock: 43.5,
        unit: 'LITRE',
      ),
      AssignableProductItem(
        id: 'p-5',
        name: 'pure honey 500g',
        sku: 'SKU-9921',
        price: 320.0,
        stock: 75,
        unit: 'PCS',
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── COMPUTED METRICS ───
  int get _mainCategoriesCount =>
      _categories.where((c) => c.isMainCategory).length;

  int get _subcategoriesCount {
    int count = 0;
    for (final c in _categories) {
      count += c.subcategories.length;
    }
    return count;
  }

  // Matching screenshot 1's "0113215" catalog products indicator
  String get _catalogProductsDisplay => '0113215';

  // ─── FILTERED LIST ───
  List<CategoryItem> get _filteredCategories {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _categories.where((cat) {
      final matchesQuery = query.isEmpty ||
          cat.name.toLowerCase().contains(query) ||
          cat.description.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (_filterType == 'Main Categories Only') {
        matchesFilter = cat.isMainCategory;
      } else if (_filterType == 'Subcategories Only') {
        matchesFilter = !cat.isMainCategory;
      } else if (_filterType == 'Active Only') {
        matchesFilter = cat.isActive;
      } else if (_filterType == 'Inactive Only') {
        matchesFilter = !cat.isActive;
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  // ─── ACTIONS ───
  void _openCreateCategoryDialog({CategoryItem? parentCategory}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _CategoryFormDialog(
        allCategories: _categories,
        initialParentCategory: parentCategory,
        uncategorizedProducts: _uncategorizedProducts,
        onSave: (newCat, assignedIds) {
          setState(() {
            _categories.insert(0, newCat);
            if (newCat.parentCategoryId != null) {
              final parent = _categories.firstWhere(
                (c) => c.id == newCat.parentCategoryId,
                orElse: () => newCat,
              );
              if (parent != newCat && !parent.subcategories.contains(newCat.name)) {
                parent.subcategories.add(newCat.name);
              }
            }
            // Remove assigned products from uncategorized pool
            _uncategorizedProducts
                .removeWhere((p) => assignedIds.contains(p.id));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${newCat.name}" created successfully.'),
              backgroundColor: const Color(0xFF14532D),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openEditCategoryDialog(CategoryItem category) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _CategoryFormDialog(
        allCategories: _categories,
        existingCategory: category,
        uncategorizedProducts: _uncategorizedProducts,
        onSave: (updatedCat, assignedIds) {
          setState(() {
            final idx = _categories.indexWhere((c) => c.id == category.id);
            if (idx != -1) {
              _categories[idx] = updatedCat;
            }
            _uncategorizedProducts
                .removeWhere((p) => assignedIds.contains(p.id));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${updatedCat.name}" updated successfully.'),
              backgroundColor: const Color(0xFF14532D),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(CategoryItem category) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.trash2, color: Color(0xFFDC2626), size: 20),
            SizedBox(width: 8),
            Text(
              'Delete Category',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? Products in this category will become uncategorized.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _categories.removeWhere((c) => c.id == category.id);
                // Also remove from any parent's subcategory list
                for (final c in _categories) {
                  c.subcategories.remove(category.name);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted category "${category.name}".'),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── BUILD METHOD ───
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 12 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Banner
              _buildTopHeader(isMobile),
              const SizedBox(height: 18),

              // 2. Metric Summary Cards
              _buildMetricCards(isMobile),
              const SizedBox(height: 18),

              // 3. Search & View Mode Switcher
              _buildSearchBar(isMobile),
              const SizedBox(height: 18),

              // 4. Content (Card Grid or Tree View)
              if (_viewMode == CategoryViewMode.cardGrid)
                _buildCardGrid(isMobile)
              else
                _buildTreeView(isMobile),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER BANNER (Exact Match to Screenshot 1 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    final titleWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
          ),
          child: const Center(
            child: Icon(
              LucideIcons.tag,
              color: Color(0xFF15803D),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Product Categories & Subcategories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Organize your catalog into parent categories (e.g. Snacks) and nested subcategories (e.g. Tea, Coffee) with cover images.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final addCategoryButton = ElevatedButton.icon(
      onPressed: () => _openCreateCategoryDialog(),
      icon: const Icon(LucideIcons.plus, size: 16),
      label: const Text(
        'Add Category',
        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF14532D),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: addCategoryButton),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 16),
        addCategoryButton,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. METRIC SUMMARY CARDS (Screenshot 1 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricCards(bool isMobile) {
    final card1 = _buildSummaryCard(
      icon: LucideIcons.tag,
      iconColor: const Color(0xFF15803D),
      iconBgColor: const Color(0xFFE8F5E9),
      title: 'MAIN CATEGORIES',
      value: '$_mainCategoriesCount',
    );

    final card2 = _buildSummaryCard(
      icon: LucideIcons.layers,
      iconColor: const Color(0xFF2563EB),
      iconBgColor: const Color(0xFFEFF6FF),
      title: 'SUBCATEGORIES',
      value: '$_subcategoriesCount',
    );

    final card3 = _buildSummaryCard(
      icon: LucideIcons.package,
      iconColor: const Color(0xFF9333EA),
      iconBgColor: const Color(0xFFFAF5FF),
      title: 'CATALOG PRODUCTS',
      value: _catalogProductsDisplay,
    );

    if (isMobile) {
      return Column(
        children: [
          card1,
          const SizedBox(height: 10),
          card2,
          const SizedBox(height: 10),
          card3,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 16),
        Expanded(child: card2),
        const SizedBox(width: 16),
        Expanded(child: card3),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. SEARCH BAR, FILTER DROPDOWN & VIEW SWITCHER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchBar(bool isMobile) {
    final searchField = Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'Search categories (e.g. Snacks, Coffee, Tea)...',
          hintStyle:
              const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search,
              size: 16, color: Color(0xFF94A3B8)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );

    final filterDropdown = Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterType,
          icon: const Icon(LucideIcons.chevronDown,
              size: 15, color: Color(0xFF64748B)),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
          onChanged: (val) {
            if (val != null) setState(() => _filterType = val);
          },
          items: const [
            DropdownMenuItem(
                value: 'All Main Categories', child: Text('All Main Categories')),
            DropdownMenuItem(
                value: 'Main Categories Only',
                child: Text('Main Categories Only')),
            DropdownMenuItem(
                value: 'Subcategories Only', child: Text('Subcategories Only')),
            DropdownMenuItem(value: 'Active Only', child: Text('Active Only')),
            DropdownMenuItem(
                value: 'Inactive Only', child: Text('Inactive Only')),
          ],
        ),
      ),
    );

    final viewToggle = Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(
            title: 'Card Grid',
            isSelected: _viewMode == CategoryViewMode.cardGrid,
            onTap: () =>
                setState(() => _viewMode = CategoryViewMode.cardGrid),
          ),
          _buildViewButton(
            title: 'Tree View',
            isSelected: _viewMode == CategoryViewMode.treeView,
            onTap: () =>
                setState(() => _viewMode = CategoryViewMode.treeView),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: filterDropdown),
              const SizedBox(width: 8),
              viewToggle,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 12),
        filterDropdown,
        const SizedBox(width: 12),
        viewToggle,
      ],
    );
  }

  Widget _buildViewButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF14532D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4A. CARD GRID VIEW (Screenshot 1 & 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCardGrid(bool isMobile) {
    final list = _filteredCategories;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(LucideIcons.tag, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'No categories found matching your query.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 3;
        if (width < 640) {
          columns = 1;
        } else if (width < 960) {
          columns = 2;
        }

        // Calculate card width
        final double spacing = 16.0;
        final double totalSpacing = spacing * (columns - 1);
        final double cardWidth = (width - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: list.map((category) {
            return SizedBox(
              width: cardWidth,
              child: _buildCategoryCard(category),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header / Cover Image ──
          Stack(
            children: [
              // Cover area
              Container(
                height: 145,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D),
                  image: category.coverImageUrl != null &&
                          category.coverImageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(category.coverImageUrl!),
                          fit: BoxFit.cover,
                          onError: (_, _) {},
                        )
                      : null,
                ),
                child: (category.coverImageUrl == null ||
                        category.coverImageUrl!.isEmpty)
                    ? Center(
                        child: Icon(
                          LucideIcons.tag,
                          size: 50,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      )
                    : null,
              ),

              // Gradient overlay for contrast
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.20),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Left Badge: Inactive or Main Category
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? const Color(0xFF15803D)
                        : const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    category.isActive ? 'Main Category' : 'Inactive',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Top Right Actions: Edit Name/Photo & Delete
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    // Edit Name / Photo Pill Button
                    InkWell(
                      onTap: () => _openEditCategoryDialog(category),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(LucideIcons.pencil,
                                size: 12, color: Color(0xFF334155)),
                            SizedBox(width: 5),
                            Text(
                              'Edit Name / Photo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Trash Delete Button
                    InkWell(
                      onTap: () => _confirmDeleteCategory(category),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.trash2,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Card Body ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Products Count Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.linkedProductsCount} Products',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  category.description.isNotEmpty
                      ? category.description
                      : 'desc',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Subcategories Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBCATEGORIES (${category.subcategories.length})',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    InkWell(
                      onTap: () => _openCreateCategoryDialog(
                          parentCategory: category),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.plus,
                              size: 12, color: Color(0xFF15803D)),
                          SizedBox(width: 4),
                          Text(
                            'Add Subcategory',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subcategories Container (screenshot placeholder box)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFE2E8F0), width: 1.0),
                  ),
                  child: category.subcategories.isEmpty
                      ? const Text(
                          'No subcategories yet. (e.g. For snacks: add Tea or Coffee)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontStyle: FontStyle.normal,
                          ),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: category.subcategories.map((sub) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                sub,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 14),

                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Card Bottom Footer Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _openEditCategoryDialog(category),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.pencil,
                              size: 13, color: Color(0xFF475569)),
                          SizedBox(width: 5),
                          Text(
                            'Edit Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Switch to products page in navbar
                        ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.products);
                      },
                      child: Row(
                        children: const [
                          Text(
                            'View In Products Catalog',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(LucideIcons.chevronRight,
                              size: 13, color: Color(0xFF475569)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4B. TREE VIEW (Screenshot 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTreeView(bool isMobile) {
    final list = _filteredCategories;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: math.max(680, MediaQuery.of(context).size.width - 48),
          ),
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 24,
            headingRowHeight: 44,
            dataRowMinHeight: 56,
            dataRowMaxHeight: 64,
            headingRowColor:
                WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(
                label: Text(
                  'CATEGORY HIERARCHY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'LINKED PRODUCTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
            rows: list.map((cat) {
              return DataRow(
                cells: [
                  // 1. Hierarchy: Thumbnail + Name + Description
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            image: cat.coverImageUrl != null &&
                                    cat.coverImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(cat.coverImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (cat.coverImageUrl == null ||
                                  cat.coverImageUrl!.isEmpty)
                              ? const Center(
                                  child: Icon(
                                    LucideIcons.tag,
                                    size: 18,
                                    color: Color(0xFF15803D),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (cat.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                cat.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Type
                  DataCell(
                    Text(
                      cat.isMainCategory ? 'Main Category' : 'Subcategory',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),

                  // 3. Linked Products
                  DataCell(
                    Text(
                      '${cat.linkedProductsCount} products',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),

                  // 4. Status (Bullet Dot + Text)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cat.isActive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cat.isActive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Actions (+ Sub, Edit, Trash)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // + Sub
                        InkWell(
                          onTap: () =>
                              _openCreateCategoryDialog(parentCategory: cat),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              '+ Sub',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Edit
                        InkWell(
                          onTap: () => _openEditCategoryDialog(cat),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(LucideIcons.pencil,
                                    size: 11, color: Color(0xFF334155)),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Trash
                        IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              size: 14, color: Color(0xFFEF4444)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 26,
                            minHeight: 26,
                          ),
                          onPressed: () => _confirmDeleteCategory(cat),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CREATE / EDIT CATEGORY MODAL DIALOG (Screenshot 3 & 4)
// ═══════════════════════════════════════════════════════════════

class _CategoryFormDialog extends StatefulWidget {
  final List<CategoryItem> allCategories;
  final CategoryItem? existingCategory;
  final CategoryItem? initialParentCategory;
  final List<AssignableProductItem> uncategorizedProducts;
  final void Function(CategoryItem category, List<String> assignedIds) onSave;

  const _CategoryFormDialog({
    required this.allCategories,
    this.existingCategory,
    this.initialParentCategory,
    required this.uncategorizedProducts,
    required this.onSave,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _coverUrlCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _productSearchCtrl;

  String? _selectedParentId;
  bool _isActive = true;

  // Product assignment selection
  late List<AssignableProductItem> _localProducts;

  // Quick sample images matching screenshot 3
  final List<Map<String, String>> _sampleImages = [
    {
      'name': '🍱 Snacks Tray',
      'url':
          'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': '🍵 Tea Cup',
      'url':
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': '☕ Coffee Beans',
      'url':
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': '🥤 Cold Drinks',
      'url':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': '🥖 Bakery & Bread',
      'url':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': '🍪 Biscuit',
      'url':
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.existingCategory;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _coverUrlCtrl = TextEditingController(text: c?.coverImageUrl ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _productSearchCtrl = TextEditingController();

    _isActive = c?.isActive ?? true;

    if (c != null) {
      _selectedParentId = c.parentCategoryId;
    } else if (widget.initialParentCategory != null) {
      _selectedParentId = widget.initialParentCategory!.id;
    }

    _localProducts = widget.uncategorizedProducts
        .map((p) => AssignableProductItem(
              id: p.id,
              name: p.name,
              sku: p.sku,
              price: p.price,
              stock: p.stock,
              unit: p.unit,
              isSelected: c?.assignedProductIds.contains(p.id) ?? false,
            ))
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _coverUrlCtrl.dispose();
    _descCtrl.dispose();
    _productSearchCtrl.dispose();
    super.dispose();
  }

  int get _selectedProductsCount =>
      _localProducts.where((p) => p.isSelected).length;

  Future<void> _pickImageFile() async {
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (res != null && res.files.isNotEmpty && res.files.first.path != null) {
        setState(() {
          _coverUrlCtrl.text = res.files.first.path!;
        });
      }
    } catch (_) {}
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter category name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isMain = _selectedParentId == null || _selectedParentId!.isEmpty;
    String? parentName;
    if (!isMain) {
      final p = widget.allCategories
          .firstWhere((c) => c.id == _selectedParentId, orElse: () => widget.allCategories.first);
      parentName = p.name;
    }

    final assignedIds = _localProducts
        .where((p) => p.isSelected)
        .map((p) => p.id)
        .toList();

    final resultCat = CategoryItem(
      id: widget.existingCategory?.id ??
          'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: _descCtrl.text.trim(),
      coverImageUrl: _coverUrlCtrl.text.trim().isNotEmpty
          ? _coverUrlCtrl.text.trim()
          : null,
      isMainCategory: isMain,
      parentCategoryId: isMain ? null : _selectedParentId,
      parentCategoryName: parentName,
      linkedProductsCount: assignedIds.isNotEmpty
          ? assignedIds.length
          : (widget.existingCategory?.linkedProductsCount ?? 0),
      isActive: _isActive,
      subcategories: widget.existingCategory?.subcategories ?? [],
      assignedProductIds: assignedIds,
    );

    widget.onSave(resultCat, assignedIds);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCategory != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = math.min(620.0, screenWidth - 32);

    final filteredProducts = _localProducts.where((p) {
      final q = _productSearchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.pencil,
                        color: Color(0xFF15803D),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? 'Edit Category'
                              : 'Create New Category',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedParentId == null
                              ? 'Configuring as a top-level Main Category'
                              : 'Configuring as a nested Subcategory',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // ─── Scrollable Form Body ───
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hierarchy Level
                    const Text(
                      'HIERARCHY LEVEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1.1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedParentId,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown,
                              size: 16, color: Color(0xFF64748B)),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'Top-Level Main Category (No Parent)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            ...widget.allCategories
                                .where((c) =>
                                    c.id != widget.existingCategory?.id &&
                                    c.isMainCategory)
                                .map((cat) {
                              return DropdownMenuItem<String?>(
                                value: cat.id,
                                child: Text(
                                  'Subcategory of: ${cat.name}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedParentId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(LucideIcons.sparkles,
                            size: 12, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4),
                        Text(
                          'Top-level category (e.g. Snacks, Beverages, Groceries).',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 2. Category Name *
                    const Text(
                      'CATEGORY NAME *',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(
                          fontSize: 13.5, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'e.g. Snacks, Beverages, Groceries',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF15803D), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Category Cover Image
                    const Text(
                      'CATEGORY COVER IMAGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Image Preview Box
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            image: _coverUrlCtrl.text.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_coverUrlCtrl.text),
                                    fit: BoxFit.cover,
                                    onError: (_, _) {},
                                  )
                                : null,
                          ),
                          child: _coverUrlCtrl.text.isEmpty
                              ? const Center(
                                  child: Icon(LucideIcons.image,
                                      size: 20, color: Color(0xFF94A3B8)),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _coverUrlCtrl,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF1E293B)),
                                decoration: InputDecoration(
                                  hintText: 'Paste Image URL (https://...)',
                                  hintStyle: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF94A3B8)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: _pickImageFile,
                                icon: const Icon(LucideIcons.uploadCloud,
                                    size: 14),
                                label: const Text('Upload Image File',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF334155),
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4. Quick Sample Images (Screenshot 3)
                    const Text(
                      'QUICK SAMPLE IMAGES',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sampleImages.map((s) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _coverUrlCtrl.text = s['url']!;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              s['name']!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 5. Description (Optional)
                    const Text(
                      'DESCRIPTION (OPTIONAL)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText:
                            'Brief note or summary about this category...',
                        hintStyle: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 6. Category Status Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Category Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Enable or disable this category across your catalog',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () =>
                                setState(() => _isActive = !_isActive),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isActive
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF94A3B8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 7. Assign Products to this Category (Screenshot 4)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.package,
                                        size: 15, color: Color(0xFF15803D)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Assign Products to this Category',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Only products with no category are shown here for safe assignment.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$_selectedProductsCount Selected',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF1F5F9)),

                          // Search & Select All Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: TextField(
                                      controller: _productSearchCtrl,
                                      onChanged: (_) => setState(() {}),
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Filter products by name, SKU...',
                                        hintStyle: TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: Icon(LucideIcons.search,
                                            size: 14,
                                            color: Color(0xFF94A3B8)),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    final anyUnselected = _localProducts
                                        .any((p) => !p.isSelected);
                                    setState(() {
                                      for (final p in _localProducts) {
                                        p.isSelected = anyUnselected;
                                      }
                                    });
                                  },
                                  child: Text(
                                    _localProducts.every((p) => p.isSelected)
                                        ? 'Deselect All'
                                        : 'Select All',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Product List with Checkboxes
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 180),
                            child: filteredProducts.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: Text(
                                        'No uncategorized products found.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: filteredProducts.length,
                                    separatorBuilder: (_, _) => const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Color(0xFFF1F5F9)),
                                    itemBuilder: (context, i) {
                                      final prod = filteredProducts[i];
                                      return CheckboxListTile(
                                        value: prod.isSelected,
                                        onChanged: (val) {
                                          setState(() =>
                                              prod.isSelected = val ?? false);
                                        },
                                        activeColor: const Color(0xFF14532D),
                                        dense: true,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Row(
                                          children: [
                                            Text(
                                              prod.name,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${prod.sku})',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          'Price: ₹${prod.price.toStringAsFixed(0)} • Stock: ${prod.stock} ${prod.unit}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        secondary: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Uncategorized',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Footer Buttons ───
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14532D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Category',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
