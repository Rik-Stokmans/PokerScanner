import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ConceptDetailScreen extends StatelessWidget {
  final String conceptId;

  const ConceptDetailScreen({super.key, required this.conceptId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        title: Text(
          'Concept',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Text(
          'Concept: $conceptId — coming soon',
          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
