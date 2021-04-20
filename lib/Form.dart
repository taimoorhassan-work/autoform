/// Straight forward form builder
library autoform;

import 'package:flutter/material.dart';
import 'AutoFormSettings.dart';
import 'AutoProperty.dart';

enum AutoPropertyType { text, select, number, date, widget }

// class AutoCustomWidget extends AutoProperty {
//   final Widget widget;
//   AutoCustomWidget({required this.widget}) : super(type: AutoPropertyType.widget, field: '');
// }

class AutoResult {
  Widget widget;
  AutoForm form;
  AutoResult({required this.form, required this.widget});
}

/// Main form builder used to create a new form.
class AutoForm {
  ///
  /// Create a form from Map.
  ///
  /// Takes a map structured as:
  ///
  /// ``` dart
  /// {
  ///   "properties" : [
  ///   {
  ///      "field" : "name",
  ///      "type" : "text",
  ///      "hint" : "Enter your full name here"
  ///   },
  ///   {
  ///     "field" : "age",
  ///      "type" : "number",
  ///      "hint" : "Type your age here"
  ///   },
  ///   {
  ///     "field" : "gender",
  ///      "type" : "select",
  ///      "hint" : "Provide your gender. If you're comfortable with that of course",
  ///      "options" : ["Male" , "Female" , "rather not say"]
  ///   }
  ///   ]
  /// }
  /// ```
  factory AutoForm.fromMap(Map<String, dynamic> map) {
    if (map['properties'] != null) {
      try {
        var l = map['properties'] as List;
        return AutoForm(values: Map<String, dynamic>.from({}), table: map['table'], properties: l.map((e) => AutoProperty.fromMap(e)).toList());
      } catch (e) {}
    } else {}
    throw FlutterError('Invalid Values');
  }

  Map<String,dynamic> toMap(){
    return {
      'properties' : this.properties.map((e) => e.toMap()).toList(),
      'table' : this.table,
    };
  }

  /// All fields inside this form.
  List<AutoProperty> properties;

  /// Table name for this Type
  String? table;

  /// Values producted by this form.
  Map<String, dynamic> values = {};

  String id = DateTime.now().millisecondsSinceEpoch.toString();

  AutoForm({this.values = const {}, this.properties = const [], this.table});
  
  @override
  bool operator ==(Object form) {
    if(form is AutoForm ){
    return this.id == (form).id;
    }else{
      return false;
    }
  }

  @override
  int get hashCode => super.hashCode;

  var _key = GlobalKey<FormState>();

  /// Adds a text field into the form
  AutoForm addText({
    String? hint,
    required String field,
    required String title,
    String? Function(dynamic)? validator,
  }) {
    this.properties.add(
          AutoProperty(field: field, hint: hint, title: title, type: AutoPropertyType.text, validator: validator),
        );
    return this;
  }

  AutoForm addNumber({
    String? hint,
    required String field,
    required String title,
    String? Function(dynamic)? validator,
  }) {
    this.properties.add(
          AutoProperty(field: field, hint: hint, title: title, type: AutoPropertyType.number, validator: validator),
        );
    return this;
  }

  List<Widget> _buildChildern() {
    List<Widget> w = [];
    for (var i = 0; i < properties.length; i++) {
      var p = properties.elementAt(i);
      w.add(Padding(
        padding: AutoFormSettings().fieldMargin,
        child: p.build((x) {
          values[p.field] = x;
        }, initialvalue: values[p.field]),
      ));
    }
    return w;
  }

  /// validates the form according to given validators
  bool validate() {
    return _key.currentState!.validate();
  }

  ///
  /// Get the form widget built from the properteis provided
  ///
  AutoResult create({Map<String, dynamic>? initialValue}) {
    if (initialValue != null) {
      values = initialValue;
    }
    var widget = Container(
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._buildChildern(),
          ],
        ),
      ),
    );

    return AutoResult(form: this, widget: widget);
  }
}
