import 'dart:io';
import 'dart:typed_data'; // For font loading
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For font loading
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../model/proKerla/planetPositionModel.dart'; // Ensure this path is correct

class PlanetResultScreen extends StatelessWidget {
  final PlanetPositionModel planetData;

  const PlanetResultScreen({Key? key, required this.planetData}) : super(key: key);

  // Define colors for the PDF, mirroring your Flutter UI colors
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color indigo800 = Color(0xFF1A237E); // Equivalent to Colors.indigo.shade800
  static const Color purple600 = Color(0xFF8E24AA); // Equivalent to Colors.purple.shade600
  static const Color grey600 = Color(0xFF757575); // Equivalent to Colors.grey.shade600
  static const Color indigo700 = Color(0xFF283593); // Equivalent to Colors.indigo.shade700
  static const Color orange100 = Color(0xFFFFF3E0); // Equivalent to Colors.orange.shade100
  static const Color deepOrange = Color(0xFFFF5722); // Equivalent to Colors.deepOrange

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planet Positions Result"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: planetData.planetPositions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final planet = planetData.planetPositions[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.blue.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Planet name with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              _getPlanetIcon(planet.name),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  planet.name,
                                  style: TextStyle(
                                    fontSize: 20, // Reduced from 22
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (planet.isRetrograde)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.sync_alt, color: Colors.deepOrange, size: 16),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Retrograde',
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12, // Reduced font size
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Divider with decoration
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                    const SizedBox(height: 12),

                    // Planet details in a grid with reduced spacing
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5, // Reduced from 3
                      crossAxisSpacing: 6, // Reduced from 8
                      mainAxisSpacing: 6, // Reduced from 8
                      children: [
                        _buildDetailItem('Longitude', planet.longitude.toString()),
                        _buildDetailItem('Degree', planet.degree.toString()),
                        _buildDetailItem('Position', planet.position.toString()),
                        _buildDetailItem('Rasi', '${planet.rasi.name} (${planet.rasi.lord.name})'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _generateAndSharePdf(context);
        },
        label: const Text('Download PDF'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: celestialGold, // Using celestialGold for consistency
        foregroundColor: cosmicBlue, // Using cosmicBlue for consistency
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13, // Reduced from 14
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15, // Reduced from 16
            fontWeight: FontWeight.w500,
            color: Colors.indigo.shade700,
          ),
        ),
      ],
    );
  }

  Widget _getPlanetIcon(String planetName) {
    final iconMap = {
      'Sun': Icons.wb_sunny,
      'Moon': Icons.nightlight_round,
      'Mars': Icons.fireplace,
      'Mercury': Icons.waves,
      'Jupiter': Icons.star,
      'Venus': Icons.favorite,
      'Saturn': Icons.ac_unit,
      'Rahu': Icons.cloud,
      'Ketu': Icons.flash_on,
    };

    final colorMap = {
      'Sun': Colors.amber,
      'Moon': Colors.blue,
      'Mars': Colors.red,
      'Mercury': Colors.green,
      'Jupiter': Colors.orange,
      'Venus': Colors.pink,
      'Saturn': Colors.indigo,
      'Rahu': Colors.grey,
      'Ketu': Colors.purple,
    };

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorMap[planetName]?.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconMap[planetName] ?? Icons.help_outline,
        color: colorMap[planetName],
        size: 22, // Reduced from 24
      ),
    );
  }

  // --- PDF Generation Logic ---
  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Convert your static colors to PdfColor for PDF styling
      final PdfColor pdfIndigo800 = PdfColor.fromInt(indigo800.value);
      final PdfColor pdfPurple600 = PdfColor.fromInt(purple600.value);
      final PdfColor pdfWhite = PdfColors.white;
      final PdfColor pdfBlue50 = PdfColor.fromInt(Colors.blue.shade50.value);
      final PdfColor pdfGrey600 = PdfColor.fromInt(grey600.value);
      final PdfColor pdfIndigo700 = PdfColor.fromInt(indigo700.value);
      final PdfColor pdfOrange100 = PdfColor.fromInt(orange100.value);
      final PdfColor pdfDeepOrange = PdfColor.fromInt(deepOrange.value);

      // Load Material Icons font
      pw.Font? materialIconsFont;
      try {
        final ByteData fontData = await rootBundle.load('fonts/MaterialIcons-Regular.ttf');
        materialIconsFont = pw.Font.ttf(fontData);
      } catch (e) {
        debugPrint('Failed to load MaterialIcons font for PDF: $e. Falling back to default.');
        materialIconsFont = pw.Font.helvetica(); // Fallback
      }

      final ByteData imageBytes = await rootBundle.load('assets/images/finalLogo.png');
      final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1.5 * PdfPageFormat.cm,
            marginTop: 1.5 * PdfPageFormat.cm,
            marginLeft: 2.0 * PdfPageFormat.cm,
            marginRight: 2.0 * PdfPageFormat.cm,
          ),
          build: (pw.Context pwContext) {
            List<pw.Widget> content = [];

            content.add(
              pw.Center(
                child: pw.Image(logoImage, height: 40, width: 40), // Adjust size as needed
              ),
            );
            content.add(pw.SizedBox(height: 15));

            content.add(
              pw.Center(
                child: pw.Text(
                  'Planet Positions Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfIndigo800,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
              ),
            );
            content.add(pw.SizedBox(height: 20));

            for (final planet in planetData.planetPositions) {
              content.add(
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.grey200, width: 0.5), // Subtle border
                    gradient: pw.LinearGradient(
                      colors: [
                        pdfWhite,
                        pdfBlue50,
                      ],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  margin: const pw.EdgeInsets.only(bottom: 12), // Spacing between planet cards
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Planet name with icon
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Flexible(
                            child: pw.Row(
                              children: [
                                _getPdfPlanetIcon(planet.name, materialIconsFont),
                                pw.SizedBox(width: 12),
                                pw.Flexible(
                                  child: pw.Text(
                                    planet.name,
                                    style: pw.TextStyle(
                                      fontSize: 18, // Adjusted for PDF
                                      fontWeight: pw.FontWeight.bold,
                                      color: pdfIndigo800,
                                      font: pw.Font.helveticaBold(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (planet.isRetrograde)
                            pw.Flexible(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  color: pdfOrange100,
                                  borderRadius: pw.BorderRadius.circular(12),
                                ),
                                child: pw.Row(
                                  mainAxisSize: pw.MainAxisSize.min,
                                  children: [
                                    pw.Icon(pw.IconData(Icons.sync_alt.codePoint), color: pdfDeepOrange, size: 14, font: materialIconsFont),
                                    pw.SizedBox(width: 4),
                                    pw.Flexible(
                                      child: pw.Text(
                                        'Retrograde',
                                        style: pw.TextStyle(
                                          color: pdfDeepOrange,
                                          fontWeight: pw.FontWeight.bold, // Use bold for emphasis
                                          fontSize: 10, // Adjusted for PDF
                                          font: pw.Font.helvetica(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      pw.SizedBox(height: 12),

                      // Divider
                      pw.Divider(
                        height: 1,
                        color: PdfColors.grey300,
                        thickness: 1,
                      ),
                      pw.SizedBox(height: 12),

                      // Planet details in a table for better alignment in PDF
                      pw.Table.fromTextArray(
                        headers: ['Property', 'Value'],
                        data: <List<String>>[
                          ['Longitude', planet.longitude.toStringAsFixed(2)], // Format to 2 decimal places
                          ['Degree', planet.degree.toStringAsFixed(2)],
                          ['Position', planet.position.toString()],
                          ['Rasi', '${planet.rasi.name} (${planet.rasi.lord.name})'],
                        ],
                        border: null, // No border for the table itself
                        headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: pdfGrey600,
                          font: pw.Font.helveticaBold(),
                        ),
                        cellStyle: pw.TextStyle(
                          fontSize: 12,
                          color: pdfIndigo700,
                          font: pw.Font.helvetica(),
                        ),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1), // Property column
                          1: const pw.FlexColumnWidth(2), // Value column
                        },
                        cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        headerDecoration: const pw.BoxDecoration(color: PdfColors.white), // No header background
                        rowDecoration: const pw.BoxDecoration(color: PdfColors.white), // No row background
                      ),
                    ],
                  ),
                ),
              );
            }
            return content;
          },
        ),
      );

      // Save and share the PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/planet_positions.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Your Planet Positions Report');
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
        );
      }
    }
  }

  // Helper function to get PDF-compatible planet icon
  pw.Widget _getPdfPlanetIcon(String planetName, pw.Font? materialIconsFont) {
    final iconMap = {
      'Sun': Icons.wb_sunny,
      'Moon': Icons.nightlight_round,
      'Mars': Icons.fireplace,
      'Mercury': Icons.waves,
      'Jupiter': Icons.star,
      'Venus': Icons.favorite,
      'Saturn': Icons.ac_unit,
      'Rahu': Icons.cloud,
      'Ketu': Icons.flash_on,
    };

    final colorMap = {
      'Sun': PdfColors.amber,
      'Moon': PdfColors.blue,
      'Mars': PdfColors.red,
      'Mercury': PdfColors.green,
      'Jupiter': PdfColors.orange,
      'Venus': PdfColors.pink,
      'Saturn': PdfColors.indigo,
      'Rahu': PdfColors.grey,
      'Ketu': PdfColors.purple,
    };

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: colorMap[planetName]?.shade(200), // Using shade for lighter background
        shape: pw.BoxShape.circle,
      ),
      child: pw.Icon(
        pw.IconData(iconMap[planetName]?.codePoint ?? Icons.help_outline.codePoint),
        color: colorMap[planetName],
        size: 20, // Adjusted size for PDF
        font: materialIconsFont,
      ),
    );
  }
}