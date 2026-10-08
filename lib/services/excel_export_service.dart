import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import '../models/order_model.dart';

class ExcelExportService {
  static Future<String?> exportOrdersToExcel(List<OrderModel> orders, {String periodName = 'Semua'}) async {
    try {
      final workbook = xls.Workbook();

      // ================= SHEET 1: RINGKASAN =================
      final summarySheet = workbook.worksheets[0];
      summarySheet.name = 'Ringkasan';

      summarySheet.getRangeByName('A1:D1').merge();
      summarySheet.getRangeByName('A1').setText('LAPORAN PENJUALAN WARDON - $periodName');
      summarySheet.getRangeByName('A1').cellStyle.bold = true;
      summarySheet.getRangeByName('A1').cellStyle.fontSize = 14;

      final totalRevenue = orders.fold<int>(0, (sum, o) => sum + o.total);
      final totalQty = orders.fold<int>(0, (sum, o) => sum + o.totalItems);
      final avgTicket = orders.isEmpty ? 0 : (totalRevenue / orders.length).round();

      summarySheet.getRangeByName('A3').setText('Waktu Export:');
      summarySheet.getRangeByName('B3').setText(DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now()));

      summarySheet.getRangeByName('A4').setText('Total Transaksi:');
      summarySheet.getRangeByName('B4').setNumber(orders.length.toDouble());

      summarySheet.getRangeByName('A5').setText('Total Item Terjual:');
      summarySheet.getRangeByName('B5').setNumber(totalQty.toDouble());

      summarySheet.getRangeByName('A6').setText('Total Pendapatan:');
      summarySheet.getRangeByName('B6').setNumber(totalRevenue.toDouble());
      summarySheet.getRangeByName('B6').numberFormat = 'Rp #,##0';

      summarySheet.getRangeByName('A7').setText('Rata-rata per Transaksi:');
      summarySheet.getRangeByName('B7').setNumber(avgTicket.toDouble());
      summarySheet.getRangeByName('B7').numberFormat = 'Rp #,##0';

      // ================= SHEET 2: DAFTAR TRANSAKSI =================
      final transSheet = workbook.worksheets.addWithName('Daftar Transaksi');

      final headers = ['No Order', 'Tanggal & Jam', 'Kasir', 'Metode Bayar', 'Status', 'Jml Item', 'Subtotal', 'Diskon', 'Total'];
      for (int i = 0; i < headers.length; i++) {
        final cell = transSheet.getRangeByIndex(1, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#1E3A2F';
        cell.cellStyle.fontColor = '#FFFFFF';
      }

      int rowIndex = 2;
      for (final order in orders) {
        transSheet.getRangeByIndex(rowIndex, 1).setText(order.orderNumber);
        transSheet.getRangeByIndex(rowIndex, 2).setText(DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt));
        transSheet.getRangeByIndex(rowIndex, 3).setText(order.cashierName);
        transSheet.getRangeByIndex(rowIndex, 4).setText(order.paymentMethod.name.toUpperCase());
        transSheet.getRangeByIndex(rowIndex, 5).setText(order.paymentStatus.toUpperCase());
        transSheet.getRangeByIndex(rowIndex, 6).setNumber(order.totalItems.toDouble());

        final subtotalCell = transSheet.getRangeByIndex(rowIndex, 7);
        subtotalCell.setNumber(order.subtotal.toDouble());
        subtotalCell.numberFormat = 'Rp #,##0';

        final discountCell = transSheet.getRangeByIndex(rowIndex, 8);
        discountCell.setNumber(order.discount.toDouble());
        discountCell.numberFormat = 'Rp #,##0';

        final totalCell = transSheet.getRangeByIndex(rowIndex, 9);
        totalCell.setNumber(order.total.toDouble());
        totalCell.numberFormat = 'Rp #,##0';

        rowIndex++;
      }

      // ================= SHEET 3: RINCIAN ITEM =================
      final itemSheet = workbook.worksheets.addWithName('Rincian Item');
      final itemHeaders = ['No Order', 'Nama Item', 'Harga Satuan', 'Qty', 'Subtotal Item', 'Catatan'];
      for (int i = 0; i < itemHeaders.length; i++) {
        final cell = itemSheet.getRangeByIndex(1, i + 1);
        cell.setText(itemHeaders[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#D97706';
        cell.cellStyle.fontColor = '#FFFFFF';
      }

      int itemRow = 2;
      for (final order in orders) {
        for (final item in order.items) {
          itemSheet.getRangeByIndex(itemRow, 1).setText(order.orderNumber);
          itemSheet.getRangeByIndex(itemRow, 2).setText(item.name);

          final priceCell = itemSheet.getRangeByIndex(itemRow, 3);
          priceCell.setNumber(item.unitPrice.toDouble());
          priceCell.numberFormat = 'Rp #,##0';

          itemSheet.getRangeByIndex(itemRow, 4).setNumber(item.quantity.toDouble());

          final itemSubtotalCell = itemSheet.getRangeByIndex(itemRow, 5);
          itemSubtotalCell.setNumber(item.subtotal.toDouble());
          itemSubtotalCell.numberFormat = 'Rp #,##0';

          itemSheet.getRangeByIndex(itemRow, 6).setText(item.notes ?? '-');
          itemRow++;
        }
      }

      // Save to file
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Laporan_WARDON_$dateStr.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      // Trigger Share Dialog
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          text: 'Laporan Penjualan WARDON ($periodName)',
        ),
      );

      return file.path;
    } catch (e) {
      return null;
    }
  }
}
