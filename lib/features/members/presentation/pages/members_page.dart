import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/color_schemes.dart';
import '../../domain/entities/member_entity.dart';
import '../bloc/members_bloc.dart';
import '../widgets/member_card.dart';
import '../widgets/member_search_bar.dart';
import '../widgets/add_member_dialog.dart';

class MembersPage extends StatefulWidget {
  final String gymId;

  const MembersPage({super.key, required this.gymId});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _pageSize = 20;
  String _sortBy = 'full_name';
  bool _ascending = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    context.read<MembersBloc>().add(LoadMembersEvent(
      gymId: widget.gymId,
      search: _searchController.text.isEmpty ? null : _searchController.text,
      page: _currentPage,
      sortBy: _sortBy,
      ascending: _ascending,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
    ));
  }

  void _onSearchChanged(String query) {
    _loadMembers();
  }

  void _onSortChanged(String? sortBy) {
    if (sortBy != null) {
      setState(() {
        _sortBy = sortBy;
      });
      _loadMembers();
    }
  }

  void _onStatusChanged(String? status) {
    if (status != null) {
      setState(() {
        _selectedStatus = status;
      });
      _loadMembers();
    }
  }

  void _onPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadMembers();
    }
  }

  void _onNextPage() {
    setState(() {
      _currentPage++;
    });
    _loadMembers();
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        onMemberAdded: (memberData) {
          context.read<MembersBloc>().add(
                CreateMemberEvent(
                  gymId: widget.gymId,
                  memberData: memberData,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Members',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadMembers,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMemberDialog,
            tooltip: 'Add Member',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                MemberSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                // Filters Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 430;
                    if (compact) {
                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.filter_list_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Status')),
                              DropdownMenuItem(value: 'active', child: Text('Active')),
                              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                              DropdownMenuItem(value: 'expired', child: Text('Expired')),
                            ],
                            onChanged: _onStatusChanged,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _sortBy,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Sort By',
                                    prefixIcon: Icon(Icons.sort_outlined),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'full_name', child: Text('Name')),
                                    DropdownMenuItem(value: 'member_code', child: Text('Member ID')),
                                    DropdownMenuItem(value: 'joined_date', child: Text('Join Date')),
                                  ],
                                  onChanged: _onSortChanged,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _sortOrderButton(),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.filter_list_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Status')),
                              DropdownMenuItem(value: 'active', child: Text('Active')),
                              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                              DropdownMenuItem(value: 'expired', child: Text('Expired')),
                            ],
                            onChanged: _onStatusChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sortBy,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Sort By',
                              prefixIcon: Icon(Icons.sort_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'full_name', child: Text('Name')),
                              DropdownMenuItem(value: 'member_code', child: Text('Member ID')),
                              DropdownMenuItem(value: 'joined_date', child: Text('Join Date')),
                            ],
                            onChanged: _onSortChanged,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _sortOrderButton(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Members List
          Expanded(
            child: BlocBuilder<MembersBloc, MembersState>(
              builder: (context, state) {
                if (state is MembersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is MembersLoaded) {
                  final members = state.members;
                  
                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_outlined, size: 80),
                          const SizedBox(height: 16),
                          Text(
                            'No members found',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Header Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              'Found ${members.length} members',
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              'Page $_currentPage',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      
                      // Members List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            return MemberCard(
                              member: member,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/member',
                                  arguments: {'memberId': member.memberId},
                                );
                              },
                              onEdit: () {
                                // Navigate to edit member
                              },
                              onDelete: () {
                                _showDeleteConfirmation(member);
                              },
                            );
                          },
                        ),
                      ),
                      
                      // Pagination Controls
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 360;
                            if (compact) {
                              return Column(
                                children: [
                                  Text(
                                    'Page $_currentPage',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        onPressed: _currentPage > 1 ? _onPreviousPage : null,
                                        icon: const Icon(Icons.chevron_left),
                                        label: const Text('Previous'),
                                      ),
                                      TextButton.icon(
                                        onPressed: state.hasMore ? _onNextPage : null,
                                        icon: const Icon(Icons.chevron_right),
                                        label: const Text('Next'),
                                        iconAlignment: IconAlignment.end,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: _currentPage > 1 ? _onPreviousPage : null,
                                  icon: const Icon(Icons.chevron_left),
                                  label: const Text('Previous'),
                                ),
                                Text(
                                  'Page $_currentPage',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextButton.icon(
                                  onPressed: state.hasMore ? _onNextPage : null,
                                  icon: const Icon(Icons.chevron_right),
                                  label: const Text('Next'),
                                  iconAlignment: IconAlignment.end,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state is MembersError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            state.error.userMessage,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadMembers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortOrderButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          _ascending ? Icons.arrow_upward : Icons.arrow_downward,
          color: AppColors.primary,
        ),
        onPressed: () {
          setState(() {
            _ascending = !_ascending;
          });
          _loadMembers();
        },
        tooltip: _ascending ? 'Ascending' : 'Descending',
      ),
    );
  }

  void _showDeleteConfirmation(MemberEntity member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MembersBloc>().add(DeleteMemberEvent(memberId: member.memberId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}