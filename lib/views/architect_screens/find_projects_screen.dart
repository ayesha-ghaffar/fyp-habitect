import 'package:flutter/material.dart';
import 'package:fyp/views/svg_icon.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/project_model.dart';
import 'project_details_screen.dart';
import 'bid_form_screen.dart';

class FindProjects extends StatefulWidget {
  const FindProjects({super.key});

  @override
  State<FindProjects> createState() => _FindProjectsState();
}

class _FindProjectsState extends State<FindProjects> {
  String activeFilter = "Location";
  final ProjectPostingService _projectService = ProjectPostingService();
  List<Project> projects = [];
  List<Project> filteredProjects = [];
  bool isLoading = true;
  String searchQuery = '';

  String? selectedLocation;
  String? selectedBudgetRange;
  String? selectedProjectType;
  String? selectedTimeline;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedProjects = await _projectService.getAllProjects(status: 'open');
      setState(() {
        projects = loadedProjects;
        filteredProjects = loadedProjects;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
    }
  }

  void _filterProjects() {
    setState(() {
      filteredProjects = projects.where((project) {
        final matchesSearch = searchQuery.isEmpty ||
            project.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            project.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
            project.type.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesLocation = selectedLocation == null ||
            project.location.toLowerCase().contains(selectedLocation!.toLowerCase());

        final matchesBudget = selectedBudgetRange == null ||
            _budgetMatchesRange(project.budget, selectedBudgetRange!);

        final matchesType = selectedProjectType == null ||
            project.type.toLowerCase() == selectedProjectType!.toLowerCase();

        final matchesTimeline = selectedTimeline == null ||
            _timelineMatches(project.endDate, selectedTimeline!);

        return matchesSearch && matchesLocation && matchesBudget && matchesType && matchesTimeline;
      }).toList();
    });
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

  String _formatBudget(String budget) {
    // Add PKR prefix if not already present
    if (!budget.toLowerCase().contains('pkr')) {
      return 'PKR $budget';
    }
    return budget;
  }

  String _formatDeadline(DateTime? endDate) {
    if (endDate == null) {
      return 'No deadline specified';
    }

    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference < 0) {
      return 'Deadline passed';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference < 30) {
      return 'Due in $difference days';
    } else {
      final months = (difference / 30).round();
      return 'Due in $months month${months > 1 ? 's' : ''}';
    }
  }

  bool _budgetMatchesRange(String budget, String range) {
    // Extract numeric value from budget string
    final budgetNum = double.tryParse(budget.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    switch (range) {
      case 'Under 100K':
        return budgetNum < 100000;
      case '100K - 500K':
        return budgetNum >= 100000 && budgetNum <= 500000;
      case '500K - 1M':
        return budgetNum >= 500000 && budgetNum <= 1000000;
      case '1M - 5M':
        return budgetNum >= 1000000 && budgetNum <= 5000000;
      case 'Above 5M':
        return budgetNum > 5000000;
      default:
        return true;
    }
  }

  bool _timelineMatches(DateTime? endDate, String timeline) {
    if (endDate == null) return timeline == 'No deadline';

    final now = DateTime.now();
    final daysRemaining = endDate.difference(now).inDays;

    switch (timeline) {
      case 'Urgent (< 1 month)':
        return daysRemaining < 30;
      case 'Short term (1-3 months)':
        return daysRemaining >= 30 && daysRemaining <= 90;
      case 'Medium term (3-6 months)':
        return daysRemaining >= 90 && daysRemaining <= 180;
      case 'Long term (> 6 months)':
        return daysRemaining > 180;
      case 'No deadline':
        return false; // We already checked for null above
      default:
        return true;
    }
  }

  void _showLocationFilter() {
    final locations = projects.map((p) => p.location).toSet().toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Locations'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                    activeFilter = "";
                  });
                  _filterProjects();
                  Navigator.pop(context);
                },
              ),
            ),
            ...locations.map((location) => ListTile(
              title: Text(location),
              leading: Radio<String?>(
                value: location,
                groupValue: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                    activeFilter = selectedLocation != null ? "Location" : "";
                  });
                  _filterProjects();
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showBudgetFilter() {
    final budgetRanges = [
      'Under 100K',
      '100K - 500K',
      '500K - 1M',
      '1M - 5M',
      'Above 5M',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Budget Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All Budgets'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: selectedBudgetRange,
                  onChanged: (value) {
                    setState(() {
                      selectedBudgetRange = value;
                      activeFilter = "";
                    });
                    _filterProjects();
                    Navigator.pop(context);
                  },
                ),
              ),
              ...budgetRanges.map((range) => ListTile(
                title: Text('PKR $range'),
                leading: Radio<String?>(
                  value: range,
                  groupValue: selectedBudgetRange,
                  onChanged: (value) {
                    setState(() {
                      selectedBudgetRange = value;
                      activeFilter = selectedBudgetRange != null ? "Budget" : "";
                    });
                    _filterProjects();
                    Navigator.pop(context);
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectTypeFilter() {
    final types = projects.map((p) => p.type).toSet().toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Project Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Types'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedProjectType,
                onChanged: (value) {
                  setState(() {
                    selectedProjectType = value;
                    activeFilter = "";
                  });
                  _filterProjects();
                  Navigator.pop(context);
                },
              ),
            ),
            ...types.map((type) => ListTile(
              title: Text(type),
              leading: Radio<String?>(
                value: type,
                groupValue: selectedProjectType,
                onChanged: (value) {
                  setState(() {
                    selectedProjectType = value;
                    activeFilter = selectedProjectType != null ? "Project Type" : "";
                  });
                  _filterProjects();
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showTimelineFilter() {
    final timelines = [
      'Urgent (< 1 month)',
      'Short term (1-3 months)',
      'Medium term (3-6 months)',
      'Long term (> 6 months)',
      'No deadline',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Timeline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All Timelines'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: selectedTimeline,
                  onChanged: (value) {
                    setState(() {
                      selectedTimeline = value;
                      activeFilter = "";
                    });
                    _filterProjects();
                    Navigator.pop(context);
                  },
                ),
              ),
              ...timelines.map((timeline) => ListTile(
                title: Text(timeline),
                leading: Radio<String?>(
                  value: timeline,
                  groupValue: selectedTimeline,
                  onChanged: (value) {
                    setState(() {
                      selectedTimeline = value;
                      activeFilter = selectedTimeline != null ? "Timeline" : "";
                    });
                    _filterProjects();
                    Navigator.pop(context);
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedLocation = null;
                        selectedBudgetRange = null;
                        selectedProjectType = null;
                        selectedTimeline = null;
                        activeFilter = "";
                      });
                      _filterProjects();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildFilterSection('Location', selectedLocation, _showLocationFilter),
                    _buildFilterSection('Budget', selectedBudgetRange, _showBudgetFilter),
                    _buildFilterSection('Project Type', selectedProjectType, _showProjectTypeFilter),
                    _buildFilterSection('Timeline', selectedTimeline, _showTimelineFilter),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    onChanged: (value) {
                      searchQuery = value;
                      _filterProjects();
                    },
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
                        _buildFilterChip("Location", 'location', _showLocationFilter),
                        _buildFilterChip("Budget", 'money-dollar', _showBudgetFilter),
                        _buildFilterChip("Project Type", 'building', _showProjectTypeFilter),
                        _buildFilterChip("Timeline", 'schedule', _showTimelineFilter),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Projects List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProjects.isEmpty
                ? const Center(
              child: Text(
                'No projects found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = filteredProjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildProjectCard(
                      project: project,
                      title: project.title,
                      category: project.type,
                      categoryColor: _getCategoryColor(project.type),
                      budget: _formatBudget(project.budget),
                      deadline: "Deadline: ${_formatDeadline(project.endDate)}",
                      description: project.notes ?? "No description provided",
                      imageAsset: _getProjectImage(project.type),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubmitBidForm(
                              projectId: project.id,
                              projectTitle: project.title,
                              projectCategory: project.type,
                              projectBudget: _formatBudget(project.budget),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
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
          onPressed: _showFilterModal,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const SvgIcon(iconName: 'filter-list', color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, String? selectedValue, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(selectedValue ?? 'All ${title}s'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProjectCard({
    required Project project,
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

                // Location row
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E897B),
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDCB287),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailsPage(project: project),
                            ),
                          );
                        },
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

  Widget _buildFilterChip(String label, String iconName, VoidCallback onTap) {
    final bool isActive = activeFilter == label;

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
}