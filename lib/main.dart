import 'dart:io';

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

/// The application that contains datagrid on it.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syncfusion DataGrid Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

/// The home page of the application which hosts the datagrid.
class MyHomePage extends StatefulWidget {
  /// Creates the home page.
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EmployeeDataSource employeeDataSource;
  List<GridColumn> _columns;

  Future<dynamic> generateEmployeeList() async {
    // Give your PHP URL. It may be online URL o local host URL.
    // Follow the steps provided in the below KB to configure the mysql using
    // XAMPP and get the local host php link,
    ///
    var url = 'GIVE YOUR PHP URL';
    final response = await http.get(url);
    var list = json.decode(response.body);

    // Convert the JSON to List collection.
    List<Employee> _employees =
        await list.map<Employee>((json) => Employee.fromJson(json)).toList();
    employeeDataSource = EmployeeDataSource(_employees);
    return _employees;
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridColumn(
          columnName: 'id',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'ID',
              ))),
      GridColumn(
          columnName: 'name',
          width: 80,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('Name'))),
      GridColumn(
          columnName: 'designation',
          width: 120,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Designation',
                overflow: TextOverflow.ellipsis,
              ))),
      GridColumn(
          columnName: 'salary',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('Salary'))),
    ];
  }

  @override
  void initState() {
    super.initState();
    _columns = getColumns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Syncfusion flutter datagrid'),
        ),
        body: FutureBuilder<Object>(
            future: generateEmployeeList(),
            builder: (context, data) {
              return data.hasData
                  ? SfDataGrid(
                      source: employeeDataSource,
                      columns: _columns,
                      columnWidthMode: ColumnWidthMode.fill)
                  : Center(
                      child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: 0.8,
                    ));
            }));
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource(this.employees) {
    buildDataGridRow();
  }

  void buildDataGridRow() {
    _employeeDataGridRows = employees
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.firstName),
              DataGridCell<String>(
                  columnName: 'designation', value: e.designation),
              DataGridCell<int>(columnName: 'salary', value: e.salary),
            ]))
        .toList();
  }

  List<Employee> employees = [];

  List<DataGridRow> _employeeDataGridRows = [];

  @override
  List<DataGridRow> get rows => _employeeDataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  void updateDataGrid() {
    notifyListeners();
  }
}

class Employee {
  int id;
  String firstName;
  String designation;
  int salary;

  Employee({this.id, this.firstName, this.designation, this.salary});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
        id: int.parse(json['id']),
        firstName: json['firstName'] as String,
        designation: json['designation'] as String,
        salary: int.parse(json['salary']));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
