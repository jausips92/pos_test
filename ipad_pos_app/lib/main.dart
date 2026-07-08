import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

const _bg = Color(0xfff5f2ec);
const _panel = Color(0xfffffdfa);
const _ink = Color(0xff23211d);
const _muted = Color(0xff736d64);
const _line = Color(0xffded7cb);
const _green = Color(0xff217a59);
const _greenDark = Color(0xff15543d);
const _red = Color(0xffb7473f);
const _redSoft = Color(0xfff6dfdc);
const _yellow = Color(0xffd99b32);
const _rail = Color(0xff242a25);
const _railActive = Color(0xfff8f1df);
const _cartBg = Color(0xffebe4d9);
const _softButton = Color(0xffe7e0d4);
const _radius = 8.0;
const _tabletWideBreakpoint = 700.0;
const _defaultMenuSheetCsvUrl =
    'https://docs.google.com/spreadsheets/d/1Ku0jeMB1VOI5Uryeqt5dgghAQbOccMdJyPLtSpxnJAU/export?format=csv&gid=0';
const _defaultMenuScriptUrl =
    'https://script.google.com/macros/s/AKfycbyhifDzVHC47TOf5tODLMZ9RJmhmKAAfpnsPJUUnbf28Gu-zw9MWijBBTAWQnsPq87DoA/exec';
const _defaultReceiptFontFamily = 'Microsoft JhengHei';
const _receiptFontOptions = <({String label, String family})>[
  (label: '微軟正黑體', family: 'Microsoft JhengHei'),
  (label: '新細明體', family: 'PMingLiU'),
  (label: '標楷體', family: 'DFKai-SB'),
];
const _defaultReceiptPriceMode = 'newLine';
const _receiptPriceModeOptions = <({String label, String value})>[
  (label: '價格換行', value: 'newLine'),
  (label: '價格同列靠右', value: 'sameLine'),
  (label: '不列印價格', value: 'hidden'),
];
const _defaultProductButtonSize = 'standard';
const _productButtonSizeOptions =
    <({String label, String value, double ratio})>[
  (label: '緊湊', value: 'compact', ratio: 1.55),
  (label: '標準', value: 'standard', ratio: 1.30),
  (label: '大按鈕', value: 'large', ratio: 1.08),
];
const _defaultProductButtonColorMode = 'plain';
const _productButtonColorModeOptions = <({String label, String value})>[
  (label: '統一淺色', value: 'plain'),
  (label: '依類別分色', value: 'category'),
  (label: '主色強調', value: 'accent'),
];
const _defaultThemeColor = 'green';
const _themeColorOptions = <({String label, String value})>[
  (label: '湖綠', value: 'green'),
  (label: '深藍', value: 'blue'),
  (label: '暖橘', value: 'orange'),
  (label: '黑金', value: 'dark'),
];

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    backgroundColor: _green,
    foregroundColor: Colors.white,
    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
  );
}

ButtonStyle _secondaryButtonStyle({Color foregroundColor = _ink}) {
  return OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    backgroundColor: _panel,
    foregroundColor: foregroundColor,
    side: const BorderSide(color: _line),
    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
  );
}

ButtonStyle _tinyButtonStyle() {
  return FilledButton.styleFrom(
    minimumSize: const Size(72, 42),
    backgroundColor: _softButton,
    foregroundColor: _ink,
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
  );
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: const BorderSide(color: _green, width: 2),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_radius)),
  );
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: _panel,
    border: Border.all(color: _line),
    borderRadius: BorderRadius.circular(_radius),
    boxShadow: const [
      BoxShadow(color: Color(0x1a27221a), blurRadius: 30, offset: Offset(0, 10))
    ],
  );
}

class _VisualPalette {
  const _VisualPalette({
    required this.primary,
    required this.primaryDark,
    required this.rail,
    required this.railActive,
    required this.cartBg,
    required this.productAccent,
  });

  final Color primary;
  final Color primaryDark;
  final Color rail;
  final Color railActive;
  final Color cartBg;
  final Color productAccent;
}

_VisualPalette _paletteFor(String value) {
  switch (_normalizeThemeColor(value)) {
    case 'blue':
      return const _VisualPalette(
        primary: Color(0xff2f5f9f),
        primaryDark: Color(0xff1f3f6d),
        rail: Color(0xff1f2633),
        railActive: Color(0xffe7efff),
        cartBg: Color(0xffe8edf7),
        productAccent: Color(0xffdbe8ff),
      );
    case 'orange':
      return const _VisualPalette(
        primary: Color(0xffb96022),
        primaryDark: Color(0xff743812),
        rail: Color(0xff30251d),
        railActive: Color(0xffffead7),
        cartBg: Color(0xfff1e4d8),
        productAccent: Color(0xffffead7),
      );
    case 'dark':
      return const _VisualPalette(
        primary: Color(0xffd99b32),
        primaryDark: Color(0xff7a5414),
        rail: Color(0xff161513),
        railActive: Color(0xfff6e4b7),
        cartBg: Color(0xffe4dfd2),
        productAccent: Color(0xfff6e4b7),
      );
    case 'green':
    default:
      return const _VisualPalette(
        primary: _green,
        primaryDark: _greenDark,
        rail: _rail,
        railActive: _railActive,
        cartBg: _cartBg,
        productAccent: Color(0xffe6f3ea),
      );
  }
}

Color _categoryColor(int index) {
  const colors = [
    Color(0xffe8f3ec),
    Color(0xffffefd9),
    Color(0xffe7efff),
    Color(0xffffe5e1),
    Color(0xffeee8ff),
    Color(0xffe8f5f5),
  ];
  return colors[index % colors.length];
}

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '店內點餐 POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: _green, surface: _panel, onSurface: _ink),
        scaffoldBackgroundColor: _bg,
        fontFamilyFallback: const [
          'Noto Sans TC',
          'Microsoft JhengHei',
          'sans-serif'
        ],
        textTheme: ThemeData.light()
            .textTheme
            .apply(bodyColor: _ink, displayColor: _ink),
        useMaterial3: true,
      ),
      home: const PosHomePage(),
    );
  }
}

class Category {
  Category({required this.id, required this.name});

  final int id;
  final String name;

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(id: map['id'] as int, name: map['name'] as String);
  }
}

class Product {
  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.sortOrder,
  });

  final int id;
  final int categoryId;
  final String name;
  final int price;
  final int sortOrder;

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      price: map['price'] as int,
      sortOrder: (map['sort_order'] as int?) ?? (map['id'] as int),
    );
  }
}

class CartLine {
  CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;
}

class AppSettings {
  const AppSettings({
    required this.printerIp,
    required this.printerPort,
    required this.receiptFontSize,
    required this.receiptPriceFontSize,
    required this.receiptLineSpacing,
    required this.receiptVerticalPadding,
    required this.receiptFontFamily,
    required this.receiptPriceMode,
    required this.productButtonSize,
    required this.productColumns,
    required this.productNameFontSize,
    required this.productPriceFontSize,
    required this.productButtonGap,
    required this.categoryButtonHeight,
    required this.categoryFontSize,
    required this.showProductPrice,
    required this.productButtonColorMode,
    required this.cartFontSize,
    required this.cartSize,
    required this.themeColor,
    required this.menuSheetUrl,
    required this.menuScriptUrl,
  });

  final String printerIp;
  final int printerPort;
  final double receiptFontSize;
  final double receiptPriceFontSize;
  final double receiptLineSpacing;
  final double receiptVerticalPadding;
  final String receiptFontFamily;
  final String receiptPriceMode;
  final String productButtonSize;
  final int productColumns;
  final double productNameFontSize;
  final double productPriceFontSize;
  final double productButtonGap;
  final double categoryButtonHeight;
  final double categoryFontSize;
  final bool showProductPrice;
  final String productButtonColorMode;
  final double cartFontSize;
  final double cartSize;
  final String themeColor;
  final String menuSheetUrl;
  final String menuScriptUrl;
}

String _normalizeOption(String? value,
    List<({String label, String value})> options, String fallback) {
  final selected = value?.trim();
  if (selected == null || selected.isEmpty) return fallback;
  return options.any((option) => option.value == selected)
      ? selected
      : fallback;
}

String _normalizeReceiptPriceMode(String? value) =>
    _normalizeOption(value, _receiptPriceModeOptions, _defaultReceiptPriceMode);

String _normalizeProductButtonSize(String? value) {
  final selected = value?.trim();
  if (selected == null || selected.isEmpty) return _defaultProductButtonSize;
  return _productButtonSizeOptions.any((option) => option.value == selected)
      ? selected
      : _defaultProductButtonSize;
}

int _normalizeProductColumns(int? value) {
  final columns = value ?? 0;
  if (columns < 0) return 0;
  if (columns > 6) return 6;
  return columns;
}

double _productButtonRatio(String value) {
  final normalized = _normalizeProductButtonSize(value);
  return _productButtonSizeOptions
      .firstWhere((option) => option.value == normalized)
      .ratio;
}

String _normalizeReceiptFontFamily(String? value) {
  final family = value?.trim();
  if (family == null || family.isEmpty) return _defaultReceiptFontFamily;
  return _receiptFontOptions.any((option) => option.family == family)
      ? family
      : _defaultReceiptFontFamily;
}

double _normalizeReceiptFontSize(double? value) {
  final size = value ?? 52;
  return size > 0 ? size : 52;
}

double _normalizeReceiptPriceFontSize(double? value) {
  final size = value ?? 42;
  return size > 0 ? size : 42;
}

double _normalizeReceiptLineSpacing(double? value) {
  final spacing = value ?? 12;
  return spacing >= 0 ? spacing : 12;
}

double _normalizeReceiptVerticalPadding(double? value) {
  final padding = value ?? 24;
  return padding >= 0 ? padding : 24;
}

double _normalizeProductNameFontSize(double? value) {
  final size = value ?? 21;
  return size > 0 ? size : 21;
}

double _normalizeProductPriceFontSize(double? value) {
  final size = value ?? 23;
  return size > 0 ? size : 23;
}

double _normalizeProductButtonGap(double? value) {
  final gap = value ?? 12;
  return gap >= 0 ? gap : 12;
}

double _normalizeCategoryButtonHeight(double? value) {
  final height = value ?? 66;
  return height > 0 ? height : 66;
}

double _normalizeCategoryFontSize(double? value) {
  final size = value ?? 22;
  return size > 0 ? size : 22;
}

double _normalizeCartFontSize(double? value) {
  final size = value ?? 18;
  return size > 0 ? size : 18;
}

double _normalizeCartSize(double? value) {
  final size = value ?? 1;
  if (size < 0.7) return 0.7;
  if (size > 1.6) return 1.6;
  return size;
}

String _normalizeProductButtonColorMode(String? value) => _normalizeOption(
    value, _productButtonColorModeOptions, _defaultProductButtonColorMode);

String _normalizeThemeColor(String? value) =>
    _normalizeOption(value, _themeColorOptions, _defaultThemeColor);

bool _parseBoolSetting(String? value, {required bool fallback}) {
  if (value == null) return fallback;
  final normalized = value.trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return fallback;
}

int _columnIndex(List<String> header, List<String> aliases) {
  for (final alias in aliases) {
    final index = header.indexOf(alias.toLowerCase());
    if (index != -1) return index;
  }
  return -1;
}

List<List<String>> _parseCsvRows(String source) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (char == '"') {
      if (inQuotes && i + 1 < source.length && source[i + 1] == '"') {
        cell.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      row.add(cell.toString());
      cell.clear();
    } else if ((char == '\n' || char == '\r') && !inQuotes) {
      if (char == '\r' && i + 1 < source.length && source[i + 1] == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
    } else {
      cell.write(char);
    }
  }

  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  return rows;
}

class OrderReceipt {
  OrderReceipt({
    required this.orderNumber,
    required this.printedAt,
    required this.lines,
  });

  final String orderNumber;
  final DateTime printedAt;
  final List<CartLine> lines;
}

class PosDatabase {
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dbPath, 'single_ipad_pos.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            price INTEGER NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE order_sequence (
            date_code TEXT PRIMARY KEY,
            sequence INTEGER NOT NULL
          )
        ''');
        await _insertSeedData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE products ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
          final rows = await db.query('products', orderBy: 'id ASC');
          for (var index = 0; index < rows.length; index++) {
            await db.update('products', {'sort_order': index},
                where: 'id = ?', whereArgs: [rows[index]['id']]);
          }
        }
      },
    );
    _database = db;
    return db;
  }

  Future<void> _insertSeedData(Database db) async {
    final drinkId = await db.insert('categories', {'name': '飲料'});
    final mainId = await db.insert('categories', {'name': '主餐'});
    final sideId = await db.insert('categories', {'name': '小菜'});
    final extraId = await db.insert('categories', {'name': '加料'});

    final products = [
      {'category_id': drinkId, 'name': '古早味紅茶', 'price': 30},
      {'category_id': drinkId, 'name': '招牌奶茶', 'price': 45},
      {'category_id': drinkId, 'name': '檸檬青茶', 'price': 50},
      {'category_id': mainId, 'name': '滷肉飯', 'price': 55},
      {'category_id': mainId, 'name': '牛肉湯麵', 'price': 120},
      {'category_id': mainId, 'name': '椒麻雞飯', 'price': 135},
      {'category_id': sideId, 'name': '皮蛋豆腐', 'price': 45},
      {'category_id': sideId, 'name': '燙青菜', 'price': 40},
      {'category_id': extraId, 'name': '滷蛋', 'price': 15},
      {'category_id': extraId, 'name': '加麵', 'price': 20},
    ];

    for (var index = 0; index < products.length; index++) {
      await db.insert('products', {...products[index], 'sort_order': index});
    }

    await db.insert('settings', {'key': 'printer_ip', 'value': ''});
    await db.insert('settings', {'key': 'printer_port', 'value': '9100'});
    await db.insert('settings', {'key': 'receipt_font_size', 'value': '52'});
    await db
        .insert('settings', {'key': 'receipt_price_font_size', 'value': '42'});
    await db.insert('settings', {'key': 'receipt_line_spacing', 'value': '12'});
    await db
        .insert('settings', {'key': 'receipt_vertical_padding', 'value': '24'});
    await db.insert('settings',
        {'key': 'receipt_font_family', 'value': _defaultReceiptFontFamily});
    await db.insert('settings',
        {'key': 'receipt_price_mode', 'value': _defaultReceiptPriceMode});
    await db.insert('settings',
        {'key': 'product_button_size', 'value': _defaultProductButtonSize});
    await db.insert('settings', {'key': 'product_columns', 'value': '0'});
    await db
        .insert('settings', {'key': 'product_name_font_size', 'value': '21'});
    await db
        .insert('settings', {'key': 'product_price_font_size', 'value': '23'});
    await db.insert('settings', {'key': 'product_button_gap', 'value': '12'});
    await db
        .insert('settings', {'key': 'category_button_height', 'value': '66'});
    await db.insert('settings', {'key': 'category_font_size', 'value': '22'});
    await db.insert('settings', {'key': 'show_product_price', 'value': 'true'});
    await db.insert('settings', {
      'key': 'product_button_color_mode',
      'value': _defaultProductButtonColorMode
    });
    await db.insert('settings', {'key': 'cart_font_size', 'value': '18'});
    await db.insert('settings', {'key': 'cart_size', 'value': '1'});
    await db.insert(
        'settings', {'key': 'theme_color', 'value': _defaultThemeColor});
    await db.insert('settings',
        {'key': 'menu_sheet_url', 'value': _defaultMenuSheetCsvUrl});
    await db.insert(
        'settings', {'key': 'menu_script_url', 'value': _defaultMenuScriptUrl});
  }

  Future<List<Category>> categories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(Category.fromMap).toList();
  }

  Future<List<Product>> products() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'sort_order ASC, id ASC');
    return rows.map(Product.fromMap).toList();
  }

  Future<int> addCategory(String name) async {
    final db = await database;
    return db.insert('categories', {'name': name});
  }

  Future<void> updateCategory(Category category, String name) async {
    final db = await database;
    await db.update('categories', {'name': name},
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteCategory(Category category) async {
    final db = await database;
    await db
        .delete('products', where: 'category_id = ?', whereArgs: [category.id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> addProduct(
      {required String name,
      required int price,
      required int categoryId}) async {
    final db = await database;
    final maxRows = await db.rawQuery(
        'SELECT MAX(sort_order) AS max_order FROM products WHERE category_id = ?',
        [categoryId]);
    final maxOrder = maxRows.first['max_order'] as int?;
    return db.insert('products', {
      'name': name,
      'price': price,
      'category_id': categoryId,
      'sort_order': (maxOrder ?? -1) + 1,
    });
  }

  Future<void> updateProduct(Product product,
      {required String name,
      required int price,
      required int categoryId}) async {
    final db = await database;
    await db.update(
      'products',
      {'name': name, 'price': price, 'category_id': categoryId},
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(Product product) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> updateProductOrder(List<Product> orderedProducts) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var index = 0; index < orderedProducts.length; index++) {
        await txn.update('products', {'sort_order': index},
            where: 'id = ?', whereArgs: [orderedProducts[index].id]);
      }
    });
  }

  Future<AppSettings> settings() async {
    final db = await database;
    final rows = await db.query('settings');
    final map = {
      for (final row in rows) row['key'] as String: row['value'] as String
    };
    return AppSettings(
      printerIp: map['printer_ip'] ?? '',
      printerPort: int.tryParse(map['printer_port'] ?? '') ?? 9100,
      receiptFontSize: _normalizeReceiptFontSize(
          double.tryParse(map['receipt_font_size'] ?? '')),
      receiptPriceFontSize: _normalizeReceiptPriceFontSize(
          double.tryParse(map['receipt_price_font_size'] ?? '')),
      receiptLineSpacing: _normalizeReceiptLineSpacing(
          double.tryParse(map['receipt_line_spacing'] ?? '')),
      receiptVerticalPadding: _normalizeReceiptVerticalPadding(
          double.tryParse(map['receipt_vertical_padding'] ?? '')),
      receiptFontFamily:
          _normalizeReceiptFontFamily(map['receipt_font_family']),
      receiptPriceMode: _normalizeReceiptPriceMode(map['receipt_price_mode']),
      productButtonSize:
          _normalizeProductButtonSize(map['product_button_size']),
      productColumns:
          _normalizeProductColumns(int.tryParse(map['product_columns'] ?? '')),
      productNameFontSize: _normalizeProductNameFontSize(
          double.tryParse(map['product_name_font_size'] ?? '')),
      productPriceFontSize: _normalizeProductPriceFontSize(
          double.tryParse(map['product_price_font_size'] ?? '')),
      productButtonGap: _normalizeProductButtonGap(
          double.tryParse(map['product_button_gap'] ?? '')),
      categoryButtonHeight: _normalizeCategoryButtonHeight(
          double.tryParse(map['category_button_height'] ?? '')),
      categoryFontSize: _normalizeCategoryFontSize(
          double.tryParse(map['category_font_size'] ?? '')),
      showProductPrice:
          _parseBoolSetting(map['show_product_price'], fallback: true),
      productButtonColorMode:
          _normalizeProductButtonColorMode(map['product_button_color_mode']),
      cartFontSize:
          _normalizeCartFontSize(double.tryParse(map['cart_font_size'] ?? '')),
      cartSize: _normalizeCartSize(double.tryParse(map['cart_size'] ?? '')),
      themeColor: _normalizeThemeColor(map['theme_color']),
      menuSheetUrl: _defaultMenuSheetCsvUrl,
      menuScriptUrl: _defaultMenuScriptUrl,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.insert(
        'settings', {'key': 'printer_ip', 'value': settings.printerIp},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
      'settings',
      {'key': 'printer_port', 'value': settings.printerPort.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'receipt_font_size',
        'value': settings.receiptFontSize.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'receipt_price_font_size',
        'value': settings.receiptPriceFontSize.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'receipt_line_spacing',
        'value': settings.receiptLineSpacing.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'receipt_vertical_padding',
        'value': settings.receiptVerticalPadding.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'receipt_font_family',
        'value': _normalizeReceiptFontFamily(settings.receiptFontFamily)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'receipt_price_mode',
        'value': _normalizeReceiptPriceMode(settings.receiptPriceMode)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'product_button_size',
        'value': _normalizeProductButtonSize(settings.productButtonSize)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'product_columns',
        'value': _normalizeProductColumns(settings.productColumns).toString()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'product_name_font_size',
        'value': settings.productNameFontSize.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'product_price_font_size',
        'value': settings.productPriceFontSize.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'product_button_gap',
        'value': settings.productButtonGap.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'category_button_height',
        'value': settings.categoryButtonHeight.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'category_font_size',
        'value': settings.categoryFontSize.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'show_product_price',
        'value': settings.showProductPrice.toString()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'product_button_color_mode',
        'value':
            _normalizeProductButtonColorMode(settings.productButtonColorMode)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'cart_font_size',
        'value': settings.cartFontSize.toStringAsFixed(0)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {'key': 'cart_size', 'value': settings.cartSize.toStringAsFixed(2)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {
        'key': 'theme_color',
        'value': _normalizeThemeColor(settings.themeColor)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {'key': 'menu_sheet_url', 'value': settings.menuSheetUrl.trim()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'settings',
      {'key': 'menu_script_url', 'value': settings.menuScriptUrl.trim()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> syncMenuFromSheetUrl(String sheetUrl) async {
    final uri = Uri.tryParse(sheetUrl.trim());
    if (uri == null || !uri.hasScheme) {
      throw const FormatException('Google Sheet CSV URL 格式不正確');
    }

    final client = HttpClient();
    try {
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 8));
      final response =
          await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Google Sheet 讀取失敗：HTTP ${response.statusCode}');
      }

      final csvText = await response.transform(utf8.decoder).join();
      final rows = _parseCsvRows(csvText);
      if (rows.isEmpty) throw const FormatException('Google Sheet 沒有資料');

      final header =
          rows.first.map((cell) => cell.trim().toLowerCase()).toList();
      final categoryIndex =
          _columnIndex(header, const ['分類', '類別', 'category']);
      final nameIndex =
          _columnIndex(header, const ['品項', '商品', '商品名稱', 'name', 'item']);
      final priceIndex = _columnIndex(header, const ['價格', '單價', 'price']);
      if (categoryIndex == -1 || nameIndex == -1) {
        throw const FormatException('Google Sheet 欄位需包含：分類、品項');
      }

      final parsedRows = <({String category, String name, int price})>[];
      for (final row in rows.skip(1)) {
        if (row.every((cell) => cell.trim().isEmpty)) continue;
        if (row.length <= categoryIndex || row.length <= nameIndex) continue;

        final category = row[categoryIndex].trim();
        final name = row[nameIndex].trim();
        final priceText = priceIndex == -1 || row.length <= priceIndex
            ? ''
            : row[priceIndex].trim().replaceAll(',', '');
        final price = int.tryParse(priceText) ?? 0;
        if (category.isEmpty || name.isEmpty) continue;
        parsedRows.add((category: category, name: name, price: price));
      }
      if (parsedRows.isEmpty)
        throw const FormatException('Google Sheet 沒有可用商品');

      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('products');
        await txn.delete('categories');

        final categoryIds = <String, int>{};
        for (var index = 0; index < parsedRows.length; index++) {
          final row = parsedRows[index];
          var categoryId = categoryIds[row.category];
          if (categoryId == null) {
            categoryId = await txn.insert('categories', {'name': row.category});
            categoryIds[row.category] = categoryId;
          }
          await txn.insert('products', {
            'category_id': categoryId,
            'name': row.name,
            'price': row.price,
            'sort_order': index
          });
        }
      });
      return parsedRows.length;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> pushMenuToSheetUrl(String scriptUrl) async {
    final uri = Uri.tryParse(scriptUrl.trim());
    if (uri == null || !uri.hasScheme) {
      throw const FormatException('Google Apps Script URL 格式不正確');
    }

    final categoriesById = {
      for (final category in await categories()) category.id: category.name
    };
    final menuRows = (await products())
        .map(
          (product) => {
            'category': categoriesById[product.categoryId] ?? '',
            'name': product.name,
            'price': product.price,
          },
        )
        .where((row) => (row['category'] as String).isNotEmpty)
        .toList();

    final client = HttpClient();
    try {
      final request =
          await client.postUrl(uri).timeout(const Duration(seconds: 8));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'action': 'replaceMenu', 'rows': menuRows}));
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode == 302 || response.statusCode == 303) {
        return;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Google Sheet 回寫失敗：HTTP ${response.statusCode}');
      }

      final data = jsonDecode(responseText) as Map<String, Object?>;
      if (data['ok'] != true) {
        throw FormatException('${data['error'] ?? 'Google Sheet 回寫失敗'}');
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<String> nextOrderNumberFromSheetUrl(
      String scriptUrl, DateTime now) async {
    final uri = Uri.tryParse(scriptUrl.trim());
    if (uri == null || !uri.hasScheme) {
      throw const FormatException('Google Apps Script URL 格式不正確');
    }

    final dateCode = _dateCode(now);
    final requestUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'action': 'nextOrderNumber',
        'dateCode': dateCode,
      },
    );

    final client = HttpClient();
    try {
      final request =
          await client.getUrl(requestUri).timeout(const Duration(seconds: 8));
      request.followRedirects = true;
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Google Sheet 單號取得失敗：HTTP ${response.statusCode}');
      }

      final data = jsonDecode(responseText) as Map<String, Object?>;
      if (data['ok'] != true) {
        throw FormatException('${data['error'] ?? 'Google Sheet 單號取得失敗'}');
      }
      final orderNumber = '${data['orderNumber'] ?? ''}'.trim();
      if (orderNumber.isEmpty) {
        throw const FormatException('Google Sheet 單號回傳為空');
      }
      return orderNumber;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> nextOrderNumber(DateTime now) async {
    final db = await database;
    final dateCode = _dateCode(now);
    return db.transaction((txn) async {
      final rows = await txn.query('order_sequence',
          where: 'date_code = ?', whereArgs: [dateCode]);
      final next = rows.isEmpty ? 1 : (rows.first['sequence'] as int) + 1;
      await txn.insert(
        'order_sequence',
        {'date_code': dateCode, 'sequence': next},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return '$dateCode${next.toString().padLeft(4, '0')}';
    });
  }
}

class ReceiptPrinter {
  static const int _paperDots = 576;
  static const double _margin = 32;
  static const double _qtyWidth = 92;
  static const double _priceWidth = 112;

  Future<void> printReceipt({
    required AppSettings settings,
    required OrderReceipt receipt,
  }) async {
    if (settings.printerIp.trim().isEmpty) {
      throw const SocketException('尚未設定出單機 IP');
    }

    final socket = await Socket.connect(
      settings.printerIp.trim(),
      settings.printerPort,
      timeout: const Duration(seconds: 3),
    );
    final raster = await _receiptRaster(
      receipt,
      itemFontSize: settings.receiptFontSize,
      priceFontSize: settings.receiptPriceFontSize,
      lineSpacing: settings.receiptLineSpacing,
      verticalPadding: settings.receiptVerticalPadding,
      fontFamily: settings.receiptFontFamily,
      priceMode: settings.receiptPriceMode,
    );

    // Render as a raster image so Chinese text does not depend on the printer code page.
    socket.add([0x1b, 0x40]);
    socket.add([0x1b, 0x61, 0x01]);
    socket.add(raster);
    socket.add([0x0a, 0x0a, 0x0a]);
    socket.add([0x1d, 0x56, 0x42, 0x00]);
    await socket.flush();
    await socket.close();
  }

  String previewText(OrderReceipt receipt) => _receiptText(receipt);

  String _receiptText(OrderReceipt receipt) {
    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('單號:${receipt.orderNumber}');
    buffer.writeln('================================');
    final priceMode = _normalizeReceiptPriceMode(receipt.lines.isEmpty
        ? _defaultReceiptPriceMode
        : _defaultReceiptPriceMode);
    buffer.writeln(_twoColumns('品項', '數量'));
    for (final line in receipt.lines) {
      buffer.writeln(_twoColumns(line.product.name, 'x${line.quantity}'));
      if (priceMode != 'hidden')
        buffer.writeln('${line.product.price * line.quantity}');
    }
    buffer.writeln('================================');
    buffer.writeln('列印時間:${_printTime(receipt.printedAt)}');
    return buffer.toString();
  }

  String _twoColumns(String name, String quantity) {
    final safeName = name.length > 12 ? name.substring(0, 12) : name;
    return '${safeName.padRight(12)} ${quantity.padLeft(4)}';
  }

  Future<Uint8List> _receiptRaster(
    OrderReceipt receipt, {
    required double itemFontSize,
    required double priceFontSize,
    required double lineSpacing,
    required double verticalPadding,
    required String fontFamily,
    required String priceMode,
  }) async {
    final width = _paperDots;
    final contentWidth = width - (_margin * 2);
    final normalizedPriceMode = _normalizeReceiptPriceMode(priceMode);
    final priceOnNewLine = normalizedPriceMode == 'newLine';
    final priceSameLine = normalizedPriceMode == 'sameLine';
    final showPrice = normalizedPriceMode != 'hidden';
    final rowNameWidth =
        contentWidth - _qtyWidth - (priceSameLine ? _priceWidth : 0);
    final normalizedItemFontSize = _normalizeReceiptFontSize(itemFontSize);
    final normalizedPriceFontSize =
        _normalizeReceiptPriceFontSize(priceFontSize);
    final normalizedLineSpacing = _normalizeReceiptLineSpacing(lineSpacing);
    final normalizedVerticalPadding =
        _normalizeReceiptVerticalPadding(verticalPadding);
    final priceLineSpacing = normalizedLineSpacing / 3;
    final normalizedFontFamily = _normalizeReceiptFontFamily(fontFamily);
    final rowPainters = receipt.lines
        .map(
          (line) => _ReceiptRowPainters(
            name: _textPainter(
                line.product.name, normalizedItemFontSize, FontWeight.w600,
                maxWidth: rowNameWidth,
                fontFamily: normalizedFontFamily,
                maxLines: 2),
            quantity: _textPainter(
                'x${line.quantity}', normalizedItemFontSize, FontWeight.w600,
                maxWidth: _qtyWidth,
                fontFamily: normalizedFontFamily,
                align: TextAlign.center),
            price: _textPainter(
              showPrice ? '${line.product.price * line.quantity}' : '',
              normalizedPriceFontSize,
              FontWeight.w600,
              maxWidth: priceSameLine ? _priceWidth : contentWidth,
              fontFamily: normalizedFontFamily,
              align: priceSameLine ? TextAlign.right : TextAlign.left,
            ),
          ),
        )
        .toList();

    double height = normalizedVerticalPadding + 4;
    height += 18;
    height += _textPainter('單號:${receipt.orderNumber}', 34, FontWeight.w600,
                maxWidth: contentWidth,
                fontFamily: normalizedFontFamily,
                align: TextAlign.center)
            .height +
        14;
    height += 18;
    height += 42;
    for (final row in rowPainters) {
      height += row.nameQuantityHeight +
          (priceOnNewLine ? row.price.height + priceLineSpacing : 0) +
          normalizedLineSpacing;
    }
    height += 20;
    height += _textPainter(
                '列印時間:${_printTime(receipt.printedAt)}', 24, FontWeight.w500,
                maxWidth: contentWidth,
                fontFamily: normalizedFontFamily,
                align: TextAlign.center)
            .height +
        normalizedVerticalPadding +
        18;

    final imageHeight = height.ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), imageHeight.toDouble()), paint);

    double y = normalizedVerticalPadding;
    _drawDivider(canvas, y, width);
    y += 18;
    y = _drawText(canvas, '單號:${receipt.orderNumber}', _margin, y, contentWidth,
            34, FontWeight.w600,
            fontFamily: normalizedFontFamily, align: TextAlign.center) +
        10;
    _drawDivider(canvas, y, width);
    y += 18;
    _drawText(canvas, '品項', _margin, y, rowNameWidth, 26, FontWeight.w500,
        fontFamily: normalizedFontFamily);
    _drawText(
        canvas, '數量', _margin + rowNameWidth, y, _qtyWidth, 26, FontWeight.w500,
        fontFamily: normalizedFontFamily, align: TextAlign.center);
    if (priceSameLine) {
      _drawText(canvas, '金額', _margin + rowNameWidth + _qtyWidth, y,
          _priceWidth, 26, FontWeight.w500,
          fontFamily: normalizedFontFamily, align: TextAlign.right);
    }
    y += 42;

    for (final row in rowPainters) {
      row.name.paint(canvas, Offset(_margin, y));
      row.quantity.paint(canvas, Offset(_margin + rowNameWidth, y));
      if (priceSameLine) {
        row.price.paint(canvas, Offset(_margin + rowNameWidth + _qtyWidth, y));
      }
      y += row.nameQuantityHeight;
      if (priceOnNewLine) {
        y += priceLineSpacing;
        row.price.paint(canvas, Offset(_margin, y));
        y += row.price.height;
      }
      y += normalizedLineSpacing;
    }

    y += 6;
    _drawDivider(canvas, y, width);
    y += 18;
    _drawText(canvas, '列印時間:${_printTime(receipt.printedAt)}', _margin, y,
        contentWidth, 24, FontWeight.w500,
        fontFamily: normalizedFontFamily, align: TextAlign.center);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, imageHeight);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) {
      throw const SocketException('小票圖像產生失敗');
    }
    return _toEscPosRaster(bytes.buffer.asUint8List(), width, imageHeight);
  }

  TextPainter _textPainter(
    String text,
    double fontSize,
    FontWeight fontWeight, {
    required double maxWidth,
    required String fontFamily,
    TextAlign align = TextAlign.left,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          fontFamilyFallback: const [
            'PingFang TC',
            'Noto Sans TC',
            'Microsoft JhengHei',
            'sans-serif'
          ],
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '...',
    );
    painter.layout(maxWidth: maxWidth);
    return painter;
  }

  double _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double maxWidth,
    double fontSize,
    FontWeight fontWeight, {
    required String fontFamily,
    TextAlign align = TextAlign.left,
  }) {
    final painter = _textPainter(text, fontSize, fontWeight,
        maxWidth: maxWidth, fontFamily: fontFamily, align: align);
    painter.paint(canvas, Offset(x, y));
    return y + painter.height;
  }

  void _drawDivider(Canvas canvas, double y, int width) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    canvas.drawLine(Offset(_margin, y), Offset(width - _margin, y), paint);
  }

  Uint8List _toEscPosRaster(Uint8List rgba, int width, int height) {
    final widthBytes = (width + 7) ~/ 8;
    final imageBytes = Uint8List(widthBytes * height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final offset = (y * width + x) * 4;
        final r = rgba[offset];
        final g = rgba[offset + 1];
        final b = rgba[offset + 2];
        final a = rgba[offset + 3];
        final isBlack = a > 0 && r + g + b < 420;
        if (isBlack) {
          imageBytes[y * widthBytes + (x ~/ 8)] |= 0x80 >> (x % 8);
        }
      }
    }

    return Uint8List.fromList([
      0x1d,
      0x76,
      0x30,
      0x00,
      widthBytes & 0xff,
      (widthBytes >> 8) & 0xff,
      height & 0xff,
      (height >> 8) & 0xff,
      ...imageBytes,
    ]);
  }
}

class _ReceiptRowPainters {
  const _ReceiptRowPainters(
      {required this.name, required this.quantity, required this.price});

  final TextPainter name;
  final TextPainter quantity;
  final TextPainter price;

  double get nameQuantityHeight {
    var result = name.height;
    if (quantity.height > result) result = quantity.height;
    return result;
  }
}

class PosHomePage extends StatefulWidget {
  const PosHomePage({super.key});

  @override
  State<PosHomePage> createState() => _PosHomePageState();
}

class _PosHomePageState extends State<PosHomePage> {
  final PosDatabase _database = PosDatabase();
  final ReceiptPrinter _printer = ReceiptPrinter();
  final Map<int, int> _cart = {};

  List<Category> _categories = [];
  List<Product> _products = [];
  int? _activeCategoryId;
  int? _activeAdminCategoryId;
  int _pageIndex = 0;
  AppSettings _settings = const AppSettings(
    printerIp: '',
    printerPort: 9100,
    receiptFontSize: 52,
    receiptPriceFontSize: 42,
    receiptLineSpacing: 12,
    receiptVerticalPadding: 24,
    receiptFontFamily: _defaultReceiptFontFamily,
    receiptPriceMode: _defaultReceiptPriceMode,
    productButtonSize: _defaultProductButtonSize,
    productColumns: 0,
    productNameFontSize: 21,
    productPriceFontSize: 23,
    productButtonGap: 12,
    categoryButtonHeight: 66,
    categoryFontSize: 22,
    showProductPrice: true,
    productButtonColorMode: _defaultProductButtonColorMode,
    cartFontSize: 18,
    cartSize: 1,
    themeColor: _defaultThemeColor,
    menuSheetUrl: _defaultMenuSheetCsvUrl,
    menuScriptUrl: _defaultMenuScriptUrl,
  );
  bool _loading = true;
  bool _checkingOut = false;
  bool _syncingMenu = false;
  int _categoryViewVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _syncMenuOnStartup();
  }

  Future<void> _load() async {
    final categories = await _database.categories();
    final products = await _database.products();
    final settings = await _database.settings();
    final nextActiveCategoryId =
        categories.any((category) => category.id == _activeCategoryId)
            ? _activeCategoryId
            : categories.isEmpty
                ? null
                : categories.first.id;
    final nextActiveAdminCategoryId =
        categories.any((category) => category.id == _activeAdminCategoryId)
            ? _activeAdminCategoryId
            : categories.isEmpty
                ? null
                : categories.first.id;

    setState(() {
      _categories = categories;
      _products = products;
      _settings = settings;
      _activeCategoryId = nextActiveCategoryId;
      _activeAdminCategoryId = nextActiveAdminCategoryId;
      _loading = false;
    });
  }

  Future<void> _syncMenuOnStartup() async {
    try {
      await _database.syncMenuFromSheetUrl(_defaultMenuSheetCsvUrl);
      if (!mounted) return;
      await _load();
    } catch (_) {
      // Keep the local menu usable when the device is offline or Google Sheet is unreachable.
    }
  }

  List<CartLine> get _cartLines {
    return _cart.entries
        .map((entry) {
          final product =
              _firstWhereOrNull(_products, (item) => item.id == entry.key);
          if (product == null) return null;
          return CartLine(product: product, quantity: entry.value);
        })
        .whereType<CartLine>()
        .toList();
  }

  int get _cartTotal {
    return _cartLines.fold(
        0, (sum, line) => sum + line.product.price * line.quantity);
  }

  int get _cartCount {
    return _cartLines.fold(0, (sum, line) => sum + line.quantity);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isNarrow = MediaQuery.sizeOf(context).width < _tabletWideBreakpoint;
    final page = switch (_pageIndex) {
      0 => _OrderPage(
          categories: _categories,
          products: _products,
          activeCategoryId: _activeCategoryId,
          cartLines: _cartLines,
          cartCount: _cartCount,
          cartTotal: _cartTotal,
          settings: _settings,
          categoryViewVersion: _categoryViewVersion,
          checkingOut: _checkingOut,
          onCategorySelected: (id) => setState(() {
            _activeCategoryId = id;
            _categoryViewVersion++;
          }),
          onProductTap: _addToCart,
          onQuantityChange: _changeQuantity,
          onClear: _confirmClearCart,
          onCheckout: _checkout,
        ),
      1 => _MenuAdminPage(
          categories: _categories,
          products: _products,
          selectedCategoryId: _activeAdminCategoryId,
          onSelectCategory: (id) => setState(() => _activeAdminCategoryId = id),
          onAddCategory: () => _editCategory(),
          onEditCategory: _editCategory,
          onDeleteCategory: _deleteCategory,
          onAddProduct: () => _editProduct(),
          onEditProduct: _editProduct,
          onDeleteProduct: _deleteProduct,
          onReorderProducts: _reorderProducts,
        ),
      _ => _SettingsPage(
          settings: _settings,
          syncingMenu: _syncingMenu,
          onSave: _saveSettings,
          onTest: _testPrinter,
          onSyncMenu: _syncMenu),
    };

    return Scaffold(
      body: SafeArea(
        child: isNarrow
            ? Column(children: [
                _TopNav(
                    index: _pageIndex,
                    settings: _settings,
                    onChanged: _setPage),
                Expanded(child: page)
              ])
            : Row(children: [
                _SideNav(
                    index: _pageIndex,
                    settings: _settings,
                    onChanged: _setPage),
                Expanded(child: page)
              ]),
      ),
    );
  }

  void _setPage(int index) {
    setState(() => _pageIndex = index);
  }

  void _addToCart(Product product) {
    setState(() => _cart[product.id] = (_cart[product.id] ?? 0) + 1);
  }

  void _changeQuantity(Product product, int delta) {
    final next = (_cart[product.id] ?? 0) + delta;
    setState(() {
      if (next <= 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = next;
      }
    });
  }

  Future<void> _confirmClearCart() async {
    final ok =
        await _confirm(title: '清空購物車', message: '確定清除目前已點商品？', action: '清空');
    if (ok) setState(_cart.clear);
  }

  Future<void> _checkout() async {
    final lines = _cartLines;
    if (lines.isEmpty || _checkingOut) return;
    if (_settings.printerIp.trim().isEmpty) {
      _snack('請先設定出單機 IP');
      return;
    }

    setState(() => _checkingOut = true);

    try {
      final now = DateTime.now();
      final receipt = OrderReceipt(
        orderNumber: await _nextOrderNumber(now),
        printedAt: now,
        lines: lines,
      );
      await _printer.printReceipt(settings: _settings, receipt: receipt);
      if (!mounted) return;
      setState(() {
        _cart.clear();
        _activeCategoryId = _categories.isEmpty ? null : _categories.first.id;
        _categoryViewVersion++;
      });
      _snack('結帳完成，已送出列印');
    } catch (error) {
      _snack('結帳失敗：$error');
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  Future<void> _saveSettings(AppSettings settings) async {
    await _database.saveSettings(settings);
    await _load();
    _snack('設定已儲存');
  }

  Future<void> _syncMenu(AppSettings settings) async {
    if (_syncingMenu) return;

    setState(() => _syncingMenu = true);
    try {
      await _database.saveSettings(settings);
      final count =
          await _database.syncMenuFromSheetUrl(_defaultMenuSheetCsvUrl);
      _cart.clear();
      await _load();
      _snack('菜單已同步：$count 個商品');
    } catch (error) {
      _snack('菜單同步失敗：$error');
    } finally {
      if (mounted) setState(() => _syncingMenu = false);
    }
  }

  Future<void> _pushMenuIfConfigured() async {
    if (_defaultMenuScriptUrl.trim().isEmpty) return;
    try {
      await _database.pushMenuToSheetUrl(_defaultMenuScriptUrl);
      _snack('菜單已同步回 Google Sheet');
    } catch (error) {
      _snack('本機已更新，但同步 Google Sheet 失敗：$error');
    }
  }

  Future<void> _testPrinter(AppSettings settings) async {
    try {
      final socket = await Socket.connect(
          settings.printerIp, settings.printerPort,
          timeout: const Duration(seconds: 3));
      await socket.close();
      _snack('連線成功');
    } catch (_) {
      _snack('連線失敗');
    }
  }

  Future<String> _nextOrderNumber(DateTime now) async {
    return _database.nextOrderNumber(now);
  }

  Future<void> _editCategory([Category? category]) async {
    final name = await _textDialog(
        title: category == null ? '新增類別' : '修改類別',
        label: '類別名稱',
        initialValue: category?.name ?? '');
    if (name == null || name.trim().isEmpty) return;
    if (category == null) {
      final newCategoryId = await _database.addCategory(name.trim());
      _activeAdminCategoryId = newCategoryId;
    } else {
      await _database.updateCategory(category, name.trim());
    }
    await _load();
    await _pushMenuIfConfigured();
  }

  Future<void> _deleteCategory(Category category) async {
    final ok = await _confirm(
        title: '刪除類別',
        message: '刪除「${category.name}」後，類別內商品也會移除。',
        action: '刪除');
    if (!ok) return;
    await _database.deleteCategory(category);
    _cart.removeWhere(
        (productId, _) => !_products.any((product) => product.id == productId));
    await _load();
    await _pushMenuIfConfigured();
  }

  Future<void> _editProduct([Product? product]) async {
    final result = await showDialog<_ProductEditResult>(
      context: context,
      builder: (context) => _ProductDialog(
        categories: _categories,
        product: product,
        activeCategoryId: _activeAdminCategoryId ?? _activeCategoryId,
      ),
    );
    if (result == null) return;
    if (product == null) {
      await _database.addProduct(
          name: result.name,
          price: result.price,
          categoryId: result.categoryId);
    } else {
      await _database.updateProduct(product,
          name: result.name,
          price: result.price,
          categoryId: result.categoryId);
    }
    _activeAdminCategoryId = result.categoryId;
    await _load();
    await _pushMenuIfConfigured();
  }

  Future<void> _deleteProduct(Product product) async {
    final ok = await _confirm(
        title: '刪除商品', message: '確定刪除「${product.name}」？', action: '刪除');
    if (!ok) return;
    await _database.deleteProduct(product);
    setState(() => _cart.remove(product.id));
    await _load();
    await _pushMenuIfConfigured();
  }

  Future<void> _reorderProducts(
      List<Product> visibleProducts, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= visibleProducts.length ||
        newIndex >= visibleProducts.length) {
      return;
    }
    final reordered = [...visibleProducts];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    await _database.updateProductOrder(reordered);
    await _load();
    await _pushMenuIfConfigured();
  }

  Future<String?> _textDialog(
      {required String title,
      required String label,
      required String initialValue}) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius)),
        backgroundColor: _panel,
        content: TextField(
            controller: controller,
            decoration: _fieldDecoration(label),
            autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: _primaryButtonStyle(),
              child: const Text('儲存')),
        ],
      ),
    );
  }

  Future<bool> _confirm(
      {required String title,
      required String message,
      required String action}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius)),
            backgroundColor: _panel,
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: _primaryButtonStyle(),
                  child: Text(action)),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1300),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav(
      {required this.index, required this.settings, required this.onChanged});

  final int index;
  final AppSettings settings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(settings.themeColor);
    return NavigationRail(
      minWidth: 136,
      selectedIndex: index,
      onDestinationSelected: onChanged,
      labelType: NavigationRailLabelType.all,
      backgroundColor: palette.rail,
      leading: const Padding(
          padding: EdgeInsets.fromLTRB(12, 18, 12, 16), child: _BrandMark()),
      selectedIconTheme: const IconThemeData(color: Color(0xff17231c)),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      indicatorColor: palette.railActive,
      selectedLabelTextStyle: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
      unselectedLabelTextStyle: const TextStyle(
          color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w700),
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.receipt_long), label: Text('點餐')),
        NavigationRailDestination(
            icon: Icon(Icons.restaurant_menu), label: Text('商品')),
        NavigationRailDestination(icon: Icon(Icons.tune), label: Text('設定')),
      ],
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav(
      {required this.index, required this.settings, required this.onChanged});

  final int index;
  final AppSettings settings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(settings.themeColor);
    return Container(
      color: palette.rail,
      padding: const EdgeInsets.all(10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const _BrandMark(horizontal: true),
            const SizedBox(width: 8),
            Expanded(
                child: _TopNavButton(
                    selected: index == 0,
                    icon: Icons.receipt_long,
                    palette: palette,
                    label: '點餐',
                    onTap: () => onChanged(0))),
            const SizedBox(width: 8),
            Expanded(
                child: _TopNavButton(
                    selected: index == 1,
                    icon: Icons.restaurant_menu,
                    palette: palette,
                    label: '商品',
                    onTap: () => onChanged(1))),
            const SizedBox(width: 8),
            Expanded(
                child: _TopNavButton(
                    selected: index == 2,
                    icon: Icons.tune,
                    palette: palette,
                    label: '設定',
                    onTap: () => onChanged(2))),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.horizontal = false});

  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 56,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: _yellow, borderRadius: BorderRadius.circular(_radius)),
      child: const Text('POS',
          style:
              TextStyle(color: Color(0xff1f1a12), fontWeight: FontWeight.w900)),
    );
    final label = const Text('店內點餐',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800));
    if (horizontal) {
      return Row(children: [mark, const SizedBox(width: 8), label]);
    }
    return Column(children: [mark, const SizedBox(height: 8), label]);
  }
}

class _TopNavButton extends StatelessWidget {
  const _TopNavButton(
      {required this.selected,
      required this.icon,
      required this.palette,
      required this.label,
      required this.onTap});

  final bool selected;
  final IconData icon;
  final _VisualPalette palette;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor:
              selected ? palette.railActive : Colors.white.withAlpha(20),
          foregroundColor:
              selected ? const Color(0xff17231c) : const Color(0xffe9e3d8),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
        ),
      ),
    );
  }
}

class _OrderPage extends StatelessWidget {
  const _OrderPage({
    required this.categories,
    required this.products,
    required this.activeCategoryId,
    required this.cartLines,
    required this.cartCount,
    required this.cartTotal,
    required this.settings,
    required this.categoryViewVersion,
    required this.checkingOut,
    required this.onCategorySelected,
    required this.onProductTap,
    required this.onQuantityChange,
    required this.onClear,
    required this.onCheckout,
  });

  final List<Category> categories;
  final List<Product> products;
  final int? activeCategoryId;
  final List<CartLine> cartLines;
  final int cartCount;
  final int cartTotal;
  final AppSettings settings;
  final int categoryViewVersion;
  final bool checkingOut;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<Product> onProductTap;
  final void Function(Product product, int delta) onQuantityChange;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products
        .where((product) => product.categoryId == activeCategoryId)
        .toList();
    final isWide = MediaQuery.sizeOf(context).width >= _tabletWideBreakpoint;
    final columns = _normalizeProductColumns(settings.productColumns);
    final crossAxisCount = columns == 0 ? (isWide ? 4 : 2) : columns;
    final productRatio = _productButtonRatio(settings.productButtonSize);
    final productNameFontSize =
        _normalizeProductNameFontSize(settings.productNameFontSize);
    final productPriceFontSize =
        _normalizeProductPriceFontSize(settings.productPriceFontSize);
    final productGap = _normalizeProductButtonGap(settings.productButtonGap);
    final categoryButtonHeight =
        _normalizeCategoryButtonHeight(settings.categoryButtonHeight);
    final categoryFontSize =
        _normalizeCategoryFontSize(settings.categoryFontSize);
    final productColorMode =
        _normalizeProductButtonColorMode(settings.productButtonColorMode);
    final palette = _paletteFor(settings.themeColor);
    final showProductPrice = settings.showProductPrice;

    final productPane = Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(title: '點餐', subtitle: '選擇商品加入購物車'),
          const SizedBox(height: 16),
          SizedBox(
            height: categoryButtonHeight + 4,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category.id == activeCategoryId;
                return SizedBox(
                  height: categoryButtonHeight,
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: selected,
                    selectedColor: palette.primary,
                    backgroundColor: _panel,
                    side: BorderSide(color: selected ? palette.primary : _line),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_radius)),
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : _ink,
                        fontSize: categoryFontSize,
                        fontWeight: FontWeight.w800),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    onSelected: (_) => onCategorySelected(category.id),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              key: ValueKey('$activeCategoryId-$categoryViewVersion'),
              itemCount: visibleProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: productRatio,
                crossAxisSpacing: productGap,
                mainAxisSpacing: productGap,
              ),
              itemBuilder: (context, index) {
                final product = visibleProducts[index];
                final categoryIndex = categories.indexWhere(
                    (category) => category.id == product.categoryId);
                final productColor = switch (productColorMode) {
                  'category' =>
                    _categoryColor(categoryIndex < 0 ? index : categoryIndex),
                  'accent' => palette.productAccent,
                  _ => _panel,
                };
                return Material(
                  color: productColor,
                  borderRadius: BorderRadius.circular(_radius),
                  child: InkWell(
                    onTap: () => onProductTap(product),
                    borderRadius: BorderRadius.circular(_radius),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffd6cfc4)),
                        borderRadius: BorderRadius.circular(_radius),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0a000000), offset: Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _ink,
                                fontSize: productNameFontSize,
                                height: 1.22,
                                fontWeight: FontWeight.w800),
                          ),
                          if (showProductPrice)
                            Text(
                              '\$${product.price}',
                              style: TextStyle(
                                  color: palette.primaryDark,
                                  fontSize: productPriceFontSize,
                                  fontWeight: FontWeight.w900),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    final cartPane = _CartPane(
      lines: cartLines,
      count: cartCount,
      total: cartTotal,
      settings: settings,
      checkingOut: checkingOut,
      onQuantityChange: onQuantityChange,
      onClear: onClear,
      onCheckout: onCheckout,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(children: [
              Expanded(flex: 3, child: productPane),
              const SizedBox(width: 16),
              Expanded(
                  flex: (_normalizeCartSize(settings.cartSize) * 2).round(),
                  child: cartPane)
            ])
          : Column(children: [
              Expanded(child: productPane),
              const SizedBox(height: 12),
              SizedBox(
                  height: 310 * _normalizeCartSize(settings.cartSize),
                  child: cartPane)
            ]),
    );
  }
}

class _CartPane extends StatelessWidget {
  const _CartPane({
    required this.lines,
    required this.count,
    required this.total,
    required this.settings,
    required this.checkingOut,
    required this.onQuantityChange,
    required this.onClear,
    required this.onCheckout,
  });

  final List<CartLine> lines;
  final int count;
  final int total;
  final AppSettings settings;
  final bool checkingOut;
  final void Function(Product product, int delta) onQuantityChange;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final cartFontSize = _normalizeCartFontSize(settings.cartFontSize);
    final palette = _paletteFor(settings.themeColor);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: palette.cartBg,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('購物車',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('$count 項',
                        style: const TextStyle(
                            color: _muted, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Text('\$$total',
                  style: TextStyle(
                      color: palette.primaryDark,
                      fontSize: 36,
                      height: 1,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: lines.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: _line, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(_radius)),
                    child: const Text('購物車尚無商品',
                        style: TextStyle(color: _muted, fontSize: 18)),
                  )
                : ListView.separated(
                    itemCount: lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      return Container(
                        constraints: const BoxConstraints(minHeight: 62),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(_radius)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(line.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: cartFontSize,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text('\$${line.product.price}',
                                      style: TextStyle(
                                          color: _muted,
                                          fontSize: cartFontSize * 0.85)),
                                ],
                              ),
                            ),
                            _QuantityButton(
                                icon: Icons.remove,
                                onPressed: () =>
                                    onQuantityChange(line.product, -1)),
                            SizedBox(
                                width: 42,
                                child: Text('${line.quantity}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: cartFontSize,
                                        fontWeight: FontWeight.w800))),
                            _QuantityButton(
                                icon: Icons.add,
                                onPressed: () =>
                                    onQuantityChange(line.product, 1)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                  width: 96,
                  child: OutlinedButton(
                      onPressed: lines.isEmpty ? null : onClear,
                      style: _secondaryButtonStyle(foregroundColor: _red),
                      child: const Text('清空'))),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: lines.isEmpty || checkingOut ? null : onCheckout,
                  style: _primaryButtonStyle(),
                  child: Text(checkingOut ? '結帳中...' : '結帳'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 42,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: _softButton,
          foregroundColor: _ink,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
        ),
      ),
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage(
      {required this.settings,
      required this.syncingMenu,
      required this.onSave,
      required this.onTest,
      required this.onSyncMenu});

  final AppSettings settings;
  final bool syncingMenu;
  final ValueChanged<AppSettings> onSave;
  final ValueChanged<AppSettings> onTest;
  final ValueChanged<AppSettings> onSyncMenu;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _fontSizeController;
  late final TextEditingController _priceFontSizeController;
  late final TextEditingController _lineSpacingController;
  late final TextEditingController _verticalPaddingController;
  late final TextEditingController _productColumnsController;
  late final TextEditingController _productNameFontSizeController;
  late final TextEditingController _productPriceFontSizeController;
  late final TextEditingController _productButtonGapController;
  late final TextEditingController _categoryButtonHeightController;
  late final TextEditingController _categoryFontSizeController;
  late final TextEditingController _cartFontSizeController;
  late final TextEditingController _cartSizeController;
  late String _receiptFontFamily;
  late String _receiptPriceMode;
  late String _productButtonSize;
  late String _productButtonColorMode;
  late String _themeColor;
  late bool _showProductPrice;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.settings.printerIp);
    _portController =
        TextEditingController(text: widget.settings.printerPort.toString());
    _fontSizeController = TextEditingController(
        text: widget.settings.receiptFontSize.toStringAsFixed(0));
    _priceFontSizeController = TextEditingController(
        text: widget.settings.receiptPriceFontSize.toStringAsFixed(0));
    _lineSpacingController = TextEditingController(
        text: widget.settings.receiptLineSpacing.toStringAsFixed(0));
    _verticalPaddingController = TextEditingController(
        text: widget.settings.receiptVerticalPadding.toStringAsFixed(0));
    _productColumnsController =
        TextEditingController(text: widget.settings.productColumns.toString());
    _productNameFontSizeController = TextEditingController(
        text: widget.settings.productNameFontSize.toStringAsFixed(0));
    _productPriceFontSizeController = TextEditingController(
        text: widget.settings.productPriceFontSize.toStringAsFixed(0));
    _productButtonGapController = TextEditingController(
        text: widget.settings.productButtonGap.toStringAsFixed(0));
    _categoryButtonHeightController = TextEditingController(
        text: widget.settings.categoryButtonHeight.toStringAsFixed(0));
    _categoryFontSizeController = TextEditingController(
        text: widget.settings.categoryFontSize.toStringAsFixed(0));
    _cartFontSizeController = TextEditingController(
        text: widget.settings.cartFontSize.toStringAsFixed(0));
    _cartSizeController = TextEditingController(
        text: widget.settings.cartSize.toStringAsFixed(2));
    _receiptFontFamily =
        _normalizeReceiptFontFamily(widget.settings.receiptFontFamily);
    _receiptPriceMode =
        _normalizeReceiptPriceMode(widget.settings.receiptPriceMode);
    _productButtonSize =
        _normalizeProductButtonSize(widget.settings.productButtonSize);
    _productButtonColorMode = _normalizeProductButtonColorMode(
        widget.settings.productButtonColorMode);
    _themeColor = _normalizeThemeColor(widget.settings.themeColor);
    _showProductPrice = widget.settings.showProductPrice;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _fontSizeController.dispose();
    _priceFontSizeController.dispose();
    _lineSpacingController.dispose();
    _verticalPaddingController.dispose();
    _productColumnsController.dispose();
    _productNameFontSizeController.dispose();
    _productPriceFontSizeController.dispose();
    _productButtonGapController.dispose();
    _categoryButtonHeightController.dispose();
    _categoryFontSizeController.dispose();
    _cartFontSizeController.dispose();
    _cartSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget section(String title, List<Widget> children) {
      return Container(
        width: 760,
        padding: const EdgeInsets.all(22),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _Header(title: '設定', subtitle: '調整列印、點餐畫面與顏色'),
        const SizedBox(height: 18),
        section('出單機', [
          TextField(
              controller: _ipController,
              style: const TextStyle(fontSize: 20),
              decoration: _fieldDecoration('出單機 IP')),
          const SizedBox(height: 12),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('Port'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fontSizeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('出單字大小'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceFontSizeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('列印金額字大小'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lineSpacingController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('出單上下間距'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _verticalPaddingController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('列印上下留白'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _receiptFontFamily,
            decoration: _fieldDecoration('出單字型'),
            items: _receiptFontOptions
                .map((option) => DropdownMenuItem<String>(
                    value: option.family, child: Text(option.label)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _receiptFontFamily = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _receiptPriceMode,
            decoration: _fieldDecoration('價格列印方式'),
            items: _receiptPriceModeOptions
                .map((option) => DropdownMenuItem<String>(
                    value: option.value, child: Text(option.label)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _receiptPriceMode = value);
            },
          ),
        ]),
        const SizedBox(height: 18),
        section('商品按鈕', [
          DropdownButtonFormField<String>(
            value: _productButtonSize,
            decoration: _fieldDecoration('商品按鈕大小'),
            items: _productButtonSizeOptions
                .map((option) => DropdownMenuItem<String>(
                    value: option.value, child: Text(option.label)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _productButtonSize = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _productButtonGapController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('商品按鈕間距'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryButtonHeightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('類別按鈕高度'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryFontSizeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('類別文字大小'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _productNameFontSizeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('商品名稱字大小'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _productPriceFontSizeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('商品金額字大小'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _productColumnsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('每列商品數量'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _showProductPrice,
            contentPadding: EdgeInsets.zero,
            title: const Text('商品按鈕顯示價格'),
            onChanged: (value) => setState(() => _showProductPrice = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _productButtonColorMode,
            decoration: _fieldDecoration('商品按鈕顏色模式'),
            items: _productButtonColorModeOptions
                .map((option) => DropdownMenuItem<String>(
                    value: option.value, child: Text(option.label)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _productButtonColorMode = value);
            },
          ),
        ]),
        const SizedBox(height: 18),
        section('購物車', [
          TextField(
            controller: _cartFontSizeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('購物車字大小'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cartSizeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20),
            decoration: _fieldDecoration('購物車大小'),
          ),
        ]),
        const SizedBox(height: 18),
        section('整體色系', [
          DropdownButtonFormField<String>(
            value: _themeColor,
            decoration: _fieldDecoration('整體顏色'),
            items: _themeColorOptions
                .map((option) => DropdownMenuItem<String>(
                    value: option.value, child: Text(option.label)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _themeColor = value);
            },
          ),
        ]),
        const SizedBox(height: 18),
        section('同步與儲存', [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.syncingMenu
                  ? null
                  : () => widget.onSyncMenu(_settings()),
              style: _secondaryButtonStyle(foregroundColor: _greenDark),
              icon: widget.syncingMenu
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync),
              label: Text(widget.syncingMenu ? '同步中...' : '同步 Google Sheet 菜單'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => widget.onTest(_settings()),
                      style: _secondaryButtonStyle(),
                      child: const Text('測試連線'))),
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: () => widget.onSave(_settings()),
                      style: _primaryButtonStyle(),
                      child: const Text('儲存設定'))),
            ],
          ),
        ]),
      ],
    );
  }

  AppSettings _settings() {
    return AppSettings(
      printerIp: _ipController.text.trim(),
      printerPort: int.tryParse(_portController.text.trim()) ?? 9100,
      receiptFontSize: _normalizeReceiptFontSize(
          double.tryParse(_fontSizeController.text.trim())),
      receiptPriceFontSize: _normalizeReceiptPriceFontSize(
          double.tryParse(_priceFontSizeController.text.trim())),
      receiptLineSpacing: _normalizeReceiptLineSpacing(
          double.tryParse(_lineSpacingController.text.trim())),
      receiptVerticalPadding: _normalizeReceiptVerticalPadding(
          double.tryParse(_verticalPaddingController.text.trim())),
      receiptFontFamily: _normalizeReceiptFontFamily(_receiptFontFamily),
      receiptPriceMode: _normalizeReceiptPriceMode(_receiptPriceMode),
      productButtonSize: _normalizeProductButtonSize(_productButtonSize),
      productColumns: _normalizeProductColumns(
          int.tryParse(_productColumnsController.text.trim())),
      productNameFontSize: _normalizeProductNameFontSize(
          double.tryParse(_productNameFontSizeController.text.trim())),
      productPriceFontSize: _normalizeProductPriceFontSize(
          double.tryParse(_productPriceFontSizeController.text.trim())),
      productButtonGap: _normalizeProductButtonGap(
          double.tryParse(_productButtonGapController.text.trim())),
      categoryButtonHeight: _normalizeCategoryButtonHeight(
          double.tryParse(_categoryButtonHeightController.text.trim())),
      categoryFontSize: _normalizeCategoryFontSize(
          double.tryParse(_categoryFontSizeController.text.trim())),
      showProductPrice: _showProductPrice,
      productButtonColorMode:
          _normalizeProductButtonColorMode(_productButtonColorMode),
      cartFontSize: _normalizeCartFontSize(
          double.tryParse(_cartFontSizeController.text.trim())),
      cartSize:
          _normalizeCartSize(double.tryParse(_cartSizeController.text.trim())),
      themeColor: _normalizeThemeColor(_themeColor),
      menuSheetUrl: _defaultMenuSheetCsvUrl,
      menuScriptUrl: _defaultMenuScriptUrl,
    );
  }
}

class _MenuAdminPage extends StatelessWidget {
  const _MenuAdminPage({
    required this.categories,
    required this.products,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.onAddCategory,
    required this.onEditCategory,
    required this.onDeleteCategory,
    required this.onAddProduct,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onReorderProducts,
  });

  final List<Category> categories;
  final List<Product> products;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelectCategory;
  final VoidCallback onAddCategory;
  final ValueChanged<Category> onEditCategory;
  final ValueChanged<Category> onDeleteCategory;
  final VoidCallback onAddProduct;
  final ValueChanged<Product> onEditProduct;
  final ValueChanged<Product> onDeleteProduct;
  final void Function(List<Product> products, int oldIndex, int newIndex)
      onReorderProducts;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _tabletWideBreakpoint;
    final selectedCategory = _firstWhereOrNull(
        categories, (category) => category.id == selectedCategoryId);
    final visibleProducts = selectedCategory == null
        ? <Product>[]
        : products
            .where((product) => product.categoryId == selectedCategory.id)
            .toList();
    final categoryPanel = _AdminPanel(
      title: '類別',
      onAdd: onAddCategory,
      children: categories
          .map(
            (category) => ListTile(
              selected: category.id == selectedCategoryId,
              tileColor: Colors.white,
              selectedTileColor: const Color(0xffeef7f1),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: category.id == selectedCategoryId ? _green : _line),
                borderRadius: BorderRadius.circular(_radius),
              ),
              title: Text(category.name),
              subtitle: Text(
                  '${products.where((product) => product.categoryId == category.id).length} 個商品'),
              onTap: () => onSelectCategory(category.id),
              trailing: _EditDeleteButtons(
                  onEdit: () => onEditCategory(category),
                  onDelete: () => onDeleteCategory(category)),
            ),
          )
          .toList(),
    );
    final productPanel = _AdminPanel(
      title: selectedCategory == null ? '商品' : '${selectedCategory.name}商品',
      onAdd: onAddProduct,
      onReorder: visibleProducts.length < 2
          ? null
          : (oldIndex, newIndex) =>
              onReorderProducts(visibleProducts, oldIndex, newIndex),
      children: visibleProducts
          .map(
            (product) => ListTile(
              key: ValueKey('product-${product.id}'),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: const BorderSide(color: _line),
                  borderRadius: BorderRadius.circular(_radius)),
              title: Text('${product.name} · \$${product.price}'),
              subtitle: Text(_firstWhereOrNull(categories,
                      (category) => category.id == product.categoryId)?.name ??
                  '未分類'),
              trailing: _EditDeleteButtons(
                  onEdit: () => onEditProduct(product),
                  onDelete: () => onDeleteProduct(product)),
            ),
          )
          .toList(),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(title: '點餐內容設定', subtitle: '管理類別與商品'),
          const SizedBox(height: 18),
          Expanded(
            child: isWide
                ? Row(children: [
                    SizedBox(width: 360, child: categoryPanel),
                    const SizedBox(width: 18),
                    Expanded(child: productPanel)
                  ])
                : ListView(children: [
                    SizedBox(height: 360, child: categoryPanel),
                    const SizedBox(height: 18),
                    SizedBox(height: 520, child: productPanel)
                  ]),
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel(
      {required this.title,
      required this.onAdd,
      required this.children,
      this.onReorder});

  final String title;
  final VoidCallback onAdd;
  final List<Widget> children;
  final ReorderCallback? onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _line))),
            child: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800))),
                SizedBox(
                    height: 42,
                    child: FilledButton(
                        onPressed: onAdd,
                        style: _tinyButtonStyle(),
                        child: const Text('新增'))),
              ],
            ),
          ),
          Expanded(
            child: onReorder == null
                ? ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) => children[index],
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: children.length,
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    buildDefaultDragHandles: true,
                    onReorder: onReorder!,
                    itemBuilder: (context, index) => Padding(
                      key: children[index].key ?? ValueKey(index),
                      padding: EdgeInsets.only(
                          bottom: index == children.length - 1 ? 0 : 8),
                      child: children[index],
                    ),
                    itemCount: children.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _EditDeleteButtons extends StatelessWidget {
  const _EditDeleteButtons({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
          style: IconButton.styleFrom(
              backgroundColor: const Color(0xffeee7db),
              foregroundColor: _ink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius))),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          style: IconButton.styleFrom(
              backgroundColor: _redSoft,
              foregroundColor: _red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius))),
        ),
      ],
    );
  }
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog(
      {required this.categories,
      required this.product,
      required this.activeCategoryId});

  final List<Category> categories;
  final Product? product;
  final int? activeCategoryId;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late int _categoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _categoryId = widget.product?.categoryId ??
        widget.activeCategoryId ??
        widget.categories.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? '新增商品' : '修改商品'),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      backgroundColor: _panel,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: _fieldDecoration('商品名稱')),
            const SizedBox(height: 12),
            TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('價格')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: _fieldDecoration('所屬類別'),
              items: widget.categories
                  .map((category) => DropdownMenuItem(
                      value: category.id, child: Text(category.name)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _categoryId = value ?? _categoryId),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
            onPressed: _submit,
            style: _primaryButtonStyle(),
            child: const Text('儲存')),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    if (name.isEmpty || price == null || price < 0) return;
    Navigator.pop(context,
        _ProductEditResult(name: name, price: price, categoryId: _categoryId));
  }
}

class _ProductEditResult {
  _ProductEditResult(
      {required this.name, required this.price, required this.categoryId});

  final String name;
  final int price;
  final int categoryId;
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

String _dateCode(DateTime date) {
  final year = date.year.toString().substring(2);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year$month$day';
}

String _printTime(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final second = date.second.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute:$second';
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
