import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/available_batch_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/available_banner_card.dart';
import 'package:medi_exam/presentation/widgets/available_screens_helpers.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
// if your banner card is in another file, import it like below:
// import 'package:medi_exam/presentation/widgets/available_banner_card.dart';

/// If you placed the AvailableBatchBannerCard in the same file tree,
/// make sure the import path is correct. For now, we assume it's accessible.

class AvailableBatchScreen extends StatefulWidget {
  const AvailableBatchScreen({Key? key}) : super(key: key);

  @override
  State<AvailableBatchScreen> createState() => _AvailableBatchScreenState();
}

class _AvailableBatchScreenState extends State<AvailableBatchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // ----- dummy data -----
  final List<AvailableBatchItem> _all = <AvailableBatchItem>[
  AvailableBatchItem(
  title: 'FCPS Part-1 (Medicine)',
  subTitle: 'Comprehensive Foundation',
  startDate: '12 Sep 2025',
  days: 'Sat, Mon, Wed',
  time: '7:30–9:00 PM',
  price: '৳ 8,500',
  imageUrl: 'https://picsum.photos/800/400?random=5',
  discount: 'Free',
  onDetails: () {},
  batchDetails: 'This batch will cover all the critical aspects of FCPS Part-1 in Medicine. Lectures will focus on theory, problem-solving, and case discussions.',
  courseOutline: '1. Introduction to Medicine\n2. Clinical Examination\n3. Common Diseases\n4. Treatment Protocols\n5. Case Studies\n6. Patient Management\n7. Pathophysiology and Pharmacology',
  courseFee: '৳ 8,500 - No additional fees',
  offer: 'Free enrollment for the first 50 students',
  ),
  AvailableBatchItem(
  title: 'FCPS Part-1 (Surgery)',
  subTitle: 'Crash + Problem Solving',
  startDate: '20 Sep 2025',
  days: 'Fri, Sun, Tue',
  time: '7:30–9:00 PM',
  price: '৳ 9,200',
  imageUrl: 'https://picsum.photos/800/400?random=6',
  discount: '20% OFF',
  onDetails: () {},
  batchDetails: 'This intensive crash course is designed for quick learning and solving complex surgical problems in Part-1.',
  courseOutline: '1. Surgical Anatomy\n2. Preoperative Preparation\n3. Common Surgeries\n4. Postoperative Care\n5. Complications in Surgery\n6. Surgical Instruments\n7. Case Management',
  courseFee: '৳ 9,200 after 20% discount',
  offer: '20% off for the first 100 registrations',
  ),
  AvailableBatchItem(
  title: 'MRCP Prep (Part 1)',
  subTitle: 'High-Yield Concepts',
  startDate: '05 Oct 2025',
  days: 'Sun, Tue, Thu',
  time: '8:00–9:30 PM',
  price: '৳ 10,000',
  imageUrl: 'https://picsum.photos/800/400?random=7',
  discount: null,
  onDetails: () {},
  batchDetails: 'A focused, high-yield course to prepare for MRCP Part 1, with an emphasis on clinically relevant topics.',
  courseOutline: '1. Clinical Knowledge\n2. Physiology\n3. Medicine & Surgery\n4. Pathology\n5. Pharmacology\n6. Microbiology\n7. Evidence-based Medicine',
  courseFee: '৳ 10,000 - Includes course materials',
  offer: '10% off for early bird registrations',
  ),
  AvailableBatchItem(
  title: 'BCS (Health) Full Course',
  subTitle: 'Syllabus-wise Strategy',
  startDate: '30 Aug 2025',
  days: 'Daily',
  time: '9:00–10:00 PM',
  price: '৳ 12,000',
  imageUrl: 'https://picsum.photos/800/400?random=8',
  discount: '15% OFF',
  onDetails: () {},
  batchDetails: 'The BCS (Health) Full Course focuses on the entire syllabus and strategy for the BCS exam, with daily sessions for comprehensive learning.',
  courseOutline: '1. Public Health\n2. Medical Sciences\n3. Ethics & Law\n4. Healthcare Management\n5. BCS Exam Pattern\n6. Current Affairs in Health\n7. Case Studies and Problem Solving',
  courseFee: '৳ 12,000 with a 15% discount',
  offer: '15% off for the first 50 students',
  ),
  AvailableBatchItem(
  title: 'FCPS Part-2 (Medicine)',
  subTitle: 'Long & Short Cases',
  startDate: '18 Sep 2025',
  days: 'Sat, Tue',
  time: '6:30–8:00 PM',
  price: '৳ 11,500',
  imageUrl: 'https://picsum.photos/800/400?random=8',
  discount: null,
  onDetails: () {},
  batchDetails: 'Focused training for Part-2 of FCPS in Medicine, covering long and short case presentations, clinical diagnosis, and treatment protocols.',
  courseOutline: '1. Medical History Taking\n2. Long Case Preparation\n3. Short Case Discussions\n4. Clinical Skills\n5. Differential Diagnosis\n6. Case Management\n7. Communication Skills',
  courseFee: '৳ 11,500',
  offer: 'No offers available currently',
  ),

  ];

  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.trim();
      if (q != _query) {
        setState(() => _query = q);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<AvailableBatchItem> get _filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((b) {
      return b.title.toLowerCase().contains(q) || b.subTitle.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 380; // extra-tight paddings for very small screens

    return CommonScaffold(
      title: 'Available Batches',
      body: SafeArea(
        child: Column(
          children: [
            // ---- top app/search area ----
            Padding(
              padding: EdgeInsets.fromLTRB(
                14, 12, 14, 6,
              ),
              child: SearchBarWidget(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                isDark: isDark,
                isCompact: isCompact,
                onClear: () {
                  _searchCtrl.clear();
                  _searchFocus.requestFocus();
                },
                onSubmitted: (_) {
                  // optional: close keyboard on submit
                  _searchFocus.unfocus();
                },
              ),
            ),

            // small helper/status row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  if (_query.isEmpty)
                    TinyChip(
                      icon: Icons.explore_rounded,
                      label: 'Showing ${_all.length} batches',
                      isDark: isDark,
                    )
                  else
                    TinyChip(
                      icon: Icons.search_rounded,
                      label: '${_filtered.length} match${_filtered.length == 1 ? '' : 'es'} for “$_query”',
                      isDark: isDark,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ---- list ----
            Expanded(
              child: _filtered.isEmpty
                  ? EmptyState(query: _query, isDark: isDark)
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                physics: const BouncingScrollPhysics(),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = _filtered[index];
                  return AvailableBannerCard(
                    title: b.title,
                    subTitle: b.subTitle,
                    startDate: b.startDate,
                    days: b.days,
                    time: b.time,
                    price: b.price,
                    discount: b.discount,
                    imageUrl: b.imageUrl,
                    onDetails: () {
                      // TODO: navigate to details page
                      // Navigator.push(...);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Open details: ${b.title}')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





