import 'package:flutter/material.dart';
import 'package:fyp/views/svg_icon.dart';
import 'package:fyp/models/bid_model.dart';
import 'package:fyp/models/project_model.dart';
import 'bid_form_screen.dart';

class BidDetailsPage extends StatefulWidget {
  final Bid bid;
  final Project? project;
  final VoidCallback? onBidUpdated;

  const BidDetailsPage({
    super.key,
    required this.bid,
    required this.project,
    this.onBidUpdated,
  });

  @override
  State<BidDetailsPage> createState() => _BidDetailsPageState();
}

class _BidDetailsPageState extends State<BidDetailsPage> {
  late Bid currentBid;

  @override
  void initState() {
    super.initState();
    currentBid = widget.bid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bid Details',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateToEditBid(context),
            child: const Text(
              "Edit",
              style: TextStyle(
                color: Color(0xFF6B8E23),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Info
            if (widget.project != null) ...[
              _buildDetailSection('Project Information', [
                _buildDetailRow('Title', widget.project!.title),
                _buildDetailRow('Location', widget.project!.location),
                _buildDetailRow('Type', widget.project!.type),
                _buildDetailRow('Budget', widget.project!.budget),
              ]),
              const SizedBox(height: 20),
            ],

            // Bid Status
            _buildDetailSection('Bid Status', [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(currentBid.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentBid.getStatusText(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Submitted ${_getTimeAgo(currentBid.submissionDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            // Bid Details
            _buildDetailSection('Your Proposal', [
              _buildDetailRow('Proposed Cost', _formatCurrency(currentBid.cost)),
              _buildDetailRow('Timeline', currentBid.timeline),
            ]),
            const SizedBox(height: 16),

            _buildDetailSection('Summary', [
              Text(
                currentBid.summary,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ]),
            const SizedBox(height: 16),

            _buildDetailSection('Approach', [
              Text(
                currentBid.approach,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ]),
            const SizedBox(height: 16),

            _buildDetailSection('Proposed Solution', [
              Text(
                currentBid.proposedSolution,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ]),

            if (currentBid.additionalComments != null) ...[
              const SizedBox(height: 16),
              _buildDetailSection('Additional Comments', [
                Text(
                  currentBid.additionalComments!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ]),
            ],

            // Contact Information
            if (currentBid.phone != null || currentBid.email != null || currentBid.website != null) ...[
              const SizedBox(height: 20),
              _buildDetailSection('Contact Information', [
                if (currentBid.phone != null) _buildDetailRow('Phone', currentBid.phone!),
                if (currentBid.email != null) _buildDetailRow('Email', currentBid.email!),
                if (currentBid.website != null) _buildDetailRow('Website', currentBid.website!),
              ]),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToEditBid(BuildContext context) async {
    if (widget.project != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubmitBidForm(
            projectId: widget.project!.id,
            projectTitle: widget.project!.title,
            projectCategory: widget.project!.type,
            projectBudget: widget.project!.budget,
            existingBid: currentBid,
          ),
        ),
      );

      // If the bid was updated, get the updated bid data and refresh
      if (result != null && result is Bid) {
        setState(() {
          currentBid = result;
        });

        // Also trigger the parent callback
        if (widget.onBidUpdated != null) {
          widget.onBidUpdated!();
        }
      }
    }
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
        return Color(0xFFDCB287);
      case BidStatus.active:
        return Color(0xFF6B8E23);
      case BidStatus.rejected:
        return Color(0xFFE2725B);
    }
  }
}