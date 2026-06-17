import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_terminals_viewmodel.dart';

class ViewTerminalsScreen extends StatefulWidget {
  const ViewTerminalsScreen({super.key});

  @override
  State<ViewTerminalsScreen> createState() => _ViewTerminalsScreenState();
}

class _ViewTerminalsScreenState extends State<ViewTerminalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewTerminalsViewModel>().loadTerminals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('POS Terminals', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ViewTerminalsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.loadTerminals,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (vm.terminals.isEmpty) {
            return const Center(child: Text('No terminals found'));
          }

          return RefreshIndicator(
            onRefresh: vm.loadTerminals,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.terminals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final terminal = vm.terminals[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: terminal.status == 'active' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.settings_input_component,
                        color: terminal.status == 'active' ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      terminal.terminalId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Serial: ${terminal.serialNumber}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: terminal.status == 'active' ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        terminal.status.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow('Agent Number', terminal.agentNumber),
                            _detailRow('Created At', terminal.createdAt),
                            _detailRow('Updated At', terminal.updatedAt),
                            if (terminal.tmsResponse != null) ...[
                              const Divider(),
                              const Text('TMS Response:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(terminal.tmsResponse!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
