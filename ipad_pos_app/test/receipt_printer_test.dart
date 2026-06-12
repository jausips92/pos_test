import 'package:flutter_test/flutter_test.dart';
import 'package:ipad_pos_app/main.dart';

void main() {
  test('receipt preview uses required order format', () {
    final printer = ReceiptPrinter();
    final receipt = OrderReceipt(
      orderNumber: '2605090001',
      printedAt: DateTime(2026, 5, 9, 14, 41, 20),
      lines: [
        CartLine(
          product: Product(id: 1, categoryId: 1, name: '陽春麵', price: 40),
          quantity: 1,
        ),
      ],
    );

    final text = printer.previewText(receipt);

    expect(text, contains('單號:2605090001'));
    expect(text, contains('品項'));
    expect(text, contains('數量'));
    expect(text, isNot(contains('單價')));
    expect(text, contains('陽春麵'));
    expect(text, contains('x1'));
    expect(text, contains('陽春麵            x1\n40'));
    expect(text, contains('列印時間:2026-05-09 14:41:20'));
  });
}
