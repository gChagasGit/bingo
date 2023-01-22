import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeralPage extends StatefulWidget {
  GeralPage({Key? key}) : super(key: key);

  @override
  State<GeralPage> createState() => _GeralPageState();
}

class _GeralPageState extends State<GeralPage> {
  late final DatabaseReference _referenceTemperatura;
  late StreamSubscription<DatabaseEvent> _subscriptionTemperatura;

  final _entradaController = TextEditingController();

  int _remover = 0;
  int _ultimaPedra = 0;
  List<int> _numeros = []; //List<int>.generate(75, (index) => index + 1);

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

  writeFirebase(int valor) async {
    // double _novaTemperatura = 44.44;
    _numeros.add(valor);
    _ultimaPedra = valor;
    // await _referenceTemperatura.set(valor);
    await _referenceTemperatura
        .child('${_numeros.length - _remover}')
        .set(valor);
    // await _referenceTemperatura.set(_numeros);
  }

  removeFirebase(int valor) async {
    // double _novaTemperatura = 44.44;
    for (var i = 0; i < _numeros.length; i++) {
      if (_numeros.elementAt(i) == valor) {
        _numeros.removeAt(i);
        _remover = 1;
      }
    }
    _ultimaPedra = _numeros.last;
    // await _referenceTemperatura.set(valor);
    await _referenceTemperatura.set(_numeros);
    // await _referenceTemperatura.set(_numeros);
  }

  removeTudoFirebase() async {
    // double _novaTemperatura = 44.44;
    _numeros.clear();
    _ultimaPedra = 0;
    // await _referenceTemperatura.set(valor);
    await _referenceTemperatura.remove();
    // await _referenceTemperatura.set(_numeros);
  }

  @override
  Widget build(BuildContext context) {
    List<String> reverso = [];

    for (int i = _numeros.length - 1; i >= 0; i--) {
      reverso.add(_numeros.elementAt(i).toString());
    }

    // print(">> rev: $reverso");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // '${convertToInt(provider.myList[1].value)}°C',
                  'Última pedra:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            Colors.grey.withOpacity(0.1),
                            Colors.grey.withOpacity(0.1),
                          ])),
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ]),
                    ),
                    Text(
                      // '${convertToInt(provider.myList[1].value)}°C',
                      (_ultimaPedra == 0) ? '-' : _ultimaPedra.toString(),
                      style:
                          TextStyle(fontSize: 150, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    width: 200,
                    // height: 80,
                    child: fieldEntrada()),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: MaterialButton(
                    onPressed: () {
                      // print(_entradaController.text);
                      setState(() {
                        writeFirebase(int.parse(_entradaController.text));
                      });
                    },
                    elevation: 5.0,
                    color: Colors.blue[700],
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      "Adicionar",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        removeFirebase(int.parse(_entradaController.text));
                      });
                    },
                    onLongPress: () => _mudarParaGeral(),
                    elevation: 5.0,
                    color: Colors.red,
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      "Remover",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              color: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey, //<-- SEE HERE
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.9,
                // child: ListView.builder(
                //   itemCount: (_ultimaPedra == 0) ? 1 : _numeros.reversed.length,
                //   itemBuilder: (context, index) {
                //     if (_ultimaPedra == 0) {
                //       return Text("Aguardando...");
                //     }
                //     return _tableNumeroSorteados(index);
                //   },
                // ),
                // child: _tableNumeroSorteados(),
                child: ListView(
                  children: [
                    Text(
                      reverso
                          .toString()
                          .replaceFirst('[', '')
                          .replaceFirst(']', ''),
                      style:
                          TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pedraSorteada() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Colors.grey.withOpacity(0.1),
                Colors.grey.withOpacity(0.1),
              ])),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ]),
        ),
        // Text(
        //   (_ultimaPedra == 0)
        //       ? '-'
        //       : _numeros.reversed.elementAt(index).toString(),
        //   style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        // )
        Text(
          _numeros.toString().replaceFirst('[', '').replaceFirst(']', ''),
          style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget fieldEntrada() {
    return TextFormField(
      controller: _entradaController,
      autofocus: true,
      style: const TextStyle(fontSize: 20),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value!.isEmpty) {
          return "Informe o valor";
        }
        return null;
      },
      // onFieldSubmitted: writeFirebase(int.parse(_entradaController.text)),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.numbers_rounded),
        border: OutlineInputBorder(),
      ),
    );
  }

  _mudarParaGeral() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Deseja iniciar nova rodada?"),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MaterialButton(
                      onPressed: () {
                        removeTudoFirebase();
                        Navigator.of(context).pop();
                      },
                      elevation: 5.0,
                      color: Colors.blueGrey[100],
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Sim",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      elevation: 5.0,
                      color: Colors.blueGrey[100],
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Não",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
