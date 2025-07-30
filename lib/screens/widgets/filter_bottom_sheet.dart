import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import '../../constants/api_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final String currentCategory;
  final String currentSortBy;
  final String currentBrandId;

  const FilterBottomSheet({
    Key? key,
    required this.currentCategory,
    required this.currentSortBy,
    required this.currentBrandId,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedSortBy;
  late String _selectedBrandId;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _brands = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory.isEmpty ? 'all' : widget.currentCategory;
    _selectedSortBy = widget.currentSortBy.isEmpty ? AppConfig.defaultSortBy : widget.currentSortBy;
    _selectedBrandId = widget.currentBrandId.isEmpty ? 'all' : widget.currentBrandId;
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final categoriesUrl = '${AppConfig.baseUrl}${AppConfig.categoriesEndpoint}';
      final brandsUrl = '${AppConfig.baseUrl}${AppConfig.brandsEndpoint}';

      print('Loading categories from: $categoriesUrl');
      print('Loading brands from: $brandsUrl');

      final responses = await Future.wait([
        http.get(
          Uri.parse(categoriesUrl),
          headers: ApiConstants.defaultHeaders,
        ).timeout(Duration(seconds: AppConfig.requestTimeout)),
        http.get(
          Uri.parse(brandsUrl),
          headers: ApiConstants.defaultHeaders,
        ).timeout(Duration(seconds: AppConfig.requestTimeout)),
      ]);

      final categoriesResponse = responses[0];
      final brandsResponse = responses[1];

      print('Categories response status: ${categoriesResponse.statusCode}');
      print('Brands response status: ${brandsResponse.statusCode}');

      if (categoriesResponse.statusCode == 200 && brandsResponse.statusCode == 200) {
        final categoriesData = json.decode(categoriesResponse.body);
        final brandsData = json.decode(brandsResponse.body);

        setState(() {
          List<dynamic> categoriesRaw = [];
          List<dynamic> brandsRaw = [];

          if (categoriesData is Map) {
            categoriesRaw = categoriesData['data'] ??
                categoriesData['categories'] ??
                categoriesData['results'] ??
                [];
          } else if (categoriesData is List) {
            categoriesRaw = categoriesData;
          }

          if (brandsData is Map) {
            brandsRaw = brandsData['data'] ??
                brandsData['brands'] ??
                brandsData['results'] ??
                [];
          } else if (brandsData is List) {
            brandsRaw = brandsData;
          }

          _categories = [
            {'id': 'all', 'name': 'All Categories'},
            ...categoriesRaw.map((item) => {
              'id': item['id']?.toString() ?? item['slug']?.toString() ?? '',
              'name': item['name']?.toString() ?? item['title']?.toString() ?? 'Unknown Category',
            }).where((item) => item['id']!.isNotEmpty).toList(),
          ];

          _brands = [
            {'id': 'all', 'name': 'All Brands'},
            ...brandsRaw.map((item) => {
              'id': item['id']?.toString() ?? item['slug']?.toString() ?? '',
              'name': item['name']?.toString() ?? item['title']?.toString() ?? 'Unknown Brand',
            }).where((item) => item['id']!.isNotEmpty).toList(),
          ];

          // Ensure selected values are valid
          if (!_categories.any((cat) => cat['id'] == _selectedCategory)) {
            _selectedCategory = 'all';
          }
          if (!_brands.any((brand) => brand['id'] == _selectedBrandId)) {
            _selectedBrandId = 'all';
          }

          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load filter data. Categories: ${categoriesResponse.statusCode}, Brands: ${brandsResponse.statusCode}');
      }
    } catch (e) {
      print('Error loading filter data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load filters. Using fallback data.';

        _categories = [
          {'id': 'all', 'name': 'All Categories'},
          ...AppConfig.categories.map((cat) => {
            'id': cat,
            'name': cat
                .split('_')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ')
          }).toList(),
        ];

        _brands = [
          {'id': 'all', 'name': 'All Brands'},
          ...AppConfig.brands.map((brand) => {
            'id': brand,
            'name': brand
                .split('_')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ')
          }).toList(),
        ];

        // Ensure selected values are valid
        if (!_categories.any((cat) => cat['id'] == _selectedCategory)) {
          _selectedCategory = 'all';
        }
        if (!_brands.any((brand) => brand['id'] == _selectedBrandId)) {
          _selectedBrandId = 'all';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    if (_errorMessage != null)
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.orange),
                        onPressed: _loadFilterData,
                        tooltip: 'Retry loading filters',
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          if (_errorMessage != null)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using fallback data. Tap refresh to retry.',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading filters...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFilterSection(
                      title: 'Sort By',
                      options: AppConfig.sortOptions.entries
                          .map((e) => {'id': e.key, 'name': e.value})
                          .toList(),
                      selected: _selectedSortBy,
                      onChanged: (value) => setState(() => _selectedSortBy = value),
                    ),
                    SizedBox(height: 24),
                    _buildFilterSection(
                      title: 'Categories (${_categories.length - 1})',
                      options: _categories,
                      selected: _selectedCategory,
                      onChanged: (value) => setState(() => _selectedCategory = value),
                    ),
                    SizedBox(height: 24),
                    _buildFilterSection(
                      title: 'Brands (${_brands.length - 1})',
                      options: _brands,
                      selected: _selectedBrandId,
                      onChanged: (value) => setState(() => _selectedBrandId = value),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = AppConfig.defaultCategory;
                          _selectedSortBy = AppConfig.defaultSortBy;
                          _selectedBrandId = 'all';
                        });
                        Navigator.pop(context, {
                          'category': _selectedCategory,
                          'sortBy': _selectedSortBy,
                          'brandId': _selectedBrandId,
                        });
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'category': _selectedCategory,
                          'sortBy': _selectedSortBy,
                          'brandId': _selectedBrandId,
                        });
                      },
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Map<String, dynamic>> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        if (options.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No options available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option['id'] == selected;
              return FilterChip(
                label: Text(
                  option['name'] ?? option['id'] ?? 'Unknown',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected && option['id'] != null) {
                    onChanged(option['id']);
                  }
                },
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey[100],
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}