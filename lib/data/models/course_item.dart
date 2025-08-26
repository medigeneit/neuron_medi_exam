import 'package:flutter/material.dart';

class CourseItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  CourseItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}


final List<CourseItem> demoCourses = [
  CourseItem(
    icon: Icons.school,
    title: 'Diploma (BUP)',
    onTap: () => print('Diploma (BUP) tapped'),
  ),
  CourseItem(
    icon: Icons.medical_information,
    title: 'Diploma/M.Phil AID',
    onTap: () => print('Diploma/M.Phil AID tapped'),
  ),
  CourseItem(
    icon: Icons.medical_services,
    title: 'FCPS Part-1 Aid',
    onTap: () => print('FCPS Part-1 Aid tapped'),
  ),
  CourseItem(
    icon: Icons.local_hospital,
    title: 'Combined (Residency & FCPS P-1)',
    onTap: () => print('Combined (Residency & FCPS P-1) tapped'),
  ),
  CourseItem(
    icon: Icons.assignment,
    title: 'BCS',
    onTap: () => print('BCS tapped'),
  ),
  CourseItem(
    icon: Icons.health_and_safety,
    title: 'Combined (Residency + FCPS P-1 + Diploma)',
    onTap: () => print('Combined (Residency + FCPS P-1 + Diploma) tapped'),
  ),
  CourseItem(
    icon: Icons.menu_book,
    title: 'Combined (Diploma + FCPS P-1)',
    onTap: () => print('Combined (Diploma + FCPS P-1) tapped'),
  ),
  CourseItem(
    icon: Icons.business_center,
    title: 'Residency',
    onTap: () => print('Residency tapped'),
  ),
  CourseItem(
    icon: Icons.verified,
    title: 'BMDC Registration',
    onTap: () => print('BMDC Registration tapped'),
  ),
];
