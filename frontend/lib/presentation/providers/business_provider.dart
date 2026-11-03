import 'package:flutter/foundation.dart';
import '../../domain/entities/business.dart';

class BusinessProvider extends ChangeNotifier {
  Business? _business;
  bool _isOnline = true;
  int _pendingSync = 0;

  Business? get business => _business;
  bool get isOnline => _isOnline;
  int get pendingSync => _pendingSync;
  bool get isRegistered => _business != null;

  void register(String name, String phone) {
    _business = Business(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phoneNumber: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void updateName(String name) {
    if (_business == null) return;
    _business = Business(
      id: _business!.id,
      name: name,
      phoneNumber: _business!.phoneNumber,
      createdAt: _business!.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void toggleOnline() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  void setPendingSync(int count) {
    _pendingSync = count;
    notifyListeners();
  }
}
