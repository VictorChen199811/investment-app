import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../model/investment.dart';
import '../../model/investment_account.dart';
import '../../database/database_helper.dart';
import 'package:investment/view/stats/StatsPage.dart';
import 'package:investment/view/account/AccountPage.dart';
import '../investment/InvestmentFormPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _db = DatabaseHelper();
  String? _selectedAccount = 'TWD Securities Account';

  // 以空列表初始化，資料將從資料庫載入
  List<Investment> _investments = [];
  
  @override
  void initState() {
    super.initState();
    _loadInvestments();

    // // 初始化時進行數據驗證
    // print("投資項目總數: ${_investments.length}");
    // for (int i = 0; i < _investments.length; i++) {
    //   print("項目 $i: ${_investments[i].symbol}");
    // }

    // // 為了在熱重載時也確保黃金項目存在，我們在構造函數中進行檢查
    // // 注意：這段代碼只是為了解決當前問題，正常情況下不建議這樣做

    // // 在初始化後立即確認數據已正確加載
    // print("初始化時的投資項目數量: ${_investments.length}");
    // for (int i = 0; i < _investments.length; i++) {
    //   print("初始化項目 $i: ${_investments[i].symbol} (cost: ${_investments[i].totalCost})");
    // }
  }

  Future<void> _loadInvestments() async {
    var accounts = await _db.getAccounts();

    final data = await _db.getInvestments(1);
    setState(() {
      _investments = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 避免在 build 方法中輸出日誌，因為它會在每次重建時執行
    // 只在開發時輸出一條簡短的日誌，幫助調試
    // print("重建 UI: ${_investments.length} 個投資項目");
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSummaryCards(),
              _buildPortfolioSection(),
              // 添加底部空間，防止內容被浮動按鈕遮擋
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<Investment?>(
            context,
            MaterialPageRoute(builder: (_) => const InvestmentFormPage()),
          );

          if (result != null) {
            setState(() {
              _investments = List.from(_investments)..add(result);
            });
            developer.log('Added investment: ${result.symbol}, total: ${_investments.length}');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('新增投資'),
        elevation: 4,
      ),
      // 添加底部間距，避免浮動按鈕擋住內容
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '分析'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '投資'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '帳戶'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              );
              break;
            case 1:
              // 已在投資頁，無需跳轉
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '選擇帳戶',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedAccount,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (value) {
                  setState(() {
                    _selectedAccount = value;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'TWD Securities Account',
                    child: Text('TWD 證券帳戶'),
                  ),
                  DropdownMenuItem(
                    value: 'USD Brokerage Account',
                    child: Text('USD 經紀帳戶'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // 使用更安全的方式計算總額
    double totalInvestment = _calculateTotalInvestment();
    double currentValue = _calculateCurrentValue();
    double profitLoss = currentValue - totalInvestment;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '投資概覽',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard('總投資', totalInvestment, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard('目前價值', currentValue, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard('收益/損失', profitLoss, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
    
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    // 創建數據快照，確保 UI 重建時使用當前數據
    final investmentsSnapshot = List<Investment>.from(_investments);
    // print("構建投資組合區段：${investmentsSnapshot.length} 個項目");

    // // 遍歷並打印所有項目，幫助調試
    // for (int i = 0; i < investmentsSnapshot.length; i++) {
    //   print("  - 項目 $i: ${investmentsSnapshot[i].symbol}");
    // }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    '投資組合',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 視覺標記，顯示黃金項目狀態
                ],
              ),
              Row(
                children: [
                  // 添加刷新按鈕
                  // 添加兩個按鈕：刷新和重置
                  Row(
                    children: [
                      // 原有的刷新按鈕
                      IconButton(
                        onPressed: () {
                          // 先執行診斷
                          // print("\n===== 刷新前診斷 =====");
                          // print("投資列表長度: ${_investments.length}");
                          // for (int i = 0; i < _investments.length; i++) {
                          //   print("  $i: ${_investments[i].symbol}");
                          // }
                          
                          // 強制刷新 UI
                          setState(() {
                            // print("手動刷新 UI");
                          });
                          
                          // 延遲執行第二次刷新，確保 UI 更新
                          Future.delayed(const Duration(milliseconds: 300), () {
                            setState(() {
                              // print("二次刷新確認 - 當前項目數: ${_investments.length}");
                            });
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        tooltip: '刷新列表',
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('排序'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 使用 Column 和 map 方法替代 ListView，避免在 SingleChildScrollView 中嵌套可滾動視圖
          // 重新構建投資列表，使用最直接的方式處理數據
          Column(
            children: List.generate(investmentsSnapshot.length, (index) {
              // 使用快照數據而不是直接引用 _investments
              final Investment item = investmentsSnapshot[index];
              final symbol = item.symbol;

              final double cost = item.totalCost;
              final double currentPrice = item.currentPrice;
              
              return Column(
                key: ValueKey('investment-$index-$symbol'), // 添加唯一 Key
                children: [
                  _buildInvestmentCard(
                    key: ValueKey(symbol), // 為卡片添加 Key
                    symbol: symbol,
                    cost: cost,
                    currentPrice: currentPrice,
                  ),
                  if (index < _investments.length - 1)
                    const SizedBox(height: 12),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // 直接計算總投資成本
  double _calculateTotalInvestment() {
    double total = 0.0;
    for (final investment in _investments) {
      total += investment.totalCost;
    }
    return total;
  }

  // 計算當前總價值
  double _calculateCurrentValue() {
    double total = 0.0;
    for (var investment in _investments) {
      total += investment.currentPrice;
    }
    return total;
  }
  
  // 計算投資項目的漲跌幅度 - 更加穩健的實現
  double _calculateChangePercentage(double cost, double currentPrice) {
    // 防止除以零錯誤
    if (cost <= 0) return 0;
    return ((currentPrice - cost) / cost) * 100;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // print("==== didChangeDependencies 被調用 ====");
  }
  
  // 添加排序方法
  void _sortInvestments(String sortBy) {
    setState(() {
      if (sortBy == 'symbol') {
        _investments.sort((a, b) => a.symbol.compareTo(b.symbol));
      } else if (sortBy == 'cost') {
        _investments.sort((a, b) => a.totalCost.compareTo(b.totalCost));
      } else if (sortBy == 'value') {
        _investments.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
      }
    });
  }
  
  // 刪除投資項目
  Future<void> _removeInvestment(int index) async {
    if (index >= 0 && index < _investments.length) {
      final removedItem = _investments[index];
      await _db.deleteInvestment(removedItem.id);
      setState(() {
        _investments.removeAt(index);
        developer.log('Removed investment: ${removedItem.symbol}');
        developer.log('Current investment count: ${_investments.length}');
      });
    }
  }
  
  Widget _buildInvestmentCard({
    Key? key, // 添加 key 參數
    required String symbol,
    required double cost,
    required double currentPrice,
  }) {
    // 計算漲跌幅和金額變化
    double changePercentage = _calculateChangePercentage(cost, currentPrice);
    double changeAmount = currentPrice - cost;
    final isPositive = changePercentage >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
  
    return GestureDetector(
      onLongPress: () {
        // 查找當前項目的索引
        int? index;
        for (int i = 0; i < _investments.length; i++) {
          final item = _investments[i];
          if (item.symbol == symbol &&
              item.totalCost == cost &&
              item.currentPrice == currentPrice) {
            index = i;
            break;
          }
        }
        
        if (index != null) {
          // 顯示確認對話框
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('刪除投資'),
              content: Text('確定要刪除 $symbol 嗎？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    await _removeInvestment(index!);
                    Navigator.pop(context);
                  },
                  child: Text('刪除'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          children: [
            // 標題行：股票代碼和漲跌幅
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      changeIcon,
                      color: changeColor,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${changePercentage.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 詳細資訊行：成本、當前價值、漲跌金額
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 成本
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '成本',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${cost.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // 當前價值
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '當前價值',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${currentPrice.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // 盈虧
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '盈虧',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${isPositive ? "+" : ""}\$${changeAmount.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
              ));
  }
}
