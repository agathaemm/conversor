import 'package:flutter/material.dart';

// Permite que realize as requisições
import 'package:http/http.dart' as http;

// Permite que não precisemos esperar as requisições terminarem (requisição asincrona)
import 'dart:async'; 

// Transforna a string em json
import 'dart:convert';

// Url de requisição
const request = "https://api.hgbrasil.com/finance?key=8a4ab863";

void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

// Busca os dados da API
Future<Map> getData() async {

  // Faz a requisição a api
  http.Response response = await http.get(request);

  // Retorna os dados em json
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Gerando os controladores dos inputs
  final realController  = TextEditingController();
  final dolarController = TextEditingController();
  final euroController  = TextEditingController();

  // Gera as variaveis
  double dolar;
  double euro;

  // Limpa o formulario
  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  // Converte o valor do tipo real
  void _realChanged(String text) {

    // Verifica se o campo esta vazio
    if(text.isNotEmpty) {

      // Faz a converção
      double real = double.parse(text);
      dolarController.text = (real/dolar).toStringAsFixed(2);
      euroController.text = (real/euro).toStringAsFixed(2);
    }else {

      // Limpa o formulario
      _clearAll();
      return;
    }
  }

  // Converte o valor do tipo dolar
  void _dolarChanged(String text) {

    // Verifica se o campo esta vazio
    if(text.isNotEmpty) {

      // Faz a converção
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }else {

      // Limpa o formulario
      _clearAll();
      return;
    }
  }

  // Converte o valor do tipo euro
  void _euroChanged(String text) {

    // Verifica se o campo esta vazio
    if(text.isNotEmpty) {

      // Faz a converção
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }else {

      // Limpa o formulario
      _clearAll();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar os dados :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {

                // Busca os dados para conversão
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro  = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber
                      ),
                      builderTextField("Reais", "R\$", realController, _realChanged),
                      Divider(), // tipo um <br>
                      builderTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(), // tipo um <br>
                      builderTextField("Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        }
      )
    );
  }
}

/**
 * Gera um widget para o textfiel
 */
Widget builderTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.amber),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber)
            ),
            prefixText: prefix
          ),
          style: TextStyle(
            color: Colors.amber,
            fontSize: 25.0
          ),
          onChanged: f,
          keyboardType: TextInputType.number,
        );
}