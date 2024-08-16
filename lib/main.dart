import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const PokemonBattle());
}

class PokemonBattle extends StatelessWidget {
  const PokemonBattle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Battle',
      home: BattleScreen(),
    );
  }
}

class BattleScreen extends StatefulWidget {
  @override
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  List<dynamic> _preloadedCards = [];
  String? _name1;
  String? _name2;
  int? _hp1;
  int? _hp2;
  String? _imageUrl1;
  String? _imageUrl2;
  bool _isLoading = true;
  bool _hasError = false;
  String? _winner;

  @override
  void initState() {
    super.initState();
    _preloadCards();
  }

  Future<void> _preloadCards() async {
    const url = 'https://api.pokemontcg.io/v2/cards';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _preloadedCards = data['data'];
          _isLoading = false;
        });
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    }
  }

  void _handleError() {
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }

  void _selectAndCompareCards() {
    if (_preloadedCards.isEmpty) return;

    final random = Random();
    final card1 = _preloadedCards[random.nextInt(_preloadedCards.length)];
    final card2 = _preloadedCards[random.nextInt(_preloadedCards.length)];

    setState(() {
      _name1 = card1['name'];
      _name2 = card2['name'];
      _hp1 = int.tryParse(card1['hp'] ?? '0') ?? 0;
      _hp2 = int.tryParse(card2['hp'] ?? '0') ?? 0;
      _imageUrl1 = card1['images']['small'];
      _imageUrl2 = card2['images']['small'];

      if (_hp1! > _hp2!) {
        _winner = _name1;
      } else if (_hp1! < _hp2!) {
        _winner = _name2;
      } else {
        _winner = null; 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Battle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? const Center(
                    child:
                        Text('Failed to load cards. Please try again later.'))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_name1 != null && _name2 != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Image.network(_imageUrl1!, width: 300),
                                const SizedBox(height: 15),
                                Text('$_name1 (HP: $_hp1)',
                                    style: const TextStyle(fontSize: 20)),
                                if (_winner == _name1)
                                  const Text('Winner',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Text('VS', style: TextStyle(fontSize: 24)),
                            Column(
                              children: [
                                Image.network(_imageUrl2!, width: 300),
                                const SizedBox(height: 15),
                                Text('$_name2 (HP: $_hp2)',
                                    style: const TextStyle(fontSize: 20)),
                                if (_winner == _name2)
                                  const Text('Winner',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_winner == null)
                          const Text('It\'s a tie!',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _preloadedCards.isEmpty
                            ? null
                            : _selectAndCompareCards,
                        child: const Text('Battle!'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
