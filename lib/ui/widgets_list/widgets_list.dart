import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetsListScreen extends StatefulWidget {
  @override
  _WidgetsListScreenState createState() => _WidgetsListScreenState();
}

class _WidgetsListScreenState extends State<WidgetsListScreen> {
  int _counter = 10;

  void _incrementCounter() {
    Navigator.pushNamed(context, '/add_new');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Widgets list"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _counter == 0 ? _initEmpty() : _initList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _initEmpty() {
    return Column(
      // Column is also a layout widget. It takes a list of children and
      // arranges them vertically. By default, it sizes itself to fit its
      // children horizontally, and tries to be as tall as its parent.
      //
      // Invoke "debug painting" (press "p" in the console, choose the
      // "Toggle Debug Paint" action from the Flutter Inspector in Android
      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      // to see the wireframe for each widget.
      //
      // Column has various properties to control how it sizes itself and
      // how it positions its children. Here we use mainAxisAlignment to
      // center the children vertically; the main axis here is the vertical
      // axis because Columns are vertical (the cross axis would be
      // horizontal).
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'You haven\'t added icons,\npush on "+" button for adding new Icon',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _initList() {
    final items = List<Widget>.generate(_counter, (i) => _initItem(i));
    return ListView(
      children: items,
    );
  }

  Widget _initItem(int i) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                width: 50,
                height: 50),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text("Icon " + (i + 1).toString()),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black38, size: 25.0,)
          ],
        ),
      ),
    );
  }
}
