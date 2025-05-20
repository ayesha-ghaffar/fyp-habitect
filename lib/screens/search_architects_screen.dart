import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class SearchArchitects extends StatefulWidget {
  const SearchArchitects({super.key});

  @override
  State<SearchArchitects> createState() => _SearchArchitectsState();
}

class _SearchArchitectsState extends State<SearchArchitects> {
  bool _showFilterModal = false;
  final ScrollController _filterChipController = ScrollController();
  final ScrollController _searchResultsController = ScrollController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Search Architects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Remix.equalizer_line),
            onPressed: _toggleFilterModal,
          ),
        ],
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.2),
        elevation: 1,
      ),
      body: Stack(
        children: [
          Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, specialty, location...',
                    prefixIcon:
                    const Icon(Remix.search_line, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: Scrollbar(
                    controller: _filterChipController,
                    thumbVisibility: false,
                    child: ListView(
                      controller: _filterChipController,
                      scrollDirection: Axis.horizontal,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Remix.filter_3_line, size: 16),
                          label: const Text('All Filters'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                            backgroundColor: const Color(0xFFbad012),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Location',
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Specialty',
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Rating 4+',
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Available Now',
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Budget',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sort and View Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('24 architects found',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Row(
                      children: [
                        Row(
                          children: const [
                            Text('Sort by:',
                                style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text('Rating',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            Icon(Remix.arrow_down_s_line, size: 16),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                            icon: const Icon(Remix.list_check_2,
                                color: Color(0xFFbad012), size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFbad012),
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
                const SizedBox(height: 16),

                // Architect Cards
                Expanded(
                  child: Scrollbar(
                    controller: _searchResultsController,
                    thumbVisibility: false,
                    child: GridView.count(
                      controller: _searchResultsController,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: [
                        _buildArchitectCard(
                          onTap: () => _viewProfile(1),
                          imageUrl:
                          "https://readdy.ai/api/search-image?query=professional%20female%20architect%20in%20modern%20office%2C%20professional%20headshot%2C%20confident%20pose%2C%20business%20attire%2C%20neutral%20background%2C%20high%20quality%2C%20photorealistic&width=200&height=200&seq=arch1&orientation=portrait",
                          name: "Aqsa Irfan",
                          rating: 4.9,
                          reviewCount: 124,
                          location: "Islamabad, 2.4 mi",
                          specialty: "Residential",
                          priceRange: "\$120-150/hr",
                        ),
                        _buildArchitectCard(
                          onTap: () => _viewProfile(2),
                          imageUrl:
                          "https://readdy.ai/api/search-image?query=professional%20male%20architect%20in%20modern%20office%2C%20professional%20headshot%2C%20confident%20pose%2C%20business%20attire%2C%20neutral%20background%2C%20high%20quality%2C%20photorealistic&width=200&height=200&seq=arch2&orientation=portrait",
                          name: "M. Ali",
                          rating: 4.8,
                          reviewCount: 87,
                          location: "Islamabad, 5.1 mi",
                          specialty: "Commercial",
                          priceRange: "\$140-180/hr",
                        ),
                        _buildArchitectCard(
                          onTap: () => _viewProfile(3),
                          imageUrl:
                          "https://readdy.ai/api/search-image?query=professional%20asian%20female%20architect%20in%20modern%20office%2C%20professional%20headshot%2C%20confident%20pose%2C%20business%20attire%2C%20neutral%20background%2C%20high%20quality%2C%20photorealistic&width=200&height=200&seq=arch3&orientation=portrait",
                          name: "Amna Khan",
                          rating: 4.7,
                          reviewCount: 56,
                          location: "Rawalpindi, 3.8 mi",
                          specialty: "Interior",
                          priceRange: "\$110-140/hr",
                        ),
                        _buildArchitectCard(
                          onTap: () => _viewProfile(4),
                          imageUrl:
                          "https://readdy.ai/api/search-image?query=professional%20black%20male%20architect%20in%20modern%20office%2C%20professional%20headshot%2C%20confident%20pose%2C%20business%20attire%2C%20neutral%20background%2C%20high%20quality%2C%20photorealistic&width=200&height=200&seq=arch4&orientation=portrait",
                          name: "Ahmed",
                          rating: 4.9,
                          reviewCount: 142,
                          location: "Islamabad, 1.5 mi",
                          specialty: "Sustainable",
                          priceRange: "\$150-200/hr",
                        ),
                        _buildArchitectCard(
                          onTap: () => _viewProfile(5),
                          imageUrl:
                          "https://readdy.ai/api/search-image?query=professional%20female%20architect%20in%20modern%20office%2C%20professional%20headshot%2C%20confident%20pose%2C%20business%20attire%2C%20neutral%20background%2C%20high%20quality%2C%20photorealistic&width=200&height=200&seq=arch5&orientation=portrait",
                          name: "Mariam Zahid",
                          rating: 4.6,
                          reviewCount: 78,
                          location: "Rawalpindi, 4.2 mi",
                          specialty: "Landscape",
                          priceRange: "\$130-160/hr",
                        ),
                        _buildArchitectCard(
                          onTap: () => _viewProfile(6),
                          imageUrl:
                          "https://readdy.ai/api/search-image?query=professional%20male%20architect%20in%20modern%20office%2C%20professional%20headshot%2C%20confident%20pose%2C%20business%20attire%2C%20neutral%20background%2C%20high%20quality%2C%20photorealistic&width=200&height=200&seq=arch6&orientation=portrait",
                          name: "Hamza",
                          rating: 4.8,
                          reviewCount: 95,
                          location: "Rawalpindi, 3.1 mi",
                          specialty: "Modern",
                          priceRange: "\$140-190/hr",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Modal
          if (_showFilterModal)
            GestureDetector(
              onTap: _toggleFilterModal,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildFilterModal(
                      onClose: _toggleFilterModal,
                      selectedSpecialties: selectedSpecialties,
                      onSpecialtyChanged: _toggleSpecialty,
                    ),
                  ),
                ],
              ),
            ),

          // Tab Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(
                      icon: Remix.home_4_line, label: 'Home', onPressed: () {}),
                  _buildTabItem(
                      icon: Remix.folder_line,
                      label: 'Projects',
                      onPressed: () {}),
                  _buildTabItem(
                      icon: Remix.message_2_line,
                      label: 'Messages',
                      onPressed: () {}),
                  _buildTabItem(
                      icon: Remix.user_line, label: 'Profile', onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
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
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildArchitectCard({
    required VoidCallback onTap,
    required String imageUrl,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
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
                    child: Image.network(
                      imageUrl,
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
                      const Icon(Remix.verified_badge_fill,
                          color: Color(0xFFbad012), size: 14),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text('$rating ($reviewCount)',
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Remix.map_pin_line,
                          color: Colors.grey, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(location,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                          color: const Color(0xFFbad012).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(specialty,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFFbad012))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(priceRange,
                      style:
                      const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterModal({
    required VoidCallback onClose,
    required List<String> selectedSpecialties,
    required Function(String) onSpecialtyChanged,
  }) {
    return Container(
      constraints:
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('All Filters',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Remix.close_line),
            onPressed: onClose,
          ),
        ],
      ),
    ),
    const Divider(height: 1),
    Expanded(
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Location Filter
    const Text('Location',
    style:
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    TextField(
    decoration: const InputDecoration(
    hintText: 'Enter city or zip code',
    prefixIcon: Icon(Remix.map_pin_line,
    color: Colors.grey),
    ),
    style: const TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 16),
    const Text('Distance',
    style: TextStyle(fontSize: 14, color: Colors.grey)),
    const SizedBox(height: 8),
    SliderTheme(
    data: SliderTheme.of(context).copyWith(
    activeTrackColor: const Color(0xFFbad012),
    inactiveTrackColor: Colors.grey[300],
    thumbColor: const Color(0xFFbad012),
    ),
    child: const Slider(
    value: 10,
    min: 1,
    max: 50,
    divisions: 49,
    label: '10 miles',
    onChanged: null, // For demonstration, should be implemented
    ),
    ),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: const [
    Text('1 mile',
    style: TextStyle(fontSize: 10, color: Colors.grey)),
    Text('10 miles',
    style: TextStyle(fontSize: 10, color: Colors.grey)),
    Text('50 miles',
    style: TextStyle(fontSize: 10, color: Colors.grey)),
    ],
    ),
    const SizedBox(height: 24),

    // Specialty Filter
    const Text('Specialty',
    style:
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    childAspectRatio: 3,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    children: [
    _buildCheckboxFilter(
    label: 'Residential',
    value: selectedSpecialties.contains('Residential'),
    onChanged: (bool? value) {
    if (value != null) {
    onSpecialtyChanged('Residential');
    }
    },
    ),
    _buildCheckboxFilter(
    label: 'Commercial',
    value: selectedSpecialties.contains('Commercial'),
    onChanged: (bool? value) {
    if (value != null) {
    onSpecialtyChanged('Commercial');
    }
    },
    ),
    _buildCheckboxFilter(
    label: 'Interior Design',
    value: selectedSpecialties.contains('Interior'),
    onChanged: (bool? value) {
    if (value != null) {
    onSpecialtyChanged('Interior');
    }
    },
    ),
    _buildCheckboxFilter(
    label: 'Landscape',
    value: selectedSpecialties.contains('Landscape'),
    onChanged: (bool? value) {
    if (value != null) {
    onSpecialtyChanged('Landscape');
    }
    },
    ),
    _buildCheckboxFilter(
    label: 'Sustainable',
    value: selectedSpecialties.contains('Sustainable'),
    onChanged: (bool? value) {
    if (value != null) {
    onSpecialtyChanged('Sustainable');
    }
    },
    ),
    _buildCheckboxFilter(
    label: 'Urban Planning',
    value: selectedSpecialties.contains('Urban'),
    onChanged: (bool? value) {
    if (value != null) {
    onSpecialtyChanged('Urban');
    }
    },
    ),
    ],
    ),
    const SizedBox(height: 24),

    // Rating Filter
    const Text('Rating',
    style:
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
    backgroundColor: const Color(0xFFbad012),
    foregroundColor: Colors.white,
    ),
    child: const Text('4.5+'),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    child: const Text('4.0+'),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    child: const Text('3.5+'),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    child: const Text('All'),
    ),
    ),
    ],
    ),
    const SizedBox(height: 24),

    // Availability Filter
    const Text('Availability',
    style:
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
    backgroundColor: const Color(0xFFbad012),
    foregroundColor: Colors.white,
    ),
    child: const Text('Available Now'),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    child: const Text('This Week'),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: OutlinedButton(
    onPressed: () {},
    child: const Text('This Month'),
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),
    Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text('Specific Date Range',
    style: TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Row(
    children: [
    Expanded(
    child: TextField(
    decoration: const InputDecoration(
    hintText: 'Start Date',
    prefixIcon: Icon(Remix.calendar_line,
    color: Colors.grey, size: 16),
    ),
    style: const TextStyle(fontSize: 12),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: TextField(
    decoration: const InputDecoration(
    hintText: 'End Date',
    prefixIcon: Icon(Remix.calendar_line,
    color: Colors.grey, size: 16),
    ),
    style: const TextStyle(fontSize: 12),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    const SizedBox(height: 24),

    // Budget Filter
                  const Text('Budget Range (per hour)',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Slider(
                    value: 150,
                    min: 50,
                    max: 300,
                    divisions: 250,
                    label: '\$150',
                    onChanged: null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('\$50',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('\$150',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('\$300+',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Min',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(text: '\$50'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Max',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(text: '\$150'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxFilter({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFbad012),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}