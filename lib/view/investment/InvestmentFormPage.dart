import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../model/investment.dart';
import '../../model/investment_account.dart';

/// A simple form page to create a new [Investment].
class InvestmentFormPage extends StatefulWidget {
  final int? initialAccountId;

  const InvestmentFormPage({super.key, this.initialAccountId});

  @override
  State<InvestmentFormPage> createState() => _InvestmentFormPageState();
}

class _InvestmentFormPageState extends State<InvestmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  final DatabaseHelper _db = DatabaseHelper();

  List<InvestmentAccount> _accounts = [];
  InvestmentAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _db.getAccounts();
    InvestmentAccount? selected;
    if (accounts.isNotEmpty) {
      if (widget.initialAccountId != null) {
        selected = accounts.firstWhere(
            (a) => a.id == widget.initialAccountId,
            orElse: () => accounts.first);
      } else {
        selected = accounts.first;
      }
    }
    setState(() {
      _accounts = accounts;
      _selectedAccount = selected;
    });
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) return;

    final symbol = _symbolController.text.trim();
    final quantity = int.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final investment = Investment.newInvestment(
      accountId: _selectedAccount!.id,
      symbol: symbol,
      buyPrice: price,
      quantity: quantity,
      fee: 0,
      currentPrice: price,
      buyDate: DateTime.now(),
    );

    final id = await _db.insertInvestment(investment);
    Navigator.pop(context, investment.copyWith(id: id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增投資'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<InvestmentAccount>(
                value: _selectedAccount,
                decoration: const InputDecoration(labelText: '投資帳戶'),
                items: _accounts
                    .map(
                      (acc) => DropdownMenuItem(
                        value: acc,
                        child: Text(acc.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedAccount = value;
                }),
              ),
              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(labelText: '投資標的'),
                validator: (value) =>
                    value == null || value.isEmpty ? '請輸入標的' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: '數量'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? '請輸入數量' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '單價'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value == null || value.isEmpty ? '請輸入單價' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('儲存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
