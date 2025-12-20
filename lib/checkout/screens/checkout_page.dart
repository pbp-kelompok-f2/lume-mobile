import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';

import '../../models/checkout.dart';
import '../checkout_service.dart';
import '../widgets/order_confirmed_dialog.dart';
import '../../profile/screens/profile_page.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Indonesia');
  final _notesController = TextEditingController();

  final _service = const CheckoutService();

  CartSummary? _summary;
  bool _isLoadingSummary = true;
  bool _isSubmitting = false;
  String? _summaryError;

  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() {
      _isLoadingSummary = true;
      _summaryError = null;
    });

    try {
      final result = await _service.fetchCartSummary(
        request,
        selectedOnly: true,
      );
      setState(() {
        _summary = result;
      });
    } catch (e) {
      setState(() {
        _summaryError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
    }
  }

  Future<void> _onPlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();

    final data = CheckoutFormData(
      addressLine1: _address1Controller.text.trim(),
      addressLine2: _address2Controller.text.trim().isEmpty
          ? null
          : _address2Controller.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    final result = await _service.checkoutCart(request, data);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result.success) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OrderConfirmedDialog(
          onBackToHome: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScaffold(initialIndex: 0),
              ),
            );
          },
          onViewOrderHistory: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScaffold(
                  initialIndex: 3,
                ),
              ),
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  String _formatCurrency(double value) {
    final int intValue = value.round();
    final String raw = intValue.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F3),
      appBar: const LumeAppBar(title: 'Checkout'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildShippingCard(theme),
                      const SizedBox(height: 16),
                      _buildPaymentCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            _buildBottomSummarySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6E7E1)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(126, 128, 115, 0.08),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3E4038),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Address',
            controller: _address1Controller,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Address Line 2',
            controller: _address2Controller,
            requiredField: false,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  controller: _cityController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'Province',
                  controller: _provinceController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Province is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Postal Code',
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Postal code is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'Country',
                  controller: _countryController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Notes',
            controller: _notesController,
            requiredField: false,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6E7E1)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(126, 128, 115, 0.08),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E4038),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD9DBD0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF7E8073),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cash on Delivery (COD)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF3E4038)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Payment will be made on delivery.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummarySection() {
    Widget content;

    if (_isLoadingSummary) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_summaryError != null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(_summaryError!, style: const TextStyle(color: Colors.red)),
      );
    } else if (_summary == null || _summary!.items.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Your cart is empty or no items selected.',
          style: TextStyle(fontSize: 13),
        ),
      );
    } else {
      final s = _summary!;
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E7E1)),
              ),
              child: Row(
                children: [
                  Text(
                    '${s.count} item(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E4038),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _showDetails ? 'Hide details' : 'Show details',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A7C72),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showDetails
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: const Color(0xFF7A7C72),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _showDetails
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE6E7E1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          children: s.items.map((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.productName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF3E4038),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '× ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF7A7C72),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatCurrency(item.lineTotal),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF3E4038),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),


          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(_formatCurrency(s.subtotal)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping'),
              Text(_formatCurrency(s.shipping)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                _formatCurrency(s.total),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE8E4D6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E4038),
              ),
            ),
            const SizedBox(height: 8),
            content,
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting || _isLoadingSummary
                    ? null
                    : _onPlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E8073),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool requiredField = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF3E4038)),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: requiredField ? validator : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD9DBD0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD9DBD0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFC9CCBF),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
