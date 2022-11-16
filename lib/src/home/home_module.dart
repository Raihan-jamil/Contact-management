import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:contact_management/src/home/home_bloc.dart';
import 'package:contact_management/src/home/home_page.dart';
import 'package:flutter/material.dart';

class HomeModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => HomeBloc()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => HomePage();

  static Inject get to => Inject<HomeModule>.of();
}
