import '../models/expense.dart';
import '../services/database_helper.dart';

class ExpenseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Add new expense
  Future<bool> addExpense(Expense expense) async {
    try {
      int result = await _databaseHelper.insertExpense(expense);
      return result > 0;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  // Get all expenses for user
  Future<List<Expense>> getExpenses(int userId) async {
    try {
      return await _databaseHelper.getExpensesByUserId(userId);
    } catch (e) {
      print('Error getting expenses: $e');
      return [];
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    try {
      int result = await _databaseHelper.updateExpense(expense);
      return result > 0;
    } catch (e) {
      print('Error updating expense: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(int expenseId) async {
    try {
      int result = await _databaseHelper.deleteExpense(expenseId);
      return result > 0;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  // Get total expenses for user
  Future<double> getTotalExpenses(int userId) async {
    try {
      return await _databaseHelper.getTotalExpensesByUserId(userId);
    } catch (e) {
      print('Error getting total expenses: $e');
      return 0.0;
    }
  }

  // Get expenses by category
  Future<List<Map<String, dynamic>>> getExpensesByCategory(int userId) async {
    try {
      return await _databaseHelper.getExpensesByCategory(userId);
    } catch (e) {
      print('Error getting expenses by category: $e');
      return [];
    }
  }
}
