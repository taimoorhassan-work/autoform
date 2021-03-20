/// Straight forward form builder
library autoform;

import 'package:flutter/material.dart';

/// Simple Form Validator
typedef FormValidator = String? Function(dynamic? email);

class AutoValidators {
  static RegExp _email = new RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  /// Validates if a text is a properly formatted email.
  static FormValidator isEmail = _isEmail;

  static String? _isEmail(dynamic? str, {String? errorMessage}) {
    if (str == null || str.isEmpty || !_email.hasMatch(str.toLowerCase())) {
      return 'Invalid Value';
    } else {
      return null;
    }
  }
}

/// Globally applied settings for forms
class AutoFormSettings {
  /// The singleton to get or set the settings
  static final AutoFormSettings singleton = AutoFormSettings._internal();

  /// Text decoration builder for all fields that display text (Applicable globally)
  late InputDecoration Function(AutoProperty prop) textDecorationBuilder;

  /// Field margin i.e. the margin in between the fields (Applicable globally) Default: const EdgeInsets.symmetric(vertical: 5);
  late EdgeInsetsGeometry fieldMargin;
  factory AutoFormSettings() {
    return singleton;
  }

  AutoFormSettings._internal() {
    fieldMargin = const EdgeInsets.symmetric(vertical: 5);
    textDecorationBuilder = (x) {
      return InputDecoration(
          border: OutlineInputBorder(), labelText: x.title, hintText: x.hint);
    };
  }
}

enum AutoPropertyType { text, number, email, date }

class AutoProperty {
  /// the current field name (if this property is for First Name field maybe first_name )
  String? field;

  /// The title (if applicable) is displayed atop the field by default
  String? title;

  /// The hint (if applicable) is displayed inside the field by default
  String? hint;

  /// Describes the type of the property
  AutoPropertyType? type;

  /// The validator to run upon submit
  String? Function(dynamic)? validator;

  AutoProperty({this.field, this.title, this.type, this.validator, this.hint});

  Widget _build(
    Function(dynamic) onChange, {
    dynamic initialvalue,
  }) {
    if (type == AutoPropertyType.text) {
      return Padding(
        padding: AutoFormSettings.singleton.fieldMargin,
        child: _buildText(onChange),
      );
    } else {
      return Container();
    }
  }

  Widget _buildText(Function(dynamic) onChange) {
    return TextFormField(
      validator: this.validator,
      onChanged: onChange,
      decoration: AutoFormSettings.singleton.textDecorationBuilder(this),
    );
  }
}

class AutoForm {
  List<AutoProperty> _properties = [];
  Map<String?, dynamic> values = {};

  var _key = GlobalKey<FormState>();

  /// Adds a text field into the form
  AutoForm addText({
    String? hint,
    String? field,
    String? title,
    String? Function(dynamic)? validator,
  }) {
    this._properties.add(
          AutoProperty(
              field: field,
              hint: hint,
              title: title,
              type: AutoPropertyType.text,
              validator: validator),
        );
    return this;
  }

  List<Widget> _buildChildern() {
    List<Widget> w = [];
    for (var i = 0; i < _properties.length; i++) {
      var p = _properties.elementAt(i);
      w.add(p._build((x) {
        values[p.field] = x;
      }));
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
  Widget getForm() {
    return Container(
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
  }
}