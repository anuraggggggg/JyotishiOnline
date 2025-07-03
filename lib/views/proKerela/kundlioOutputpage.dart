import 'dart:io';
import 'dart:typed_data'; // For font loading
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For font loading
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // For Flutter UI text
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/proKerela/detailed_kundli_controller.dart';
import '../../model/proKerla/detailedKundliModel.dart';

class DetailedKundliResultScreen extends StatelessWidget {
  final DetailedKundliController controller = Get.find<DetailedKundliController>();

  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 25;



    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Your Detailed Kundli',
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              darkAccent,
              mediumAccent,
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: topPadding),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: celestialGold),
              );
            } else if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: _buildErrorWidget(controller.errorMessage.value),
              );
            } else if (controller.kundliData.value == null || controller.kundliData.value!.data == null) {
              return Center(
                child: Text(
                  'No Kundli data available. Please generate from the input screen.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: stardustWhite),
                ),
              );
            } else {
              final kundliDataContent = controller.kundliData.value!.data!;
              final nakshatraDetails = kundliDataContent.nakshatraDetails;
              final mangalDosha = kundliDataContent.mangalDosha;
              final chandraRasi = nakshatraDetails?.chandraRasi;
              final sooryaRasi = nakshatraDetails?.sooryaRasi;
              final zodiac = nakshatraDetails?.zodiac;
              final additionalInfo = nakshatraDetails?.additionalInfo;
              final yogaDetails = kundliDataContent.yogaDetails;
              final dashaBalance = kundliDataContent.dashaBalance;
              final dashaPeriods = kundliDataContent.dashaPeriods;

              return SingleChildScrollView(
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: celestialGold.withOpacity(0.8), width: 2),
                  ),
                  color: cosmicBlue.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Your Detailed Kundli',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: celestialGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (nakshatraDetails != null && nakshatraDetails.nakshatra != null) ...[
                          _buildSectionTitle('Nakshatra Details', Icons.star_border),
                          _buildDetailRow('Name:', nakshatraDetails.nakshatra!.name ?? 'N/A'),
                          _buildDetailRow('Pada:', nakshatraDetails.nakshatra!.pada?.toString() ?? 'N/A'),
                          _buildDetailRow('Lord:', nakshatraDetails.nakshatra!.lord?.name ?? 'N/A'),
                          const SizedBox(height: 20),
                        ],

                        if (chandraRasi != null) ...[
                          _buildSectionTitle('Chandra Rasi', Icons.nightlight_round),
                          _buildDetailRow('Name:', chandraRasi.name ?? 'N/A'),
                          _buildDetailRow('Lord:', chandraRasi.lord?.name ?? 'N/A'),
                          const SizedBox(height: 20),
                        ],

                        if (sooryaRasi != null) ...[
                          _buildSectionTitle('Soorya Rasi', Icons.wb_sunny_rounded),
                          _buildDetailRow('Name:', sooryaRasi.name ?? 'N/A'),
                          _buildDetailRow('Lord:', sooryaRasi.lord?.name ?? 'N/A'),
                          const SizedBox(height: 20),
                        ],

                        if (zodiac != null) ...[
                          _buildSectionTitle('Zodiac Sign', Icons.architecture),
                          _buildDetailRow('Name:', zodiac.name ?? 'N/A'),
                          const SizedBox(height: 20),
                        ],

                        if (additionalInfo != null) ...[
                          _buildSectionTitle('Additional Information', Icons.info_outline),
                          _buildDetailRow('Deity:', additionalInfo.deity ?? 'N/A'),
                          _buildDetailRow('Ganam:', additionalInfo.ganam ?? 'N/A'),
                          _buildDetailRow('Symbol:', additionalInfo.symbol ?? 'N/A'),
                          _buildDetailRow('Animal Sign:', additionalInfo.animalSign ?? 'N/A'),
                          _buildDetailRow('Nadi:', additionalInfo.nadi ?? 'N/A'),
                          _buildDetailRow('Color:', additionalInfo.color ?? 'N/A'),
                          _buildDetailRow('Best Direction:', additionalInfo.bestDirection ?? 'N/A'),
                          _buildDetailRow('Birth Stone:', additionalInfo.birthStone ?? 'N/A'),
                          _buildDetailRow('Gender:', additionalInfo.gender ?? 'N/A'),
                          _buildDetailRow('Planet:', additionalInfo.planet ?? 'N/A'),
                          _buildDetailRow('Enemy Yoni:', additionalInfo.enemyYoni ?? 'N/A'),
                          _buildDetailRow('Syllables:', additionalInfo.syllables ?? 'N/A'),
                          const SizedBox(height: 20),
                        ],

                        if (mangalDosha != null) ...[
                          _buildSectionTitle('Mangal Dosha', Icons.fireplace),
                          _buildDetailRow('Has Dosha:', mangalDosha.hasDosha == true ? 'Yes' : 'No'),
                          _buildDetailRow('Type:', mangalDosha.type?.toString() ?? 'N/A'),
                          _buildDescriptionText(mangalDosha.description),
                          if (mangalDosha.exceptions != null && mangalDosha.exceptions!.isNotEmpty)
                            _buildListSection('Exceptions:', mangalDosha.exceptions!.map((e) => e.toString()).toList()),
                          if (mangalDosha.remedies != null && mangalDosha.remedies!.isNotEmpty)
                            _buildListSection('Remedies:', mangalDosha.remedies!.map((e) => e.toString()).toList()),
                          const SizedBox(height: 20),
                        ],

                        if (yogaDetails != null && yogaDetails.isNotEmpty) ...[
                          _buildSectionTitle('Yoga Details', Icons.self_improvement),
                          ...yogaDetails.map((yoga) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSubSectionTitle(yoga.name),
                              _buildDescriptionText(yoga.description),
                              if (yoga.yogaList != null && yoga.yogaList!.isNotEmpty)
                                ...yoga.yogaList!.map((yogaItem) => Padding(
                                  padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        yogaItem.name ?? 'Unnamed Yoga',
                                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: stardustWhite.withOpacity(0.9)),
                                      ),
                                      if (yogaItem.description != null)
                                        Text(
                                          yogaItem.description!,
                                          style: GoogleFonts.poppins(fontSize: 14, color: lunarSilver),
                                        ),
                                    ],
                                  ),
                                )).toList(),
                              const SizedBox(height: 10),
                            ],
                          )).toList(),
                          const SizedBox(height: 20),
                        ],

                        if (dashaBalance != null) ...[
                          _buildSectionTitle('Dasha Balance', Icons.timeline),
                          _buildDetailRow('Lord:', dashaBalance.lord?.name ?? 'N/A'),
                          _buildDetailRow('Duration:', dashaBalance.duration ?? 'N/A'),
                          _buildDescriptionText(dashaBalance.description),
                          const SizedBox(height: 20),
                        ],

                        if (dashaPeriods != null && dashaPeriods.isNotEmpty) ...[
                          _buildSectionTitle('Dasha Periods', Icons.hourglass_empty),
                          // Limit Dasha periods to display in UI for brevity
                          ...dashaPeriods.take(3).map((dasha) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSubSectionTitle('${dasha.name} Dasha (${dasha.start} - ${dasha.end})'),
                              if (dasha.antardasha != null && dasha.antardasha!.isNotEmpty)
                                Text('  Antardasha:', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: stardustWhite.withOpacity(0.8))),
                              // Limit Antardasha periods to display in UI for brevity
                              if (dasha.antardasha != null && dasha.antardasha!.isNotEmpty)
                                ...dasha.antardasha!.take(2).map((antar) => Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text('  - ${antar.name} (${antar.start} - ${antar.end})', style: GoogleFonts.poppins(fontSize: 14, color: lunarSilver)),
                                )).toList(),
                              if (dasha.antardasha != null && dasha.antardasha!.length > 2)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text('...and ${dasha.antardasha!.length - 2} more antardashas', style: GoogleFonts.poppins(fontSize: 13, color: lunarSilver)),
                                ),
                              const SizedBox(height: 8),
                            ],
                          )).toList(),
                          if (dashaPeriods.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text('...and ${dashaPeriods.length - 3} more Dasha periods', style: GoogleFonts.poppins(fontSize: 14, color: lunarSilver, fontStyle: FontStyle.italic)),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
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

  // --- Helper Widgets for consistent styling (Flutter UI) ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Column(
      children: [
        const Divider(height: 30, thickness: 1.5, color: celestialGold),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: celestialGold, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: celestialGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSubSectionTitle(String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: stardustWhite,
          decoration: TextDecoration.underline,
          decorationColor: celestialGold.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: stardustWhite.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: stardustWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText(String? description) {
    if (description == null || description.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        description,
        style: GoogleFonts.poppins(fontSize: 15, color: lunarSilver, fontStyle: FontStyle.italic),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: stardustWhite.withOpacity(0.9),
            ),
          ),
        ),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
          child: Text(
            '• $item',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: stardustWhite,
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: warningRed, size: 48),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: stardustWhite),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: celestialGold,
              foregroundColor: cosmicBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Go Back', style: GoogleFonts.poppins(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // --- PDF Generation Logic ---

  // Helper function to check if a string contains Malayalam characters
  bool _isMalayalam(String text) {
    // Unicode range for Malayalam script: U+0D00 to U+0D7F
    final malRe = RegExp(r'[\u0D00-\u0D7F]');
    return malRe.hasMatch(text);
  }

  // Helper function to check if a string contains Tamil characters
  bool _isTamil(String text) {
    // Unicode range for Tamil script: U+0B80 to U+0BFF
    final tamRe = RegExp(r'[\u0B80-\u0BFF]');
    return tamRe.hasMatch(text);
  }

  // Helper function to determine the script of the text and return the appropriate font
  pw.Font? _getFontForText(String text, pw.Font? defaultFont, pw.Font? malayalamFont, pw.Font? tamilFont) {
    if (_isMalayalam(text) && malayalamFont != null) {
      return malayalamFont;
    } else if (_isTamil(text) && tamilFont != null) {
      return tamilFont;
    }
    return defaultFont; // Fallback to default for English or other scripts
  }


  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Convert your static colors to PdfColor
      final PdfColor pdfCosmicBlue = PdfColor.fromInt(cosmicBlue.value);
      final PdfColor pdfCelestialGold = PdfColor.fromInt(celestialGold.value);
      // Changed text colors to darker shades for better readability
      final PdfColor pdfDarkText = PdfColors.black; // Dark text color for labels and important info
      final PdfColor pdfMediumGrey = PdfColors.grey700; // Slightly lighter for descriptions


      // Fetch the Kundli data safely
      final kundliData = controller.kundliData.value?.data;
      if (kundliData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No Kundli data available to generate PDF.')),
          );
        }
        return;
      }

      // --- Font Loading for PDF ---
      // Load a general font for English/Latin text
      pw.Font? defaultTextFont;
      try {
        final ByteData notoFontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        defaultTextFont = pw.Font.ttf(notoFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSans-Regular font for PDF: $e. Falling back to Helvetica.');
        defaultTextFont = pw.Font.helvetica(); // Fallback
      }

      // Load Malayalam font
      pw.Font? malayalamFont;
      try {
        final ByteData malayalamFontData = await rootBundle.load('assets/fonts/NotoSansMalayalam-Regular.ttf');
        malayalamFont = pw.Font.ttf(malayalamFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSansMalayalam-Regular font for PDF: $e. Malayalam text might not render correctly.');
        malayalamFont = defaultTextFont; // Fallback to default if Malayalam font fails to load
      }

      // Load Tamil font
      pw.Font? tamilFont;
      try {
        final ByteData tamilFontData = await rootBundle.load('assets/fonts/NotoSansTamil-Regular.ttf');
        tamilFont = pw.Font.ttf(tamilFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSansTamil-Regular font for PDF: $e. Tamil text might not render correctly.');
        tamilFont = defaultTextFont; // Fallback to default if Tamil font fails to load
      }

      // Material Icons font is no longer needed since icons are removed from PDF
      // pw.Font? materialIconsFont;
      // try {
      //   final ByteData materialIconFontData = await rootBundle.load('assets/fonts/MaterialIcons-Regular.ttf');
      //   materialIconsFont = pw.Font.ttf(materialIconFontData);
      // } catch (e) {
      //   debugPrint('Failed to load MaterialIcons font for PDF: $e. Falling back to default.');
      //   materialIconsFont = pw.Font.helvetica(); // Fallback for icons
      // }
      // --- END Font Loading ---

      // --- Load the finalLogo.png image ---
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
          maxPages: 200,
          build: (pw.Context pwContext) {
            return [
              pw.Center(
                child:  pw.Image(logoImage, height: 40, width: 40),
              ),

              // --- Combined Logo and Title in a Row, centered ---
              pw.Center(
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min, // Keep the row compact
                  crossAxisAlignment: pw.CrossAxisAlignment.center, // Vertically align items
                  children: [
                  // Adjust size here for the logo
                    pw.SizedBox(width: 10), // Space between logo and text
                    pw.Text(
                      'Detailed Kundli Report', // Changed title text
                      style: pw.TextStyle(
                        fontSize: 26, // Increased font size for prominence
                        fontWeight: pw.FontWeight.bold,
                        color: pdfCosmicBlue,
                        font: defaultTextFont,
                      ),
                    ),
                  ],
                ),
              ),
              // --- End of combined Logo and Title ---

              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated on: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    font: defaultTextFont, // Use default
                  ),
                ),
              ),
              pw.SizedBox(height: 25),

              // --- Kundli Data Sections ---
              if (kundliData.nakshatraDetails != null && kundliData.nakshatraDetails!.nakshatra != null)
                _buildPdfSection(
                  title: 'Nakshatra Details',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText, // Using darker text color
                  pdfMediumGrey: pdfMediumGrey, // Using darker grey for descriptions
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Name:', kundliData.nakshatraDetails!.nakshatra!.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Pada:', kundliData.nakshatraDetails!.nakshatra!.pada?.toString() ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Lord:', kundliData.nakshatraDetails!.nakshatra!.lord?.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Chandra Rasi
              if (kundliData.nakshatraDetails?.chandraRasi != null)
                _buildPdfSection(
                  title: 'Chandra Rasi',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Name:', kundliData.nakshatraDetails!.chandraRasi!.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Lord:', kundliData.nakshatraDetails!.chandraRasi!.lord?.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Soorya Rasi
              if (kundliData.nakshatraDetails?.sooryaRasi != null)
                _buildPdfSection(
                  title: 'Soorya Rasi',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Name:', kundliData.nakshatraDetails!.sooryaRasi!.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Lord:', kundliData.nakshatraDetails!.sooryaRasi!.lord?.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Zodiac
              if (kundliData.nakshatraDetails?.zodiac != null)
                _buildPdfSection(
                  title: 'Zodiac Sign',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Name:', kundliData.nakshatraDetails!.zodiac!.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Additional Info
              if (kundliData.nakshatraDetails?.additionalInfo != null)
                _buildPdfSection(
                  title: 'Additional Information',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Deity:', kundliData.nakshatraDetails!.additionalInfo!.deity ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Ganam:', kundliData.nakshatraDetails!.additionalInfo!.ganam ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Symbol:', kundliData.nakshatraDetails!.additionalInfo!.symbol ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Animal Sign:', kundliData.nakshatraDetails!.additionalInfo!.animalSign ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Nadi:', kundliData.nakshatraDetails!.additionalInfo!.nadi ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Color:', kundliData.nakshatraDetails!.additionalInfo!.color ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Best Direction:', kundliData.nakshatraDetails!.additionalInfo!.bestDirection ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Birth Stone:', kundliData.nakshatraDetails!.additionalInfo!.birthStone ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Gender:', kundliData.nakshatraDetails!.additionalInfo!.gender ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Planet:', kundliData.nakshatraDetails!.additionalInfo!.planet ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Enemy Yoni:', kundliData.nakshatraDetails!.additionalInfo!.enemyYoni ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Syllables:', kundliData.nakshatraDetails!.additionalInfo!.syllables ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Mangal Dosha
              if (kundliData.mangalDosha != null)
                _buildPdfSection(
                  title: 'Mangal Dosha',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Has Dosha:', kundliData.mangalDosha!.hasDosha == true ? 'Yes' : 'No', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Type:', kundliData.mangalDosha!.type?.toString() ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDescriptionText(kundliData.mangalDosha!.description, pdfMediumGrey, defaultTextFont, malayalamFont, tamilFont),
                    if (kundliData.mangalDosha!.exceptions != null && kundliData.mangalDosha!.exceptions!.isNotEmpty)
                      _buildPdfListSection('Exceptions:', kundliData.mangalDosha!.exceptions!.map((e) => e.toString()).toList(), pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    if (kundliData.mangalDosha!.remedies != null && kundliData.mangalDosha!.remedies!.isNotEmpty)
                      _buildPdfListSection('Remedies:', kundliData.mangalDosha!.remedies!.map((e) => e.toString()).toList(), pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Yoga Details
              if (kundliData.yogaDetails != null && kundliData.yogaDetails!.isNotEmpty)
                _buildPdfSection(
                  title: 'Yoga Details',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    for (var yoga in kundliData.yogaDetails!)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfSubSectionTitle(yoga.name, pdfDarkText, pdfCelestialGold, defaultTextFont, malayalamFont, tamilFont),
                          _buildPdfDescriptionText(yoga.description, pdfMediumGrey, defaultTextFont, malayalamFont, tamilFont),
                          if (yoga.yogaList != null && yoga.yogaList!.isNotEmpty)
                            for (var yogaItem in yoga.yogaList!)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 10.0, bottom: 2.0),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      yogaItem.name ?? 'Unnamed Yoga',
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                        color: pdfDarkText,
                                        font: _getFontForText(yogaItem.name ?? '', defaultTextFont, malayalamFont, tamilFont),
                                      ),
                                    ),
                                    if (yogaItem.description != null)
                                      pw.Text(
                                        yogaItem.description!,
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: pdfMediumGrey,
                                          font: _getFontForText(yogaItem.description!, defaultTextFont, malayalamFont, tamilFont),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          pw.SizedBox(height: 5),
                        ],
                      ),
                  ],
                ),

              // Dasha Balance
              if (kundliData.dashaBalance != null)
                _buildPdfSection(
                  title: 'Dasha Balance',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    _buildPdfDetailRow('Lord:', kundliData.dashaBalance!.lord?.name ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDetailRow('Duration:', kundliData.dashaBalance!.duration ?? 'N/A', pdfDarkText, defaultTextFont, malayalamFont, tamilFont),
                    _buildPdfDescriptionText(kundliData.dashaBalance!.description, pdfMediumGrey, defaultTextFont, malayalamFont, tamilFont),
                  ],
                ),

              // Dasha Periods
              if (kundliData.dashaPeriods != null && kundliData.dashaPeriods!.isNotEmpty)
                _buildPdfSection(
                  title: 'Dasha Periods',
                  pdfCosmicBlue: pdfCosmicBlue,
                  pdfCelestialGold: pdfCelestialGold,
                  pdfDarkText: pdfDarkText,
                  pdfMediumGrey: pdfMediumGrey,
                  textFont: defaultTextFont,
                  children: [
                    for (var dasha in kundliData.dashaPeriods!.take(10))
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfSubSectionTitle(
                            '${dasha.name} Dasha (${dasha.start} - ${dasha.end})',
                            pdfDarkText,
                            pdfCelestialGold,
                            defaultTextFont,
                            malayalamFont,
                            tamilFont,
                          ),
                          if (dasha.antardasha != null && dasha.antardasha!.isNotEmpty)
                            pw.Text('  Antardasha:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: pdfDarkText.shade(0.8), font: defaultTextFont)),
                          if (dasha.antardasha != null && dasha.antardasha!.isNotEmpty)
                            for (var antar in dasha.antardasha!.take(5))
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 12.0),
                                child: pw.Text(
                                  '  - ${antar.name} (${antar.start} - ${antar.end})',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: pdfMediumGrey,
                                    font: _getFontForText(antar.name ?? '', defaultTextFont, malayalamFont, tamilFont),
                                  ),
                                ),
                              ),
                          if (dasha.antardasha != null && dasha.antardasha!.length > 5)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 12.0),
                              child: pw.Text(
                                '...and ${dasha.antardasha!.length - 5} more antardashas',
                                style: pw.TextStyle(fontSize: 9, color: pdfMediumGrey, fontStyle: pw.FontStyle.italic, font: defaultTextFont),
                              ),
                            ),
                          pw.SizedBox(height: 4),
                        ],
                      ),
                    if (kundliData.dashaPeriods!.length > 10)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 8.0),
                        child: pw.Text(
                          '...and ${kundliData.dashaPeriods!.length - 10} more Dasha periods',
                          style: pw.TextStyle(fontSize: 10, color: pdfMediumGrey, fontStyle: pw.FontStyle.italic, font: defaultTextFont),
                        ),
                      ),
                  ],
                ),
            ];
          },
        ),
      );

      // Save and share the PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/detailed_kundli.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Your Detailed Kundli Report');
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (e.toString().contains('TooManyPagesException')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF generation failed: Content exceeds maximum page limit. Try reducing the data displayed or further optimizing spacing.')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
          );
        }
      }
    }
  }

  // --- Helper Widgets for PDF generation (pw.Widget) ---
  // Updated: All text-related helpers now accept 'textFont' and use it.
  // Modified to accept multiple fonts and try to render based on content script.

  pw.Widget _buildPdfSection({
    required String title,
    // Removed IconData icon parameter as icons are being removed from PDF
    required PdfColor pdfCosmicBlue,
    required PdfColor pdfCelestialGold,
    required PdfColor pdfDarkText, // Changed parameter name for clarity
    required PdfColor pdfMediumGrey, // Changed parameter name for clarity
    // Removed materialIconsFont parameter
    required pw.Font? textFont,
    required List<pw.Widget> children,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(height: 15, thickness: 1.5, color: pdfCelestialGold),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            // Removed pw.Icon widget
            // pw.Icon(pw.IconData(icon.codePoint), color: pdfCelestialGold, size: 24, font: materialIconsFont),
            // pw.SizedBox(width: 8), // Removed SizedBox if no icon is present
            pw.Flexible(
              child: pw.Text(
                title,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfCelestialGold,
                  font: textFont,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        ...children,
        pw.SizedBox(height: 15),
      ],
    );
  }

  pw.Widget _buildPdfSubSectionTitle(String? title, PdfColor textColor, PdfColor highlightColor, pw.Font? defaultFont, pw.Font? malayalamFont, pw.Font? tamilFont) {
    if (title == null || title.isEmpty) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
          color: textColor, // Using the passed textColor
          decoration: pw.TextDecoration.underline,
          decorationColor: highlightColor.shade(0.5), // Using the passed highlightColor
          font: _getFontForText(title, defaultFont, malayalamFont, tamilFont),
        ),
        textDirection: _isMalayalam(title) || _isTamil(title) ? pw.TextDirection.ltr : pw.TextDirection.ltr, // Explicit LTR for Indic scripts
      ),
    );
  }

  pw.Widget _buildPdfDetailRow(String label, String value, PdfColor textColor, pw.Font? defaultFont, pw.Font? malayalamFont, pw.Font? tamilFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: textColor.shade(0.9), // Using the passed textColor
              font: defaultFont,
            ),
          ),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                color: textColor, // Using the passed textColor
                font: _getFontForText(value, defaultFont, malayalamFont, tamilFont),
              ),
              textDirection: _isMalayalam(value) || _isTamil(value) ? pw.TextDirection.ltr : pw.TextDirection.ltr, // Explicit LTR for Indic scripts
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDescriptionText(String? description, PdfColor textColor, pw.Font? defaultFont, pw.Font? malayalamFont, pw.Font? tamilFont) {
    if (description == null || description.isEmpty) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Text(
        description,
        style: pw.TextStyle(fontSize: 11, color: textColor, fontStyle: pw.FontStyle.italic, font: _getFontForText(description, defaultFont, malayalamFont, tamilFont)),
        textAlign: pw.TextAlign.justify,
        textDirection: _isMalayalam(description) || _isTamil(description) ? pw.TextDirection.ltr : pw.TextDirection.ltr, // Explicit LTR for Indic scripts
      ),
    );
  }

  pw.Widget _buildPdfListSection(String title, List<String> items, PdfColor textColor, pw.Font? defaultFont, pw.Font? malayalamFont, pw.Font? tamilFont) {
    if (items.isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: textColor.shade(1), // Using the passed textColor
              font: defaultFont,
            ),
          ),
        ),
        ...items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12.0, bottom: 2.0),
          child: pw.Text(
            '• $item',
            style: pw.TextStyle(
              fontSize: 11,
              color: textColor, // Using the passed textColor
              font: _getFontForText(item, defaultFont, malayalamFont, tamilFont),
            ),
            textDirection: _isMalayalam(item) || _isTamil(item) ? pw.TextDirection.ltr : pw.TextDirection.ltr, // Explicit LTR for Indic scripts
          ),
        )).toList(),
      ],
    );
  }
}