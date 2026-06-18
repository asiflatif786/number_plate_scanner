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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.settings_input_component,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    title: Text(
                      terminal.terminalId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Serial: ${terminal.serialNumber}', 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => vm.viewAgentDetail(context, terminal.agentNumber),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A237E),
                            side: const BorderSide(color: Color(0xFF1A237E)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Agent Detail',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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
