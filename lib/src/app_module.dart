import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:contact_management/src/app_bloc.dart';
import 'package:contact_management/src/app_widget.dart';
import 'package:flutter/material.dart';

import 'shared/repository/contact_repository.dart';

class AppModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => AppBloc()),
      ];

  @override
  List<Dependency> get dependencies => [
        Dependency((i) => ContactRepository()),
      ];

  @override
  Widget get view => AppWidget();

  static Inject get to => Inject<AppModule>.of();
}
