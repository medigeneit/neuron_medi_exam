import 'package:flutter/material.dart';

class AvailableBatchItem {
  final String title;
  final String subTitle;
  final String startDate;
  final String days;
  final String time;
  final String? price;
  final String? discount;
  final String? imageUrl;
  final String? batchDetails;
  final String? courseOutline;
  final String? courseFee;
  final String? offer;
  final VoidCallback? onDetails;

  const AvailableBatchItem({
    required this.title,
    required this.subTitle,
    required this.startDate,
    required this.days,
    required this.time,
    this.price,
    this.discount,
    this.imageUrl,
    this.batchDetails,
    this.courseOutline,
    this.courseFee,
    this.offer,
    this.onDetails,
  });
}


class DemoSessionWiseBatchData {
  static const List<Map<String, dynamic>> sessionData = [
    {
      'title': "Nov'26 Session",
      'subtitle': '6:00 AM - 12:00 PM',
      'items': [
        AvailableBatchItem(
          title: 'FCPS Part-1 (Medicine)',
          subTitle: 'Comprehensive Foundation',
          startDate: '12 Sep 2025',
          days: 'Sat, Mon, Wed',
          time: '7:30–9:00 PM',
          price: '৳ 8,500',
          discount: 'Free',
          imageUrl: 'https://picsum.photos/800/400?random=5',
          batchDetails:
          'This batch will cover all the critical aspects of FCPS Part-1 in Medicine. This batch will cover all the critical aspects of FCPS Part-1 in Medicine.',
          courseOutline:
          '1. Introduction to Medicine\n2. Clinical Examination\n3. Common Diseases\n4. Treatment Protocols\n5. Case Studies\n6. Patient Management\n7. Pathophysiology and Pharmacology',
          courseFee: '৳ 8,500 - No additional fees',
          offer: 'Free enrollment for the first 50 students',
        ),
        AvailableBatchItem(
          title: 'BCS (Health) Full Course',
          subTitle: 'Syllabus-wise Strategy',
          startDate: '30 Aug 2025',
          days: 'Daily',
          time: '9:00–10:00 PM',
          price: '৳ 12,000',
          discount: '15% OFF',
          imageUrl: 'https://picsum.photos/800/400?random=6',
          batchDetails:
          'The BCS (Health) Full Course focuses on the entire syllabus. The BCS (Health) Full Course focuses on the entire syllabus. The BCS (Health) Full Course focuses on the entire syllabus.',
          courseOutline:
          '1. Public Health\n2. Medical Sciences\n3. Ethics & Law\n4. Healthcare Management\n5. BCS Exam Pattern',
          courseFee: '৳ 12,000 with a 15% discount',
          offer: '15% off for the first 50 students',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-1 (Surgery)',
          subTitle: 'Crash + Problem Solving',
          startDate: '20 Sep 2025',
          days: 'Fri, Sun, Tue',
          time: '7:30–9:00 PM',
          price: '৳ 9,200',
          discount: '20% OFF',
          imageUrl: 'https://picsum.photos/800/400?random=7',
          batchDetails:
          'This intensive crash course is designed for quick learning. This intensive crash course is designed for quick learning. This intensive crash course is designed for quick learning.',
          courseOutline:
          '1. Surgical Anatomy\n2. Preoperative Preparation\n3. Common Surgeries\n4. Postoperative Care\n5. Complications in Surgery',
          courseFee: '৳ 9,200 after 20% discount',
          offer: '20% off for the first 100 registrations',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-2 (Medicine)',
          subTitle: 'Long & Short Cases',
          startDate: '18 Sep 2025',
          days: 'Sat, Tue',
          time: '6:30–8:00 PM',
          price: '৳ 11,500',
          discount: null,
          imageUrl: 'https://picsum.photos/800/400?random=8',
          batchDetails: 'Focused training for Part-2 of FCPS in Medicine. Focused training for Part-2 of FCPS in Medicine. Focused training for Part-2 of FCPS in Medicine.',
          courseOutline:
          '1. Medical History Taking\n2. Long Case Preparation\n3. Short Case Discussions\n4. Clinical Skills\n5. Diagnostic Reasoning',
          courseFee: '৳ 11,500',
          offer: 'No offers available currently',
        ),
      ],
    },
    {
      'title': "Jan'26 Session",
      'subtitle': '4:00 PM - 10:00 PM',
      'items': [
        AvailableBatchItem(
          title: 'FCPS Part-1 (Surgery)',
          subTitle: 'Crash + Problem Solving',
          startDate: '20 Sep 2025',
          days: 'Fri, Sun, Tue',
          time: '7:30–9:00 PM',
          price: '৳ 9,200',
          discount: '20% OFF',
          imageUrl: 'https://picsum.photos/800/400?random=9',
          batchDetails:
          'This intensive crash course is designed for quick learning. This intensive crash course is designed for quick learning. This intensive crash course is designed for quick learning.',
          courseOutline:
          '1. Surgical Anatomy\n2. Preoperative Preparation\n3. Common Surgeries\n4. Postoperative Care\n5. Complications in Surgery',
          courseFee: '৳ 9,200 after 20% discount',
          offer: '20% off for the first 100 registrations',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-2 (Medicine)',
          subTitle: 'Long & Short Cases',
          startDate: '18 Sep 2025',
          days: 'Sat, Tue',
          time: '6:30–8:00 PM',
          price: '৳ 11,500',
          discount: null,
          imageUrl: 'https://picsum.photos/800/400?random=10',
          batchDetails: 'Focused training for Part-2 of FCPS in Medicine. Focused training for Part-2 of FCPS in Medicine. Focused training for Part-2 of FCPS in Medicine.',
          courseOutline:
          '1. Medical History Taking\n2. Long Case Preparation\n3. Short Case Discussions\n4. Clinical Skills\n5. Diagnostic Reasoning',
          courseFee: '৳ 11,500',
          offer: 'No offers available currently',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-1 (Medicine)',
          subTitle: 'Comprehensive Foundation',
          startDate: '12 Sep 2025',
          days: 'Sat, Mon, Wed',
          time: '7:30–9:00 PM',
          price: '৳ 8,500',
          discount: 'Free',
          imageUrl: 'https://picsum.photos/800/400?random=11',
          batchDetails:
          'This batch will cover all the critical aspects of FCPS Part-1 in Medicine. This batch will cover all the critical aspects of FCPS Part-1 in Medicine.',
          courseOutline:
          '1. Introduction to Medicine\n2. Clinical Examination\n3. Common Diseases\n4. Treatment Protocols\n5. Case Studies\n6. Patient Management\n7. Pathophysiology and Pharmacology',
          courseFee: '৳ 8,500 - No additional fees',
          offer: 'Free enrollment for the first 50 students',
        ),
        AvailableBatchItem(
          title: 'BCS (Health) Full Course',
          subTitle: 'Syllabus-wise Strategy',
          startDate: '30 Aug 2025',
          days: 'Daily',
          time: '9:00–10:00 PM',
          price: '৳ 12,000',
          discount: '15% OFF',
          imageUrl: 'https://picsum.photos/800/400?random=12',
          batchDetails:
          'The BCS (Health) Full Course focuses on the entire syllabus. The BCS (Health) Full Course focuses on the entire syllabus. The BCS (Health) Full Course focuses on the entire syllabus.',
          courseOutline:
          '1. Public Health\n2. Medical Sciences\n3. Ethics & Law\n4. Healthcare Management\n5. BCS Exam Pattern',
          courseFee: '৳ 12,000 with a 15% discount',
          offer: '15% off for the first 50 students',
        ),
      ],
    },
    {
      'title': "Nov'25 Session",
      'subtitle': 'Special Weekend Classes',
      'items': [
        AvailableBatchItem(
          title: 'MRCP Prep (Part 1)',
          subTitle: 'High-Yield Concepts',
          startDate: '05 Oct 2025',
          days: 'Sun, Tue, Thu',
          time: '8:00–9:30 PM',
          price: '৳ 10,000',
          discount: null,
          imageUrl: 'https://picsum.photos/800/400?random=14',
          batchDetails:
          'A focused, high-yield course to prepare for MRCP Part 1. A focused, high-yield course to prepare for MRCP Part 1. A focused, high-yield course to prepare for MRCP Part 1.',
          courseOutline:
          '1. Clinical Knowledge\n2. Physiology\n3. Medicine & Surgery\n4. Pathology\n5. Pharmacology\n6. Microbiology\n7. Evidence-based Medicine',
          courseFee: '৳ 10,000 - Includes course materials',
          offer: '10% off for early bird registrations',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-2 (Medicine)',
          subTitle: 'Long & Short Cases',
          startDate: '18 Sep 2025',
          days: 'Sat, Tue',
          time: '6:30–8:00 PM',
          price: '৳ 11,500',
          discount: null,
          imageUrl: 'https://picsum.photos/800/400?random=15',
          batchDetails: 'Focused training for Part-2 of FCPS in Medicine. Focused training for Part-2 of FCPS in Medicine. Focused training for Part-2 of FCPS in Medicine.',
          courseOutline:
          '1. Medical History Taking\n2. Long Case Preparation\n3. Short Case Discussions\n4. Clinical Skills\n5. Diagnostic Reasoning',
          courseFee: '৳ 11,500',
          offer: 'No offers available currently',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-1 (Medicine)',
          subTitle: 'Comprehensive Foundation',
          startDate: '12 Sep 2025',
          days: 'Sat, Mon, Wed',
          time: '7:30–9:00 PM',
          price: '৳ 8,500',
          discount: 'Free',
          imageUrl: 'https://picsum.photos/800/400?random=16',
          batchDetails:
          'This batch will cover all the critical aspects of FCPS Part-1 in Medicine. This batch will cover all the critical aspects of FCPS Part-1 in Medicine.',
          courseOutline:
          '1. Introduction to Medicine\n2. Clinical Examination\n3. Common Diseases\n4. Treatment Protocols\n5. Case Studies\n6. Patient Management\n7. Pathophysiology and Pharmacology',
          courseFee: '৳ 8,500 - No additional fees',
          offer: 'Free enrollment for the first 50 students',
        ),
        AvailableBatchItem(
          title: 'BCS (Health) Full Course',
          subTitle: 'Syllabus-wise Strategy',
          startDate: '30 Aug 2025',
          days: 'Daily',
          time: '9:00–10:00 PM',
          price: '৳ 12,000',
          discount: '15% OFF',
          imageUrl: 'https://picsum.photos/800/400?random=17',
          batchDetails:
          'The BCS (Health) Full Course focuses on the entire syllabus. The BCS (Health) Full Course focuses on the entire syllabus. The BCS (Health) Full Course focuses on the entire syllabus.',
          courseOutline:
          '1. Public Health\n2. Medical Sciences\n3. Ethics & Law\n4. Healthcare Management\n5. BCS Exam Pattern',
          courseFee: '৳ 12,000 with a 15% discount',
          offer: '15% off for the first 50 students',
        ),
        AvailableBatchItem(
          title: 'FCPS Part-1 (Surgery)',
          subTitle: 'Crash + Problem Solving',
          startDate: '20 Sep 2025',
          days: 'Fri, Sun, Tue',
          time: '7:30–9:00 PM',
          price: '৳ 9,200',
          discount: '20% OFF',
          imageUrl: 'https://picsum.photos/800/400?random=18',
          batchDetails:
          'This intensive crash course is designed for quick learning. This intensive crash course is designed for quick learning. This intensive crash course is designed for quick learning.',
          courseOutline:
          '1. Surgical Anatomy\n2. Preoperative Preparation\n3. Common Surgeries\n4. Postoperative Care\n5. Complications in Surgery',
          courseFee: '৳ 9,200 after 20% discount',
          offer: '20% off for the first 100 registrations',
        ),
      ],
    },
  ];
}