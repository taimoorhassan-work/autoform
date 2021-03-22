/// Straight forward form builder
library autoform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Simple Form Validator
typedef FormValidator = String? Function(dynamic? email);

class AutoValidators {
  static RegExp _email = new RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  /// Validates if a text is a properly formatted email.
  static FormValidator isEmail = _isEmail;

  static Map<String, FormValidator> validators = {
    'isEmail': _isEmail,
    'isRequired': isRequired
  };

  static FormValidator isRequired = (x) {
    if (x == null || x.toString().isEmpty) {
      return 'Value Required';
    } else {
      return null;
    }
  };

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

enum AutoPropertyType { text, select, number, date, widget }

class AutoCustomWidget extends AutoProperty {
  final Widget widget;
  AutoCustomWidget({required this.widget})
      : super(type: AutoPropertyType.widget, field: '');
}

class AutoProperty {
  /// the current field name (if this property is for First Name field maybe first_name ) Provide a random field name for [AutoPropertyType.widgets]
  String field;

  /// The title (if applicable) is displayed atop the field by default
  String? title;

  /// The hint (if applicable) is displayed inside the field by default
  String? hint;

  /// Custom widget. Applicapple only with [AutoPropertyType.widget]
  Widget? widget;

  /// Options for [AutoPropertyType.select]
  List<String>? options;

  /// Describes the type of the property
  AutoPropertyType type;

  /// The validator to run upon submit
  String? Function(dynamic)? validator;

  factory AutoProperty.fromMap(Map<String, dynamic> map) {
    String? f = map['field'];
    print(map);
    var t = AutoPropertyType.values.singleWhere((element) {
      return element.toString() ==
          ('AutoPropertyType.' + map['type'].toString());
    });
    if (f != null) {
      return AutoProperty(
          field: f,
          type: t,
          title: map['title'],
          validator: AutoValidators.validators[map['validator']],
          hint: map['hint'],
          options: map['options'] as List<String>?);
    } else {
      throw FlutterError('Values Missing');
    }
  }

  AutoProperty({
    required this.field,
    this.title,
    required this.type,
    this.validator,
    this.widget,
    this.options,
    this.hint,
  });

  Widget _build(
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
    return Material(
      elevation: 0,
    );
  }

  Widget _buildMultiSelect(Function(dynamic) onChange, String? initailValue) {
    return _AutoDropDown(
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

class _AutoDropDown extends StatelessWidget {
  const _AutoDropDown({
    Key? key,
    required this.property,
    required this.onChange,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  final AutoProperty property;
  final Function(dynamic) onChange;
  final String? initialValue;
  final FormValidator? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      validator: this.validator,
      onChanged: onChange,
      // value: initailValue,
      decoration: AutoFormSettings.singleton.textDecorationBuilder(property),
      items: (property.options ?? [])
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
              // onTap: () {
              //   onChange(e);
              // },
            ),
          )
          .toList(),
    );
  }
}

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
        return AutoForm(
            values: Map<String, dynamic>.from({}),
            properties: l.map((e) => AutoProperty.fromMap(e)).toList());
      } catch (e) {
        print(e);
      }
    } else {}
    throw FlutterError('Invalid Values');
  }

  /// All fields inside this form.
  List<AutoProperty> properties;

  /// Values producted by this form.
  Map<String?, dynamic> values = {};

  AutoForm({this.values = const {}, this.properties = const []});

  var _key = GlobalKey<FormState>();

  /// Adds a text field into the form
  AutoForm addText({
    String? hint,
    required String field,
    String? title,
    String? Function(dynamic)? validator,
  }) {
    this.properties.add(
          AutoProperty(
              field: field,
              hint: hint,
              title: title,
              type: AutoPropertyType.text,
              validator: validator),
        );
    return this;
  }

  AutoForm addNumber({
    String? hint,
    required String field,
    String? title,
    String? Function(dynamic)? validator,
  }) {
    this.properties.add(
          AutoProperty(
              field: field,
              hint: hint,
              title: title,
              type: AutoPropertyType.number,
              validator: validator),
        );
    return this;
  }

  List<Widget> _buildChildern() {
    List<Widget> w = [];
    for (var i = 0; i < properties.length; i++) {
      var p = properties.elementAt(i);
      w.add(Padding(
        padding: AutoFormSettings().fieldMargin,
        child: p._build((x) {
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
  AutoResult create() {
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
