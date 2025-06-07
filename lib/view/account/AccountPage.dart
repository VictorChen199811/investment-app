import 'package:flutter/material.dart';
import '../../model/investment.dart';
import '../../model/investment_account.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final List<InvestmentAccount> _accounts;
  late final List<Investment> _investments;

  @override
  void initState() {
    super.initState();
    _accounts = [
      InvestmentAccount(id: 1, name: 'TWD 證券帳戶', currency: 'TWD'),
      InvestmentAccount(id: 2, name: 'USD 經紀帳戶', currency: 'USD'),
    ];

    _investments = [
      Investment(
        id: 1,
        accountId: 1,
        symbol: 'AAPL',
        buyPrice: 2500,
        quantity: 1,
        fee: 0,
        currentPrice: 2587.5,
        buyDate: DateTime.now(),
      ),
      Investment(
        id: 2,
        accountId: 1,
        symbol: 'TSMC',
        buyPrice: 3700,
        quantity: 1,
        fee: 0,
        currentPrice: 3655.6,
        buyDate: DateTime.now(),
      ),
      Investment(
        id: 3,
        accountId: 2,
        symbol: 'MSFT',
        buyPrice: 150,
        quantity: 1,
        fee: 0,
        currentPrice: 162.5,
        buyDate: DateTime.now(),
      ),
    ];
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
          final investments = _investments
              .where((inv) => inv.accountId == account.id)
              .toList();

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
