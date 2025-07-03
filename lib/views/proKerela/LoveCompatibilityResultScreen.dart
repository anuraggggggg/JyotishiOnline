import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// PDF-related imports
import 'dart:io';
import 'dart:typed_data'; // Needed for rootBundle.load
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use pw prefix for PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';


class LoveCompatibilityResultScreen extends StatelessWidget {
  final String compatibility;
  final String report;

  // Cosmic color palette
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);

  const LoveCompatibilityResultScreen({
    Key? key,
    required this.compatibility,
    required this.report,
  }) : super(key: key);

  /// Builds the main Flutter UI card for the cosmic relationship analysis report.
  /// This widget is for the on-screen display.
  Widget _buildReportCard(String report) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: celestialGold.withOpacity(0.6), width: 1.5),
      ),
      color: cosmicBlue.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cosmic Relationship Analysis',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: celestialGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report,
              style: GoogleFonts.poppins(
                color: stardustWhite,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to show a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait for dialog to close
      builder: (BuildContext context) {
        return PopScope( // Prevents dismissal via back button
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: celestialGold),
                const SizedBox(height: 16),
                Text(
                  "Generating PDF...",
                  style: GoogleFonts.poppins(color: cosmicBlue), // Using Poppins for dialog text
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // --- PDF Generation Logic for Love Compatibility Report ---
  Future<void> _generateLoveReportPdf(BuildContext context) async {
    // Show loading dialog
    _showLoadingDialog(context);

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

      // Load the logo image
      final ByteData imageBytes = await rootBundle.load('assets/images/finalLogo.png');
      final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());


      pdf.addPage(
        pw.MultiPage( // Allows content to span multiple pages
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1.5 * PdfPageFormat.cm,
            marginTop: 1.5 * PdfPageFormat.cm,
            marginLeft: 2.0 * PdfPageFormat.cm,
            marginRight: 2.0 * PdfPageFormat.cm,
          ),
          maxPages: 200, // Set a reasonable maximum number of pages
          build: (pw.Context pwContext) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo and Main Title aligned horizontally
                  pw.Center(
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min, // Make the row take minimum space
                      crossAxisAlignment: pw.CrossAxisAlignment.center, // Vertically align items in the row
                      children: [
                        pw.Image(logoImage, height: 40, width: 40), // Adjust logo size as needed
                        pw.SizedBox(width: 10), // Space between logo and text
                        pw.Text(
                          'Cosmic Relationship Analysis Report',
                          style: pw.TextStyle(
                            font: poppinsBold,
                            fontSize: 24, // Main title font size
                            fontWeight: pw.FontWeight.bold,
                            color: pdfCelestialGold,
                          ),
                        ),
                      ],
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
                          'Your Cosmic Compatibility Report:',
                          style: pw.TextStyle(
                            font: poppinsBold,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfCelestialGold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          report, // The actual report content from LoveCompatibilityResultScreen
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
                  // No pw.Spacer() here, as MultiPage handles content flow
                  pw.SizedBox(height: 25), // Ensure enough space before footer elements
                  pw.Center(
                    child: pw.Text(
                      'Remember: The stars incline, they do not compel',
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
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final fileName = 'cosmic_compatibility_report_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Check out my Cosmic Compatibility Report!');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate or share PDF: $e')),
        );
      }
      debugPrint('Error generating PDF: $e');
    } finally {
      // Dismiss the loading dialog regardless of success or failure
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Cosmic Compatibility',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cosmicBlue, darkAccent, mediumAccent],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 30,
            top: MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 20,
          ),
          child: Column(
            children: [
              _buildReportCard(report),
              const SizedBox(height: 30),
              Text(
                'Remember: The stars incline, they do not compel',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _generateLoveReportPdf(context); // Call the PDF generation
        },
        label: Text(
          'Download Cosmic Report',
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
    );
  }
}