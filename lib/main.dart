import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(hintColor: Colors.green, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _clearAll() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  Widget buildTextField(
      String label, String prefix, TextEditingController c, Function f) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.green),
          border: const OutlineInputBorder(),
          prefixText: prefix),
      style: const TextStyle(color: Colors.green, fontSize: 25.0),
      onChanged: (String newText) {
        f(newText);
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Future<Map> getData() async {
    final key = dotenv.get('HG_API_FINANCE_KEY');

    Uri request = Uri.https(
      'api.hgbrasil.com',
      'finance',
      <String, dynamic>{
        'key': key,
      },
    );

    http.Response response = await http.get(request);
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Aguarde...',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 30.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Ops, houve uma falha ao buscar os dados.',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.attach_money,
                        size: 180.0,
                        color: Colors.green,
                      ),
                      buildTextField(
                          'Reais', 'R\$ ', realController, _realChanged),
                      const Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChanged),
                      const Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, _dolarChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
