import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../utils/formatters.dart';
import 'package:permission_handler/permission_handler.dart';
import './camera_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  String? _imagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Check and request camera permission
  Future<bool> _checkCameraPermission() async {
    if (kIsWeb) return true; // Web doesn't need explicit permission

    PermissionStatus permission = await Permission.camera.status;

    if (permission.isDenied) {
      permission = await Permission.camera.request();
    }

    if (permission.isPermanentlyDenied) {
      // Show dialog to open app settings
      if (mounted) {
        _showPermissionDialog();
      }
      return false;
    }

    return permission.isGranted;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Kamera Diperlukan'),
          content: const Text(
            'Aplikasi memerlukan izin kamera untuk mengambil foto struk belanja. '
            'Silakan buka pengaturan dan berikan izin kamera.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog(ExpenseViewModel expenseViewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Sumber Foto Struk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue.shade600),
                ),
                title: const Text('Ambil Foto'),
                subtitle: Text(
                  kIsWeb
                      ? 'Gunakan webcam untuk foto struk'
                      : 'Gunakan kamera untuk foto struk',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera(expenseViewModel);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.green.shade600,
                  ),
                ),
                title: Text(kIsWeb ? 'Pilih File' : 'Dari Galeri'),
                subtitle: Text(
                  kIsWeb
                      ? 'Pilih gambar dari komputer'
                      : 'Pilih foto dari galeri',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery(expenseViewModel);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Tambah Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<AuthViewModel, ExpenseViewModel>(
        builder: (context, authViewModel, expenseViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (expenseViewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              expenseViewModel.errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => expenseViewModel.clearError(),
                            icon: Icon(Icons.close, color: Colors.red.shade600),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),

                  // Judul
                  _buildFormCard(
                    title: 'Informasi Pengeluaran',
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Judul Pengeluaran *',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Jumlah
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah (Rp) *',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          double? amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Jumlah harus berupa angka positif';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Kategori
                      DropdownButtonFormField<String>(
                        value:
                            _selectedCategory.isEmpty
                                ? null
                                : _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori *',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items:
                            expenseViewModel.categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih kategori';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tanggal
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal *',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          child: Text(
                            Formatters.formatDate(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Deskripsi
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi (Opsional)',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Foto Struk
                  _buildFormCard(
                    title: 'Foto Struk (Opsional)',
                    children: [
                      _buildImageDisplay(),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              () => _showImageSourceDialog(expenseViewModel),
                          icon: const Icon(Icons.add_a_photo),
                          label: Text(
                            _imagePath == null
                                ? 'Tambah Foto Struk'
                                : 'Ganti Foto',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          expenseViewModel.isLoading
                              ? null
                              : () => _handleSaveExpense(
                                authViewModel,
                                expenseViewModel,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          expenseViewModel.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Simpan Pengeluaran',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_imagePath == null) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Belum ada foto struk',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap tombol di bawah untuk menambah foto',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(child: _buildImageWidget()),
            // Overlay dengan gradient untuk tombol hapus
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.center,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                    stops: const [0.0, 0.3],
                  ),
                ),
              ),
            ),
            // Tombol hapus
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _imagePath = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto dihapus'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            // Label foto struk
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Foto Struk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imagePath == null) return Container();

    // Cek apakah ini data URL (untuk web) atau file path (untuk mobile)
    if (_imagePath!.startsWith('data:image/')) {
      // Untuk web dengan data URL
      return Image.network(
        _imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Untuk mobile dengan file path
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImageFromCamera(ExpenseViewModel expenseViewModel) async {
    if (kIsWeb) {
      // Buka halaman kamera kustom untuk web
      final XFile? imageFile = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );

      if (imageFile != null) {
        // Konversi gambar yang didapat ke format base64
        final Uint8List bytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(bytes);
        final String dataUrl = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _imagePath = dataUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diambil dari webcam'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Gunakan implementasi image_picker standar untuk mobile
      bool hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin kamera diperlukan untuk mengambil foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      String? imagePath = await expenseViewModel.pickImageFromCamera();
      if (imagePath != null) {
        setState(() {
          _imagePath = imagePath;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diambil'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImageFromGallery(ExpenseViewModel expenseViewModel) async {
    String? imagePath = await expenseViewModel.pickImageFromGallery();
    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil dipilih'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveExpense(
    AuthViewModel authViewModel,
    ExpenseViewModel expenseViewModel,
  ) async {
    if (_formKey.currentState!.validate()) {
      if (authViewModel.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      bool success = await expenseViewModel.addExpense(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        imagePath: _imagePath,
        date: _selectedDate,
        userId: authViewModel.currentUser!.id!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengeluaran berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    }
  }
}
