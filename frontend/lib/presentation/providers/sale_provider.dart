import 'package:flutter/foundation.dart';
import '../../domain/entities/sale.dart';

class DaySummary {
  final double sales;
  final double profit;
  final int tickets;

  const DaySummary({required this.sales, required this.profit, required this.tickets});
}

class SaleProvider extends ChangeNotifier {
  final List<Sale> _sales = [];
  DaySummary _today = const DaySummary(sales: 0, profit: 0, tickets: 0);

  List<Sale> get sales => List.unmodifiable(_sales);
  List<Sale> get recentSales => _sales.take(5).toList();
  DaySummary get today => _today;

  void addSale(Sale sale) {
    _sales.insert(0, sale);
    _today = DaySummary(
      sales: _today.sales + sale.total,
      profit: _today.profit + sale.profit,
      tickets: _today.tickets + 1,
    );
    notifyListeners();
  }

  void loadSampleData() {
    _today = const DaySummary(sales: 1180, profit: 496, tickets: 26);
    notifyListeners();
  }
}
