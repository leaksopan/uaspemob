import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../utils/formatters.dart';
import 'package:path/path.dart' as path;

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  void _loadExpenses() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final expenseViewModel = Provider.of<ExpenseViewModel>(
      context,
      listen: false,
    );

    if (authViewModel.currentUser != null) {
      expenseViewModel.loadExpenses(authViewModel.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Daftar Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<AuthViewModel, ExpenseViewModel>(
        builder: (context, authViewModel, expenseViewModel, child) {
          if (authViewModel.currentUser == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: () async => _loadExpenses(),
            child:
                expenseViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : expenseViewModel.expenses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: expenseViewModel.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenseViewModel.expenses[index];
                        return _buildExpenseCard(
                          expense,
                          expenseViewModel,
                          authViewModel,
                        );
                      },
                    ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada pengeluaran\nMulai tambahkan pengeluaran pertama Anda',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
    Expense expense,
    ExpenseViewModel expenseViewModel,
    AuthViewModel authViewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Leading icon
            CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                _getCategoryIcon(expense.category),
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.category,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatRelativeDate(expense.date),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Trailing section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatters.formatCurrency(expense.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                PopupMenuButton<String>(
                  onSelected:
                      (value) => _handleMenuAction(
                        value,
                        expense,
                        expenseViewModel,
                        authViewModel,
                      ),
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Lihat Detail'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    String action,
    Expense expense,
    ExpenseViewModel expenseViewModel,
    AuthViewModel authViewModel,
  ) {
    if (action == 'delete') {
      _confirmDelete(expense, expenseViewModel, authViewModel);
    } else if (action == 'detail') {
      _showExpenseDetail(expense);
    }
  }

  void _showExpenseDetail(Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detail Pengeluaran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tampilkan gambar jika ada
                      if (expense.imagePath != null &&
                          expense.imagePath!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildImage(expense.imagePath!),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Detail informasi
                      _buildDetailRow('Judul', expense.title),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Jumlah',
                        Formatters.formatCurrency(expense.amount),
                        isAmount: true,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Kategori', expense.category),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Tanggal & Waktu',
                        DateFormat(
                          'dd MMMM yyyy, HH:mm',
                          'id_ID',
                        ).format(expense.date),
                      ),

                      // Tampilkan deskripsi jika ada
                      if (expense.description != null &&
                          expense.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('Deskripsi', expense.description!),
                      ],

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Tutup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (kIsWeb || imagePath.startsWith('data:image/')) {
      // Untuk web dengan data URL
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Untuk mobile/desktop dengan file path
      final String fullPath = path.join(Directory.current.path, imagePath);
      final File imageFile = File(fullPath);

      // Cek apakah file ada
      if (!imageFile.existsSync()) {
        return Container(
          color: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Gambar tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        );
      }

      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.red.shade600 : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    Expense expense,
    ExpenseViewModel expenseViewModel,
    AuthViewModel authViewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus pengeluaran "${expense.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  bool success = await expenseViewModel.deleteExpense(
                    expense.id!,
                    authViewModel.currentUser!.id!,
                    imagePath: expense.imagePath,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengeluaran berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Hiburan':
        return Icons.movie;
      case 'Kesehatan':
        return Icons.local_hospital;
      case 'Pendidikan':
        return Icons.school;
      case 'Tagihan':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }
}
