import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef MySyncWidgetBuilder<T> = Widget Function(
    BuildContext context, T snapshot);

class MyFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final MySyncWidgetBuilder<T> builder;
  const MyFutureBuilder({
    this.future,
    @required this.builder,
  }) : assert(builder != null);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          switch (snapshot.hasData) {
            case true:
              return builder(context, snapshot.data);
            case false:
            default:
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
          }
        });
  }
}
