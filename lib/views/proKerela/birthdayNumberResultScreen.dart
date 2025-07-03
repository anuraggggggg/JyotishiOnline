import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- PDF related imports ---
import 'dart:io';
import 'dart:typed_data'; // Needed for rootBundle.load
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use pw prefix for PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
// --- End PDF related imports ---


class BirthdayNumberResultScreen extends StatelessWidget {
  final String name; // Usually “Birthday Number”
  final String number; // e.g. “3”
  final String description; // Detailed description text

  const BirthdayNumberResultScreen({
    Key? key,
    required this.name,
    required this.number,
    required this.description,
  }) : super(key: key);

  // Cosmic color palette
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);

  // --- PDF Generation Logic for Birthday Number Report ---
  Future<void> _generateBirthdayReportPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Define PDF colors from your palette
      final PdfColor pdfCosmicBlue = PdfColor.fromInt(cosmicBlue.value);
      final PdfColor pdfCelestialGold = PdfColor.fromInt(celestialGold.value);
      final PdfColor pdfStardustWhite = PdfColor.fromInt(stardustWhite.value);
      final PdfColor pdfLunarSilver = PdfColor.fromInt(lunarSilver.value);

      // Load Poppins font (ensure Poppins-Regular.ttf and Poppins-Bold.ttf are in assets/fonts and pubspec.yaml)
      pw.Font? poppinsRegular;
      pw.Font? poppinsBold;
      try {
        final fontDataRegular = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
        poppinsRegular = pw.Font.ttf(fontDataRegular);
        final fontDataBold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
        poppinsBold = pw.Font.ttf(fontDataBold);
      } catch (e) {
        debugPrint("Error loading Poppins fonts for PDF: $e. Using built-in fonts.");
        poppinsRegular = pw.Font.helvetica(); // Fallback
        poppinsBold = pw.Font.helveticaBold(); // Fallback
      }
      final ByteData imageBytes = await rootBundle.load('assets/images/finalLogo.png');
      final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pwContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Image(logoImage, height: 40, width: 40),
                ),
                pw.Center(
                  child: pw.Text(
                    'Your Birthday Number Report',
                    style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: pdfCelestialGold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Center(
                  child: pw.Text(
                    'Generated on: ${DateFormat('dd-MM-yyyy – hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      fontSize: 12,
                      color: pdfLunarSilver,
                    ),
                  ),
                ),
                pw.SizedBox(height: 25),
                // Birthday Number Display in PDF
                pw.Center(
                  child: pw.Container(
                    width: 150, // Fixed width for the number card
                    height: 150, // Fixed height
                    decoration: pw.BoxDecoration(
                      color: pdfCosmicBlue,
                      borderRadius: pw.BorderRadius.circular(75), // Make it circular
                      border: pw.Border.all(color: pdfCelestialGold, width: 2),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Your Number',
                          style: pw.TextStyle(
                            font: poppinsRegular,
                            fontSize: 14,
                            color: pdfLunarSilver,
                          ),
                        ),
                        pw.Text(
                          number,
                          style: pw.TextStyle(
                            font: poppinsBold,
                            fontSize: 60, // Large font size for the number
                            color: pdfStardustWhite,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 25),
                // Description Section in PDF
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: pdfCelestialGold, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(15),
                    color: pdfCosmicBlue,
                  ),
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'About Your Birthday Number:',
                        style: pw.TextStyle(
                          font: poppinsBold,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: pdfCelestialGold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        description, // The detailed description content
                        style: pw.TextStyle(
                          font: poppinsRegular,
                          color: pdfStardustWhite,
                          fontSize: 14,
                          lineSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Embrace the wisdom of numerology.',
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      color: pdfLunarSilver,
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Generated by Astroway Customer App', // Your app name
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                      font: poppinsRegular,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final fileName = 'birthday_number_report_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Check out my Birthday Number Report!');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate or share PDF: $e')),
        );
      }
      debugPrint('Error generating PDF: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 20;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [cosmicBlue, darkAccent, mediumAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: topPadding,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Number Display Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: celestialGold.withOpacity(0.8), width: 2)),
                color: cosmicBlue.withOpacity(0.85),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        'Your Birthday Number',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: celestialGold,
                          letterSpacing: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        number,
                        style: GoogleFonts.poppins(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: stardustWhite,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The key to understanding your inherent talents and life path.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: lunarSilver,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Description Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: celestialGold.withOpacity(0.6), width: 1.5)),
                color: cosmicBlue.withOpacity(0.75),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Your Number',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: celestialGold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          color: stardustWhite,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'Embrace the wisdom of numerology.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lunarSilver,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      // --- Floating Action Button for PDF Download ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateBirthdayReportPdf(context),
        label: Text(
          'Download Report',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: cosmicBlue,
            fontSize: 16,
          ),
        ),
        icon: const Icon(Icons.download, color: cosmicBlue),
        backgroundColor: celestialGold,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- End Floating Action Button ---
    );
  }
}