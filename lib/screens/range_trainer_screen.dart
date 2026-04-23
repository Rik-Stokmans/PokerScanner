import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class RangeTrainerScreen extends StatelessWidget {
  const RangeTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        title: Text(
          'Range Trainer',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Text(
          'Range Trainer — coming soon',
          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
