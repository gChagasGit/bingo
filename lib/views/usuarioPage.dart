import 'dart:async';
import 'dart:html';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<UsuarioPage> {
  final _entradaController = TextEditingController();
  final _senhaController = TextEditingController();

  late final DatabaseReference _referenceTemperatura;
  late StreamSubscription<DatabaseEvent> _subscriptionTemperatura;

  List<int> _numeros = List<int>.generate(75, (index) => index + 1);

  List<Map<int, int>> cartela = [];

  @override
  void initState() {
    super.initState();
    readFirebase();
  }

  readFirebase() async {
    _referenceTemperatura = FirebaseDatabase.instance.ref('numeros');

    try {
      //leitura da temperatura
      final snapshot = await _referenceTemperatura.get();
    } catch (err) {
      debugPrint(err.toString());
    }

    _subscriptionTemperatura =
        _referenceTemperatura.onValue.listen((DatabaseEvent event) {
      setState(() {
        //altera estado da tela
        // List<int> aux = (event.snapshot.value ?? 0) as List<int>;

        var aux = (event.snapshot.value ?? 0)
            .toString()
            .replaceFirst('[null,', '')
            .replaceFirst(']', '');

        if (aux.contains('[')) {
          aux = aux.replaceFirst('[', '');
        }

        // print(">> ${aux.split(',')}");

        _numeros.clear();

        aux.split(',').forEach((element) {
          _numeros.add(int.parse(element));
        });

        // print(">>> $_numeros");

        // _temperatura = (event.snapshot.value ?? 0) as int;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> reverso = [];

    for (int i = _numeros.length - 1; i >= 0; i--) {
      reverso.add(_numeros.elementAt(i).toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                child: const Text("Bingo - São Sebastião"),
                onLongPress: () => _mudarParaGeral())
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton.small(
        elevation: 5,
        child: Icon(Icons.refresh),
        onPressed: () {
        setState(() {
          readFirebase();
        });
      }),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              color: Colors.grey.shade400,
              child: Container(
                margin: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView(
                  children: [
                    Text(
                      reverso
                          .toString()
                          .replaceFirst('[', '')
                          .replaceFirst(']', ''),
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Divider(indent: 20, endIndent: 20),
            // Flexible(
            //   child: Card(
            //     margin: EdgeInsets.only(bottom: 20),
            //     color: Colors.grey.shade300,
            //     child: Container(
            //         // padding: EdgeInsets.all(10),
            //         width: MediaQuery.of(context).size.width * 0.9,
            //         child: DataTable(
            //           dividerThickness: 1,
            //           border: TableBorder.all(width: 1.0, color: Colors.white),
            //           columns: _columns(),
            //           rows: _rows(),
            //         )),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
  /*
  _columns() {
    return const <DataColumn>[
      DataColumn(
        label: Text(
          'B',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'I',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'N',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'G',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'O',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  _rows() {
    return List<DataRow>.generate(5, (index) {
      return DataRow(
        cells: <DataCell>[
          // DataCell(Text(
          //   '2',
          //   textAlign: TextAlign.justify,
          // )),
          DataCell(
            fieldNumeroCartela(index),
          ),
          DataCell(
            fieldNumeroCartela(index+5),
          ),
          DataCell(
            fieldNumeroCartela(index+10),
          ),
          DataCell(
            fieldNumeroCartela(index+15),
          ),
          DataCell(
            fieldNumeroCartela(index+20),
          ),
        ],
      );
    }).toList();
  }

  Widget fieldNumeroCartela(int index) {
    return TextFormField(
      controller: _entradaController,
      style: const TextStyle(fontSize: 15),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        hintText: "0",
        border: OutlineInputBorder(),
      ),
      onEditingComplete: (){
        cartela.add({index : int.parse(_entradaController.text)});
      },
    );
  }

  */

  _mudarParaGeral() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Insira a senha!"),
            actions: [
              fieldSenha(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () {
                    if (_entradaController.text.compareTo('180400') == 0) {
                      Navigator.pushNamed(context, '/geral');
                    } else {
                      Navigator.of(context).pop();
                    }
                    _entradaController.clear();
                  },
                  elevation: 5.0,
                  color: Colors.blueGrey[100],
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "Acessar",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget fieldSenha() {
    return TextFormField(
      controller: _entradaController,
      style: const TextStyle(fontSize: 15),
      // keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value!.isEmpty) {
          return "Informe a senha";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Senha:",
        hintText: "******",
        prefixIcon: Icon(Icons.password),
        border: OutlineInputBorder(),
      ),
    );
  }
}
