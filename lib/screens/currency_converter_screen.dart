import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_app_new/themes/themes.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _toCurrency2 = 'JPY';
  double _convertedAmount = 0.0;
  double _convertedAmount2 = 0.0;
  bool _isLoading = false;

  final List<String> _currencies = [
    'USD',
    'EUR',
    'IDR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'SGD'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
            ),
          ),
        ),
        title: const Text(
          'Currency Converter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrencyCard(),
            const SizedBox(height: 24),
            _buildConvertButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildFromSection(),
          const SizedBox(height: 24),
          _buildToSection(),
          const SizedBox(height: 24),
          _buildToSection2(),
        ],
      ),
    );
  }

  Widget _buildFromSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'From',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCurrencyDropdown(
                value: _fromCurrency,
                onChanged: (value) => setState(() => _fromCurrency = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCurrencyDropdown(
                value: _toCurrency,
                onChanged: (value) => setState(() => _toCurrency = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isLoading
                      ? 'Converting...'
                      : _convertedAmount > 0
                          ? '${_convertedAmount.toStringAsFixed(2)} $_toCurrency'
                          : 'Converted amount',
                  style: TextStyle(
                    color: _isLoading || _convertedAmount == 0
                        ? Colors.grey
                        : AppColors.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Also convert to',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCurrencyDropdown(
                value: _toCurrency2,
                onChanged: (value) => setState(() => _toCurrency2 = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isLoading
                      ? 'Converting...'
                      : _convertedAmount2 > 0
                          ? '${_convertedAmount2.toStringAsFixed(2)} $_toCurrency2'
                          : 'Converted amount',
                  style: TextStyle(
                    color: _isLoading || _convertedAmount2 == 0
                        ? Colors.grey
                        : AppColors.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        items: _currencies.map((currency) {
          return DropdownMenuItem(
            value: currency,
            child: Text(currency),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConvertButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _isLoading ? null : _convertCurrency,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Convert',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  // Fungsi untuk melakukan konversi mata uang
  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) {
      _showErrorDialog('Masukkan jumlah mata uang');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String accessKey = dotenv.env['CONVERT_CURRENCY_API_KEY'] ?? '';
      final response = await http.get(Uri.parse(
          'https://api.exchangerate-api.com/v4/latest/$_fromCurrency?access_key=$accessKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_toCurrency];
        final rate2 = data['rates'][_toCurrency2];

        setState(() {
          _convertedAmount = double.parse(_amountController.text) * rate;
          _convertedAmount2 = double.parse(_amountController.text) * rate2;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Gagal mengambil data konversi');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Tutup'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _isLoading = false;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
