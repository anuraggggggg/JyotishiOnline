import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../model/proKerla/planetPositionModel.dart';

class PlanetResultScreen extends StatelessWidget {
  final PlanetPositionModel planetData;

  const PlanetResultScreen({Key? key, required this.planetData}) : super(key: key);

  // UI colors (Flutter side)
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);

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
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFE3F2FD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
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
                                    fontSize: 20,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sync_alt, color: Colors.deepOrange, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Retrograde',
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 12),

                    // Details grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      children: [
                        _buildDetailItem('Longitude', planet.longitude.toStringAsFixed(2)),
                        _buildDetailItem('Degree', planet.degree.toStringAsFixed(2)),
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
        backgroundColor: celestialGold,
        foregroundColor: cosmicBlue,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.indigo.shade700),
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconMap[planetName] ?? Icons.help_outline,
        color: colorMap[planetName],
        size: 22,
      ),
    );
  }

  // ---------------- PDF Generation ----------------

  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Load a font that supports Malayalam (and Latin) — use it as the BASE font
      final ByteData mal = await rootBundle.load('assets/fonts/NotoSansMalayalam-Regular.ttf');
      final pw.Font baseFont = pw.Font.ttf(mal);

      // Optional: If you want Latin-only fallback for safety (not using fontFallback API),
      // you could also load NotoSans-Regular and just ignore it or switch manually if needed.
      // final pw.Font latin = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

      // Load Material Icons from your pubspec path
      pw.Font? materialIconsFont;
      try {
        final ByteData iconData = await rootBundle.load('assets/fonts/materialicons-regular.otf');
        materialIconsFont = pw.Font.ttf(iconData);
      } catch (e) {
        // Fallback to Helvetica if Material Icons fail (icons will be plain text)
        materialIconsFont = pw.Font.helvetica();
      }

      // Load logo (optional)
      pw.MemoryImage? logoImage;
      try {
        final ByteData imageBytes = await rootBundle.load('assets/images/finalLogo.png');
        logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
      } catch (_) {
        logoImage = null;
      }

      // Build a theme that uses Malayalam-capable font everywhere
      final theme = pw.ThemeData.withFont(
        base: baseFont,
        bold: baseFont,
        italic: baseFont,
        boldItalic: baseFont,
      );

      // Helpful PDF-side colors
      final PdfColor pdfIndigo800 = PdfColor.fromInt(Colors.indigo.shade800.value);
      final PdfColor pdfBlue50 = PdfColor.fromInt(const Color(0xFFE3F2FD).value);
      final PdfColor pdfGrey200 = PdfColor.fromInt(Colors.grey.shade200.value);
      final PdfColor pdfGrey300 = PdfColor.fromInt(Colors.grey.shade300.value);
      final PdfColor pdfIndigo700 = PdfColor.fromInt(Colors.indigo.shade700.value);
      final PdfColor pdfDeepOrange = PdfColor.fromInt(Colors.deepOrange.value);
      final PdfColor pdfOrange100 = PdfColor.fromInt(Colors.orange.shade100.value);

      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1.5 * PdfPageFormat.cm,
            marginTop: 1.5 * PdfPageFormat.cm,
            marginLeft: 2.0 * PdfPageFormat.cm,
            marginRight: 2.0 * PdfPageFormat.cm,
          ),
          build: (_) {
            final widgets = <pw.Widget>[];

            if (logoImage != null) {
              widgets.add(pw.Center(child: pw.Image(logoImage!, height: 40, width: 40)));
              widgets.add(pw.SizedBox(height: 15));
            }

            widgets.add(
              pw.Center(
                child: pw.Text(
                  'Planet Positions Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfIndigo800,
                  ),
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));

            for (final planet in planetData.planetPositions) {
              widgets.add(
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: pdfGrey200, width: 0.5),
                    gradient: pw.LinearGradient(
                      colors: [PdfColors.white, pdfBlue50],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header row
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(
                            children: [
                              _pdfPlanetIcon(planet.name, materialIconsFont, pdfIndigo800),
                              pw.SizedBox(width: 12),
                              pw.Text(
                                planet.name, // Malayalam names render correctly with baseFont
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: pdfIndigo800,
                                ),
                              ),
                            ],
                          ),
                          if (planet.isRetrograde)
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: pdfOrange100,
                                borderRadius: pw.BorderRadius.circular(12),
                              ),
                              child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Icon(
                                    pw.IconData(Icons.sync_alt.codePoint),
                                    color: pdfDeepOrange,
                                    size: 14,
                                    font: materialIconsFont,
                                  ),
                                  pw.SizedBox(width: 4),
                                  pw.Text(
                                    'Retrograde',
                                    style: pw.TextStyle(
                                      color: pdfDeepOrange,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      pw.SizedBox(height: 12),

                      pw.Divider(height: 1, color: pdfGrey300, thickness: 1),
                      pw.SizedBox(height: 12),

                      // Details table
                      pw.Table.fromTextArray(
                        headers: ['Property', 'Value'],
                        data: <List<String>>[
                          ['Longitude', planet.longitude.toStringAsFixed(2)],
                          ['Degree', planet.degree.toStringAsFixed(2)],
                          ['Position', planet.position.toString()],
                          // Malayalam rasi/lord names render fine now:
                          ['Rasi', '${planet.rasi.name} (${planet.rasi.lord.name})'],
                        ],
                        border: null,
                        headerStyle:  pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                        cellStyle: pw.TextStyle(
                          fontSize: 12,
                          color: pdfIndigo700,
                        ),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(1),
                          1: pw.FlexColumnWidth(2),
                        },
                        cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        headerDecoration: const pw.BoxDecoration(color: PdfColors.white),
                        rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                      ),
                    ],
                  ),
                ),
              );
            }

            return widgets;
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/planet_positions.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Your Planet Positions Report');
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  // Simpler PDF icon (no background shade/transparent needed)
  pw.Widget _pdfPlanetIcon(String planetName, pw.Font? materialIconsFont, PdfColor fallbackColor) {
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

    // map to PdfColor using Flutter Colors
    final Map<String, PdfColor> pdfColorMap = {
      'Sun': PdfColor.fromInt(Colors.amber.value),
      'Moon': PdfColor.fromInt(Colors.blue.value),
      'Mars': PdfColor.fromInt(Colors.red.value),
      'Mercury': PdfColor.fromInt(Colors.green.value),
      'Jupiter': PdfColor.fromInt(Colors.orange.value),
      'Venus': PdfColor.fromInt(Colors.pink.value),
      'Saturn': PdfColor.fromInt(Colors.indigo.value),
      'Rahu': PdfColor.fromInt(Colors.grey.value),
      'Ketu': PdfColor.fromInt(Colors.purple.value),
    };

    final PdfColor color = pdfColorMap[planetName] ?? fallbackColor;

    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Icon(
        pw.IconData(iconMap[planetName]?.codePoint ?? Icons.help_outline.codePoint),
        color: color,
        size: 18,
        font: materialIconsFont,
      ),
    );
  }
}
