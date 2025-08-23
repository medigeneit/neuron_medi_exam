import 'package:flutter/material.dart';
import '../widgets/available_batch_item.dart';
import '../widgets/image_slider_banner.dart'; // Import the fixed widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list for demo
    final List<AvailableBatchItem> demoItems = [

      AvailableBatchItem(
        title: "Biology Batch A",
        subTitle: "Intermediate Level",
        startDate: "01 Oct 2025",
        days: "Mon, Wed, Fri",
        time: "6:00 PM - 7:30 PM",
        onDetails: () {
          // You can navigate or show dialog here
          debugPrint("Clicked Biology Batch A");
        },
      ),
      AvailableBatchItem(
        title: "Chemistry Batch B",
        subTitle: "Foundation Course",
        startDate: "05 Oct 2025",
        days: "Tue, Thu",
        time: "7:00 PM - 8:30 PM",
        onDetails: () {
          debugPrint("Clicked Chemistry Batch B");
        },
      ),
      AvailableBatchItem(
        title: "Physics Crash Course",
        subTitle: "Fast Track",
        startDate: "10 Oct 2025",
        days: "Sat, Sun",
        time: "5:00 PM - 6:30 PM",
        onDetails: () {
          debugPrint("Clicked Physics Crash Course");
        },
      ),
      AvailableBatchItem(
        title: "Math Batch D",
        subTitle: "Regular Class",
        startDate: "12 Oct 2025",
        days: "Mon - Fri",
        time: "8:00 PM - 9:00 PM",
        onDetails: () {
          debugPrint("Clicked Math Batch D");
        },
      ),
      // ... other items
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
            ],
          ),
        ),
      ),
    );
  }
}