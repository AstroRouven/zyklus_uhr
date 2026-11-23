import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Debug-Schalter
const bool showDebugText = false;
const bool showDebugHotspots = false;

void main() => runApp(const CycleApp());

class CycleApp extends StatelessWidget {
  const CycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zyklus-Uhr',
      theme: ThemeData(useMaterial3: true),
      home: const BootScreen(),
    );
  }
}

/// ---------------------------
/// LOGIK: 12 Phasen à 56 Stunden
/// ---------------------------

const int kPhases = 12;
const int kHoursPerPhase = 56; // 2 Tage + 8 Stunden
const int kHoursPerCycle = kPhases * kHoursPerPhase; // 672

DateTime normalizeToMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

int internalPhaseIndex(DateTime start, DateTime atTime) {
  final diffHours = atTime.difference(start).inHours;
  final normalized = ((diffHours % kHoursPerCycle) + kHoursPerCycle) % kHoursPerCycle;
  return normalized ~/ kHoursPerPhase; // 0..11
}

double phaseProgress(DateTime start, DateTime atTime) {
  final diffMinutes = atTime.difference(start).inMinutes;
  final cycleMinutes = kHoursPerCycle * 60;
  final normalized = ((diffMinutes % cycleMinutes) + cycleMinutes) % cycleMinutes;
  final inPhase = normalized % (kHoursPerPhase * 60);
  return inPhase / (kHoursPerPhase * 60);
}

Duration timeToNextPhase(DateTime start, DateTime atTime) {
  final diffMinutes = atTime.difference(start).inMinutes;
  final cycleMinutes = kHoursPerCycle * 60;
  final normalized = ((diffMinutes % cycleMinutes) + cycleMinutes) % cycleMinutes;
  final inPhaseMinutes = normalized % (kHoursPerPhase * 60);
  final remaining = (kHoursPerPhase * 60) - inPhaseMinutes;
  return Duration(minutes: remaining);
}

/// DEIN Shift:
/// Intern 0 = Winterbeginn.
/// Du willst: Winterbeginn = Phase 10.
int displayedPhaseNumber(int internalIdx) {
  return ((internalIdx + 9) % 12) + 1; // 1..12
}

String p2(int n) => n.toString().padLeft(2, '0');

String clockAssetPath({required int displayedPhase, required bool isCurrentVariant}) {
  final p = p2(displayedPhase);
  return isCurrentVariant
      ? 'assets/clock/p${p}_current.png'
      : 'assets/clock/p${p}_preview.png';
}

List<String> categoryAssets({
  required String category, // female | male | rel
  required int displayedPhase,
}) {
  final p = p2(displayedPhase);
  final count = (category == 'male') ? 3 : 2;
  return List.generate(count, (i) => 'assets/$category/p${p}_$i.png');
}

/// ---------------------------
/// BOOT: Startdatum vorhanden?
/// ---------------------------

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  Future<DateTime?> _loadStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('startDateMillis');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final startDate = await _loadStartDate();
    if (!mounted) return;

    if (startDate == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetupScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeClockScreen(startDate: startDate)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// ---------------------------
/// SETUP: Datum wählen + speichern
/// ---------------------------

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  DateTime? selected;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selected ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() => selected = picked);
  }

  Future<void> _saveAndGo() async {
    if (selected == null) return;
    final midnight = normalizeToMidnight(selected!);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startDateMillis', midnight.millisecondsSinceEpoch);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeClockScreen(startDate: midnight)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startdatum setzen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Gib den Beginn der letzten Periode ein.\n(Uhrzeit wird auf 00:00 gesetzt.)',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pickDate,
              child: Text(selected == null ? 'Datum wählen' : 'Datum ändern'),
            ),
            const SizedBox(height: 12),
            Text(selected == null ? 'Kein Datum gewählt' : 'Gewählt: ${_fmtDate(selected!)}'),
            const Spacer(),
            FilledButton(
              onPressed: selected == null ? null : _saveAndGo,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------
/// HOME: Fullscreen Bild (contain) + Hotspots korrekt gemappt + optional Offset-Buttons
/// ---------------------------

class HomeClockScreen extends StatefulWidget {
  final DateTime startDate;
  const HomeClockScreen({super.key, required this.startDate});

  @override
  State<HomeClockScreen> createState() => _HomeClockScreenState();
}

class _HomeClockScreenState extends State<HomeClockScreen> {
  Duration offset = Duration.zero; // Zeitreise
  late DateTime viewTime;

  late int displayedPhase;
  late double progress;
  late Duration remaining;

  @override
  void initState() {
    super.initState();
    _recalc();
  }

  void _recalc() {
    viewTime = DateTime.now().add(offset);
    final internalIdx = internalPhaseIndex(widget.startDate, viewTime);
    displayedPhase = displayedPhaseNumber(internalIdx);
    progress = phaseProgress(widget.startDate, viewTime);
    remaining = timeToNextPhase(widget.startDate, viewTime);
    setState(() {});
  }

  void _addOffset(Duration d) {
    offset += d;
    _recalc();
  }

  void _resetOffset() {
    offset = Duration.zero;
    _recalc();
  }

  bool get isCurrentView => offset == Duration.zero;

  void _openCategory(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          category: category,
          frozenDisplayedPhase: displayedPhase,
          frozenAtTime: viewTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckPath = clockAssetPath(
      displayedPhase: displayedPhase,
      isCurrentVariant: isCurrentView,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zyklus-Uhr'),
        actions: [
          IconButton(onPressed: _recalc, icon: const Icon(Icons.refresh)),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
            child: const Text('Anpassen'),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Fullscreen (contain)
          Image.asset(deckPath, fit: BoxFit.contain),

          // ✅ Hotspots korrekt relativ zum "sichtbaren" Bildbereich bei contain
          _HotspotOverlay(
            onFemale: () => _openCategory('female'),
            onMale: () => _openCategory('male'),
            onRel: () => _openCategory('rel'),
          ),
          if (!isCurrentView)
  Positioned(
    top: 12,
    right: 12,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _fmtDate(viewTime),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    ),
  ),

          // Optional: Mini-Offset Buttons unten (kannst du später rauswerfen)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _miniBtn('-1 Tag', () => _addOffset(const Duration(days: -1))),
                _miniBtn('Jetzt', _resetOffset, filled: true),
                _miniBtn('+1 Tag', () => _addOffset(const Duration(days: 1))),
              ],
            ),
          ),

          // Debug-Text optional
          if (showDebugText)
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  'Phase $displayedPhase | Offset ${_fmtOffset(offset)} | ${(progress * 100).toStringAsFixed(0)}% | '
                  'Next ${remaining.inHours}h ${(remaining.inMinutes % 60)}m',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _miniBtn(String text, VoidCallback onTap, {bool filled = false}) {
  final child = Text(text);
  return filled
      ? FilledButton(onPressed: onTap, child: child)
      : OutlinedButton(onPressed: onTap, child: child);
}

/// ---------------------------
/// HOTSPOT OVERLAY (contain-aware)
/// ---------------------------

class _HotspotOverlay extends StatelessWidget {
  final VoidCallback onFemale;
  final VoidCallback onMale;
  final VoidCallback onRel;

  const _HotspotOverlay({
    required this.onFemale,
    required this.onMale,
    required this.onRel,
  });

  // Deine Originalbildgröße (Photoshop)
  static const double imgW = 1080;
  static const double imgH = 1920;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, c) {
          final screenW = c.maxWidth;
          final screenH = c.maxHeight;

          // BoxFit.contain: skaliert + zentriert
          final scale = (screenW / imgW < screenH / imgH) ? (screenW / imgW) : (screenH / imgH);
          final dispW = imgW * scale;
          final dispH = imgH * scale;
          final offsetX = (screenW - dispW) / 2;
          final offsetY = (screenH - dispH) / 2;

          Offset map(double x, double y) => Offset(offsetX + x * scale, offsetY + y * scale);

          final female = map(217, 186);
          final male = map(211, 1383);
          final rel = map(211, 1656);

          final diameter = 220 * scale;

          return Stack(
            children: [
              _CircleHotspot(center: female, diameter: diameter, onTap: onFemale, label: 'DIE FRAU ENTDECKEN', showRing: false),
              _CircleHotspot(center: male, diameter: diameter, onTap: onMale, label: 'DEN MANN ENTDECKEN'),
              _CircleHotspot(center: rel, diameter: diameter, onTap: onRel, label: 'DAS WIR ENTDECKEN'),
            ],
          );
        },
      ),
    );
  }
}

class _CircleHotspot extends StatelessWidget {
  final Offset center;
  final double diameter;
  final VoidCallback onTap;
  final String label;
  final bool showRing;

  const _CircleHotspot({
    required this.center,
    required this.diameter,
    required this.onTap,
    required this.label,
    this.showRing = true,
  });

  @override
  Widget build(BuildContext context) {
    // Das Label ragt unter den Bildkreis; die gesamte Fläche bleibt klickbar.
    final badgeHeight = (diameter * .27).clamp(19.0, 36.0);
    final badgeWidth = (diameter * 1.50).clamp(110.0, 190.0);
    final totalHeight = diameter + badgeHeight * .48;
    return Positioned(
      left: center.dx - badgeWidth / 2,
      top: center.dy - diameter / 2,
      width: badgeWidth,
      height: totalHeight,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(diameter),
            onTap: onTap,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (showRing) Positioned(
                  top: 0,
                  width: diameter,
                  height: diameter,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD878), width: 3),
                      // Kein Schatten: Ein transparenter Kreis mit BoxShadow
                      // würde die darunterliegende Illustration gelb überlagern.
                    ),
                    child: showDebugHotspots
                        ? Center(child: Text(label, style: const TextStyle(color: Colors.red)))
                        : null,
                  ),
                ),
                Positioned(
                  top: diameter - badgeHeight * .72,
                  child: Container(
                    width: badgeWidth * .91,
                    height: badgeHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFE9A2), Color(0xFFD49B32), Color(0xFFFFE39A)]),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFFFF1C3), width: 1),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(0, 2))],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(label, style: TextStyle(color: Colors.black, fontSize: (badgeHeight * .48).clamp(10.0, 15.0), fontWeight: FontWeight.w900)),
                            const Icon(Icons.chevron_right, size: 17, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gestrichelter Kreis (Debug)
class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = (size.shortestSide / 2) - 2;
    final center = Offset(size.width / 2, size.height / 2);

    const dash = 10.0;
    const gap = 6.0;
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dash + gap)).floor().clamp(12, 200);

    final step = 2 * 3.141592653589793 / dashCount;
    final dashAngle = step * (dash / (dash + gap));

    for (int i = 0; i < dashCount; i++) {
      final start = i * step;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------
/// CATEGORY: Freeze + Bilder blättern
/// ---------------------------

class CategoryScreen extends StatefulWidget {
  final String category; // female | male | rel
  final int frozenDisplayedPhase; // 1..12
  final DateTime frozenAtTime;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.frozenDisplayedPhase,
    required this.frozenAtTime,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<String> images;
  int index = 0;

  @override
  void initState() {
    super.initState();
    images = categoryAssets(
      category: widget.category,
      displayedPhase: widget.frozenDisplayedPhase,
    );
  }

  void _next() => setState(() => index = (index + 1) % images.length);
  void _prev() => setState(() => index = (index - 1 + images.length) % images.length);

  String get title => switch (widget.category) {
        'female' => 'Weiblicher Archetyp',
        'male' => 'Männlicher Archetyp',
        _ => 'Beziehungsarchetyp',
      };

  @override
  Widget build(BuildContext context) {
    final path = images[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('$title · Phase ${widget.frozenDisplayedPhase}/12'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(path, fit: BoxFit.contain),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _prev,
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _next,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(22)),
                    child: Text('${index + 1} von ${images.length}',
                      style: const TextStyle(color: Color(0xFFFFE0A0), fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0x80E7B751), // 50 % Deckkraft
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
                    ),
                    onPressed: index == images.length - 1
                        ? () => Navigator.of(context).pop()
                        : _next,
                    icon: Icon(index == images.length - 1 ? Icons.home_outlined : Icons.arrow_forward),
                    label: Text(index == images.length - 1 ? 'Zur Zyklusuhr' : 'Weiter'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------
/// HELPERS
/// ---------------------------

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String _fmtOffset(Duration d) {
  final sign = d.isNegative ? '-' : '+';
  final abs = d.abs();
  final h = abs.inHours;
  final m = abs.inMinutes % 60;
  return '$sign${h}h ${m}m';
}
