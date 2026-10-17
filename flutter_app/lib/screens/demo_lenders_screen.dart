import '../widgets/photo_scaffold.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DemoLendersScreen extends StatefulWidget {
  final int assessmentId;
  const DemoLendersScreen({super.key, required this.assessmentId});
  @override
  State<DemoLendersScreen> createState() => _DemoLendersScreenState();
}

class _DemoLendersScreenState extends State<DemoLendersScreen> {
  List<dynamic> _lenders = [];
  List<dynamic> _applications = [];
  String? _selected;
  String? _error;
  bool _consent = false;
  bool _busy = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _busy = true; _error = null; });
    try {
      final lenders = await ApiService.demoGet('demo-lenders');
      final applications = await ApiService.demoGet('demo-applications');
      if (!mounted) return;
      setState(() { _lenders = lenders['lenders']; _applications = applications['applications']; });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _apply() async {
    setState(() { _busy = true; _error = null; });
    try {
      final response = await ApiService.applyDemo(widget.assessmentId, _selected!);
      if (!mounted) return;
      final application = response['application'];
      setState(() {
        _applications.removeWhere((item) => item['reference'] == application['reference']);
        _applications.insert(0, application);
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => PhotoScaffold(
    appBar: AppBar(title: const Text('Choose a demo lender'), actions: [
      IconButton(onPressed: _busy ? null : _load, icon: const Icon(Icons.refresh), tooltip: 'Refresh applications'),
    ]),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 16),
        const Text('THE NEXT STEP', style: TextStyle(color: Color(0xFF087F75), letterSpacing: 1.8, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Choose your demo lending partner.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const Text('Fictional lenders for a college demonstration. Your requested amount, rate and duration remain illustrative; these are not company offers.'),
        const SizedBox(height: 16),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _busy ? null : _load, child: const Text('Retry loading')),
        ],
        for (final lender in _lenders)
          Card(child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            selectedTileColor: const Color(0xFFEAF6F3),
            leading: CircleAvatar(backgroundColor: const Color(0xFFEAF1F5),
              child: Icon(lender['id'] == 'demo-one' ? Icons.account_balance_outlined :
                lender['id'] == 'demo-two' ? Icons.devices_outlined : Icons.support_agent, color: const Color(0xFF087F75))),
            trailing: Icon(_selected == lender['id'] ? Icons.check_circle : Icons.radio_button_off, color: const Color(0xFF087F75)),
            title: Text(lender['name']), subtitle: Text(lender['description']),
            selected: _selected == lender['id'],
            onTap: _busy ? null : () => setState(() => _selected = lender['id']),
          )),
        CheckboxListTile(
          value: _consent,
          onChanged: _busy ? null : (value) => setState(() => _consent = value ?? false),
          title: const Text('Save my demo application and send a demo acknowledgement to my registered email if email delivery is configured.'),
        ),
        FilledButton(onPressed: _busy || !_consent || _selected == null ? null : _apply,
          child: const Text('Submit demo application')),
        const SizedBox(height: 24),
        const Text('My demo applications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        for (final application in _applications)
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${application['lender_name']} — ${application['reference']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(application['status']),
              const SizedBox(height: 8),
              Text(switch (application['email_status']) {
                'sent' => 'Acknowledgement accepted by the email server for ${application['email_to']}. Check your inbox or spam folder.',
                'failed' => 'Email delivery failed. Your application is saved; the acknowledgement is available below.',
                'pending' => 'Email processing is pending. Reload this page to check its status.',
                _ => 'Email is not configured. No email was sent. Preview the acknowledgement below.',
              }),
              const SizedBox(height: 8),
              const Text('Next steps (simulation): sample documents → reviewer checks → terms review → simulated disbursal. No real documents or money are processed.'),
              ExpansionTile(title: const Text('View acknowledgement email'), children: [
                SelectableText('${application['email_subject']}\n\n${application['email_body']}'),
              ]),
            ],
          ))),
      ]),
    )),
  );
}
