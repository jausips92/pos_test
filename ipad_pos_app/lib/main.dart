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
    boxShadow: const [BoxShadow(color: Color(0x1a27221a), blurRadius: 30, offset: Offset(0, 10))],
  );
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
        colorScheme: ColorScheme.fromSeed(seedColor: _green, surface: _panel, onSurface: _ink),
        scaffoldBackgroundColor: _bg,
        fontFamilyFallback: const ['Noto Sans TC', 'Microsoft JhengHei', 'sans-serif'],
        textTheme: ThemeData.light().textTheme.apply(bodyColor: _ink, displayColor: _ink),
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
  });

  final int id;
  final int categoryId;
  final String name;
  final int price;

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      price: map['price'] as int,
    );
  }
}

class CartLine {
  CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;
}

class AppSettings {
  const AppSettings({required this.printerIp, required this.printerPort});

  final String printerIp;
  final int printerPort;
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
      version: 1,
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

    for (final product in products) {
      await db.insert('products', product);
    }

    await db.insert('settings', {'key': 'printer_ip', 'value': ''});
    await db.insert('settings', {'key': 'printer_port', 'value': '9100'});
  }

  Future<List<Category>> categories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(Category.fromMap).toList();
  }

  Future<List<Product>> products() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'id ASC');
    return rows.map(Product.fromMap).toList();
  }

  Future<int> addCategory(String name) async {
    final db = await database;
    return db.insert('categories', {'name': name});
  }

  Future<void> updateCategory(Category category, String name) async {
    final db = await database;
    await db.update('categories', {'name': name}, where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteCategory(Category category) async {
    final db = await database;
    await db.delete('products', where: 'category_id = ?', whereArgs: [category.id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> addProduct({required String name, required int price, required int categoryId}) async {
    final db = await database;
    return db.insert('products', {
      'name': name,
      'price': price,
      'category_id': categoryId,
    });
  }

  Future<void> updateProduct(Product product, {required String name, required int price, required int categoryId}) async {
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

  Future<AppSettings> settings() async {
    final db = await database;
    final rows = await db.query('settings');
    final map = {for (final row in rows) row['key'] as String: row['value'] as String};
    return AppSettings(
      printerIp: map['printer_ip'] ?? '',
      printerPort: int.tryParse(map['printer_port'] ?? '') ?? 9100,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.insert('settings', {'key': 'printer_ip', 'value': settings.printerIp}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
      'settings',
      {'key': 'printer_port', 'value': settings.printerPort.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> nextOrderNumber(DateTime now) async {
    final db = await database;
    final dateCode = _dateCode(now);
    return db.transaction((txn) async {
      final rows = await txn.query('order_sequence', where: 'date_code = ?', whereArgs: [dateCode]);
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
    final raster = await _receiptRaster(receipt);

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
    buffer.writeln(_threeColumns('品項', '數量', '單價'));
    for (final line in receipt.lines) {
      buffer.writeln(_threeColumns(line.product.name, 'x${line.quantity}', '${line.product.price}'));
    }
    buffer.writeln('================================');
    buffer.writeln('列印時間:${_printTime(receipt.printedAt)}');
    return buffer.toString();
  }

  String _threeColumns(String name, String quantity, String price) {
    final safeName = name.length > 12 ? name.substring(0, 12) : name;
    return '${safeName.padRight(12)} ${quantity.padLeft(4)} ${price.padLeft(5)}';
  }

  Future<Uint8List> _receiptRaster(OrderReceipt receipt) async {
    final width = _paperDots;
    final contentWidth = width - (_margin * 2);
    final rowNameWidth = contentWidth - _qtyWidth - _priceWidth;
    final rowPainters = receipt.lines
        .map(
          (line) => _ReceiptRowPainters(
            name: _textPainter(line.product.name, 34, FontWeight.w800, maxWidth: rowNameWidth, maxLines: 2),
            quantity: _textPainter('x${line.quantity}', 34, FontWeight.w800, maxWidth: _qtyWidth, align: TextAlign.center),
            price: _textPainter('${line.product.price}', 34, FontWeight.w800, maxWidth: _priceWidth, align: TextAlign.right),
          ),
        )
        .toList();

    double height = 28;
    height += 18;
    height += _textPainter('單號:${receipt.orderNumber}', 34, FontWeight.w800, maxWidth: contentWidth, align: TextAlign.center).height + 14;
    height += 18;
    height += 42;
    for (final row in rowPainters) {
      height += row.height + 12;
    }
    height += 20;
    height += _textPainter('列印時間:${_printTime(receipt.printedAt)}', 24, FontWeight.w700, maxWidth: contentWidth, align: TextAlign.center).height + 42;

    final imageHeight = height.ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), imageHeight.toDouble()), paint);

    double y = 24;
    _drawDivider(canvas, y, width);
    y += 18;
    y = _drawText(canvas, '單號:${receipt.orderNumber}', _margin, y, contentWidth, 34, FontWeight.w800, align: TextAlign.center) + 10;
    _drawDivider(canvas, y, width);
    y += 18;
    _drawText(canvas, '品項', _margin, y, rowNameWidth, 26, FontWeight.w700);
    _drawText(canvas, '數量', _margin + rowNameWidth, y, _qtyWidth, 26, FontWeight.w700, align: TextAlign.center);
    _drawText(canvas, '單價', _margin + rowNameWidth + _qtyWidth, y, _priceWidth, 26, FontWeight.w700, align: TextAlign.right);
    y += 42;

    for (final row in rowPainters) {
      row.name.paint(canvas, Offset(_margin, y));
      row.quantity.paint(canvas, Offset(_margin + rowNameWidth, y));
      row.price.paint(canvas, Offset(_margin + rowNameWidth + _qtyWidth, y));
      y += row.height + 12;
    }

    y += 6;
    _drawDivider(canvas, y, width);
    y += 18;
    _drawText(canvas, '列印時間:${_printTime(receipt.printedAt)}', _margin, y, contentWidth, 24, FontWeight.w700, align: TextAlign.center);

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
    TextAlign align = TextAlign.left,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.black, fontSize: fontSize, fontWeight: fontWeight, height: 1.1)),
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
    TextAlign align = TextAlign.left,
  }) {
    final painter = _textPainter(text, fontSize, fontWeight, maxWidth: maxWidth, align: align);
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
  const _ReceiptRowPainters({required this.name, required this.quantity, required this.price});

  final TextPainter name;
  final TextPainter quantity;
  final TextPainter price;

  double get height {
    var result = name.height;
    if (quantity.height > result) result = quantity.height;
    if (price.height > result) result = price.height;
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
  AppSettings _settings = const AppSettings(printerIp: '', printerPort: 9100);
  bool _loading = true;
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await _database.categories();
    final products = await _database.products();
    final settings = await _database.settings();
    final nextActiveCategoryId = categories.any((category) => category.id == _activeCategoryId)
        ? _activeCategoryId
        : categories.isEmpty
            ? null
            : categories.first.id;
    final nextActiveAdminCategoryId = categories.any((category) => category.id == _activeAdminCategoryId)
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

  List<CartLine> get _cartLines {
    return _cart.entries
        .map((entry) {
          final product = _firstWhereOrNull(_products, (item) => item.id == entry.key);
          if (product == null) return null;
          return CartLine(product: product, quantity: entry.value);
        })
        .whereType<CartLine>()
        .toList();
  }

  int get _cartTotal {
    return _cartLines.fold(0, (sum, line) => sum + line.product.price * line.quantity);
  }

  int get _cartCount {
    return _cartLines.fold(0, (sum, line) => sum + line.quantity);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isNarrow = MediaQuery.sizeOf(context).width < 720;
    final page = switch (_pageIndex) {
      0 => _OrderPage(
          categories: _categories,
          products: _products,
          activeCategoryId: _activeCategoryId,
          cartLines: _cartLines,
          cartCount: _cartCount,
          cartTotal: _cartTotal,
          checkingOut: _checkingOut,
          onCategorySelected: (id) => setState(() => _activeCategoryId = id),
          onProductTap: _addToCart,
          onQuantityChange: _changeQuantity,
          onClear: _confirmClearCart,
          onCheckout: _checkout,
        ),
      1 => _PrinterPage(settings: _settings, onSave: _saveSettings, onTest: _testPrinter),
      _ => _MenuAdminPage(
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
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: isNarrow
            ? Column(children: [_TopNav(index: _pageIndex, onChanged: _setPage), Expanded(child: page)])
            : Row(children: [_SideNav(index: _pageIndex, onChanged: _setPage), Expanded(child: page)]),
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
    final ok = await _confirm(title: '清空購物車', message: '確定清除目前已點商品？', action: '清空');
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
        orderNumber: await _database.nextOrderNumber(now),
        printedAt: now,
        lines: lines,
      );
      await _printer.printReceipt(settings: _settings, receipt: receipt);
      if (!mounted) return;
      setState(_cart.clear);
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
    _snack('出單機設定已儲存');
  }

  Future<void> _testPrinter(AppSettings settings) async {
    try {
      final socket = await Socket.connect(settings.printerIp, settings.printerPort, timeout: const Duration(seconds: 3));
      await socket.close();
      _snack('連線成功');
    } catch (_) {
      _snack('連線失敗');
    }
  }

  Future<void> _editCategory([Category? category]) async {
    final name = await _textDialog(title: category == null ? '新增類別' : '修改類別', label: '類別名稱', initialValue: category?.name ?? '');
    if (name == null || name.trim().isEmpty) return;
    if (category == null) {
      final newCategoryId = await _database.addCategory(name.trim());
      _activeAdminCategoryId = newCategoryId;
    } else {
      await _database.updateCategory(category, name.trim());
    }
    await _load();
  }

  Future<void> _deleteCategory(Category category) async {
    final ok = await _confirm(title: '刪除類別', message: '刪除「${category.name}」後，類別內商品也會移除。', action: '刪除');
    if (!ok) return;
    await _database.deleteCategory(category);
    _cart.removeWhere((productId, _) => !_products.any((product) => product.id == productId));
    await _load();
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
      await _database.addProduct(name: result.name, price: result.price, categoryId: result.categoryId);
    } else {
      await _database.updateProduct(product, name: result.name, price: result.price, categoryId: result.categoryId);
    }
    _activeAdminCategoryId = result.categoryId;
    await _load();
  }

  Future<void> _deleteProduct(Product product) async {
    final ok = await _confirm(title: '刪除商品', message: '確定刪除「${product.name}」？', action: '刪除');
    if (!ok) return;
    await _database.deleteProduct(product);
    setState(() => _cart.remove(product.id));
    await _load();
  }

  Future<String?> _textDialog({required String title, required String label, required String initialValue}) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
        backgroundColor: _panel,
        content: TextField(controller: controller, decoration: _fieldDecoration(label), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), style: _primaryButtonStyle(), child: const Text('儲存')),
        ],
      ),
    );
  }

  Future<bool> _confirm({required String title, required String message, required String action}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
            backgroundColor: _panel,
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
              FilledButton(onPressed: () => Navigator.pop(context, true), style: _primaryButtonStyle(), child: Text(action)),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      minWidth: 136,
      selectedIndex: index,
      onDestinationSelected: onChanged,
      labelType: NavigationRailLabelType.all,
      backgroundColor: _rail,
      leading: const Padding(padding: EdgeInsets.fromLTRB(12, 18, 12, 16), child: _BrandMark()),
      selectedIconTheme: const IconThemeData(color: Color(0xff17231c)),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      indicatorColor: _railActive,
      selectedLabelTextStyle: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w700),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('點餐')),
        NavigationRailDestination(icon: Icon(Icons.print), label: Text('出單機')),
        NavigationRailDestination(icon: Icon(Icons.restaurant_menu), label: Text('商品')),
      ],
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _rail,
      padding: const EdgeInsets.all(10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const _BrandMark(horizontal: true),
            const SizedBox(width: 8),
            Expanded(child: _TopNavButton(selected: index == 0, icon: Icons.receipt_long, label: '點餐', onTap: () => onChanged(0))),
            const SizedBox(width: 8),
            Expanded(child: _TopNavButton(selected: index == 1, icon: Icons.print, label: '出單機', onTap: () => onChanged(1))),
            const SizedBox(width: 8),
            Expanded(child: _TopNavButton(selected: index == 2, icon: Icons.restaurant_menu, label: '商品', onTap: () => onChanged(2))),
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
      decoration: BoxDecoration(color: _yellow, borderRadius: BorderRadius.circular(_radius)),
      child: const Text('POS', style: TextStyle(color: Color(0xff1f1a12), fontWeight: FontWeight.w900)),
    );
    final label = const Text('店內點餐', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800));
    if (horizontal) {
      return Row(children: [mark, const SizedBox(width: 8), label]);
    }
    return Column(children: [mark, const SizedBox(height: 8), label]);
  }
}

class _TopNavButton extends StatelessWidget {
  const _TopNavButton({required this.selected, required this.icon, required this.label, required this.onTap});

  final bool selected;
  final IconData icon;
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
          backgroundColor: selected ? _railActive : Colors.white.withAlpha(20),
          foregroundColor: selected ? const Color(0xff17231c) : const Color(0xffe9e3d8),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
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
  final bool checkingOut;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<Product> onProductTap;
  final void Function(Product product, int delta) onQuantityChange;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.where((product) => product.categoryId == activeCategoryId).toList();
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final productPane = Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(title: '點餐', subtitle: '選擇商品加入購物車'),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category.id == activeCategoryId;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: selected,
                  selectedColor: _green,
                  backgroundColor: _panel,
                  side: BorderSide(color: selected ? _green : _line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
                  labelStyle: TextStyle(color: selected ? Colors.white : _ink, fontSize: 18, fontWeight: FontWeight.w800),
                  onSelected: (_) => onCategorySelected(category.id),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: visibleProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                childAspectRatio: isWide ? 1.6 : 1.38,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = visibleProducts[index];
                return Material(
                  color: _panel,
                  borderRadius: BorderRadius.circular(_radius),
                  child: InkWell(
                    onTap: () => onProductTap(product),
                    borderRadius: BorderRadius.circular(_radius),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffd6cfc4)),
                        borderRadius: BorderRadius.circular(_radius),
                        boxShadow: const [BoxShadow(color: Color(0x0a000000), offset: Offset(0, 2))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _ink, fontSize: 21, height: 1.22, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '\$${product.price}',
                            style: const TextStyle(color: _greenDark, fontSize: 23, fontWeight: FontWeight.w900),
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
      checkingOut: checkingOut,
      onQuantityChange: onQuantityChange,
      onClear: onClear,
      onCheckout: onCheckout,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(children: [Expanded(flex: 3, child: productPane), const SizedBox(width: 16), Expanded(flex: 2, child: cartPane)])
          : Column(children: [Expanded(child: productPane), const SizedBox(height: 12), SizedBox(height: 310, child: cartPane)]),
    );
  }
}

class _CartPane extends StatelessWidget {
  const _CartPane({
    required this.lines,
    required this.count,
    required this.total,
    required this.checkingOut,
    required this.onQuantityChange,
    required this.onClear,
    required this.onCheckout,
  });

  final List<CartLine> lines;
  final int count;
  final int total;
  final bool checkingOut;
  final void Function(Product product, int delta) onQuantityChange;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: _cartBg,
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
                    Text('購物車', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('$count 項', style: const TextStyle(color: _muted, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Text('\$$total', style: const TextStyle(color: _greenDark, fontSize: 36, height: 1, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: lines.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border.all(color: _line, style: BorderStyle.solid), borderRadius: BorderRadius.circular(_radius)),
                    child: const Text('購物車尚無商品', style: TextStyle(color: _muted, fontSize: 18)),
                  )
                : ListView.separated(
                    itemCount: lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      return Container(
                        constraints: const BoxConstraints(minHeight: 62),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(_radius)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(line.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text('\$${line.product.price}', style: const TextStyle(color: _muted)),
                                ],
                              ),
                            ),
                            _QuantityButton(icon: Icons.remove, onPressed: () => onQuantityChange(line.product, -1)),
                            SizedBox(width: 42, child: Text('${line.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                            _QuantityButton(icon: Icons.add, onPressed: () => onQuantityChange(line.product, 1)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: lines.isEmpty ? null : onClear, style: _secondaryButtonStyle(foregroundColor: _red), child: const Text('清空'))),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
        ),
      ),
    );
  }
}

class _PrinterPage extends StatefulWidget {
  const _PrinterPage({required this.settings, required this.onSave, required this.onTest});

  final AppSettings settings;
  final ValueChanged<AppSettings> onSave;
  final ValueChanged<AppSettings> onTest;

  @override
  State<_PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<_PrinterPage> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.settings.printerIp);
    _portController = TextEditingController(text: widget.settings.printerPort.toString());
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _Header(title: '出單機設定', subtitle: '單台 iPad 直接連區網出單機'),
        const SizedBox(height: 18),
        Container(
          width: 520,
          padding: const EdgeInsets.all(22),
          decoration: _panelDecoration(),
          child: Column(
            children: [
              TextField(controller: _ipController, style: const TextStyle(fontSize: 20), decoration: _fieldDecoration('出單機 IP')),
              const SizedBox(height: 12),
              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20),
                decoration: _fieldDecoration('Port'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => widget.onTest(_settings()), style: _secondaryButtonStyle(), child: const Text('測試連線'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () => widget.onSave(_settings()), style: _primaryButtonStyle(), child: const Text('儲存設定'))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppSettings _settings() {
    return AppSettings(printerIp: _ipController.text.trim(), printerPort: int.tryParse(_portController.text.trim()) ?? 9100);
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final selectedCategory = _firstWhereOrNull(categories, (category) => category.id == selectedCategoryId);
    final visibleProducts = selectedCategory == null
        ? <Product>[]
        : products.where((product) => product.categoryId == selectedCategory.id).toList();
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
                side: BorderSide(color: category.id == selectedCategoryId ? _green : _line),
                borderRadius: BorderRadius.circular(_radius),
              ),
              title: Text(category.name),
              subtitle: Text('${products.where((product) => product.categoryId == category.id).length} 個商品'),
              onTap: () => onSelectCategory(category.id),
              trailing: _EditDeleteButtons(onEdit: () => onEditCategory(category), onDelete: () => onDeleteCategory(category)),
            ),
          )
          .toList(),
    );
    final productPanel = _AdminPanel(
      title: selectedCategory == null ? '商品' : '${selectedCategory.name}商品',
      onAdd: onAddProduct,
      children: visibleProducts
          .map(
            (product) => ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(side: const BorderSide(color: _line), borderRadius: BorderRadius.circular(_radius)),
              title: Text('${product.name} · \$${product.price}'),
              subtitle: Text(_firstWhereOrNull(categories, (category) => category.id == product.categoryId)?.name ?? '未分類'),
              trailing: _EditDeleteButtons(onEdit: () => onEditProduct(product), onDelete: () => onDeleteProduct(product)),
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
                ? Row(children: [SizedBox(width: 360, child: categoryPanel), const SizedBox(width: 18), Expanded(child: productPanel)])
                : ListView(children: [SizedBox(height: 360, child: categoryPanel), const SizedBox(height: 18), SizedBox(height: 520, child: productPanel)]),
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({required this.title, required this.onAdd, required this.children});

  final String title;
  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _line))),
            child: Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
                SizedBox(height: 42, child: FilledButton(onPressed: onAdd, style: _tinyButtonStyle(), child: const Text('新增'))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (_, __) => const SizedBox(height: 8),
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
          style: IconButton.styleFrom(backgroundColor: const Color(0xffeee7db), foregroundColor: _ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius))),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          style: IconButton.styleFrom(backgroundColor: _redSoft, foregroundColor: _red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius))),
        ),
      ],
    );
  }
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({required this.categories, required this.product, required this.activeCategoryId});

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
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _categoryId = widget.product?.categoryId ?? widget.activeCategoryId ?? widget.categories.first.id;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      backgroundColor: _panel,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: _fieldDecoration('商品名稱')),
            const SizedBox(height: 12),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: _fieldDecoration('價格')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: _fieldDecoration('所屬類別'),
              items: widget.categories.map((category) => DropdownMenuItem(value: category.id, child: Text(category.name))).toList(),
              onChanged: (value) => setState(() => _categoryId = value ?? _categoryId),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _submit, style: _primaryButtonStyle(), child: const Text('儲存')),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    if (name.isEmpty || price == null || price < 0) return;
    Navigator.pop(context, _ProductEditResult(name: name, price: price, categoryId: _categoryId));
  }
}

class _ProductEditResult {
  _ProductEditResult({required this.name, required this.price, required this.categoryId});

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
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
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
