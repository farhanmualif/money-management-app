import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_app_new/themes/themes.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CurrencyConverterScreen createState() => _CurrencyConverterScreen();
}

class _CurrencyConverterScreen extends State<CurrencyConverterScreen> {
  // Variabel untuk menyimpan data
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _toCurrency2 = 'JPY';
  double _convertedAmount = 0.0;
  double _convertedAmount2 = 0.0;
  bool _isLoading = false;

  // Daftar mata uang yang tersedia
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Mata Uang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Baris Pertama: Mata Uang Asal dan Jumlah
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Dari Mata Uang',
                      border: OutlineInputBorder(),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Masukkan Jumlah',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baris Kedua: Mata Uang Tujuan
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Ke Mata Uang',
                      border: OutlineInputBorder(),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isLoading
                          ? 'Sedang memproses...'
                          : _convertedAmount > 0
                              ? '${_convertedAmount.toStringAsFixed(2)} $_toCurrency'
                              : 'Hasil Konversi',
                      style: TextStyle(
                        color: _isLoading || _convertedAmount == 0
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baris Tambahan: Pilihan Hasil Konversi Kedua
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency2,
                    decoration: const InputDecoration(
                      labelText: 'Ke Mata Uang',
                      border: OutlineInputBorder(),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency2 = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isLoading
                          ? 'Sedang memproses...'
                          : _convertedAmount2 > 0
                              ? '${_convertedAmount2.toStringAsFixed(2)} $_toCurrency2'
                              : 'Hasil Konversi',
                      style: TextStyle(
                        color: _isLoading || _convertedAmount2 == 0
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tombol Konversi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _convertCurrency,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Konversi',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
