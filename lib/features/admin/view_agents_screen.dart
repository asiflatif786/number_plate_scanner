import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../data/models/agent_model.dart';
import 'view_agents_viewmodel.dart';

class ViewAgentsScreen extends StatefulWidget {
  const ViewAgentsScreen({super.key});

  @override
  State<ViewAgentsScreen> createState() => _ViewAgentsScreenState();
}

class _ViewAgentsScreenState extends State<ViewAgentsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewAgentsViewModel>().loadAgents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      context.read<ViewAgentsViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Agents'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          Consumer<ViewAgentsViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Agent',
              onPressed: () => vm.navigateToAddAgent(context),
            ),
          ),
        ],
      ),
      body: Consumer<ViewAgentsViewModel>(
        builder: (context, vm, _) => Column(
          children: [
            _buildSearchBar(vm),
            _buildSummaryRow(vm),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ViewAgentsViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: AppTextField(
        label: 'Search',
        hint: 'Search by name or agent number',
        controller: _searchController,
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  vm.onSearchChanged('');
                },
              )
            : null,
        onChanged: vm.onSearchChanged,
        fillColor: Colors.grey.shade50,
        customPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _buildSummaryRow(ViewAgentsViewModel vm) {
    final count = vm.filteredAgents.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            'Showing $count agent${count == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (vm.searchQuery.isNotEmpty)
            Text(
              ' • filtered',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          const Spacer(),
          if (vm.totalAgents > 0)
            Text(
              '${vm.totalAgents} total',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ViewAgentsViewModel vm) {
    if (vm.isLoading) return _buildShimmerList();

    if (vm.errorMessage != null && vm.agents.isEmpty) {
      return _buildErrorState(vm);
    }

    if (vm.agents.isEmpty) {
      return _buildEmptyState(vm);
    }

    if (vm.searchQuery.isNotEmpty && vm.filteredAgents.isEmpty) {
      return _buildNoSearchResults(vm);
    }

    return RefreshIndicator(
      onRefresh: vm.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: vm.filteredAgents.length + 1,
        itemBuilder: (context, index) {
          if (index == vm.filteredAgents.length) {
            return _buildPaginationFooter(vm);
          }
          return _agentCard(vm.filteredAgents[index], vm);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ShimmerLoader(itemCount: 4, itemHeight: 72);
  }

  Widget _buildErrorState(ViewAgentsViewModel vm) {
    return ErrorStateWidget(
      message: vm.errorMessage!,
      onRetry: () => vm.loadAgents(refresh: true),
    );
  }

  Widget _buildEmptyState(ViewAgentsViewModel vm) {
    return EmptyStateWidget(
      title: 'No agents registered yet',
      message: 'Tap + to register a new agent',
      actionLabel: 'Add Agent',
      onAction: () => vm.navigateToAddAgent(context),
      icon: Icons.people_outline,
    );
  }

  Widget _buildNoSearchResults(ViewAgentsViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off,
                size: 64, color: Color(0xFFBDBDBD)),
            const SizedBox(height: 16),
            Text(
              "No agents found for '${vm.searchQuery}'",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(ViewAgentsViewModel vm) {
    if (vm.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.hasMorePages) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: AppButton(
            label: 'Load More',
            isOutlined: true,
            onPressed: () => vm.loadMore(),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'All agents loaded',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _agentCard(AgentModel agent, ViewAgentsViewModel vm) {
    final initials = agent.firstName.isNotEmpty && agent.lastName.isNotEmpty
        ? '${agent.firstName[0]}${agent.lastName[0]}'
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A237E),
          child: Text(initials.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(agent.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis),
            ),
            Text(agent.agentNumber,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF9E9E9E))),
          ],
        ),
        subtitle: Text(agent.email.isNotEmpty ? agent.email : 'No email',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
        onTap: () => vm.navigateToAgentDetail(context, agent),
        ),
      ),
    );
  }
}
