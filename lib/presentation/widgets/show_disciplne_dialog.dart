// Update the dialog function to accept packages directly
import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/presentation/widgets/discipline_faculty_picker_dialog.dart';

void showDisciplineDialog(BuildContext context, String courseTitle,
    IconData courseIcon, bool isBatch, List<Package> packages) {

  showDisciplineFacultyPickerDialog(
    context,
    title: courseTitle,
    subtitle: 'Select a Discipline/Faculty to proceed.',
    icon: courseIcon,
    isBatch: isBatch,
    packages: packages, // Pass packages directly
    onSelected: (pickedPackage) {
      debugPrint('Selected: ${pickedPackage.packageName} from $courseTitle');
      // You can now navigate with both course and package info
    },
  );
}