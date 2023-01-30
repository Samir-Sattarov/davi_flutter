import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Person {
  Person(this.name, this.age, this.value);

  final String name;
  final int age;
  final int value;

  bool _valid = true;

  bool get valid => _valid;

  String _editable = '';

  String get editable => _editable;

  set editable(String value) {
    _editable = value;
    _valid = _editable.length < 6;
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Davi Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DaviModel<Person>? _model;

  @override
  void initState() {
    super.initState();

    List<Person> rows = [];

    Random random = Random();
    for (int i = 1; i < 500; i++) {
      rows.add(Person('User $i', 20 + random.nextInt(50), random.nextInt(999)));
    }
    rows.shuffle();

    _model = DaviModel<Person>(
        rows: rows,
        columns: [
          DaviColumn(name: 'Name', stringValue: (row) => row.name),
          DaviColumn(name: 'Age', intValue: (row) => row.age),
          DaviColumn(name: 'Value', intValue: (row) => row.value),
          DaviColumn(
              name: 'Editable',
              cellBuilder: _buildField,
              cellBackground: (rowData) =>
                  rowData.data.valid ? null : Colors.red[800])
        ],
        alwaysSorted: true,
        multiSortEnabled: true);
  }

  Widget _buildField(BuildContext context, DaviRow<Person> rowData) {
    return TextFormField(
        initialValue: rowData.data.editable,
        style:
            TextStyle(color: rowData.data.valid ? Colors.black : Colors.white),
        onChanged: (value) => _onFieldChange(value, rowData.data));
  }

  void _onFieldChange(String value, Person person) {
    final wasValid = person.valid;
    person.editable = value;
    if (wasValid != person.valid) {
      setState(() {
        // rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Davi<Person>(_model));
  }
}
