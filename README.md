# How-to-load-data-from-mysql-to-Flutter-DataTable-SfDataGrid

Load the data from mysql to the Flutter DataTable widget by fetching the data from mysql and convert it to JSON data. Then convert the JSON data to list collection. And then, create the rows for the datagrid from the list collection.
The following steps explains how to load the data from mysql database for flutter DataTable. In the below example, XAMPP is used to configure the mysql server and explained with the test server. Make your own XAMPP server at your end, do the JSON conversion and set up the datagrid.

## STEP 1

To fetch the data from the server, add the `http` package in the dependencies of pubspec.yaml.

```xml
dependencies:
  http: 0.12.2
```


## STEP 2

Import the following library in flutter application.

```xml
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
```

## STEP 3

Create a database in the phpMyAdmin of XAMPP with the required columns and rows. Here, the Employee database is configured with four columns (ID, Name, Designation and Salary).

## STEP 4

After finishing a table creation, create PHP script and add that local server location. Create a connection with phpMyAdmin using username, password, and data base name with the table name.

```xml
<?php
   
    $servername = "localhost";

    // Give your username and password
    $username = "";
    $password = "";

   // Give your Database name
    $dbname = "";

  // Give your table name
    $table = "Employees"; // lets create a table named Employees.
     
    // Create Connection
    $conn = new mysqli($servername, $username, $password, $dbname);
    // Check Connection
    if($conn->connect_error){
        die("Connection Failed: " . $conn->connect_error);
        return;
    }
 
    // Get all records from the database

    $sql = "SELECT * from $table ORDER BY id ";
    $db_data = array();

    $result = $conn->query($sql);
    if($result->num_rows > 0){
        while($row = $result->fetch_assoc()){
            $db_data[] = $row;
        }
        // Send back the complete records as a json
        echo json_encode($db_data);
    }else{
        echo "error";
    }
    $conn->close();
    
    return;
 
?>
```

## STEP 5 

Fetch the data from the database using php script. By passing the root of your script to http.get() method, decode the fetched data from database as JSON data. Then, convert the JSON data to the list collection. 

```xml
  Future<dynamic> generateEmployeeList() async {

  // Give your sever URL of get_employees_details.php file
    var url = ‘ ’;

    final response = await http.get(url);
    var list = json.decode(response.body);
    List<Employee> _employees =
        await list.map<Employee>((json) => Employee.fromJson(json)).toList();
    employeeDataSource = EmployeeDataSource(_employees);
    return _employees;
  }

  ```

## STEP 6
Create data source class extends with DataGridSource for mapping data to the SfDataGrid. 

```xml
 class EmployeeDataSource extends DataGridSource {

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
```

## STEP 7

Wrap the SfDataGrid inside the FutureBuilder widget. Initialize the SfDataGrid with all the required details.  

```xml   
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
                      columnWidthMode: ColumnWidthMode.fill,
                      columns: _column)
                  : Center(
                      child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: 0.8,
                    ));
            }));
  }
  ```



