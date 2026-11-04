class CurrencyFormatter {
  static String format(double amount, {bool showUnit = true}) {
    final int val = amount.round();
    final String str = val.toString();
    final buffer = StringBuffer();
    
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    
    final formatted = buffer.toString().split('').reversed.join('');
    return showUnit ? '$formatted đ' : formatted;
  }

  static String formatPerDay(double amount) {
    return '${format(amount)}/ngày';
  }
}
