library autoform;

import 'package:autoform/AutoHelpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AutoDropDown.dart';
import 'Form.dart';
import 'AutoFormSettings.dart';
import 'AutoValidators.dart';

class AutoProperty {
  /// the current field name (if this property is for First Name field maybe first_name ) Provide a random field name for [AutoPropertyType.widgets]
  String field;

  /// The title (if applicable) is displayed atop the field by default
  String title;

  /// The hint (if applicable) is displayed inside the field by default
  String? hint;

  /// Custom widget. Applicapple only with [AutoPropertyType.widget]
  Widget? widget;

  bool? showInTable;

  /// Options for [AutoPropertyType.select]
  List<String>? options;

  /// Describes the type of the property
  AutoPropertyType type;

  /// The validator to run upon submit
  String? Function(dynamic)? validator;

  factory AutoProperty.fromMap(Map<String, dynamic> map) {
    String? f = map['field'];

    // if(map['options']!=null){
    //   map['options'] = (map['options'] as List).map((e) => e.toString());
    // }
    var t = AutoPropertyType.values.singleWhere((element) {
      return element.toString() == ('AutoPropertyType.' + map['type'].toString());
    });
    List<String>? loadedOptions;
    try {
      if (map['options'] != null) {
        if (map['options'] is List<dynamic>) {
          map['options'] = (map['options'] as List).map((e) => e.toString()).toList();
        }
        loadedOptions = map['options'] = map['options'] as List<String>?;
      }
    } catch (x) {
      pprint(x);
    }

    if (f != null) {
      return AutoProperty(
        field: f,
        type: t,
        showInTable: map['showInTable'] ?? true,
        title: map['title'],
        validator: AutoValidators.validators[map['validator']],
        hint: map['hint'],
        options: loadedOptions,
      );
    } else {
      throw FlutterError('Values Missing');
    }
  }

  AutoProperty({
    required this.field,
    required this.title,
    this.showInTable,
    required this.type,
    this.validator,
    this.widget,
    this.options,
    this.hint,
  });

  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'title': title,
      'showInTable': showInTable,
      'type': type.toString().replaceAll('AutoPropertyType.', ''),
      'options': options,
      'hint': hint,
    };
  }

  Widget build(
    Function(dynamic) onChange, {
    dynamic initialvalue,
  }) {
    switch (type) {
      case AutoPropertyType.text:
        return _buildText(onChange, initialvalue);
      case AutoPropertyType.select:
        return _buildMultiSelect(onChange, initialvalue);
      case AutoPropertyType.number:
        return _buildNumber(onChange, initialvalue);
      case AutoPropertyType.date:
        return _buildDate(onChange, initialvalue);
      case AutoPropertyType.widget:
        return widget ?? Container();
    }
  }

  Widget _buildDate(Function(dynamic) onChange, String? initialValue) {
    return LayoutBuilder(builder: (context, constraints) {
      var con = TextEditingController();

      var show = () async {
        var d = await showDatePicker(
          context: context,
          firstDate: DateTime(1971),
          initialDate: DateTime.now(),
          lastDate: DateTime.now().add(
            Duration(days: 9000000),
          ),
        );
        if (d != null) {
          onChange(d.toIso8601String());
          con.text = "${d.day}-${d.month}-${d.year}";
        }
      };

      return TextFormField(
        readOnly: true,
        controller: con,
        decoration: InputDecoration(
            labelText: this.title,
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: show,
            )),
      );

    });
  }

  Widget _buildMultiSelect(Function(dynamic) onChange, String? initailValue) {
    return AutoDropDown(
      onChange: onChange,
      validator: this.validator,
      property: this,
      initialValue: initailValue,
    );
  }

  Widget _buildText(Function(dynamic) onChange, String? initailValue) {
    return TextFormField(
      validator: this.validator,
      initialValue: initailValue,
      onChanged: onChange,
      decoration: AutoFormSettings.singleton.textDecorationBuilder(this),
    );
  }

  Widget _buildNumber(Function(dynamic) onChange, String? initialValue) {
    return TextFormField(
      validator: this.validator,
      initialValue: initialValue,
      onChanged: onChange,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: AutoFormSettings.singleton.textDecorationBuilder(this),
    );
  }
}
