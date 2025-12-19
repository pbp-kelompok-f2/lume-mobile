import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminClassFormPage extends StatefulWidget {
  final ClassSession? session; // Null = Add, Not Null = Edit

  const AdminClassFormPage({super.key, this.session});

  @override
  State<AdminClassFormPage> createState() => _AdminClassFormPageState();
}

class _AdminClassFormPageState extends State<AdminClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _instructorController;
  late TextEditingController _roomController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  
  // Dropdown Values
  String _selectedCategory = 'daily';
  String _selectedTime = '10.00 AM - 11.30 AM'; // Default Time Slot

  // Data Options (Sesuai Django models.py)
  final List<String> _timeSlots = [
    '10.00 AM - 11.30 AM',
    '12.00 PM - 13.30 PM',
    '14.00 PM - 15.30 PM',
    '16.00 PM - 17.30 PM',
    '18.00 PM - 19.30 PM',
  ];

  // Map Hari: Flutter UI -> Django Value ('mon', 'tue', dst)
  final Map<String, String> _dayMap = {
    'mon': 'Monday',
    'tue': 'Tuesday',
    'wed': 'Wednesday',
    'thur': 'Thursday',
    'fri': 'Friday',
    'sat': 'Saturday',
  };
  
  final List<String> _selectedDays = []; // Menyimpan kode hari ('mon', 'tue')

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    
    _titleController = TextEditingController(text: s?.title ?? "");
    _instructorController = TextEditingController(text: s?.instructor ?? "");
    _roomController = TextEditingController(text: s?.room ?? "");
    _priceController = TextEditingController(text: s != null ? s.price.toString() : "");
    _capacityController = TextEditingController(text: s != null ? s.capacityMax.toString() : "20"); // Default 20
    _descriptionController = TextEditingController(text: s?.description ?? "");
    
    if (s != null) {
      _selectedCategory = s.category.toLowerCase();
      // Pastikan time ada di list, kalau tidak (misal data lama), masukkan ke list sementara atau set default
      if (_timeSlots.contains(s.time)) {
        _selectedTime = s.time;
      } else {
        _selectedTime = _timeSlots.first; 
      }
      
      // Load existing days
      _selectedDays.addAll(s.days); 
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi Khusus: Jika Weekly, harus pilih hari
    if (_selectedCategory == 'weekly' && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one day for Weekly class."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    
    String url;
    if (widget.session == null) {
      // Create
      url = 'http://localhost:8000/bookingkelas/create-flutter/';
    } else {
      // Edit
      url = 'http://localhost:8000/bookingkelas/edit-flutter/${widget.session!.id}/';
    }

    final Map<String, dynamic> body = {
      'title': _titleController.text,
      'instructor': _instructorController.text,
      'time': _selectedTime, // Pakai dropdown value
      'room': _roomController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'capacity_max': int.tryParse(_capacityController.text) ?? 20,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'days': _selectedCategory == 'daily' ? [] : _selectedDays, // Daily dihandle backend, Weekly kirim list
    };

    try {
      final response = await request.post(
        url,
        jsonEncode(body),
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Success!"),
              backgroundColor: LumeColors.sageGreen,
            ),
          );
          Navigator.pop(context); // Kembali ke list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Error occurred"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.session != null;

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: LumeAppBar(
        title: isEdit ? "Edit Session" : "Add New Session",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Title", _titleController),
              _buildTextField("Instructor", _instructorController),
              
              // --- CATEGORY DROPDOWN ---
              const SizedBox(height: 16),
              Text("Category", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: LumeColors.darkText)),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedCategory,
                items: const ['daily', 'weekly'],
                onChanged: (val) => setState(() => _selectedCategory = val!),
                itemLabel: (val) => val == 'daily' ? 'Daily' : 'Weekly',
              ),

              // --- DAYS SELECTION (Only for Weekly) ---
              if (_selectedCategory == 'weekly') ...[
                const SizedBox(height: 16),
                Text("Select Days", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: LumeColors.darkText)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dayMap.entries.map((entry) {
                    final dayCode = entry.key; // 'mon', 'tue'
                    final dayName = entry.value; // 'Monday', 'Tuesday'
                    final isSelected = _selectedDays.contains(dayCode);
                    
                    return FilterChip(
                      label: Text(dayName),
                      selected: isSelected,
                      selectedColor: LumeColors.sageGreen.withOpacity(0.3),
                      checkmarkColor: LumeColors.darkGreen,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayCode);
                          } else {
                            _selectedDays.remove(dayCode);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              // --- TIME SLOT DROPDOWN ---
              const SizedBox(height: 16),
              Text("Time Slot", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: LumeColors.darkText)),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedTime,
                items: _timeSlots,
                onChanged: (val) => setState(() => _selectedTime = val!),
                itemLabel: (val) => val, // Display as is
              ),

              _buildTextField("Room", _roomController),
              _buildTextField("Price", _priceController, isNumber: true),
              _buildTextField("Capacity", _capacityController, isNumber: true),
              _buildTextField("Description", _descriptionController, maxLines: 3),

              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LumeColors.sageGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(isEdit ? "Update Session" : "Save Session", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: LumeColors.darkText)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            validator: (val) => val == null || val.isEmpty ? "Required" : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String Function(String) itemLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(itemLabel(item), style: GoogleFonts.inter()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
