import 'package:flutter/material.dart';

void main() => runApp(const NaapnamaApp());

/// Naapnama — tailor measurement register with a due board and a printable chit.
/// Mirrors the Go journal service; measurements are the production pipeline.
class NaapnamaApp extends StatelessWidget {
  const NaapnamaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Naapnama',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF6E3E5E), useMaterial3: true),
        home: const HomePage(),
      );
}

class Order {
  final String customer, garment, measurements, dueDate;
  bool delivered;
  Order(this.customer, this.garment, this.measurements, this.dueDate, {this.delivered = false});

  /// overdue is true for a pending order whose due date is before today.
  bool overdue(DateTime today) {
    if (delivered || dueDate.isEmpty) return false;
    final due = DateTime.tryParse(dueDate);
    return due != null && due.isBefore(DateTime(today.year, today.month, today.day));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _orders = <Order>[];
  final _cust = TextEditingController();
  final _garment = TextEditingController();
  final _meas = TextEditingController();
  final _due = TextEditingController(text: '2026-08-25');

  void _add() {
    if (_cust.text.trim().isEmpty || _garment.text.trim().isEmpty) return;
    setState(() {
      _orders.insert(0, Order(_cust.text.trim(), _garment.text.trim(), _meas.text.trim(), _due.text.trim()));
      _cust.clear();
      _garment.clear();
      _meas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = _orders.where((o) => o.overdue(now)).length;
    final pending = _orders.where((o) => !o.delivered).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naapnama · measurements'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.all(14),
          child: Text('$pending pending · $overdue overdue',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _cust, decoration: const InputDecoration(labelText: 'Customer', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _garment, decoration: const InputDecoration(labelText: 'Garment', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _meas, decoration: const InputDecoration(labelText: 'Measurements (chest, waist, length…)', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _due, decoration: const InputDecoration(labelText: 'Due date YYYY-MM-DD', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            FilledButton(onPressed: _add, child: const Text('Add')),
          ]),
        ])),
        const Divider(),
        Expanded(child: ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (_, i) {
            final o = _orders[i];
            final od = o.overdue(now);
            return ListTile(
              leading: Icon(o.delivered ? Icons.check_circle : (od ? Icons.error : Icons.schedule),
                  color: o.delivered ? Colors.green : (od ? Colors.red : null)),
              title: Text('${o.customer} · ${o.garment}'),
              subtitle: Text('${o.measurements}\nDue ${o.dueDate}'),
              isThreeLine: true,
              trailing: TextButton(
                onPressed: () => setState(() => o.delivered = !o.delivered),
                child: Text(o.delivered ? 'done ✓' : 'deliver'),
              ),
            );
          },
        )),
      ]),
    );
  }
}
