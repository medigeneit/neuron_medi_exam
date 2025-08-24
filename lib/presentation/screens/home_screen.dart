import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/available_batch_item.dart';
import 'package:medi_exam/data/models/available_subject_item.dart';
import 'package:medi_exam/data/models/slider_image.dart';
import 'package:medi_exam/presentation/widgets/available_subjects_container.dart';
import '../widgets/available_batch_container.dart';
import '../widgets/image_slider_banner.dart'; // Import the fixed widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list for demo
    final List<AvailableBatchItem> demoItems = [

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
      // ... other items
    ];


    // Dummy list for demo
    final List<AvailableSubjectsItem> demoSubjectsItems = [

      AvailableSubjectsItem(
        title: "Chapter 01: Cell Structure & Function",
        subTitle: "Subject: Biology",
        startDate: "01 Oct 2025",
        days: "Mon, Wed, Fri",
        time: "6:00 PM - 7:30 PM",
        discount: "Free",
        onDetails: () {
          // You can navigate or show dialog here
          debugPrint("Chapter 01: Cell Structure & Function");
        },
      ),

      AvailableSubjectsItem(
        title: "Chapter 02: Atomic Structure",
        subTitle: "Subject: Chemistry",
        startDate: "03 Oct 2025",
        days: "Mon, Wed",
        time: "6:00 PM - 7:30 PM",

        onDetails: () {
          debugPrint("Chapter 02: Atomic Structure");
        },
      ),

      AvailableSubjectsItem(
        title: "Chapter 05: Laws of Motion",
        subTitle: "Subject: Physics",
        startDate: "04 Oct 2025",
        days: "Tue, Thu",
        time: "5:00 PM - 6:30 PM",
        discount: "50% OFF",
        onDetails: () {
          debugPrint("Chapter 05: Laws of Motion");
        },
      ),

      AvailableSubjectsItem(
        title: "Chapter 03: Quantitative Chemistry",
        subTitle: "Subject: Chemistry",
        startDate: "05 Oct 2025",
        days: "Tue, Thu",
        time: "7:00 PM - 8:30 PM",
        onDetails: () {
          debugPrint("Chapter 03: Quantitative Chemistry");
        },
      ),

      AvailableSubjectsItem(
        title: "Chapter 10: Semiconductors & Electronics",
        subTitle: "Subjects: Physics",
        startDate: "10 Oct 2025",
        days: "Sat, Sun",
        time: "5:00 PM - 6:30 PM",
        discount: "Free",
        onDetails: () {
          debugPrint("Chapter 10: Semiconductors & Electronics");
        },
      ),
      AvailableSubjectsItem(
        title: "Chapter 10: Statistics & Probability",
        subTitle: "Subject: Math",
        startDate: "12 Oct 2025",
        days: "Mon - Fri",
        time: "8:00 PM - 9:00 PM",

        onDetails: () {
          debugPrint("Chapter 10: Statistics & Probability");
        },
      ),


    ];


    // Dummy images for the slider
    final List<SliderImage> sliderImages = [
      SliderImage(
        imageUrl: "https://picsum.photos/800/400?random=1",
        onTap: () {
          debugPrint("Banner 1 tapped");
        },
        caption: "Special Offer - 50% Off on Biology Courses",
      ),

      SliderImage(
        imageUrl: "https://picsum.photos/800/400?random=2",
        onTap: () {
          debugPrint("Banner 2 tapped");
        },
        caption: "Special Offer - 30% Off on Math Courses",
      ),
      SliderImage(
        imageUrl: "https://picsum.photos/800/400?random=3",
        onTap: () {
          debugPrint("Banner 3 tapped");
        },
        caption: "Special Offer - 45% Off on Physics Crash Courses",
      ),
      // ... other images
    ];

    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Slider Banner at the top
              ImageSliderBanner(
                images: sliderImages,
                height: 240,
              ),

              const SizedBox(height: 8),

              // Section: Available Batches
              AvailableBatchContainer(
                items: demoItems,
              ),

              const SizedBox(height: 8),

              // Section: Available Batches
              AvailableSubjectsContainer(
                items: demoSubjectsItems,
              ),
            ],
          ),
        ),
      ),
    );
  }
}