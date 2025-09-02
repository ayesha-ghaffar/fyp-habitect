import 'package:flutter/material.dart';
import 'package:fyp/models/bid_model.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/user_model.dart';
import 'package:fyp/views/svg_icon.dart';

class ProjectBidsScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectBidsScreen({Key? key, required this.projectId, required this.projectTitle}) : super(key: key);

  @override
  State<ProjectBidsScreen> createState() => _ProjectBidsScreenState();
}

class _ProjectBidsScreenState extends State<ProjectBidsScreen> {
  late Future<List<Map<String, dynamic>>> _bidsWithArchitectInfoFuture;
  List<Map<String, dynamic>> allBids = [];
  List<Map<String, dynamic>> filteredBids = [];
  String searchQuery = '';
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _bidsWithArchitectInfoFuture = _fetchBidsWithArchitectInfo();
  }

  Future<List<Map<String, dynamic>>> _fetchBidsWithArchitectInfo() async {
    try {
      final List<Bid> bids = await ProjectPostingService().getBidsByProject(widget.projectId);
      final List<Map<String, dynamic>> bidsWithInfo = [];

      for (final bid in bids) {
        final UserModel? architect = await ProjectPostingService().getUser(bid.architectId);
        bidsWithInfo.add({
          'bid': bid,
          'architectName': architect?.username ?? 'Unknown Architect',
        });
      }

      // Sort bids by submission date (newest first)
      bidsWithInfo.sort((a, b) => (b['bid'] as Bid).submissionDate.compareTo((a['bid'] as Bid).submissionDate));

      setState(() {
        allBids = bidsWithInfo;
        filteredBids = bidsWithInfo;
      });

      return bidsWithInfo;
    } catch (e) {
      print('Error fetching bids with architect info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bids: $e')),
        );
      }
      return [];
    }
  }

  void _filterBids() {
    setState(() {
      filteredBids = allBids.where((bidData) {
        final Bid bid = bidData['bid'];
        final String architectName = bidData['architectName'];

        final matchesSearch = searchQuery.isEmpty ||
            architectName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            bid.summary.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesStatus = selectedStatus == null ||
            bid.getStatusText().toLowerCase() == selectedStatus!.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _refreshBids() {
    setState(() {
      _bidsWithArchitectInfoFuture = _fetchBidsWithArchitectInfo();
    });
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
        return Colors.orange;
      case BidStatus.active:
        return const Color(0xFF6B8E23);
      case BidStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        title: Text(
          'Bids for "${widget.projectTitle}"',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
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
                      hintText: 'Search bids by architect or summary...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                        child: SvgIcon(
                          iconName: 'search',
                          size: 20,
                          color: const Color(0xFF6B8E23),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bids List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _bidsWithArchitectInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
                }
                else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(
                            iconName: 'alert',
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading bids',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                else if (filteredBids.isEmpty) {
                  return Center(
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
                          allBids.isEmpty ? 'No bids submitted yet' : 'No bids match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (allBids.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Architects will be able to submit bids for this project',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  );
                }
                else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _fetchBidsWithArchitectInfo();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredBids.length,
                      itemBuilder: (context, index) {
                        final bidData = filteredBids[index];
                        final Bid bid = bidData['bid'];
                        final String architectName = bidData['architectName'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: BidTile(
                            bid: bid,
                            architectName: architectName,
                            onStatusUpdate: _refreshBids,
                          ),
                        );
                      },
                    ),
                  );
                }
              },
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

class BidTile extends StatefulWidget {
  final Bid bid;
  final String architectName;
  final VoidCallback onStatusUpdate;

  const BidTile({
    Key? key,
    required this.bid,
    required this.architectName,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<BidTile> createState() => _BidTileState();
}

class _BidTileState extends State<BidTile> {
  late Bid _currentBid;

  @override
  void initState() {
    super.initState();
    _currentBid = widget.bid;
  }

  Color _getStatusColor(BidStatus status) {
    switch (status) {
      case BidStatus.pending:
        return Colors.orange;
      case BidStatus.active:
        return const Color(0xFF6B8E23);
      case BidStatus.rejected:
        return Colors.red;
    }
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

  Future<void> _updateBidStatus(BidStatus newStatus) async {
    try {
      await ProjectPostingService().updateBidStatus(
        widget.bid.id,
        newStatus,
      );

      setState(() {
        _currentBid = _currentBid.copyWith(status: newStatus);
      });

      widget.onStatusUpdate();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid status updated to ${newStatus.name.toUpperCase()}!')),
      );
    } catch (e) {
      print('Error updating bid status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bid status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Header with architect info and status
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Architect avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8E23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.architectName.isNotEmpty
                          ? widget.architectName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B8E23),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Architect name and submission time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.architectName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Submitted ${_getTimeAgo(_currentBid.submissionDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_currentBid.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentBid.getStatusText(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bid details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cost and Timeline
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bid Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(_currentBid.cost),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                            'Timeline',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentBid.timeline,
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
                const SizedBox(height: 16),

                // Summary
                Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentBid.summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                // Additional Comments
                if (_currentBid.additionalComments != null && _currentBid.additionalComments!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Additional Comments',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentBid.additionalComments!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentBid.status == BidStatus.active
                            ? null
                            : () => _updateBidStatus(BidStatus.active),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B8E23),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _currentBid.status == BidStatus.active ? 'Accepted' : 'Accept Bid',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentBid.status == BidStatus.rejected
                            ? null
                            : () => _updateBidStatus(BidStatus.rejected),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(
                            color: _currentBid.status == BidStatus.rejected
                                ? Colors.grey.shade300
                                : Colors.red,
                          ),
                          disabledForegroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _currentBid.status == BidStatus.rejected ? 'Rejected' : 'Reject Bid',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}