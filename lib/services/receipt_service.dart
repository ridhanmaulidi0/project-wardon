import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/store_settings_model.dart';

class ReceiptService {
  static String generateReceiptText(OrderModel order, StoreSettingsModel settings) {
    final buffer = StringBuffer();
    const divider = '================================';
    const subDivider = '--------------------------------';

    buffer.writeln(divider);
    buffer.writeln(centerText(settings.storeName, 32));
    buffer.writeln(centerText(settings.tagline, 32));
    buffer.writeln(centerText(settings.address, 32));
    buffer.writeln(centerText(settings.phone, 32));
    buffer.writeln(divider);

    buffer.writeln('No. Order : ${order.orderNumber}');
    buffer.writeln('Waktu     : ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}');
    buffer.writeln('Kasir     : ${order.cashierName}');
    if (order.customerName != null && order.customerName!.isNotEmpty) {
      buffer.writeln('Pelanggan : ${order.customerName}');
    }
    buffer.writeln(subDivider);

    for (final item in order.items) {
      buffer.writeln(item.name);
      final line = '  ${item.quantity}x @${formatRp(item.unitPrice)}';
      final subtotal = formatRp(item.subtotal);
      buffer.writeln(justifyText(line, subtotal, 32));
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('  * ${item.notes}');
      }
    }

    buffer.writeln(subDivider);
    buffer.writeln(justifyText('Subtotal:', formatRp(order.subtotal), 32));
    if (order.discount > 0) {
      buffer.writeln(justifyText('Diskon:', '-${formatRp(order.discount)}', 32));
    }
    if (order.tax > 0) {
      buffer.writeln(justifyText('Pajak (PPN):', formatRp(order.tax), 32));
    }
    buffer.writeln(divider);
    buffer.writeln(justifyText('TOTAL:', formatRp(order.total), 32));
    buffer.writeln(divider);

    buffer.writeln('Metode Bayar: ${order.paymentMethod.name.toUpperCase()}');
    if (order.paymentMethod == PaymentMethod.tunai) {
      buffer.writeln(justifyText('Tunai Diterima:', formatRp(order.cashReceived), 32));
      buffer.writeln(justifyText('Kembalian:', formatRp(order.change), 32));
    } else {
      buffer.writeln('Status: LUNAS (QRIS / Digital)');
    }

    buffer.writeln(divider);
    buffer.writeln(centerText('Terima Kasih!', 32));
    buffer.writeln(centerText('Selamat Menikmati ☕', 32));
    buffer.writeln(divider);

    return buffer.toString();
  }

  static String centerText(String text, int width) {
    if (text.length >= width) return text;
    final pad = (width - text.length) ~/ 2;
    return ' ' * pad + text;
  }

  static String justifyText(String left, String right, int width) {
    final spaces = width - left.length - right.length;
    if (spaces <= 0) return '$left $right';
    return left + (' ' * spaces) + right;
  }

  static String formatRp(num value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }
}

