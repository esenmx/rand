import 'package:flutter/material.dart';
import 'package:rand/rand.dart';

void main() => runApp(const RandExampleApp());

class RandExampleApp extends StatelessWidget {
  const RandExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rand Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RandShowcase(),
    );
  }
}

class RandShowcase extends StatefulWidget {
  const RandShowcase({super.key});

  @override
  State<RandShowcase> createState() => _RandShowcaseState();
}

class _RandShowcaseState extends State<RandShowcase> {
  final _scrollController = ScrollController();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎲 Rand Package'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Generate new values',
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('🔢 Numbers', [
            _item('integer(max: 100)', '${Rand.integer(max: 100)}'),
            _item('float(max: 1)', Rand.float(max: 1).toStringAsFixed(4)),
            _item('boolean()', '${Rand.boolean()}'),
            _item('latitude()', '${Rand.latitude()}'),
            _item('longitude()', '${Rand.longitude()}'),
          ]),
          _buildSection('👤 Identity', [
            _item('firstName()', Rand.firstName()),
            _item('lastName()', Rand.lastName()),
            _item('fullName()', Rand.fullName()),
            _item('alias()', Rand.alias()),
            _item('city()', Rand.city()),
          ]),
          _buildSection('📝 Text', [
            _item('word()', Rand.word()),
            _item('words(count: 4)', Rand.words(count: 4)),
            _item('sentence()', Rand.sentence(), wrap: true),
          ]),
          _buildSection('🔐 Cryptographic', [
            _item('id()', Rand.id()),
            _item('nonce(24)', Rand.nonce(24)),
            _item('password()', Rand.password()),
            _item('password(symbols: false)', Rand.password(symbols: false)),
          ]),
          _buildSection('⏰ Time', [
            _item('dateTime()', Rand.dateTime().toString().split('.').first),
            _item(
              'duration(Duration(days: 30))',
              _formatDuration(Rand.duration(const Duration(days: 30))),
            ),
          ]),
          _buildColorSection(),
          _buildSection('📦 Collections', [
            _item(
              'element([1, 2, 3, 4, 5])',
              '${Rand.element([1, 2, 3, 4, 5])}',
            ),
            _item('subSet([1, 2, 3, 4, 5], 3)',
                '${Rand.subSet([1, 2, 3, 4, 5], 3)}'),
          ]),
          _buildSamplingSection(),
          _buildSection('🎯 Nullable', [
            _item('nullable("value")', Rand.nullable("value") ?? "null"),
            _item(
                'nullable("value", 90)', Rand.nullable("value", 90) ?? "null"),
          ]),
          const SizedBox(height: 32),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refresh,
        icon: const Icon(Icons.casino),
        label: const Text('Randomize'),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _item(String method, String value, {bool wrap = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
            wrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              method,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    final color = Rand.color();
    final dark = Rand.colorDark();
    final light = Rand.colorLight();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎨 Colors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _colorItem('color()', color),
            _colorItem('colorDark()', dark),
            _colorItem('colorLight()', light),
          ],
        ),
      ),
    );
  }

  Widget _colorItem(String method, CSSColors cssColor) {
    final flutterColor = Color(cssColor.color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              method,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: flutterColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(cssColor.name, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildSamplingSection() {
    final loot = Rand.sample(
      from: ['🌟 Legendary', '💎 Rare', '📦 Common'],
      count: 10,
      weights: [1, 10, 100],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚖️ Weighted Sampling',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'sample(from: [...], count: 10, weights: [1, 10, 100])',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: loot.map((item) {
                return Chip(
                  label: Text(item, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    return '${days}d ${hours}h ${minutes}m';
  }
}
