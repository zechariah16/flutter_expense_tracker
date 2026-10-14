import 'package:expense_tracker/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.parseToMinorUnits', () {
    test('parses whole and decimal amounts', () {
      expect(Money.parseToMinorUnits('1500'), 150000);
      expect(Money.parseToMinorUnits('1,500.50'), 150050);
      expect(Money.parseToMinorUnits('0.1'), 10);
      expect(Money.parseToMinorUnits('20.5'), 2050);
      expect(Money.parseToMinorUnits('₦ 20.05'), 2005);
    });

    test('rejects invalid input', () {
      expect(Money.parseToMinorUnits(''), isNull);
      expect(Money.parseToMinorUnits('abc'), isNull);
      expect(Money.parseToMinorUnits('1.234'), isNull);
      expect(Money.parseToMinorUnits('-5'), isNull);
      expect(Money.parseToMinorUnits('1.'), isNull);
      expect(Money.parseToMinorUnits('.5'), isNull);
      expect(Money.parseToMinorUnits('1.2.3'), isNull);
    });

    test('rejects absurdly large values', () {
      expect(Money.parseToMinorUnits('9' * 13), isNull);
    });

    test('has no floating point drift', () {
      final a = Money.parseToMinorUnits('0.1')!;
      final b = Money.parseToMinorUnits('0.2')!;
      expect(a + b, Money.parseToMinorUnits('0.3'));
    });
  });

  group('Money.format', () {
    test('formats with symbol, grouping and two decimals', () {
      expect(Money.format(150050), '₦1,500.50');
      expect(Money.format(5), '₦0.05');
      expect(Money.format(0), '₦0.00');
      expect(Money.format(123456789), '₦1,234,567.89');
    });

    test('formats negatives and signed values', () {
      expect(Money.format(-250), '-₦2.50');
      expect(Money.formatSigned(250, isIncome: true), '+₦2.50');
      expect(Money.formatSigned(250, isIncome: false), '-₦2.50');
    });
  });

  test('toInputString round-trips with parse', () {
    expect(Money.toInputString(150000), '1500');
    expect(Money.toInputString(150050), '1500.50');
    expect(Money.toInputString(5), '0.05');
    expect(Money.parseToMinorUnits(Money.toInputString(150050)), 150050);
  });
}
