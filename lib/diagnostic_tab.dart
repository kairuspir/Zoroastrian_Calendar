import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'widgets.dart';

class DiagnosticTab extends StatefulWidget {
  static const title = "Diagnostics";

  const DiagnosticTab({super.key});
  @override
  State<DiagnosticTab> createState() => _DiagnosticTabState();
}

class _DiagnosticTabState extends State<DiagnosticTab> {
  final data = List<_DiagnosticTable>.empty(growable: true);
  var isLoading = true;

  int get itemCount => isLoading ? data.length + 1 : data.length;
  bool isLoadingRow(index) => isLoading ? index == data.length : false;

  @override
  void initState() {
    super.initState();
    loadTableData();
  }

  void loadTableData() async {
    final database = await DBProvider.db.database;
    final tableNameQuery = await database.rawQuery("""SELECT name 
        FROM sqlite_master 
        WHERE type='table'AND name NOT LIKE 'sqlite_%';""");
    final tableNames = tableNameQuery.map((e) => e["name"].toString()).toList();

    for (var tableName in tableNames) {
      final tableSchemaQuery =
          await database.rawQuery("PRAGMA table_info($tableName)");
      final columnNamesForTable =
          tableSchemaQuery.map((e) => e["name"].toString()).toList();

      final tableDataQuery = await database.query(tableName);
      final tableData = List<List<String>>.empty(growable: true);
      tableData.add(columnNamesForTable);
      tableDataQuery
          .map((e) =>
              columnNamesForTable.map((col) => e[col].toString()).toList())
          .map((x) => tableData.add(x))
          .toList();

      final table = _DiagnosticTable(
          tableName: tableName, tableData: tableData, showData: false);
      if (mounted) {
        setState(() {
          data.add(table);
        });
      } else {
        return;
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTab() {
    return Scaffold(
        appBar: AppBar(
          title: Text(DiagnosticTab.title),
        ),
        body: Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView.separated(
              itemCount: itemCount,
              itemBuilder: (context, index) => ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: isLoadingRow(index)
                    ? [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue))
                            ])
                      ]
                    : [
                        ListTile(
                          title: Text(data[index].tableName),
                          trailing: Switch.adaptive(
                              value: data[index].showData,
                              onChanged: (value) =>
                                  setState(() => data[index].showData = value)),
                        ),
                        if (data[index].showData)
                          Container(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 3),
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: data[index].tableData.length,
                                  itemBuilder: (context, tableIndex) => Row(
                                        children: [
                                          ...data[index]
                                              .tableData[tableIndex]
                                              .map((td) => Expanded(
                                                  flex: 1, child: Text(td)))
                                        ],
                                      ),
                                  separatorBuilder: (context, tableIndex) =>
                                      Divider(
                                        color: Colors.black,
                                      ))),
                        Padding(padding: EdgeInsets.only(top: 10)),
                      ],
              ),
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(context).primaryColor,
              ),
            )));
  }

  // ===========================================================================
  // Non-shared code below because this tab uses different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return _buildTab();
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: _buildTab(),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}

class _DiagnosticTable {
  final String tableName;
  final List<List<String>> tableData;
  bool showData;

  _DiagnosticTable(
      {required this.tableName,
      required this.tableData,
      required this.showData});
}
