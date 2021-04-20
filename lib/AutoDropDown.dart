library autoform;

import 'package:flutter/material.dart';

import 'AutoFormSettings.dart';
import 'AutoProperty.dart';
import 'AutoValidators.dart';


class AutoDropDown extends StatelessWidget {
  const AutoDropDown({
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
