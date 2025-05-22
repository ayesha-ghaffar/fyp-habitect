import 'package:flutter/material.dart';
import 'package:fyp/views/svg_icon.dart';
import 'bid_form_screen.dart';

class FindProjects extends StatefulWidget {
  const FindProjects({super.key});

  @override
  State<FindProjects> createState() => _FindProjectsState();
}

class _FindProjectsState extends State<FindProjects> {
  String activeFilter = "Location";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Section (sticky)
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
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
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
                        _buildFilterChip("Location", 'location'),
                        _buildFilterChip("Budget", 'money-dollar'),
                        _buildFilterChip("Project Type", 'building'),
                        _buildFilterChip("Timeline", 'schedule'),
                        _buildFilterChip("Rating", 'star'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Projects List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProjectCard(
                  title: "Modern House in Islamabad",
                  category: "Residential",
                  categoryColor: const Color(0xFFE2725B),
                  budget: "PKR 1,500,000 - 2,000,000",
                  deadline: "Deadline: 4 months (Sep 17, 2025)",
                  description: "A contemporary 3-bedroom residence with emphasis on sustainable materials and natural lighting. Client seeks innovative design for sloped terrain with panoramic views.",
                  imageAsset: "assets/images/Hillside Residence.jpg",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitBidForm(
                          projectTitle: "Modern House in Islamabad",
                          projectCategory: "Residential",
                          projectBudget: "PKR 1,500,000 - 2,000,000",
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                _buildProjectCard(
                  title: "Boutique Hotel Renovation",
                  category: "Commercial",
                  categoryColor: Colors.blue,
                  budget: "PKR 5,000,000 - 7,500,000",
                  deadline: "Deadline: 8 months (Jan 15, 2026)",
                  description: "Complete renovation of a 25-room colonial-era hotel in Lahore. Project includes redesigning lobby, guest rooms, and adding a rooftop restaurant while preserving historical elements.",
                  imageAsset: "assets/images/Boutique.jpg",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitBidForm(
                          projectTitle: "Boutique Hotel Renovation",
                          projectCategory: "Commercial",
                          projectBudget: "PKR 5,000,000 - 7,500,000",
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                _buildProjectCard(
                  title: "Tech Startup Office Space",
                  category: "Office",
                  categoryColor: Colors.purple,
                  budget: "PKR 3,000,000 - 4,000,000",
                  deadline: "Deadline: 3 months (Aug 20, 2025)",
                  description: "Design a modern 5,000 sq ft office space for a growing tech company in Karachi. Focus on collaborative spaces, flexible workstations, and recreational areas to foster creativity.",
                  imageAsset: "assets/images/Nexus Office.jpg",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitBidForm(
                          projectTitle: "Tech Startup Office Space",
                          projectCategory: "Office",
                          projectBudget: "PKR 3,000,000 - 4,000,000",
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                _buildProjectCard(
                  title: "Luxury Villa Complex",
                  category: "Residential",
                  categoryColor: const Color(0xFFE2725B),
                  budget: "PKR 10,000,000 - 15,000,000",
                  deadline: "Deadline: 12 months (May 17, 2026)",
                  description: "Design a gated community of 8 luxury villas in Murree. Each villa should have unique character while maintaining cohesive aesthetic. Includes communal facilities and landscaping.",
                  imageAsset: "assets/images/Hillside Residence.jpg",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitBidForm(
                          projectTitle: "Luxury Villa Complex",
                          projectCategory: "Residential",
                          projectBudget: "PKR 1,500,000 - 2,000,000",
                        ),
                      ),
                    );
                  }
                ),
                // Add bottom padding to account for the FAB and bottom navigation
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      // Filter FAB
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 64),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.tertiary,
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(28),
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Show filter modal
          },
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const SvgIcon(iconName: 'filter-list', color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String iconName) {
    final bool isActive = activeFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          activeFilter = isActive ? "" : label;
        });
      },
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
              label,
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

  Widget _buildProjectCard({
    required String title,
    required String category,
    required Color categoryColor,
    required String budget,
    required String deadline,
    required String description,
    required String imageAsset,
    required VoidCallback onPressed,
  }) {
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
          // Project image
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              image: DecorationImage(
                image: AssetImage(imageAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Project details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Category and budget
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        budget,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF9E897B),
                        ),
                      ),
                    ),
                  ],
                ),

                // Deadline
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      SvgIcon(
                        iconName: 'schedule',
                        size: 16,
                        color: const Color(0xFFDCB287),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deadline,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFDCB287),
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B8E23),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Submit Bid'),
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