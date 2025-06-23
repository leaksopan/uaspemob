import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../services/image_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final ImageService _imageService = ImageService();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _totalExpenses = 0.0;
  List<Map<String, dynamic>> _expensesByCategory = [];

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalExpenses => _totalExpenses;
  List<Map<String, dynamic>> get expensesByCategory => _expensesByCategory;

  // Load all expenses for user
  Future<void> loadExpenses(int userId) async {
    _setLoading(true);
    _clearError();

    try {
      _expenses = await _expenseRepository.getExpenses(userId);
      _totalExpenses = await _expenseRepository.getTotalExpenses(userId);
      _expensesByCategory = await _expenseRepository.getExpensesByCategory(
        userId,
      );
      _clearError();
    } catch (e) {
      _setError('Error loading expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new expense
  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
    String? description,
    String? imagePath,
    required DateTime date,
    required int userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (title.isEmpty) {
        _setError('Judul pengeluaran tidak boleh kosong');
        return false;
      }

      if (amount <= 0) {
        _setError('Jumlah pengeluaran harus lebih dari 0');
        return false;
      }

      if (category.isEmpty) {
        _setError('Kategori harus dipilih');
        return false;
      }

      Expense newExpense = Expense(
        title: title,
        amount: amount,
        category: category,
        description: description,
        imagePath: imagePath,
        date: date,
        userId: userId,
      );

      bool result = await _expenseRepository.addExpense(newExpense);

      if (result) {
        await loadExpenses(userId); // Reload data
        _clearError();
        return true;
      } else {
        _setError('Gagal menambahkan pengeluaran');
        return false;
      }
    } catch (e) {
      _setError('Error adding expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense, int userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (expense.title.isEmpty) {
        _setError('Judul pengeluaran tidak boleh kosong');
        return false;
      }

      if (expense.amount <= 0) {
        _setError('Jumlah pengeluaran harus lebih dari 0');
        return false;
      }

      if (expense.category.isEmpty) {
        _setError('Kategori harus dipilih');
        return false;
      }

      bool result = await _expenseRepository.updateExpense(expense);

      if (result) {
        await loadExpenses(userId); // Reload data
        _clearError();
        return true;
      } else {
        _setError('Gagal mengupdate pengeluaran');
        return false;
      }
    } catch (e) {
      _setError('Error updating expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete expense
  Future<bool> deleteExpense(
    int expenseId,
    int userId, {
    String? imagePath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      bool result = await _expenseRepository.deleteExpense(expenseId);

      if (result) {
        // Delete associated image if exists
        if (imagePath != null && imagePath.isNotEmpty) {
          await _imageService.deleteImage(imagePath);
        }

        await loadExpenses(userId); // Reload data
        _clearError();
        return true;
      } else {
        _setError('Gagal menghapus pengeluaran');
        return false;
      }
    } catch (e) {
      _setError('Error deleting expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      return await _imageService.pickImageFromCamera();
    } catch (e) {
      _setError('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      return await _imageService.pickImageFromGallery();
    } catch (e) {
      _setError('Error picking image from gallery: $e');
      return null;
    }
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((expense) {
      return expense.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get expenses by category filter
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Search expenses
  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) return _expenses;

    return _expenses.where((expense) {
      return expense.title.toLowerCase().contains(query.toLowerCase()) ||
          expense.category.toLowerCase().contains(query.toLowerCase()) ||
          (expense.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Get predefined categories
  List<String> get categories => [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Tagihan',
    'Lainnya',
  ];
}
