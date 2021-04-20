library  autoform;

import 'package:flutter/material.dart';

import 'AutoProperty.dart';



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
      return InputDecoration(border: OutlineInputBorder(), labelText: x.title, hintText: x.hint);
    };
  }
}
