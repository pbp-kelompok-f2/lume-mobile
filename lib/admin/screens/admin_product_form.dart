import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminProductFormPage extends StatefulWidget {
  final Product? product; // Jika null = Mode Add, Jika ada = Mode Edit

  const AdminProductFormPage({super.key, this.product});

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _thumbnailController = TextEditingController();
  bool _inStock = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Isi form jika mode edit
      _nameController.text = widget.product!.name;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _thumbnailController.text = widget.product!.thumbnail;
      _inStock = widget.product!.inStock;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = jsonEncode({
      "name": _nameController.text,
      "description": _descController.text,
      "price": int.parse(_priceController.text),
      "stock": int.parse(_stockController.text),
      "in_stock": _inStock,
      "thumbnail": _thumbnailController.text,
    });

    try {
      if (widget.product == null) {
        // --- CREATE MODE ---
        final response = await request.postJson(
          apiPath('/catalog/api/products/create/'),
          body,
        );
        if (response['id'] != null) { // Cek sukses via respon ID
            if(!mounted) return;
            Navigator.pop(context); // Kembali ke list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product created successfully!")),
            );
        }
      } else {
        // --- EDIT MODE ---
        // postJson di pbp_django_auth biasanya kirim POST, 
        // tapi api.py update butuh PUT/PATCH. 
        // Namun, pbp_django_auth versi baru support method lain via `request.post` atau `request.put`?
        // Jika library terbatas, kita pakai endpoint khusus atau trik. 
        // Tapi mari kita coba request.postJson tapi backend kita handle POST juga?
        // Oh, api.py Anda pakai @require_http_methods(["PUT","PATCH"]).
        
        // Kita harus pakai method update manual kalau library pbp tidak support method PUT langsung dengan mudah.
        // Tapi, asumsi pbp_django_auth standar:
        
        // Versi custom request untuk PUT:
        // (Jika pbp_django_auth tidak punya helper putJson, kita akali dengan kirim request biasa)
        // Note: Sebagian versi pbp_django_auth hanya support GET/POST. 
        // Solusi: Ganti view Django jadi @require_http_methods(["POST", "PUT"]) ATAU
        // gunakan http client bawaan dart dengan headers cookie dari request.
        
        // Namun, jika Anda menggunakan library standar UI, kita coba fetch method custom:
        
        /* NOTE: Karena API endpoint 'update' di Django Anda strict ["PUT", "PATCH"], 
           pastikan library Flutter Anda bisa kirim PUT. 
           Kalau pbp_django_auth versi lama hanya POST, Anda mungkin perlu mengubah Django viewnya
           menjadi @require_http_methods(["POST"]) sementara, atau pakai kode di bawah ini 
           jika library mendukung.
        */

        // Menggunakan request base class untuk PUT (jika didukung)
        // Atau kita pakai `request.postJson` tapi ubah view Django sedikit.
        // TAPI, agar aman tanpa ubah Django, kita pakai `request.update` (jika ada) 
        // atau `http.put` dengan header dari request.headers.
        
        // Mari kita asumsikan pbp_django_auth bisa menghandle ini, atau kita pakai workaround:
        // Menggunakan endpoint create untuk update? Tidak bisa.
        
        // Solusi Paling Aman tanpa ubah Django & Library:
        // Gunakan request provider yang sudah ada
        
        // Coba kirim sebagai POST ke endpoint update? 
        // Django view `api_product_update` di file Anda: @require_http_methods(["PUT","PATCH"]).
        // Jadi POST akan 405 Method Not Allowed.
        
        // *Saran*: Ubah sedikit Django `api.py` untuk `api_product_update` menerima POST juga, 
        // ATAU gunakan kode di bawah ini yang mencoba melakukan PUT (tergantung implementasi package).
        
        // Jika package pbp_django_auth tidak support PUT, 
        // gunakan perintah ini (perlu import 'package:http/http.dart' as http):
        /*
          final url = Uri.parse(apiPath('/catalog/api/products/${widget.product!.id}/update/'));
          final response = await http.put(
            url,
            headers: request.headers..addAll({"Content-Type": "application/json"}),
            body: body,
          );
        */
        
        // TAPI, untuk sekarang saya gunakan `request.postJson` dengan asumsi 
        // Anda akan menambahkan "POST" ke decorator Django view `api_product_update` 
        // agar lebih mudah di Flutter.
        // -> @require_http_methods(["PUT", "PATCH", "POST"])
        
        // Jika tidak mau ubah Django, gunakan ini (fitur hidden library):
        // (Tapi saya sarankan tambahkan POST di Django viewnya demi kestabilan).
        
        // SEMENTARA SAYA PAKAI POST (Tolong tambahkan "POST" di api_product_update Django Anda)
         final response = await request.postJson(
          apiPath('/catalog/api/products/${widget.product!.id}/update/'),
          body,
        );
        
        if (response['id'] != null) {
          if(!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product updated successfully!")),
          );
        }
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e. (Check Django view methods)")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: LumeAppBar(
        title: isEdit ? "Edit Product" : "Add Product",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Product Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Enter product name"),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 16),
              
              _buildLabel("Price (Rp)"),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter price"),
                validator: (v) => v!.isEmpty ? "Price required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Stock"),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter stock quantity"),
                validator: (v) => v!.isEmpty ? "Stock required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Description"),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration("Product description..."),
                validator: (v) => v!.isEmpty ? "Description required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Thumbnail URL"),
              TextFormField(
                controller: _thumbnailController,
                decoration: _inputDecoration("https://example.com/image.png"),
                validator: (v) => v!.isEmpty ? "Image URL required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _inStock, 
                    activeColor: LumeColors.sageGreen,
                    onChanged: (v) => setState(() => _inStock = v!)
                  ),
                  const Text("In Stock", style: TextStyle(fontSize: 16, color: LumeColors.darkText)),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveProduct(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LumeColors.sageGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEdit ? "Update Product" : "Save Product",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: LumeColors.darkText)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LumeColors.brownBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LumeColors.brownBorder),
      ),
    );
  }
}
