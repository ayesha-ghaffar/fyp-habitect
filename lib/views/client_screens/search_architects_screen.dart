import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../svg_icon.dart';

class SearchArchitects extends StatefulWidget {
  const SearchArchitects({super.key});

  @override
  State<SearchArchitects> createState() => _SearchArchitectsState();
}

class _SearchArchitectsState extends State<SearchArchitects> {
  bool _showFilterModal = false;
  final ScrollController _searchResultsController = ScrollController();
  String activeFilter = "";
  String searchQuery = '';

  // Filter state variables
  String? selectedLocation;
  String? selectedSpecialty;
  String? selectedRating;
  String? selectedAvailability;
  String? selectedBudgetRange;

  List<String> selectedSpecialties = ['Residential'];

  void _toggleFilterModal() {
    setState(() {
      _showFilterModal = !_showFilterModal;
    });
    if (_showFilterModal) {
      FocusScope.of(context).unfocus();
    }
  }

  void _viewProfile(int id) {
    print('Viewing architect profile with ID: $id');
    // Implement navigation to profile page
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (selectedSpecialties.contains(specialty)) {
        selectedSpecialties.remove(specialty);
      } else {
        selectedSpecialties.add(specialty);
      }
    });
  }

  void _showLocationFilter() {
    final locations = ['Islamabad', 'Rawalpindi', 'Karachi', 'Lahore', 'Faisalabad'];

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
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showSpecialtyFilter() {
    final specialties = ['Residential', 'Commercial', 'Interior', 'Landscape', 'Sustainable', 'Modern'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Specialty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Specialties'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedSpecialty,
                onChanged: (value) {
                  setState(() {
                    selectedSpecialty = value;
                    activeFilter = "";
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...specialties.map((specialty) => ListTile(
              title: Text(specialty),
              leading: Radio<String?>(
                value: specialty,
                groupValue: selectedSpecialty,
                onChanged: (value) {
                  setState(() {
                    selectedSpecialty = value;
                    activeFilter = selectedSpecialty != null ? "Specialty" : "";
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showRatingFilter() {
    final ratings = ['4.5+', '4.0+', '3.5+', 'All'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ratings.map((rating) => ListTile(
              title: Text(rating),
              leading: Radio<String?>(
                value: rating == 'All' ? null : rating,
                groupValue: selectedRating,
                onChanged: (value) {
                  setState(() {
                    selectedRating = value;
                    activeFilter = selectedRating != null ? "Rating" : "";
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityFilter() {
    final availabilities = ['Available Now', 'This Week', 'This Month'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Any Time'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedAvailability,
                onChanged: (value) {
                  setState(() {
                    selectedAvailability = value;
                    activeFilter = "";
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...availabilities.map((availability) => ListTile(
              title: Text(availability),
              leading: Radio<String?>(
                value: availability,
                groupValue: selectedAvailability,
                onChanged: (value) {
                  setState(() {
                    selectedAvailability = value;
                    activeFilter = selectedAvailability != null ? "Availability" : "";
                  });
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
    final budgetRanges = ['\$50-100/hr', '\$100-150/hr', '\$150-200/hr', '\$200+/hr'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
                  Navigator.pop(context);
                },
              ),
            ),
            ...budgetRanges.map((range) => ListTile(
              title: Text(range),
              leading: Radio<String?>(
                value: range,
                groupValue: selectedBudgetRange,
                onChanged: (value) {
                  setState(() {
                    selectedBudgetRange = value;
                    activeFilter = selectedBudgetRange != null ? "Budget" : "";
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showFilterModalBottomSheet() {
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
                        selectedSpecialty = null;
                        selectedRating = null;
                        selectedAvailability = null;
                        selectedBudgetRange = null;
                        activeFilter = "";
                      });
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
                    _buildFilterSection('Specialty', selectedSpecialty, _showSpecialtyFilter),
                    _buildFilterSection('Rating', selectedRating, _showRatingFilter),
                    _buildFilterSection('Availability', selectedAvailability, _showAvailabilityFilter),
                    _buildFilterSection('Budget', selectedBudgetRange, _showBudgetFilter),
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
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search input
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, specialty, location...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
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
                        _buildFilterChip("Specialty", 'building', _showSpecialtyFilter),
                        _buildFilterChip("Rating", 'star', _showRatingFilter),
                        _buildFilterChip("Availability", 'calendar', _showAvailabilityFilter),
                        _buildFilterChip("Budget", 'money-dollar', _showBudgetFilter),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sort and View Options
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('24 architects found',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('Sort by:',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('Rating',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary)),
                        Icon(Remix.arrow_down_s_line,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: Icon(Remix.list_check_2,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: const Icon(Remix.grid_line,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Architect Cards
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Scrollbar(
                controller: _searchResultsController,
                thumbVisibility: true, // Fixed: this should be bool, not VoidCallback
                child: GridView.count(
                  controller: _searchResultsController,
                  padding: const EdgeInsets.all(16.0),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.6,
                  children: [
                    _buildArchitectCard(
                      onTap: () => _viewProfile(1),
                      imageAsset:
                      "assets/images/Female Architect 1.jpeg",
                      name: "Amna Khan",
                      rating: 4.9,
                      reviewCount: 124,
                      location: "Islamabad",
                      specialty: "Residential",
                      priceRange: "\$120-150/hr",
                    ),
                    _buildArchitectCard(
                      onTap: () => _viewProfile(2),
                      imageAsset:
                      "assets/images/Male Architect 1.jpeg",
                      name: "Ali Akbar",
                      rating: 4.8,
                      reviewCount: 87,
                      location: "Lahore",
                      specialty: "Commercial",
                      priceRange: "\$140-180/hr",
                    ),
                    _buildArchitectCard(
                      onTap: () => _viewProfile(3),
                      imageAsset:
                      "assets/images/Female Architect 2.jpeg",
                      name: "Aqsa Irfan",
                      rating: 4.7,
                      reviewCount: 56,
                      location: "Lahore",
                      specialty: "Interior",
                      priceRange: "\$110-140/hr",
                    ),
                    _buildArchitectCard(
                      onTap: () => _viewProfile(4),
                      imageAsset:
                      "assets/images/Female Architect 3.jpeg",
                      name: "Mariam Zahid",
                      rating: 4.6,
                      reviewCount: 78,
                      location: "Karachi, 4.2",
                      specialty: "Landscape",
                      priceRange: "\$130-160/hr",
                    ),
                    _buildArchitectCard(
                      onTap: () => _viewProfile(5),
                      imageAsset:
                      "assets/images/Male Architect 2.jpeg",
                      name: "Musa Malik",
                      rating: 4.9,
                      reviewCount: 142,
                      location: "Islamabad",
                      specialty: "Sustainable",
                      priceRange: "\$150-200/hr",
                    ),
                    _buildArchitectCard(
                      onTap: () => _viewProfile(6),
                      imageAsset:
                      "assets/images/Male Architect 3.jpeg",
                      name: "Asad Omer",
                      rating: 4.8,
                      reviewCount: 95,
                      location: "Islamabad",
                      specialty: "Modern",
                      priceRange: "\$140-190/hr",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Filter FAB (Fixed: changed method name to avoid confusion)
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
          onPressed: _showFilterModalBottomSheet, // Fixed: use proper method name
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

  Widget _buildTabItem(
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildArchitectCard({
    required VoidCallback onTap,
    required String imageAsset,
    required String name,
    required double rating,
    required int reviewCount,
    required String location,
    required String specialty,
    required String priceRange,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
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
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8.0)),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child:
                          const Center(child: Icon(Icons.broken_image)),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      icon: const Icon(Remix.heart_line,
                          color: Colors.grey, size: 20),
                      onPressed: () {
                        // Handle favorite action
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 4),
                      Icon(Remix.verified_badge_fill,
                          color: Theme.of(context).colorScheme.primary,
                          size: 14),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Theme.of(context).colorScheme.tertiary, size: 12),
                      const SizedBox(width: 4),
                      Text('$rating ($reviewCount)',
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Remix.map_pin_line,
                          color: Colors.grey.shade600, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(location,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(specialty,
                            style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(priceRange,
                      style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.tertiaryFixed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String icon, VoidCallback onTap) {
    final bool isActive = activeFilter == label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            SvgIcon(
              iconName: icon,
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