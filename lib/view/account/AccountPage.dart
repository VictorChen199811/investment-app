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
    var accounts = await _db.getAccounts();
    if (accounts.isEmpty) {
      await _db.insertAccount(
          InvestmentAccount(id: 0, name: 'TWD 證券帳戶', currency: 'TWD'));
      await _db.insertAccount(
          InvestmentAccount(id: 0, name: 'USD 經紀帳戶', currency: 'USD'));
      accounts = await _db.getAccounts();
    }

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
                    trailing:
                        Text('\$${inv.currentPrice.toStringAsFixed(1)}'),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
