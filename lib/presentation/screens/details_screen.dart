import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/banner_card_helpers.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final Map<String, bool> _expandedSections = {
    'batchDetails': false,
    'courseOutline': false,
  };

  late Map<String, dynamic> courseData;

  @override
  void initState() {
    super.initState();
    courseData = Get.arguments ?? {};
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = [AppColor.indigo, AppColor.purple];

    // Extracting the required data from the map
    final title = courseData['title'] ?? '';
    final subTitle = courseData['subTitle'] ?? '';
    final startDate = courseData['startDate'] ?? '';
    final days = courseData['days'] ?? '';
    final time = courseData['time'] ?? '';
    final price = courseData['price'];
    final discount = courseData['discount'];
    final imageUrl = courseData['imageUrl'];
    final batchDetails = courseData['batchDetails'] ?? '';
    final courseOutline = courseData['courseOutline'] ?? '';
    final courseFee = courseData['courseFee'] ?? '';
    final offer = courseData['offer'] ?? '';

    return CommonScaffold(
      title: 'Course Details',
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            child: Column(
              children: [
                // Hero image section
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: BannerImage(url: imageUrl),
                  ),
                ),

                // Course info section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & SubTitle with gradient
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info Chips in a grid layout
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3.5,
                        children: [
                          _InfoPill(
                            icon: Icons.calendar_today_rounded,
                            label: 'Start: $startDate',
                            bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                            iconColor: gradientColors[0],
                          ),
                          _InfoPill(
                            icon: Icons.event_repeat_rounded,
                            label: 'Days: $days',
                            bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                            iconColor: gradientColors[0],
                          ),
                          _InfoPill(
                            icon: Icons.schedule_rounded,
                            label: 'Time: $time',
                            bg: isDark ? const Color(0xFF2F3337) : const Color(0xFFF8FBFF),
                            iconColor: gradientColors[0],
                          ),
                          if (price != null)
                            _InfoPill(
                              icon: Icons.attach_money_rounded,
                              label: 'Price: $price',
                              bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                              iconColor: gradientColors[0],
                            ),
                          if (discount != null)
                            _InfoPill(
                              icon: Icons.discount_rounded,
                              label: 'Discount: $discount',
                              bg: isDark ? const Color(0xFF2D2F33) : Colors.orange.withOpacity(0.2),
                              iconColor: Colors.orange,
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Batch Details Section (Expandable)
                      _ExpandableSection(
                        title: 'Batch Details',
                        content: batchDetails,
                        isExpanded: _expandedSections['batchDetails']!,
                        onToggle: () => _toggleSection('batchDetails'),
                      ),

                      const SizedBox(height: 16),

                      // Course Outline Section (Expandable)
                      _ExpandableSection(
                        title: 'Course Outline',
                        content: courseOutline,
                        isExpanded: _expandedSections['courseOutline']!,
                        onToggle: () => _toggleSection('courseOutline'),
                      ),

                      const SizedBox(height: 16),

                      // Course Fee Section (Non-expandable)
                      _InfoSection(
                        title: 'Course Fee',
                        content: courseFee,
                      ),

                      const SizedBox(height: 16),

                      // Offer Section (Non-expandable)
                      _InfoSection(
                        title: 'Special Offers',
                        content: offer,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enroll Now Button (Fixed at bottom)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // Handle enroll now action
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Enroll Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Expandable Section (for Batch Details and Course Outline)
class _ExpandableSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableSection({
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = [AppColor.indigo, AppColor.purple];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2125) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              isExpanded ? 'Show less' : 'Show more',
              style: TextStyle(
                color: gradientColors[0],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Non-expandable Section (for Course Fee and Special Offers)
class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = [AppColor.indigo, AppColor.purple];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2125) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}