import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import 'admin_dashboard_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().loadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _buildWelcomeSection(vm),
                Expanded(child: _buildGridMenu()),
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A237E),
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cyber1 TMS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Admin Portal',
              style: TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
      actions: [
        Consumer<AdminDashboardViewModel>(
          builder: (context, vm, _) => IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => vm.logout(context),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(AdminDashboardViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome back,',
                      style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(vm.adminName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('C1',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Company: ${vm.companyNumber}',
              style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 2),
          Text(vm.currentDate,
              style: const TextStyle(fontSize: 12, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildGridMenu() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Actions',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.0,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _menuCard(
                  icon: Icons.person_add,
                  label: 'Add Agent',
                  subtitle: 'Register a new agent',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.companyVerify),
                ),
                _menuCard(
                  icon: Icons.search,
                  label: 'Search Vehicle',
                  subtitle: 'Find vehicle details',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.vehicleSearch),
                ),
                _menuCard(
                  icon: Icons.business,
                  label: 'Add Company',
                  subtitle: 'Register a new corporate',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.corporateRegistration,
                    arguments: {'isFromAdmin': true},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF1A237E)),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242))),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Column(
        children: [
          Text('Cyber1 TMS v1.0.0',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          SizedBox(height: 2),
          Text('Powered by Cyber1 Systems',
              style: TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
        ],
      ),
    );
  }
}
