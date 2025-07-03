import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // Assuming GetX is used for navigation/state
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'
    as pw; // Import with prefix 'pw' for PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/proKerla/panchangModel.dart'; // Ensure this path is correct

class PanchangResultScreen extends StatelessWidget {
  final DetailedPanchangModel data;

  const PanchangResultScreen({super.key, required this.data});

  // Define a consistent sophisticated color palette
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite =
      Color(0xFFF0F0F0); // Off-white for readability
  static const Color lunarSilver = Color(0xFFC0C0C0); // Soft silver
  static const Color greenAuspicious =
      Color(0xFF28a745); // Green for auspicious periods
  static const Color redInauspicious =
      Color(0xFFdc3545); // Red for inauspicious periods

  String _formatTime(String? dt) {
    if (dt == null || dt.isEmpty) return "N/A";
    try {
      // Assuming the time string is in 'HH:mm' format for parsing
      // If your backend sends 'YYYY-MM-DD HH:mm:ss', DateTime.parse works directly.
      // If it's just 'HH:mm', you might need a dummy date.
      final parts = dt.split(':');
      if (parts.length == 2) {
        // Construct a dummy DateTime for parsing just time
        final now = DateTime.now();
        final dateTime = DateTime(now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]));
        return DateFormat('hh:mm a').format(dateTime);
      } else {
        // Try parsing as a full DateTime string
        final dateTime = DateTime.parse(dt);
        return DateFormat('hh:mm a').format(dateTime);
      }
    } catch (e) {
      debugPrint('Error parsing time: $dt - $e');
      return dt; // Return original if parsing fails, but log the error
    }
  }

  // Common text style for details
  final TextStyle _detailTextStyle = const TextStyle(
    color: stardustWhite,
    fontSize: 16,
    height: 1.5,
  );

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: celestialGold.withOpacity(0.6), width: 1.5),
      ),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: cosmicBlue.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: celestialGold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: celestialGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: lunarSilver, height: 25, thickness: 0.5),
            ...children, // Children are already widgets, no need to map them again
          ],
        ),
      ),
    );
  }

  // Widget to display periods (Auspicious/Inauspicious)
  Widget _buildPeriodSection(String title, List<Muhurta> periods,
      Color indicatorColor, IconData icon) {
    if (periods.isEmpty)
      return const SizedBox.shrink(); // Don't show if no periods

    return _buildDetailCard(
      title,
      icon,
      periods.map((muhurta) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ ${muhurta.name}:',
              style: _detailTextStyle.copyWith(
                  fontWeight: FontWeight.bold, color: indicatorColor),
            ),
            ...muhurta.period.map((p) => Text(
                '   ⏱ ${_formatTime(p.start)} → ${_formatTime(p.end)}',
                style: _detailTextStyle)),
            if (muhurta.period.isNotEmpty &&
                muhurta !=
                    periods
                        .last) // Add a small space between different muhurtas
              const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cosmic Panchang',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: cosmicBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: stardustWhite),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDetailCard(
                  "Sun & Vaara",
                  Icons.wb_sunny_outlined,
                  [
                    Text("🌅 Sunrise: ${_formatTime(data.sunrise)}",
                        style: _detailTextStyle),
                    Text("🌇 Sunset: ${_formatTime(data.sunset)}",
                        style: _detailTextStyle),
                    Text("📅 Vaara: ${data.vaara ?? "N/A"}",
                        style: _detailTextStyle),
                  ],
                ),
                if (data.tithi.isNotEmpty) // Use .isNotEmpty for lists
                  _buildDetailCard(
                    "Tithi (Lunar Day)",
                    Icons.brightness_2_outlined,
                    data.tithi
                        .map((t) => Text(
                            '🌓 ${t.name} (${t.paksha})\n⏱ ${_formatTime(t.start)} → ${_formatTime(t.end)}',
                            style: _detailTextStyle))
                        .toList(),
                  ),
                if (data.nakshatra.isNotEmpty)
                  _buildDetailCard(
                    "Nakshatra (Lunar Mansion)",
                    Icons.star_border,
                    data.nakshatra
                        .map((n) => Text(
                            '🌟 ${n.name}\n⏱ ${_formatTime(n.start)} → ${_formatTime(n.end)}',
                            style: _detailTextStyle))
                        .toList(),
                  ),
                if (data.karana.isNotEmpty)
                  _buildDetailCard(
                    "Karana (Half Tithi)",
                    Icons.autorenew,
                    data.karana
                        .map((k) => Text(
                            '🔄 ${k.name}\n⏱ ${_formatTime(k.start)} → ${_formatTime(k.end)}',
                            style: _detailTextStyle))
                        .toList(),
                  ),
                if (data.yoga.isNotEmpty)
                  _buildDetailCard(
                    "Yoga (Lunar Conjunction)",
                    Icons.self_improvement,
                    data.yoga
                        .map((y) => Text(
                            '🧘 ${y.name}\n⏱ ${_formatTime(y.start)} → ${_formatTime(y.end)}',
                            style: _detailTextStyle))
                        .toList(),
                  ),
                // Add Auspicious and Inauspicious Periods
                _buildPeriodSection(
                  "Auspicious Periods",
                  data.auspiciousPeriod,
                  greenAuspicious,
                  Icons.check_circle_outline,
                ),
                _buildPeriodSection(
                  "Inauspicious Periods",
                  data.inauspiciousPeriod,
                  redInauspicious,
                  Icons.cancel_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Show a loading indicator
          _showLoadingDialog(context);
          try {
            await _generateAndSharePdf(context);
          } finally {
            // Dismiss the loading indicator if the widget is still mounted
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        label: const Text('Download PDF'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: celestialGold,
        foregroundColor: cosmicBlue,
      ),
    );
  }

  // Helper to show a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait for dialog to close
      builder: (BuildContext context) {
        return PopScope(
          // Prevents dismissal via back button
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: celestialGold),
                const SizedBox(height: 16),
                Text(
                  "Generating PDF...",
                  style: TextStyle(color: cosmicBlue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- PDF Generation Logic ---
  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Define PDF colors
      final PdfColor pdfCosmicBlue = PdfColor.fromInt(cosmicBlue.value);
      final PdfColor pdfCelestialGold = PdfColor.fromInt(celestialGold.value);
      final PdfColor pdfStardustWhite = PdfColor.fromInt(stardustWhite.value);
      final PdfColor pdfLunarSilver = PdfColor.fromInt(lunarSilver.value);
      final PdfColor pdfGreenAuspicious =
          PdfColor.fromInt(greenAuspicious.value);
      final PdfColor pdfRedInauspicious =
          PdfColor.fromInt(redInauspicious.value);

      // Load custom fonts
      final ByteData malayalamFontData =
          await rootBundle.load('assets/fonts/NotoSansMalayalam-Regular.ttf');
      final pw.Font malayalamFont = pw.Font.ttf(malayalamFontData);

      final ByteData emojiFontData =
          await rootBundle.load('assets/fonts/NotoColorEmoji.ttf');
      final pw.Font emojiFont = pw.Font.ttf(emojiFontData);

      // Define standard fonts for general text and fallbacks
      final pw.Font helveticaFont = pw.Font.helvetica();
      final pw.Font helveticaBoldFont = pw.Font.helveticaBold();

      // --- Load the newLogo.png image ---
      final ByteData imageBytes =
          await rootBundle.load('assets/images/finalLogo.png');
      final pw.MemoryImage logoImage =
          pw.MemoryImage(imageBytes.buffer.asUint8List());

      pdf.addPage(
        pw.MultiPage(
          // Use MultiPage to allow content to span multiple pages
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 30, // Adjust bottom margin for footer
            marginTop: 30, // Adjust top margin for header
            marginLeft: 25,
            marginRight: 25,
          ),
          header: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Center(
                  child: pw.Image(logoImage, height: 50, width: 50),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Panchang Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: pdfCosmicBlue,
                      font: helveticaBoldFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Generated on: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                      font: helveticaFont,
                    ),
                  ),
                ),
                pw.Divider(color: pdfLunarSilver, height: 20, thickness: 0.5),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(color: pdfLunarSilver, height: 20, thickness: 0.5),
                pw.Center(
                  child: pw.Text(
                    'Generated by Astroway Customer App | Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                      font: helveticaFont,
                    ),
                  ),
                ),
              ],
            );
          },
          build: (pw.Context pwContext) {
            return [
              // Content goes here in a list of widgets
              _buildPdfDetailCard(
                title: "Sun & Vaara",
                iconDescription: '☀️',
                entries: [
                  '🌅 Sunrise: ${_formatTime(data.sunrise)}',
                  '🌇 Sunset: ${_formatTime(data.sunset)}',
                  '📅 Vaara: ${data.vaara ?? "N/A"}',
                ],
                pdfCosmicBlue: pdfCosmicBlue,
                pdfCelestialGold: pdfCelestialGold,
                pdfStardustWhite: pdfStardustWhite,
                pdfLunarSilver: pdfLunarSilver,
                contentFont: malayalamFont,
                emojiFont: emojiFont,
              ),
              if (data.tithi.isNotEmpty)
                _buildPdfDetailCard(
                  title: "Tithi (Lunar Day)",
                  iconDescription: '🌕',
                  entries: data.tithi
                      .map((t) =>
                          '🌓 ${t.name} (${t.paksha})\n⏱ ${_formatTime(t.start)} → ${_formatTime(t.end)}')
                      .toList(),
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfStardustWhite: pdfStardustWhite,
                  pdfLunarSilver: pdfLunarSilver,
                  contentFont: malayalamFont,
                  emojiFont: emojiFont,
                ),
              if (data.nakshatra.isNotEmpty)
                _buildPdfDetailCard(
                  title: "Nakshatra (Lunar Mansion)",
                  iconDescription: '⭐',
                  entries: data.nakshatra
                      .map((n) =>
                          '🌟 ${n.name}\n⏱ ${_formatTime(n.start)} → ${_formatTime(n.end)}')
                      .toList(),
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfStardustWhite: pdfStardustWhite,
                  pdfLunarSilver: pdfLunarSilver,
                  contentFont: malayalamFont,
                  emojiFont: emojiFont,
                ),
              if (data.karana.isNotEmpty)
                _buildPdfDetailCard(
                  title: "Karana (Half Tithi)",
                  iconDescription: '🔄',
                  entries: data.karana
                      .map((k) =>
                          '🔄 ${k.name}\n⏱ ${_formatTime(k.start)} → ${_formatTime(k.end)}')
                      .toList(),
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfStardustWhite: pdfStardustWhite,
                  pdfLunarSilver: pdfLunarSilver,
                  contentFont: malayalamFont,
                  emojiFont: emojiFont,
                ),
              if (data.yoga.isNotEmpty)
                _buildPdfDetailCard(
                  title: "Yoga (Lunar Conjunction)",
                  iconDescription: '🧘',
                  entries: data.yoga
                      .map((y) =>
                          '🧘 ${y.name}\n⏱ ${_formatTime(y.start)} → ${_formatTime(y.end)}')
                      .toList(),
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfStardustWhite: pdfStardustWhite,
                  pdfLunarSilver: pdfLunarSilver,
                  contentFont: malayalamFont,
                  emojiFont: emojiFont,
                ),
              // PDF Auspicious Periods
              _buildPdfPeriodSection(
                title: "Auspicious Periods",
                iconDescription: '✅',
                periods: data.auspiciousPeriod,
                indicatorPdfColor: pdfGreenAuspicious,
                pdfCosmicBlue: pdfCosmicBlue,
                pdfCelestialGold: pdfCelestialGold,
                pdfStardustWhite: pdfStardustWhite,
                pdfLunarSilver: pdfLunarSilver,
                contentFont: malayalamFont,
                emojiFont: emojiFont,
              ),
              // PDF Inauspicious Periods
              _buildPdfPeriodSection(
                title: "Inauspicious Periods",
                iconDescription: '❌',
                periods: data.inauspiciousPeriod,
                indicatorPdfColor: pdfRedInauspicious,
                pdfCosmicBlue: pdfCosmicBlue,
                pdfCelestialGold: pdfCelestialGold,
                pdfStardustWhite: pdfStardustWhite,
                pdfLunarSilver: pdfLunarSilver,
                contentFont: malayalamFont,
                emojiFont: emojiFont,
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/panchang_report_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf');

      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)],
            text: 'Here is your Panchang Report!');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
      debugPrint(
          'Error generating PDF: $e'); // Use debugPrint for error logging
    }
  }

  // --- Helper for building PDF cards ---
  pw.Widget _buildPdfDetailCard({
    required String title,
    required String iconDescription,
    required List<String> entries,
    required PdfColor pdfCosmicBlue,
    required PdfColor pdfCelestialGold,
    required PdfColor pdfStardustWhite,
    required PdfColor pdfLunarSilver,
    required pw.Font contentFont,
    required pw.Font emojiFont,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: pdfCosmicBlue,
        borderRadius: pw.BorderRadius.circular(15),
        border: pw.Border.all(color: pdfCelestialGold, width: 1),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                iconDescription,
                style: pw.TextStyle(
                  font: emojiFont,
                  fontSize: 16,
                  color: pdfCelestialGold,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: pdfCelestialGold,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(color: pdfLunarSilver, height: 15, thickness: 0.5),
          ...entries
              .map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4.0),
                  child: pw.Text(
                    entry,
                    style: pw.TextStyle(
                      color: pdfStardustWhite,
                      fontSize: 14,
                      lineSpacing: 4,
                      font: contentFont,
                      fontFallback: [emojiFont, pw.Font.helvetica()],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // --- Helper for building PDF period sections (Auspicious/Inauspicious) ---
  pw.Widget _buildPdfPeriodSection({
    required String title,
    required String iconDescription,
    required List<Muhurta> periods,
    required PdfColor indicatorPdfColor,
    required PdfColor pdfCosmicBlue,
    required PdfColor pdfCelestialGold,
    required PdfColor pdfStardustWhite,
    required PdfColor pdfLunarSilver,
    required pw.Font contentFont,
    required pw.Font emojiFont,
  }) {
    if (periods.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: pdfCosmicBlue,
        borderRadius: pw.BorderRadius.circular(15),
        border: pw.Border.all(color: pdfCelestialGold, width: 1),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                iconDescription,
                style: pw.TextStyle(
                  font: emojiFont,
                  fontSize: 16,
                  color: pdfCelestialGold,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: pdfCelestialGold,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(color: pdfLunarSilver, height: 15, thickness: 0.5),
          ...periods.map((muhurta) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '✨ ${muhurta.name}:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: indicatorPdfColor,
                    fontSize: 14,
                    font: contentFont,
                    fontFallback: [emojiFont, pw.Font.helvetica()],
                  ),
                ),
                ...muhurta.period.map(
                  (p) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 15, bottom: 4.0),
                    child: pw.Text(
                      '⏱ ${_formatTime(p.start)} → ${_formatTime(p.end)}',
                      style: pw.TextStyle(
                        color: pdfStardustWhite,
                        fontSize: 14,
                        lineSpacing: 4,
                        font: contentFont,
                        fontFallback: [emojiFont, pw.Font.helvetica()],
                      ),
                    ),
                  ),
                ),
                if (muhurta.period.isNotEmpty && muhurta != periods.last)
                  pw.SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
