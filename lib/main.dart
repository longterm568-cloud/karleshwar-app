import 'package:flutter/material.dart';

void main() {
  runApp(const KarleshwarApp());
}

// ---------------- MODELS ----------------
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

class WorkerProfile {
  final String id;
  final String name;
  final String role;
  final String phone;
  String workDone;
  double salaryPaid;
  double nextSalaryDue;
  double expenseAdvance; // kharcha

  WorkerProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    this.workDone = "Cane cutting & loading",
    this.salaryPaid = 0.0,
    this.nextSalaryDue = 0.0,
    this.expenseAdvance = 0.0,
  });
}

class FarmerPurchase {
  final String farmerName;
  final String phone;
  final String village;
  final double quantity; // in tons or acres
  final String unit; // 'Tons' or 'Acres'
  final double ratePerUnit;
  final double totalPayable;
  final double paidAmount;
  final double balanceDue;
  final DateTime date;

  FarmerPurchase({
    required this.farmerName,
    required this.phone,
    required this.village,
    required this.quantity,
    required this.unit,
    required this.ratePerUnit,
    required this.totalPayable,
    required this.paidAmount,
    required this.balanceDue,
    required this.date,
  });
}

// ---------------- ROOT APP ----------------
class KarleshwarApp extends StatelessWidget {
  const KarleshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KARLESHWAR SUGARCANE FEEDS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E5631),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E5631),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const MainNavigationHolder(),
    );
  }
}

// ---------------- MAIN NAVIGATION ----------------
class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  final List<Customer> _customers = [];
  final List<TransactionRecord> _transactions = [];
  final List<WorkerProfile> _workers = [];
  final List<FarmerPurchase> _farmers = [];

  double rateCo86032 = 3200.0;
  double rateCo265 = 2950.0;
  String adminPin = "1234";

  void _addCustomer(Customer customer) => setState(() => _customers.add(customer));
  void _addTransaction(TransactionRecord tx) => setState(() => _transactions.add(tx));
  void _addWorker(WorkerProfile w) => setState(() => _workers.add(w));
  void _addFarmer(FarmerPurchase f) => setState(() => _farmers.add(f));

  void _updateRates(double r1, double r2) {
    setState(() {
      rateCo86032 = r1;
      rateCo265 = r2;
    });
  }

  void _changePin(String newPin) {
    setState(() {
      adminPin = newPin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      WorkersScreen(
        workers: _workers,
        onAddWorker: _addWorker,
        onUpdateWorker: () => setState(() {}),
      ),
      FarmersScreen(
        farmers: _farmers,
        onAddFarmer: _addFarmer,
      ),
      RevenueScreen(transactions: _transactions),
      AddCustomerScreen(onCustomerAdded: _addCustomer),
      UdhariScreen(customers: _customers, onTransactionAdded: _addTransaction),
      LiveRateScreen(
        rateCo86032: rateCo86032,
        rateCo265: rateCo265,
        adminPin: adminPin,
        onRatesUpdated: _updateRates,
        onPinChanged: _changePin,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KARLESHWAR SUGARCANE FEEDS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: const Color(0xFFC8E6C9),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.badge), label: 'Workers'),
          NavigationDestination(icon: Icon(Icons.agriculture), label: 'Farmers'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Revenue'),
          NavigationDestination(icon: Icon(Icons.person_add), label: 'Customer'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Udhari'),
          NavigationDestination(icon: Icon(Icons.price_change), label: 'Rates'),
        ],
      ),
    );
  }
}

// ---------------- 1. HOME SCREEN ----------------
class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionTile(
          title: 'WORKERS DIRECTORY',
          subtitle: 'Worker profiles, work log, salary & kharcha advances',
          icon: Icons.badge,
          color: const Color(0xFF00695C),
          onTap: () => onNavigate(1),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'FARMERS CANE PURCHASE',
          subtitle: 'Sugarcane bought, live rate per Ton/Acre & dues',
          icon: Icons.agriculture,
          color: const Color(0xFF558B2F),
          onTap: () => onNavigate(2),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'REVENUE & CASH FLOW',
          subtitle: 'Weekly collection & verified transactions',
          icon: Icons.payments,
          color: const Color(0xFF2E7D32),
          onTap: () => onNavigate(3),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'ADD CUSTOMER',
          subtitle: 'Register feed buyer & sugarcane tons',
          icon: Icons.person_add,
          color: const Color(0xFFE65100),
          onTap: () => onNavigate(4),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'UDHARI (CREDIT) REGISTER',
          subtitle: 'Track advances, balance & pending dues',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFC62828),
          onTap: () => onNavigate(5),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: "TODAY'S LIVE RATE",
          subtitle: 'CO-86032 & CO-265 rates + PIN controls',
          icon: Icons.bolt,
          color: const Color(0xFF1565C0),
          onTap: () => onNavigate(6),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// ---------------- 2. WORKERS SCREEN ----------------
class WorkersScreen extends StatelessWidget {
  final List<WorkerProfile> workers;
  final Function(WorkerProfile) onAddWorker;
  final VoidCallback onUpdateWorker;

  const WorkersScreen({
    super.key,
    required this.workers,
    required this.onAddWorker,
    required this.onUpdateWorker,
  });

  void _openAddWorkerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Cane Harvester / Loader');
    final phoneCtrl = TextEditingController();
    final nextSalCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Worker Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Worker Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Role / Job', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: nextSalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Next Base Salary (₹)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final w = WorkerProfile(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                role: roleCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                nextSalaryDue: double.tryParse(nextSalCtrl.text) ?? 0.0,
              );
              onAddWorker(w);
              Navigator.pop(ctx);
            },
            child: const Text('SAVE WORKER'),
          ),
        ],
      ),
    );
  }

  void _openWorkerDetails(BuildContext context, WorkerProfile worker) {
    final workCtrl = TextEditingController(text: worker.workDone);
    final paidCtrl = TextEditingController(text: worker.salaryPaid.toString());
    final nextCtrl = TextEditingController(text: worker.nextSalaryDue.toString());
    final expCtrl = TextEditingController(text: worker.expenseAdvance.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${worker.name} Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact: ${worker.phone.isEmpty ? "N/A" : worker.phone} | ${worker.role}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Divider(height: 20),
              TextField(controller: workCtrl, decoration: const InputDecoration(labelText: 'Work Performed Log', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Salary Already Paid (₹)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: nextCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Next Salary Payable (₹)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: expCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Money Given for Kharcha/Expense (₹)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
          ElevatedButton(
            onPressed: () {
              worker.workDone = workCtrl.text.trim();
              worker.salaryPaid = double.tryParse(paidCtrl.text) ?? worker.salaryPaid;
              worker.nextSalaryDue = double.tryParse(nextCtrl.text) ?? worker.nextSalaryDue;
              worker.expenseAdvance = double.tryParse(expCtrl.text) ?? worker.expenseAdvance;
              onUpdateWorker();
              Navigator.pop(ctx);
            },
            child: const Text('UPDATE PROFILE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: workers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.badge_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No workers added yet.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openAddWorkerDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Worker'),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workers.length,
              itemBuilder: (ctx, i) {
                final w = workers[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      child: Text(w.name.isNotEmpty ? w.name[0].toUpperCase() : 'W'),
                    ),
                    title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Work: ${w.workDone}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Paid: ₹${w.salaryPaid}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('Next: ₹${w.nextSalaryDue}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('Kharcha: ₹${w.expenseAdvance}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () => _openWorkerDetails(context, w),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddWorkerDialog(context),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Worker'),
      ),
    );
  }
}

// ---------------- 3. FARMERS SCREEN ----------------
class FarmersScreen extends StatelessWidget {
  final List<FarmerPurchase> farmers;
  final Function(FarmerPurchase) onAddFarmer;

  const FarmersScreen({super.key, required this.farmers, required this.onAddFarmer});

  void _openAddFarmerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final villageCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    String unit = 'Tons';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Record Farmer Cane Purchase'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Farmer Full Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: villageCtrl, decoration: const InputDecoration(labelText: 'Village / Farm Location', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity Brought', border: OutlineInputBorder())),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: unit,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: ['Tons', 'Acres'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (val) => setStateDialog(() => unit = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Rate per $unit (₹)', border: const OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount Paid to Farmer (₹)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                final paid = double.tryParse(paidCtrl.text) ?? 0.0;
                final total = qty * rate;
                final bal = total - paid;

                onAddFarmer(FarmerPurchase(
                  farmerName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  village: villageCtrl.text.trim(),
                  quantity: qty,
                  unit: unit,
                  ratePerUnit: rate,
                  totalPayable: total,
                  paidAmount: paid,
                  balanceDue: bal,
                  date: DateTime.now(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('SAVE RECORD'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: farmers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No farmer purchases logged.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openAddFarmerDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Farmer Cane Purchase'),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: farmers.length,
              itemBuilder: (ctx, i) {
                final f = farmers[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(f.farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${f.quantity} ${f.unit}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                          ],
                        ),
                        Text('Village: ${f.village.isEmpty ? "Local" : f.village} | Phone: ${f.phone.isEmpty ? "N/A" : f.phone}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rate: ₹${f.ratePerUnit}/${f.unit}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('Total: ₹${f.totalPayable}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Paid: ₹${f.paidAmount}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('Balance Due: ₹${f.balanceDue}', style: TextStyle(color: f.balanceDue > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFarmerDialog(context),
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase'),
      ),
    );
  }
}

// ---------------- 4. REVENUE SCREEN ----------------
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

// ---------------- 5. ADD CUSTOMER SCREEN ----------------
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
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
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

// ---------------- 6. UDHARI (CREDIT) SCREEN ----------------
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
            onPressed: _saveTransaction,
            child: const Text('SUBMIT ENTRY'),
          ),
        ],
      ),
    );
  }
}

// ---------------- 7. LIVE RATE & ADMIN SETTINGS ----------------
class LiveRateScreen extends StatelessWidget {
  final double rateCo86032;
  final double rateCo265;
  final String adminPin;
  final Function(double, double) onRatesUpdated;
  final Function(String) onPinChanged;

  const LiveRateScreen({
    super.key,
    required this.rateCo86032,
    required this.rateCo265,
    required this.adminPin,
    required this.onRatesUpdated,
    required this.onPinChanged,
  });

  void _showRateDialog(BuildContext context, String variety, double currentRate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$variety Live Rate'),
        content: Text('Current Market Price: ₹$currentRate / ton', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE'))],
      ),
    );
  }

  void _openAdminEditor(BuildContext context) {
    final pinCtrl = TextEditingController();
    final r1Ctrl = TextEditingController(text: rateCo86032.toString());
    final r2Ctrl = TextEditingController(text: rateCo265.toString());
    final newPinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Owner Rate & PIN Edit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Current Secret PIN', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(controller: r1Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CO-86032 Rate (₹)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: r2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CO-265 Rate (₹)', border: OutlineInputBorder())),
              const Divider(height: 24),
              TextField(
                controller: newPinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Secret PIN (Optional)', border: OutlineInputBorder()),
              ),
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

                if (newPinCtrl.text.trim().isNotEmpty) {
                  onPinChanged(newPinCtrl.text.trim());
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings updated successfully!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN. Access denied.')));
              }
            },
            child: const Text('SAVE CHANGES'),
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
            leading: const CircleAvatar(backgroundColor: Color(0xFF1565C0), child: Text('1', style: TextStyle(color: Colors.white))),
            title: const Text('CO - 86032', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('Tap to view live rate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRateDialog(context, 'CO - 86032', rateCo86032),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const CircleAvatar(backgroundColor: Color(0xFF1565C0), child: Text('2', style: TextStyle(color: Colors.white))),
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
            label: const Text('Owner Rate & PIN Edit (Protected)'),
          ),
        ],
      ),
    );
  }
}
