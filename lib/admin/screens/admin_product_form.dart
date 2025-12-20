import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminProductFormPage extends StatefulWidget {
  final Product? product;

  const AdminProductFormPage({super.key, this.product});

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
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
        final response = await request.postJson(
          apiPath('/catalog/api/products/create/'),
          body,
        );
        if (response['id'] != null) { 
            if(!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product created successfully!")),
            );
        }
      } else {

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
