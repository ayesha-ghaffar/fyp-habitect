import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/views/svg_icon.dart';
import 'package:fyp/models/bid_model.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/project_model.dart';
import 'bid_details_screen.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProjectPostingService _projectService = ProjectPostingService();

  List<Bid> bids = [];
  List<Bid> filteredBids = [];
  Map<String, Project> projectsCache = {};
  bool isLoading = true;
  String searchQuery = '';
  String? selectedStatus;
  String? selectedCategory;
  String? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    try {
      setState(() {
        isLoading = true;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('ERROR: No current user found');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('=== DEBUGGING BID LOADING ===');
      print('Current user ID: ${currentUser.uid}');

      // Debug: Check what's in the bids collection
      final allBidsSnapshot = await _database.child('bids').get();
      if (allBidsSnapshot.exists) {
        final allBidsData = Map<String, dynamic>.from(allBidsSnapshot.value as Map);
        print('Total bids in database: ${allBidsData.length}');

        allBidsData.forEach((bidId, bidData) {
          final bidMap = Map<String, dynamic>.from(bidData);
          print('Bid $bidId:');
          print('  - architectId: ${bidMap['architectId']}');
          print('  - projectId: ${bidMap['projectId']}');
          print('  - summary: ${bidMap['summary']}');
          print('  - approach: ${bidMap['approach']}');
          print('  - Match: ${bidMap['architectId'] == currentUser.uid}');
        });
      } else {
        print('ERROR: No bids found in database at all');
      }

      // Fetch bids using the service
      final List<Bid> loadedBids = await _projectService.getBidsByArchitect(currentUser.uid);
      print('Bids loaded by service: ${loadedBids.length}');

      // Debug each loaded bid
      for (int i = 0; i < loadedBids.length; i++) {
        final bid = loadedBids[i];
        print('Loaded bid $i:');
        print('  - ID: ${bid.id}');
        print('  - Project ID: ${bid.projectId}');
        print('  - Architect ID: ${bid.architectId}');
        print('  - Summary: ${bid.summary}');
        print('  - Cost: ${bid.cost}');
        print('  - Status: ${bid.status}');
      }

      // Cache project data for each bid
      for (final bid in loadedBids) {
        if (!projectsCache.containsKey(bid.projectId)) {
          try {
            final project = await _projectService.getProject(bid.projectId);
            if (project != null) {
              projectsCache[bid.projectId] = project;
              print('Cached project: ${project.title} for bid ${bid.id}');
            } else {
              print('WARNING: Project ${bid.projectId} not found for bid ${bid.id}');
            }
          } catch (e) {
            print('ERROR: Failed to load project ${bid.projectId}: $e');
          }
        }
      }

      // Sort bids by submission date (newest first)
      loadedBids.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));

      setState(() {
        bids = loadedBids;
        filteredBids = loadedBids;
        isLoading = false;
      });

      print('=== FINAL RESULT ===');
      print('Total bids displayed: ${bids.length}');
      print('Projects cached: ${projectsCache.length}');

    } catch (e) {
      print('ERROR in _loadBids: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bids: $e')),
      );
    }
  }

  void _filterBids() {
    setState(() {
      filteredBids = bids.where((bid) {
        final project = projectsCache[bid.projectId];

        final matchesSearch = searchQuery.isEmpty ||
            (project?.title.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            bid.summary.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (project?.location.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

        final matchesStatus = selectedStatus == null ||
            bid.getStatusText().toLowerCase() == selectedStatus!.toLowerCase();

        final matchesCategory = selectedCategory == null ||
            (project?.type.toLowerCase() == selectedCategory!.toLowerCase());

        final matchesDateRange = selectedDateRange == null ||
            _dateRangeMatches(bid.submissionDate, selectedDateRange!);

        return matchesSearch && matchesStatus && matchesCategory && matchesDateRange;
      }).toList();
    });
  }

  bool _dateRangeMatches(DateTime submissionDate, String dateRange) {
    final now = DateTime.now();
    final daysDifference = now.difference(submissionDate).inDays;

    switch (dateRange) {
      case 'Last 7 days':
        return daysDifference <= 7;
      case 'Last 30 days':
        return daysDifference <= 30;
      case 'Last 3 months':
        return daysDifference <= 90;
      case 'Last 6 months':
        return daysDifference <= 180;
      case 'This year':
        return submissionDate.year == now.year;
      default:
        return true;
    }
  }

  String _getProjectImage(String projectType) {
    // Map project types to available images
    switch (projectType.toLowerCase()) {
      case 'new construction':
        return "assets/images/Hillside Residence.jpg";
      case 'renovation/remodeling':
        return "assets/images/Boutique.jpg";
      case 'commercial':
        return "assets/images/Nexus Office.jpg";
      default:
        return "assets/images/Hillside Residence.jpg";
    }
  }

  Color _getCategoryColor(String projectType) {
    switch (projectType.toLowerCase()) {
      case 'new construction':
        return const Color(0xFFE2725B);
      case 'renovation/remodeling':
        return Colors.blue;
      case 'commercial':
        return Colors.purple;
      default:
        return const Color(0xFFE2725B);
    }
  }

  void _showStatusFilter() {
    final statuses = ['Pending', 'Active', 'Rejected'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Statuses'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  _filterBids();
                  Navigator.pop(context);
                },
              ),
            ),
            ...statuses.map((status) => ListTile(
              title: Text(status),
              leading: Radio<String?>(
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  _filterBids();
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    final categories = projectsCache.values.map((p) => p.type).toSet().toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Categories'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                  _filterBids();
                  Navigator.pop(context);
                },
              ),
            ),
            ...categories.map((category) => ListTile(
              title: Text(category),
              leading: Radio<String?>(
                value: category,
                groupValue: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                  _filterBids();
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showDateRangeFilter() {
    final dateRanges = [
      'Last 7 days',
      'Last 30 days',
      'Last 3 months',
      'Last 6 months',
      'This year',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Time'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedDateRange,
                onChanged: (value) {
                  setState(() {
                    selectedDateRange = value;
                  });
                  _filterBids();
                  Navigator.pop(context);
                },
              ),
            ),
            ...dateRanges.map((range) => ListTile(
              title: Text(range),
              leading: Radio<String?>(
                value: range,
                groupValue: selectedDateRange,
                onChanged: (value) {
                  setState(() {
                    selectedDateRange = value;
                  });
                  _filterBids();
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'PKR ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'PKR ${amount.toStringAsFixed(0)}';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(BidStatus status) {
    switch (status) {
      case BidStatus.pending:
        return Theme.of(context).colorScheme.tertiary;
      case BidStatus.active:
        return Theme.of(context).colorScheme.primary;
      case BidStatus.rejected:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  void _navigateToBidDetails(Bid bid) async {
    final project = projectsCache[bid.projectId];

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BidDetailsPage(
          bid: bid,
          project: project,
          onBidUpdated: () {
            // Refresh the bids list when a bid is updated
            _loadBids();
          },
        ),
      ),
    );

    // If we got an updated bid back, refresh the list
    if (result != null) {
      _loadBids();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        title: Text(
          'Bids',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE0E0E0),
            height: 0.25,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      _filterBids();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search your bids...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                        child: SvgIcon(
                          iconName: 'search',
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        _buildFilterChip("Status", 'calendar', _showStatusFilter, selectedStatus),
                        _buildFilterChip("Project Type", 'building', _showCategoryFilter, selectedCategory),
                        _buildFilterChip("Last Dated", 'schedule', _showDateRangeFilter, selectedDateRange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bids List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBids.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcon(
                    iconName: 'document',
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bids.isEmpty ? 'No bids submitted yet' : 'No bids match your search',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (bids.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Start exploring projects and submit your first bid!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadBids,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredBids.length,
                itemBuilder: (context, index) {
                  final bid = filteredBids[index];
                  final project = projectsCache[bid.projectId];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildBidCard(bid, project),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(Bid bid, Project? project) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project image (similar to FindProjects)
          if (project != null)
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                image: DecorationImage(
                  image: AssetImage(_getProjectImage(project.type)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Status badge overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(bid.status),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(bid.status),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Text(
                        bid.getStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Project details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with project title
                Text(
                  project?.title ?? 'Project #${bid.projectId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Project location and category
                if (project != null) ...[
                  Row(
                    children: [
                      SvgIcon(
                        iconName: 'location',
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(project.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      project.type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(project.type),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Bid details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Bid',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _formatCurrency(bid.cost),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B8E23),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submitted',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _getTimeAgo(bid.submissionDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bid summary
                Text(
                  bid.summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // View Details button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _navigateToBidDetails(bid),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B8E23),
                      side: const BorderSide(color: Color(0xFF6B8E23)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String iconName, VoidCallback onTap, String? selectedValue) {
    final bool isActive = selectedValue != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6B8E23) : const Color(0xFFF9F9F7),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            SvgIcon(
              iconName: iconName,
              size: 16,
              color: isActive ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              selectedValue != null ? '$label: $selectedValue' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}