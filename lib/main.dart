import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KarleshwarApp());
}

class KarleshwarApp extends StatelessWidget {
  const KarleshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'कारळेश्वर ॲग्रो',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ---------------- LOCAL + CLOUD STORAGE ENGINE ----------------
class StorageService {
  static const String projectId = "karaleshwar-mamagmemt";
  static const String baseUrl =
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents";

  static Future<List<Map<String, dynamic>>> getLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      List decoded = json.decode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLocal(String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(list));
  }

  static void syncToCloud(String collection, Map<String, dynamic> data) async {
    try {
      Map<String, dynamic> fields = {};
      data.forEach((k, v) {
        fields[k] = {'stringValue': v.toString()};
      });
      await http.post(
        Uri.parse('$baseUrl/$collection'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': fields}),
      );
    } catch (_) {}
  }
}

// ---------------- MAIN NAVIGATION ----------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    WorkersScreen(),
    FarmersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'डॅशबोर्ड'),
          NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'कामगार'),
          NavigationDestination(icon: Icon(Icons.agriculture_rounded), label: 'शेतकरी'),
        ],
      ),
    );
  }
}

// ---------------- 1. DASHBOARD & CHART ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalCash = 0;
  double totalUdhari = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    calculateTotals();
  }

  Future<void> calculateTotals() async {
    setState(() => loading = true);
    final sales = await StorageService.getLocal('farmer_sales');
    double cash = 0;
    double udhari = 0;

    for (var s in sales) {
      double paid = double.tryParse(s['paid']?.toString() ?? '0') ?? 0;
      double pending = double.tryParse(s['pending']?.toString() ?? '0') ?? 0;
      cash += paid;
      udhari += pending;
    }

    setState(() {
      totalCash = cash;
      totalUdhari = udhari;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = totalCash + totalUdhari;
    double cashPercent = grandTotal == 0 ? 0 : (totalCash / grandTotal) * 100;
    double udhariPercent = grandTotal == 0 ? 0 : (totalUdhari / grandTotal) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('कारळेश्वर ॲग्रो डॅशबोर्ड'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: calculateTotals),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'व्यवसाय आढावा (रोख वि. उधारी)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          CustomPaint(
                            size: const Size(190, 190),
                            painter: DashboardPiePainter(
                              cashPercent: cashPercent,
                              udhariPercent: udhariPercent,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IndicatorBadge(
                                color: Colors.green.shade700,
                                label: 'रोख जमा',
                                value: '${cashPercent.toStringAsFixed(1)}%',
                              ),
                              IndicatorBadge(
                                color: Colors.red.shade700,
                                label: 'उधारी बाकी',
                                value: '${udhariPercent.toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatBox(
                          title: 'रोख मिळालेले',
                          amount: '₹ ${totalCash.toStringAsFixed(0)}',
                          color: Colors.green.shade700,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatBox(
                          title: 'उधारी शिल्लक',
                          amount: '₹ ${totalUdhari.toStringAsFixed(0)}',
                          color: Colors.red.shade700,
                          icon: Icons.pending_actions_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StatBox(
                    title: 'एकूण व्यवसाय उलाढाल',
                    amount: '₹ ${grandTotal.toStringAsFixed(0)}',
                    color: Colors.blue.shade800,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
            ),
    );
  }
}

class DashboardPiePainter extends CustomPainter {
  final double cashPercent;
  final double udhariPercent;
  DashboardPiePainter({required this.cashPercent, required this.udhariPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 26.0;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (cashPercent == 0 && udhariPercent == 0) {
      basePaint.color = Colors.grey.shade300;
      canvas.drawCircle(center, radius - strokeWidth / 2, basePaint);
      return;
    }

    basePaint.color = Colors.red.shade600;
    canvas.drawCircle(center, radius - strokeWidth / 2, basePaint);

    if (cashPercent > 0) {
      final cashPaint = Paint()
        ..color = Colors.green.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      double sweep = (cashPercent / 100) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -pi / 2,
        sweep,
        false,
        cashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IndicatorBadge extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const IndicatorBadge({super.key, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const StatBox({super.key, required this.title, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------- 2. WORKERS (कामगार) ----------------
class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  List<Map<String, dynamic>> workers = [];

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    final list = await StorageService.getLocal('workers_list');
    setState(() => workers = list);
  }

  void _addWorkerDialog() {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नवीन कामगार जोडा'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'कामगाराचे नाव')),
            TextField(controller: mobileCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'मोबाईल नंबर')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final newW = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameCtrl.text.trim(),
                  'mobile': mobileCtrl.text.trim(),
                };
                workers.add(newW);
                await StorageService.saveLocal('workers_list', workers);
                StorageService.syncToCloud('workers', newW);
                if (mounted) Navigator.pop(ctx);
                loadWorkers();
              }
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWorker(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('कामगार हटवायचा आहे का?'),
        content: Text('${workers[index]['name']} यांचे नाव आणि सर्व नोंदी हटतील.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              String wId = workers[index]['id'];
              workers.removeAt(index);
              await StorageService.saveLocal('workers_list', workers);

              // remove his ledger records too
              final allLedger = await StorageService.getLocal('worker_ledger');
              allLedger.removeWhere((e) => e['workerId'] == wId);
              await StorageService.saveLocal('worker_ledger', allLedger);

              if (mounted) Navigator.pop(ctx);
              loadWorkers();
            },
            child: const Text('हटवा (Delete)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कामगार यादी')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkerDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: workers.isEmpty
          ? const Center(child: Text('कामगार नोंदवले नाहीत. + वर क्लिक करून जोडा.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: workers.length,
              itemBuilder: (ctx, i) {
                final w = workers[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1B5E20),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(w['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(w['mobile']?.isEmpty ?? true ? 'नंबर नाही' : w['mobile']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDeleteWorker(i),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerLedgerScreen(worker: w),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class WorkerLedgerScreen extends StatefulWidget {
  final Map<String, dynamic> worker;
  const WorkerLedgerScreen({super.key, required this.worker});

  @override
  State<WorkerLedgerScreen> createState() => _WorkerLedgerScreenState();
}

class _WorkerLedgerScreenState extends State<WorkerLedgerScreen> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    loadLedger();
  }

  Future<void> loadLedger() async {
    final all = await StorageService.getLocal('worker_ledger');
    setState(() {
      records = all.where((e) => e['workerId'] == widget.worker['id']).toList();
    });
  }

  void _addRecordDialog(bool isUchal) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUchal ? 'उचल जोडा (Advance)' : 'काम जोडा (Work)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'रक्कम (₹)')),
            TextField(controller: noteCtrl, decoration: InputDecoration(labelText: isUchal ? 'कशासाठी उचल घेतली?' : 'कामाचा तपशील')),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'तारीख (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              double amt = double.tryParse(amountCtrl.text) ?? 0;
              if (amt > 0) {
                final all = await StorageService.getLocal('worker_ledger');
                final rec = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'workerId': widget.worker['id'],
                  'type': isUchal ? 'uchal' : 'kaam',
                  'amount': amt,
                  'note': noteCtrl.text.trim(),
                  'date': dateCtrl.text.trim(),
                };
                all.add(rec);
                await StorageService.saveLocal('worker_ledger', all);
                StorageService.syncToCloud('worker_ledger', rec);
                if (mounted) Navigator.pop(ctx);
                loadLedger();
              }
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(int index) async {
    final item = records[index];
    final all = await StorageService.getLocal('worker_ledger');
    all.removeWhere((e) => e['id'] == item['id'] || (e['workerId'] == item['workerId'] && e['date'] == item['date'] && e['amount'] == item['amount']));
    await StorageService.saveLocal('worker_ledger', all);
    loadLedger();
  }

  @override
  Widget build(BuildContext context) {
    double totalKaam = 0;
    double totalUchal = 0;
    for (var r in records) {
      double amt = double.tryParse(r['amount']?.toString() ?? '0') ?? 0;
      if (r['type'] == 'kaam') totalKaam += amt;
      if (r['type'] == 'uchal') totalUchal += amt;
    }
    double balance = totalKaam - totalUchal;

    return Scaffold(
      appBar: AppBar(title: Text(widget.worker['name'] ?? 'कामगार')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _col('एकूण काम', '₹ ${totalKaam.toStringAsFixed(0)}', Colors.green.shade700),
                _col('एकूण उचल', '₹ ${totalUchal.toStringAsFixed(0)}', Colors.red.shade700),
                _col('बाकी देणे', '₹ ${balance.toStringAsFixed(0)}', Colors.blue.shade800),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('उचल जोडा', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _addRecordDialog(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('काम जोडा', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _addRecordDialog(false),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('कोणतीही नोंद नाही.'))
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (ctx, i) {
                      final item = records[i];
                      bool isUchal = item['type'] == 'uchal';
                      return ListTile(
                        leading: Icon(
                          isUchal ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isUchal ? Colors.red : Colors.green,
                        ),
                        title: Text(item['note']?.isEmpty ?? true ? (isUchal ? 'उचल' : 'काम') : item['note'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item['date'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹ ${item['amount']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUchal ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                              onPressed: () => _deleteRecord(i),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _col(String title, String val, Color c) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c)),
      ],
    );
  }
}

// ---------------- 3. FARMERS (शेतकरी व रोख/उधारी विक्री) ----------------
class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  List<Map<String, dynamic>> farmers = [];

  @override
  void initState() {
    super.initState();
    loadFarmers();
  }

  Future<void> loadFarmers() async {
    final list = await StorageService.getLocal('farmers_list');
    setState(() => farmers = list);
  }

  void _addFarmerDialog() {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नवीन शेतकरी / ग्राहक जोडा'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'शेतकऱ्याचे नाव')),
            TextField(controller: mobileCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'मोबाईल नंबर')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final newF = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameCtrl.text.trim(),
                  'mobile': mobileCtrl.text.trim(),
                };
                farmers.add(newF);
                await StorageService.saveLocal('farmers_list', farmers);
                StorageService.syncToCloud('farmers', newF);
                if (mounted) Navigator.pop(ctx);
                loadFarmers();
              }
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFarmer(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('शेतकरी खाते हटवायचे का?'),
        content: Text('${farmers[index]['name']} यांचे नाव आणि सर्व पावत्या हटतील.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              String fId = farmers[index]['id'];
              farmers.removeAt(index);
              await StorageService.saveLocal('farmers_list', farmers);

              final allSales = await StorageService.getLocal('farmer_sales');
              allSales.removeWhere((e) => e['farmerId'] == fId);
              await StorageService.saveLocal('farmer_sales', allSales);

              if (mounted) Navigator.pop(ctx);
              loadFarmers();
            },
            child: const Text('हटवा (Delete)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('शेतकरी / ग्राहक यादी')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFarmerDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: farmers.isEmpty
          ? const Center(child: Text('शेतकरी नोंदवले नाहीत. + वर क्लिक करून जोडा.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: farmers.length,
              itemBuilder: (ctx, i) {
                final f = farmers[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1B5E20),
                      child: Icon(Icons.agriculture, color: Colors.white),
                    ),
                    title: Text(f['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(f['mobile']?.isEmpty ?? true ? 'नंबर नाही' : f['mobile']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDeleteFarmer(i),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FarmerLedgerScreen(farmer: f),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class FarmerLedgerScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;
  const FarmerLedgerScreen({super.key, required this.farmer});

  @override
  State<FarmerLedgerScreen> createState() => _FarmerLedgerScreenState();
}

class _FarmerLedgerScreenState extends State<FarmerLedgerScreen> {
  List<Map<String, dynamic>> sales = [];

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    final all = await StorageService.getLocal('farmer_sales');
    setState(() {
      sales = all.where((e) => e['farmerId'] == widget.farmer['id']).toList();
    });
  }

  void _addSaleDialog() {
    final itemCtrl = TextEditingController(text: 'ऊस / खाद्य');
    final totalCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नवीन विक्री / पावती जोडा'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'तपशील (उदा. ऊस गाडी)')),
              TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'एकूण बिल रक्कम (₹)')),
              TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'दिलेली रोख रक्कम (₹)')),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'तारीख (YYYY-MM-DD)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              double total = double.tryParse(totalCtrl.text) ?? 0;
              double paid = double.tryParse(paidCtrl.text) ?? 0;
              if (total > 0) {
                double pending = total - paid;
                if (pending < 0) pending = 0;

                final all = await StorageService.getLocal('farmer_sales');
                final rec = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'farmerId': widget.farmer['id'],
                  'item': itemCtrl.text.trim(),
                  'total': total,
                  'paid': paid,
                  'pending': pending,
                  'date': dateCtrl.text.trim(),
                };
                all.add(rec);
                await StorageService.saveLocal('farmer_sales', all);
                StorageService.syncToCloud('sales', rec);
                if (mounted) Navigator.pop(ctx);
                loadSales();
              }
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  void _deleteSale(int index) async {
    final item = sales[index];
    final all = await StorageService.getLocal('farmer_sales');
    all.removeWhere((e) => e['id'] == item['id'] || (e['farmerId'] == item['farmerId'] && e['date'] == item['date'] && e['total'] == item['total']));
    await StorageService.saveLocal('farmer_sales', all);
    loadSales();
  }

  @override
  Widget build(BuildContext context) {
    double totalBill = 0;
    double totalPaid = 0;
    double totalPending = 0;
    for (var s in sales) {
      totalBill += double.tryParse(s['total']?.toString() ?? '0') ?? 0;
      totalPaid += double.tryParse(s['paid']?.toString() ?? '0') ?? 0;
      totalPending += double.tryParse(s['pending']?.toString() ?? '0') ?? 0;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.farmer['name'] ?? 'शेतकरी खातं')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSaleDialog,
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('विक्री नोंदवा', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _col('एकूण बिल', '₹ ${totalBill.toStringAsFixed(0)}', Colors.blue.shade800),
                _col('रोख मिळाले', '₹ ${totalPaid.toStringAsFixed(0)}', Colors.green.shade700),
                _col('बाकी उधारी', '₹ ${totalPending.toStringAsFixed(0)}', Colors.red.shade700),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: sales.isEmpty
                ? const Center(child: Text('अद्याप कोणत्याही नोंदी नाहीत. + वर क्लिक करा.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: sales.length,
                    itemBuilder: (ctx, i) {
                      final item = sales[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['item'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Row(
                                    children: [
                                      Text(item['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => _deleteSale(i),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('एकूण: ₹ ${item['total']}'),
                                  Text('रोख: ₹ ${item['paid']}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                  Text('उधारी: ₹ ${item['pending']}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _col(String title, String val, Color c) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
      ],
    );
  }
}
