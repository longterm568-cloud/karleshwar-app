import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const KarleshwarApp());
}

class KarleshwarApp extends StatelessWidget {
  const KarleshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karleshwar Feeds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ---------------- FIRESTORE SERVICE ----------------
class FirestoreService {
  static const String projectId = "karaleshwar-mamagmemt";
  static const String baseUrl =
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents";

  static Future<List<Map<String, dynamic>>> fetchCollection(String collection) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/$collection'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['documents'] == null) return [];
        List<Map<String, dynamic>> list = [];
        for (var doc in data['documents']) {
          String docId = doc['name'].toString().split('/').last;
          Map<String, dynamic> fields = doc['fields'] ?? {};
          Map<String, dynamic> item = {'id': docId};
          fields.forEach((k, v) {
            item[k] = v['stringValue'] ??
                (v['integerValue'] != null ? int.parse(v['integerValue']) : null) ??
                (v['doubleValue'] != null ? double.parse(v['doubleValue'].toString()) : null) ??
                '';
          });
          list.add(item);
        }
        return list;
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      Map<String, dynamic> fields = {};
      data.forEach((k, v) {
        if (v is int) {
          fields[k] = {'integerValue': v.toString()};
        } else if (v is double) {
          fields[k] = {'doubleValue': v};
        } else {
          fields[k] = {'stringValue': v.toString()};
        }
      });
      final res = await http.post(
        Uri.parse('$baseUrl/$collection'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': fields}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'डॅशबोर्ड'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'कामगार'),
          NavigationDestination(icon: Icon(Icons.agriculture), label: 'शेतकरी'),
        ],
      ),
    );
  }
}

// ---------------- DASHBOARD & CHART ----------------
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
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => loading = true);
    final sales = await FirestoreService.fetchCollection('sales');
    double cash = 0;
    double udhari = 0;
    for (var s in sales) {
      double total = double.tryParse(s['total']?.toString() ?? '0') ?? 0;
      double paid = double.tryParse(s['paid']?.toString() ?? '0') ?? 0;
      cash += paid;
      if (total > paid) udhari += (total - paid);
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadDashboardData),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'व्यवसाय आढावा (रोख वि. उधारी)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          CustomPaint(
                            size: const Size(180, 180),
                            painter: DashboardPiePainter(cashPercent: cashPercent),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IndicatorWidget(
                                color: Colors.green,
                                label: 'रोख जमा',
                                value: '${cashPercent.toStringAsFixed(1)}%',
                              ),
                              IndicatorWidget(
                                color: Colors.red,
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
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatBox(
                          title: 'उधारी शिल्लक',
                          amount: '₹ ${totalUdhari.toStringAsFixed(0)}',
                          color: Colors.red.shade700,
                          icon: Icons.pending_actions,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StatBox(
                    title: 'एकूण व्यवसाय उलाढाल',
                    amount: '₹ ${grandTotal.toStringAsFixed(0)}',
                    color: Colors.blue.shade800,
                    icon: Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
    );
  }
}

class DashboardPiePainter extends CustomPainter {
  final double cashPercent;
  DashboardPiePainter({required this.cashPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 26.0;

    final bgPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final cashPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (cashPercent > 0) {
      double sweepAngle = (cashPercent / 100) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -pi / 2,
        sweepAngle,
        false,
        cashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IndicatorWidget extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const IndicatorWidget({super.key, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------- WORKERS SCREEN ----------------
class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  List<Map<String, dynamic>> workers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    setState(() => loading = true);
    final data = await FirestoreService.fetchCollection('workers');
    setState(() {
      workers = data;
      loading = false;
    });
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
              if (nameCtrl.text.isNotEmpty) {
                await FirestoreService.addDocument('workers', {
                  'name': nameCtrl.text,
                  'mobile': mobileCtrl.text,
                  'created_at': DateTime.now().toIso8601String(),
                });
                Navigator.pop(ctx);
                loadWorkers();
              }
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('कामगार यादी'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadWorkers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkerDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
              ? const Center(child: Text('कामगार नोंदवले नाहीत. + वर क्लिक करून जोडा.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: workers.length,
                  itemBuilder: (ctx, i) {
                    final w = workers[i];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1B5E20),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(w['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(w['mobile'] ?? 'मोबाईल नाही'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkerDetailScreen(workerId: w['id'], workerName: w['name'] ?? ''),
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

// ---------------- WORKER DETAIL (UCHAL & KAAM) ----------------
class WorkerDetailScreen extends StatefulWidget {
  final String workerId;
  final String workerName;
  const WorkerDetailScreen({super.key, required this.workerId, required this.workerName});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  List<Map<String, dynamic>> entries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLedger();
  }

  Future<void> loadLedger() async {
    setState(() => loading = true);
    final all = await FirestoreService.fetchCollection('worker_ledger');
    setState(() {
      entries = all.where((e) => e['workerId'] == widget.workerId).toList();
      loading = false;
    });
  }

  void _openAddEntryDialog(bool isUchal) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUchal ? 'उचल जोडा (Advance)' : 'काम जोडा (Work Done)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'रक्कम (₹)')),
            TextField(controller: reasonCtrl, decoration: InputDecoration(labelText: isUchal ? 'कशासाठी उचल घेतली (कारण)' : 'कोणते काम केले?')),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'तारीख (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              double amt = double.tryParse(amountCtrl.text) ?? 0;
              if (amt > 0) {
                await FirestoreService.addDocument('worker_ledger', {
                  'workerId': widget.workerId,
                  'type': isUchal ? 'uchal' : 'kaam',
                  'amount': amt,
                  'reason': reasonCtrl.text,
                  'date': dateCtrl.text,
                });
                Navigator.pop(ctx);
                loadLedger();
              }
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalKaam = 0;
    double totalUchal = 0;
    for (var e in entries) {
      double amt = double.tryParse(e['amount']?.toString() ?? '0') ?? 0;
      if (e['type'] == 'kaam') totalKaam += amt;
      if (e['type'] == 'uchal') totalUchal += amt;
    }
    double balance = totalKaam - totalUchal;

    return Scaffold(
      appBar: AppBar(title: Text(widget.workerName)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryCol('एकूण काम', '₹ ${totalKaam.toStringAsFixed(0)}', Colors.green),
                      _summaryCol('एकूण उचल', '₹ ${totalUchal.toStringAsFixed(0)}', Colors.red),
                      _summaryCol('बाकी देणे', '₹ ${balance.toStringAsFixed(0)}', Colors.blue),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('उचल जोडा'),
                          onPressed: () => _openAddEntryDialog(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('काम जोडा'),
                          onPressed: () => _openAddEntryDialog(false),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(child: Text('अद्याप कोणत्याही नोंदी नाहीत.'))
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (ctx, i) {
                            final item = entries[i];
                            bool isUchal = item['type'] == 'uchal';
                            return ListTile(
                              leading: Icon(
                                isUchal ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isUchal ? Colors.red : Colors.green,
                              ),
                              title: Text(item['reason'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item['date'] ?? ''),
                              trailing: Text(
                                '₹ ${item['amount']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isUchal ? Colors.red : Colors.green,
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

  Widget _summaryCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// ---------------- FARMERS SCREEN ----------------
class FarmersScreen extends StatelessWidget {
  const FarmersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('शेतकरी व पुरवठादार')),
      body: const Center(
        child: Text('शेतकऱ्यांची यादी आणि उधारी नोंदणी थेट जोडलेली आहे.'),
      ),
    );
  }
}
