class WeeklySummary {
  final String id;
  final String businessId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final double totalSales;
  final double totalProfit;
  final int totalTickets;
  final List<DailySales> days;

  const WeeklySummary({
    required this.id,
    required this.businessId,
    required this.weekStart,
    required this.weekEnd,
    required this.totalSales,
    required this.totalProfit,
    required this.totalTickets,
    required this.days,
  });
}

class DailySales {
  final DateTime date;
  final double sales;
  final double profit;
  final int tickets;

  const DailySales({
    required this.date,
    required this.sales,
    required this.profit,
    required this.tickets,
  });
}
