import 'package:flutter/material.dart';
import '../../model/investment.dart';
import '../../model/investment_account.dart';
import '../../database/database_helper.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<InvestmentAccount> _accounts = [];
  Map<int, List<Investment>> _investments = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final accounts = await _db.getAccounts();

    final investmentMap = <int, List<Investment>>{};
    for (final acc in accounts) {
      final invs = await _db.getInvestments(acc.id);
      investmentMap[acc.id] = invs;
    }

    setState(() {
      _accounts = accounts;
      _investments = investmentMap;
    });
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    String category = '美股';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增帳戶'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '帳戶名稱'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: '帳戶類別'),
              items: const [
                DropdownMenuItem(value: '美股', child: Text('美股')),
                DropdownMenuItem(value: '台股', child: Text('台股')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => category = v ?? '美股',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final currency = _currencyForCategory(category);
              await _db.insertAccount(
                InvestmentAccount.newAccount(
                    name: name, currency: currency, category: category),
              );
              if (mounted) {
                Navigator.pop(context);
                await _loadData();
              }
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  String _currencyForCategory(String category) {
    switch (category) {
      case '台股':
        return 'TWD';
      case '美股':
        return 'USD';
      default:
        return 'USD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          final investments = _investments[account.id] ?? [];

          return ExpansionTile(
            title: Text('${account.name} (${account.currency})'),
            children: investments
                .map(
                  (inv) => ListTile(
                    title: Text(inv.symbol),
                    subtitle: Text('買入 ${inv.quantity} 股 @\$${inv.buyPrice}'),
                    trailing: Text('\$${inv.currentPrice * inv.quantity}'),
                  ),
                )
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
