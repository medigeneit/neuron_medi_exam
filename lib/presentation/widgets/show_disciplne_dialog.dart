import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/presentation/widgets/discipline_faculty_picker_dialog.dart';

void showDisciplineDialog(
    BuildContext context, {
      required String courseTitle,
      required IconData courseIcon,
      required bool isBatch,
      required List<Package> packages,
      required void Function(Package pickedPackage) onPicked,
    }) {
  showDisciplineFacultyPickerDialog(
    context,
    title: courseTitle,
    subtitle: 'Select a Discipline/Faculty to proceed.',
    icon: courseIcon,
    isBatch: isBatch,
    packages: packages,
    onSelected: onPicked, // ✅ forward selection
  );
}
