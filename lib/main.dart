import 'package:flutter/material.dart';

void main() {
  runApp(const KarleshwarApp());
}

class Customer {
  final String name;
  final String phone;
  final double tons;

  Customer({required this.name, required this.phone, required this.tons});
}

class TransactionRecord {
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final DateTime date;

  TransactionRecord({
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.date,
  });
}

class KarleshwarApp extends StatelessWidget {
  const KarleshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KARLESHWAR SUGARCANE FEEDS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainNavigationHolder(),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  final List<Customer> _customers = [];
  final List<TransactionRecord> _transactions = [];

  double rateCo86032 = 3200.0;
  double rateCo265 = 2950.0;
  final String adminPin = "1234";

  void _addCustomer(Customer customer) {
    setState(() {
      _customers.add(customer);
    });
  }

  void _addTransaction(TransactionRecord tx) {
    setState(() {
      _transactions.add(tx);
    });
  }

  void _updateRates(double r1, double r2) {
    setState(() {
      rateCo86032 = r1;
      rateCo265 = r2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        customers: _customers,
        transactions: _transactions,
        rateCo86032: rateCo86032,
        rateCo265: rateCo265,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      RevenueScreen(transactions: _transactions),
      AddCustomerScreen(onCustomerAdded: _addCustomer),
      UdhariScreen(
        customers: _customers,
        onTransactionAdded: _addTransaction,
      ),
      LiveRateScreen(
        rateCo86032: rateCo86032,
        rateCo265: rateCo265,
        adminPin: adminPin,
        onRatesUpdated: _updateRates,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KARLESHWAR SUGARCANE FEEDS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E5631),
        elevation: 2,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: const Color(0xFFE8F5E9),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF1E5631)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Revenue'),
          NavigationDestination(icon: Icon(Icons.person_add_alt_1), label: 'Customer'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Udhari'),
          NavigationDestination(icon: Icon(Icons.price_change), label: 'Rates'),
        ],
      ),
    );
  }
}

// 1. HOME SCREEN
class HomeScreen extends StatelessWidget {
  final List<Customer> customers;
  final List<TransactionRecord> transactions;
  final double rateCo86032;
  final double rateCo265;
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.customers,
    required this.transactions,
    required this.rateCo86032,
    required this.rateCo265,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionCard(
            title: 'REVENUE THIS WEEK',
            subtitle: 'Tap to view weekly ledger and cash flow',
            icon: Icons.payments,
            backgroundColor: const Color(0xFF2E7D32),
            textColor: Colors.white,
            onTap: () => onNavigate(1),
          ),
          const SizedBox(height: 14),
          _buildActionCard(
            title: 'ADD CUSTOMER',
            subtitle: 'Register new buyer & sugarcane tons',
            icon: Icons.person_add,
            backgroundColor: const Color(0xFFFFF9C4),
            textColor: Colors.black87,
            onTap: () => onNavigate(2),
          ),
          const SizedBox(height: 14),
          _buildActionCard(
            title: 'UDHARI REGISTER',
            subtitle: 'Track advance, balance & outstanding dues',
            icon: Icons.account_balance_wallet,
            backgroundColor: const Color(0xFFD32F2F),
            textColor: Colors.white,
            onTap: () => onNavigate(3),
          ),
          const SizedBox(height: 14),
          _buildActionCard(
            title: "TODAY'S LIVE RATE",
            subtitle: 'CO-86032 & CO-265 current prices',
            icon: Icons.bolt,
            backgroundColor: const Color(0xFF1976D2),
            textColor: Colors.white,
            onTap: () => onNavigate(4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: textColor.withOpacity(0.15),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

// 2. REVENUE SCREEN
class RevenueScreen extends StatelessWidget {
  final List<TransactionRecord> transactions;
  const RevenueScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final weeklyList = transactions.where((t) => t.date.isAfter(sevenDaysAgo)).toList();
    final totalWeeklyReceived = weeklyList.fold<double>(0.0, (sum, item) => sum + item.paidAmount);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF2E7D32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weekly Cash Received:', style: TextStyle(color: Colors.white, fontSize: 15)),
                  Text('₹${totalWeeklyReceived.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Recent Weekly Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: weeklyList.isEmpty
                ? const Center(child: Text('No transactions recorded this week.'))
                : ListView.builder(
                    itemCount: weeklyList.length,
                    itemBuilder: (context, i) {
                      final item = weeklyList[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(item.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Paid: ₹${item.paidAmount} | Pending: ₹${item.pendingAmount}'),
                          trailing: Text('${item.date.day}/${item.date.month}'),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

// 3. ADD CUSTOMER SCREEN
class AddCustomerScreen extends StatefulWidget {
  final Function(Customer) onCustomerAdded;
  const AddCustomerScreen({super.key, required this.onCustomerAdded});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _tonsCtrl = TextEditingController();

  void _save() {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _tonsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final tons = double.tryParse(_tonsCtrl.text) ?? 0.0;
    widget.onCustomerAdded(Customer(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(), tons: tons));
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _tonsCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer registered successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 16),
          TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone))),
          const SizedBox(height: 16),
          TextField(controller: _tonsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sugarcane Brought (Tons)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.scale))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('SAVE CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// 4. UDHARI (CREDIT) SCREEN
class UdhariScreen extends StatefulWidget {
  final List<Customer> customers;
  final Function(TransactionRecord) onTransactionAdded;
  const UdhariScreen({super.key, required this.customers, required this.onTransactionAdded});

  @override
  State<UdhariScreen> createState() => _UdhariScreenState();
}

class _UdhariScreenState extends State<UdhariScreen> {
  Customer? _selectedCustomer;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _tonsCtrl = TextEditingController();
  final _totalAmountCtrl = TextEditingController();
  final _paidAmountCtrl = TextEditingController();

  double _pendingAmount = 0.0;

  void _calculatePending() {
    final total = double.tryParse(_totalAmountCtrl.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountCtrl.text) ?? 0.0;
    setState(() {
      _pendingAmount = total - paid;
    });
  }

  void _saveTransaction() {
    final customerName = _selectedCustomer != null ? _selectedCustomer!.name : _nameCtrl.text.trim();
    if (customerName.isEmpty) return;

    final total = double.tryParse(_totalAmountCtrl.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountCtrl.text) ?? 0.0;

    widget.onTransactionAdded(
      TransactionRecord(
        customerName: customerName,
        totalAmount: total,
        paidAmount: paid,
        pendingAmount: _pendingAmount,
        date: DateTime.now(),
      ),
    );

    _nameCtrl.clear();
    _phoneCtrl.clear();
    _tonsCtrl.clear();
    _totalAmountCtrl.clear();
    _paidAmountCtrl.clear();
    setState(() {
      _selectedCustomer = null;
      _pendingAmount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Udhari entry logged!')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Registered Customer:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Customer>(
            value: _selectedCustomer,
            hint: const Text('Choose customer (Auto-fills below)'),
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: widget.customers.map((c) {
              return DropdownMenuItem(value: c, child: Text('${c.name} (${c.tons} Tons)'));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCustomer = val;
                if (val != null) {
                  _nameCtrl.text = val.name;
                  _phoneCtrl.text = val.phone;
                  _tonsCtrl.text = val.tons.toString();
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _tonsCtrl, decoration: const InputDecoration(labelText: 'Tons', border: OutlineInputBorder())),
          const Divider(height: 36),
          TextField(
            controller: _totalAmountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total Payable Amount (₹)', border: OutlineInputBorder()),
            onChanged: (_) => _calculatePending(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paidAmountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Paid Amount (₹)', border: OutlineInputBorder()),
            onChanged: (_) => _calculatePending(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending (Udhari):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                Text('₹${_pendingAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
            onPressed: _saveTransaction,
            child: const Text('SUBMIT ENTRY'),
          ),
        ],
      ),
    );
  }
}

// 5. LIVE RATE SCREEN
class LiveRateScreen extends StatelessWidget {
  final double rateCo86032;
  final double rateCo265;
  final String adminPin;
  final Function(double, double) onRatesUpdated;

  const LiveRateScreen({
    super.key,
    required this.rateCo86032,
    required this.rateCo265,
    required this.adminPin,
    required this.onRatesUpdated,
  });

  void _showRateDialog(BuildContext context, String variety, double currentRate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$variety Live Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Market Price: ₹$currentRate / ton', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            const Text('Rates update according to local harvesting & transport rates.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  void _openAdminEditor(BuildContext context) {
    final pinCtrl = TextEditingController();
    final r1Ctrl = TextEditingController(text: rateCo86032.toString());
    final r2Ctrl = TextEditingController(text: rateCo265.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Owner Rate Edit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Owner Secret PIN (Default: 1234)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(controller: r1Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CO-86032 Rate (₹)', border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: r2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CO-265 Rate (₹)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (pinCtrl.text == adminPin) {
                final r1 = double.tryParse(r1Ctrl.text) ?? rateCo86032;
                final r2 = double.tryParse(r2Ctrl.text) ?? rateCo265;
                onRatesUpdated(r1, r2);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rates updated successfully!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN. Access denied.')));
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const CircleAvatar(backgroundColor: Color(0xFF1976D2), child: Text('1', style: TextStyle(color: Colors.white))),
            title: const Text('CO - 86032', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('Tap to view live rate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRateDialog(context, 'CO - 86032', rateCo86032),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const CircleAvatar(backgroundColor: Color(0xFF1976D2), child: Text('2', style: TextStyle(color: Colors.white))),
            title: const Text('CO - 265', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('Tap to view live rate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRateDialog(context, 'CO - 265', rateCo265),
          ),
          const Spacer(),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => _openAdminEditor(context),
            icon: const Icon(Icons.lock_clock),
            label: const Text('Owner Rate Edit (PIN Protected)'),
          ),
        ],
      ),
    );
  }
}
