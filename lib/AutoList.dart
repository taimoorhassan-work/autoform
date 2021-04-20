library autoform;

import 'dart:convert';


import 'package:autoform/AutoDBConnector.dart';

import 'autoform.dart';

class AutoList {
  static final AutoList singleton = AutoList._internal();
  late Set<AutoForm> loadedForms = Set();
  late Set<AutoForm>? initialForms = Set();

  late AutoDbConnector dbConnector;

  Map<String, dynamic> toMap() {
    return Map<String,dynamic>.from({'forms': loadedForms.map((e) => e.toMap()).toList()});
  }

  factory AutoList.fromMap(Map<String,dynamic> map){
    singleton.loadedForms = (map['forms'] as List).map((e) => AutoForm.fromMap(e)).toSet();
    return singleton;
  }

  String toJson() {
    pprint(AutoList.singleton.toMap());
    return jsonEncode(AutoList.singleton.toMap());
  }

  late Function(AutoList config)? saveConfig;
  late Future<Set<AutoForm>?> Function()? loadConfig;

  Future? reload() async {
    if (loadConfig != null) {
      var lf = await loadConfig!();
      if (lf != null) {
        loadedForms = lf;
        return;
      }
    }

    if (this.initialForms != null) {
      loadedForms = this.initialForms!;
    }
  }

  AutoForm? getForm(String tableName) {
    var res = loadedForms.where((element) {
      return element.table == element.table;
    });
    if(res.length >0){
      return res.elementAt(0);
    }else{
      return null;
    }
  }

  factory AutoList() {
    return singleton;
  }

  AutoList._internal();
}
