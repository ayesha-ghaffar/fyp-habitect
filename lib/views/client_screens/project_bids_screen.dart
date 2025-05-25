import 'package:flutter/material.dart';
import 'package:fyp/models/bid_model.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/user_model.dart'; // Import UserModel

class ProjectBidsScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectBidsScreen({Key? key, required this.projectId, required this.projectTitle}) : super(key: key);

  @override
  State<ProjectBidsScreen> createState() => _ProjectBidsScreenState();
}

class _ProjectBidsScreenState extends State<ProjectBidsScreen> {
  late Future<List<Map<String, dynamic>>> _bidsWithArchitectInfoFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch bids along with architect information
    _bidsWithArchitectInfoFuture = _fetchBidsWithArchitectInfo();
  }

  // Asynchronously fetches bids for the current project and then fetches architect details for each bid
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

  // Method to refresh bids after a status update
  void _refreshBids() {
    setState(() {
      _bidsWithArchitectInfoFuture = _fetchBidsWithArchitectInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary color based on the provided green for consistent UI
    const Color primaryGreen = Color(0xFF6B8E23);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bids for "${widget.projectTitle}"', style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen, // Apply the green color to the AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back arrow is white
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bidsWithArchitectInfoFuture, // The future that fetches bids with architect info
        builder: (context, snapshot) {
          // Display a loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen)); // Green loading indicator
          }
          // Display an error message if fetching fails
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          }
          // Display a message if no bids are found for the project
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_outlined, size: 80, color: primaryGreen.withOpacity(0.5)), // Faded green icon
                  const SizedBox(height: 16),
                  Text(
                    'No bids submitted for this project yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          // Display the list of bids if data is successfully fetched
          else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final bidData = snapshot.data![index];
                final Bid bid = bidData['bid'];
                final String architectName = bidData['architectName'];
                return BidTile(
                  bid: bid,
                  architectName: architectName, // Pass architect name
                  onStatusUpdate: _refreshBids, // Pass refresh callback
                );
              },
            );
          }
        },
      ),
    );
  }
}

class BidTile extends StatefulWidget {
  final Bid bid;
  final String architectName; // New parameter for architect name
  final VoidCallback onStatusUpdate; // Callback to notify parent about status change

  const BidTile({
    Key? key,
    required this.bid,
    required this.architectName, // Mark as required
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<BidTile> createState() => _BidTileState();
}

class _BidTileState extends State<BidTile> {
  late Bid _currentBid; // To hold the mutable bid state

  @override
  void initState() {
    super.initState();
    _currentBid = widget.bid; // Initialize with the passed bid
  }

  // Helper function to determine the color of the bid status text
  Color _getBidStatusColor(BidStatus status) {
    const Color primaryGreen = Color(0xFF6B8E23); // Define green color locally for consistency
    switch (status) {
      case BidStatus.active:
        return primaryGreen; // Active bids in primary green
      case BidStatus.pending:
        return Colors.blue; // Pending bids in blue
      case BidStatus.rejected:
        return Colors.red; // Rejected bids in red
    }
  }

  // Function to update bid status in Firebase
  Future<void> _updateBidStatus(BidStatus newStatus) async {
    try {
      // Update the bid in Firebase
      await ProjectPostingService().updateBidStatus(
        widget.bid.id, // Use the original bid ID
        newStatus,
      );

      // Update local state to reflect the change immediately
      setState(() {
        _currentBid = _currentBid.copyWith(status: newStatus);
      });

      // Notify the parent widget to refresh the list
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
    return Card(
      elevation: 3, // Add a subtle shadow to the card
      margin: const EdgeInsets.only(bottom: 12.0), // Spacing between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bid from Architect Name
            Row(
              children: [
                const Icon(Icons.person_outline, color: Color(0xFF2C3E50), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Architect: ${widget.architectName}', // Display architect Name
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50), // Dark text color for contrast
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long names
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 1), // Separator

            // Bid Cost
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Cost',
              value: '\$${_currentBid.cost.toStringAsFixed(2)}',
            ),

            // Bid Timeline
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Timeline',
              value: _currentBid.timeline, // This will now correctly wrap
            ),

            // Bid Status
            _buildDetailRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: _currentBid.getStatusText(),
              valueColor: _getBidStatusColor(_currentBid.status),
            ),

            const SizedBox(height: 12),

            // Bid Summary
            Text(
              'Summary:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentBid.summary,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),

            if (_currentBid.additionalComments != null && _currentBid.additionalComments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Additional Comments:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentBid.additionalComments!,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ],

            const SizedBox(height: 16),

            // Submission Date
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Submitted: ${_currentBid.submissionDate.day}/${_currentBid.submissionDate.month}/${_currentBid.submissionDate.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentBid.status == BidStatus.active
                        ? null // Disable if already active
                        : () => _updateBidStatus(BidStatus.active),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('Accept Bid', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getBidStatusColor(BidStatus.active),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      disabledBackgroundColor: Colors.grey, // Grey out when disabled
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentBid.status == BidStatus.rejected
                        ? null // Disable if already rejected
                        : () => _updateBidStatus(BidStatus.rejected),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                    label: const Text('Reject Bid', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getBidStatusColor(BidStatus.rejected),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      disabledBackgroundColor: Colors.grey, // Grey out when disabled
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6B8E23), size: 18), // Primary green for icons
          const SizedBox(width: 12),
          Expanded( // Use Expanded to prevent overflow for long values
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
