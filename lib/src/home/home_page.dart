
import 'package:contact_management/src/contact/add_page.dart';
import 'package:contact_management/src/shared/widgets/ContactList.dart';
import 'package:flutter/material.dart';

import 'home_bloc.dart';
import 'home_module.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc bloc;
  late List<Map> items;
  Widget appBarTitle = new Text("Contacts");
  Icon actionIcon = new Icon(Icons.search);
  Color color = Colors.indigo;
  bool searching = false;
  final _cSearch = TextEditingController();

  @override
  void initState() {
    items = [];
    bloc = HomeModule.to.getBloc<HomeBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bloc.getListContact();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: StreamBuilder(
          stream: bloc.buttonSearchOut,
          builder: (conext, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            } else {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data != null) {
                return AppBar(
                  title: appBarTitle,
                  backgroundColor: color,
                  actions: <Widget>[
                    IconButton(
                      icon: actionIcon,
                      onPressed: () {
                        setState(() {
                          if (this.actionIcon.icon == Icons.search) {
                            this.actionIcon = new Icon(
                              Icons.close,
                              color: Colors.indigo,
                            );
                            this.color = Colors.white;
                            this.appBarTitle = new TextField(
                              controller: _cSearch,
                              style: new TextStyle(
                                color: Colors.indigo,
                              ),
                              autofocus: true,
                              onChanged: (value) {
                                this.searching = true;
                                bloc.getListBySearch(value);
                              },
                              decoration: new InputDecoration(
                                  prefixIcon: new Icon(Icons.search,
                                      color: Colors.indigo),
                                  hintText: "Search contacts",
                                  hintStyle:
                                      new TextStyle(color: Colors.indigo)),
                            );
                          } else {
                            _cSearch.clear();
                            this.searching = false;
                            this.actionIcon = new Icon(
                              Icons.search,
                            );
                            this.color = Colors.indigo;
                            this.appBarTitle = new Text("Contatos");
                            // bloc.getListContact();
                          }
                        });
                      },
                    ),
                  ],
                );
              } else {
                return AppBar(
                  title: Text("Contatos"),
                );
              }
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: bloc.listContactOut,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error: ${snapshot.error}');
          } else {
            items = snapshot.data as List<Map>;
            bloc.setVisibleButtonSearch(items.length > 0 || searching);

            if (searching && items.length == 0) {
              return Column(
                children: <Widget>[
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Nenhum contato localizado"),
                  )),
                ],
              );
            } else {
              return ContactList(items: items);
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPage()),
          );
        },
      ),
    );
  }
}
