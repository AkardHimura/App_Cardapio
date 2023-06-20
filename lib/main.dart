import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(RestauranteApp());
}

class RestauranteApp extends StatelessWidget {
  final List<Item> itens = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurante App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Cardápio')),
        body: FutureBuilder(
          future: loadMenu(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text("Erro ao carregar o cardápio.");
              }
              return ListView.builder(
                itemCount: itens.length,
                itemBuilder: (context, index) {
                  final item = itens[index];
                  return ListTile(
                    title: Text(
                      item.nome,
                      style: TextStyle(
                        color: item.cor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(item.descricao),
                    trailing: Text(
                      currencyFormatter.format(item.preco),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesPedidoPage(item: item),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<void> loadMenu() async {
    String jsonString = await _loadAsset();
    final jsonParsed = json.decode(jsonString);
    for (var itemJson in jsonParsed) {
      itens.add(Item.fromJson(itemJson));
    }
  }

  Future<String> _loadAsset() async {
    return await rootBundle.loadString('assets/cardapio.json');
  }
}

class DetalhesPedidoPage extends StatelessWidget {
  final Item item;

  const DetalhesPedidoPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Pedido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.nome, style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text(item.descricao),
            const SizedBox(height: 16),
            Text(
              currencyFormatter.format(item.preco),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DadosPedidoPage(item: item),
                  ),
                );
              },
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}

class DadosPedidoPage extends StatelessWidget {
  final Item item;

  const DadosPedidoPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados do Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, informe seus dados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Endereço de Entrega',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Pedido realizado'),
                      content:
                          const Text('Seu pedido foi realizado com sucesso!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Finalizar Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String nome;
  final String descricao;
  final double preco;
  final Color cor;

  Item({
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.cor,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      nome: json['nome'],
      descricao: json['descricao'],
      preco: json['preco'],
      cor: Color(int.parse(json['cor'], radix: 16)),
    );
  }
}

final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
