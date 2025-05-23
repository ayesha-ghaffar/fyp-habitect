
import 'package:flutter/material.dart';
import 'package:fyp/models/bid_model.dart';
import 'package:fyp/services/project_posting_service.dart';

class ProjectBidsScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectBidsScreen({Key? key, required this.projectId, required this.projectTitle}) : super(key: key);

  @override
  State<ProjectBidsScreen> createState() => _ProjectBidsScreenState();
}

class _ProjectBidsScreenState extends State<ProjectBidsScreen> {
  late Future<List<Bid>> _bidsFuture;

  @override
  void initState() {
    super.initState();
    _bidsFuture = _fetchBidsForProject();
  }

  Future<List<Bid>> _fetchBidsForProject() async {
    try {
      return await ProjectPostingService().getBidsByProject(widget.projectId);
    } catch (e) {
      print('Error fetching bids: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bids: $e')),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bids for "${widget.projectTitle}"', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C3E50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Bid>>(
        future: _bidsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: const Color(0xFF3498DB)));
          } else if (snapshot.hasError) {
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No bids submitted for this project yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final bid = snapshot.data![index];
                return BidTile(bid: bid);
              },
            );
          }
        },
      ),
    );
  }
}

class BidTile extends StatelessWidget {
  final Bid bid;

  const BidTile({Key? key, required this.bid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bid from Architect ID: ${bid.architectId}', // In a real app, you'd fetch architect name
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cost: \$${bid.cost.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            Text(
              'Timeline: ${bid.timeline}',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            Text(
              'Status: ${bid.getStatusText()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: bid.getStatusColor(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Submitted: ${bid.submissionDate.day}/${bid.submissionDate.month}/${bid.submissionDate.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
            // You can add more buttons here, e.g., "Accept Bid", "Reject Bid"
          ],
        ),
      ),
    );
  }
}