library autoform;

import 'package:autoform/AutoHelpers.dart';
import 'package:autoform/AutoList.dart';
import 'package:autoform/Form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WidgetFromEnum<T> extends StatefulWidget {
  final List<T> prop;
  final String title;
  final T initialValue;
  final void Function(dynamic x) onChange;
  WidgetFromEnum({required this.title, required this.onChange, required this.prop, required this.initialValue});
  @override
  _WidgetFromEnumState createState() => _WidgetFromEnumState();
}

class _WidgetFromEnumState extends State<WidgetFromEnum> {
  @override
  void initState() {
    super.initState();
    val = widget.initialValue;
  }

  var val;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(widget.title),
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: DropdownButton(
                value: val,
                onChanged: (x) {},
                items: widget.prop.map(
                  (e) {
                    return DropdownMenuItem(
                      onTap: () {
                        widget.onChange(e);
                        val = e;
                        setState(() {});
                      },
                      value: e,
                      child: Text(e.toString()),
                    );
                  },
                ).toList()),
          )
        ],
      ),
    );
  }
}

class WidgetFromBool extends StatefulWidget {
  @override
  _WidgetFromBoolState createState() => _WidgetFromBoolState();
}

class _WidgetFromBoolState extends State<WidgetFromBool> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WidgetCreator {
  Widget fromBool({required String title, required bool? initialValue, required Function(bool?) onChanged}) {
    return Row(
      children: [
        Text(title),
        Container(
          width: 10,
        ),
        Flexible(
            child: Checkbox(
          onChanged: onChanged,
          value: initialValue,
        )),
      ],
    );
  }

  Widget fromString({required String title, required String initialValue, required Function(String) onChanged}) {
    return Row(
      children: [
        Text(title),
        Container(
          width: 10,
        ),
        Flexible(child: TextFormField(initialValue: initialValue, onChanged: onChanged)),
      ],
    );
  }

  Widget fromInt({required String title, required int initialValue, required Function(String) onChanged}) {
    return Row(
      children: [
        Text(title),
        TextFormField(
          initialValue: initialValue.toString(),
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget from({required String title, required String initialValue, required Function(String) onChanged}) {
    return Row(
      children: [
        Text(title),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
        )
      ],
    );
  }
}

class SingleFormEditor extends StatefulWidget {
  final AutoForm autoForm;

  const SingleFormEditor({Key? key, required this.autoForm}) : super(key: key);
  @override
  _SingleFormEditorState createState() => _SingleFormEditorState();
}

class _SingleFormEditorState extends State<SingleFormEditor> {
  @override
  Widget build(BuildContext context) {
    var creator = WidgetCreator();
    return Container(
      child: Column(
        children: [
          ...widget.autoForm.properties.map((e) => Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Column(
                  children: [
                    Text(e.title),
                    creator.fromString(
                        title: 'Title',
                        initialValue: e.title,
                        onChanged: (x) {
                          e.title = x;
                        }),
                    creator.fromString(
                        title: 'Field',
                        initialValue: e.field,
                        onChanged: (x) {
                          e.field = x;
                        }),
                    creator.fromBool(
                        title: 'Show in table',
                        initialValue: e.showInTable,
                        onChanged: (x) {
                          e.showInTable = x;
                       }),
                    WidgetFromEnum<AutoPropertyType>(
                        initialValue: e.type,
                        title: 'Property Type',
                        onChange: (x) {
                          if (x != null) {
                            e.type = x;
                          }
                        },
                        prop: AutoPropertyType.values),
                  ],
                ),
              )),
          ElevatedButton( 
            onPressed: () async {
              var isSaveAvailable = AutoList.singleton.saveConfig != null;
              pprint(isSaveAvailable);
              if (isSaveAvailable) {
                var f = AutoList.singleton.loadedForms.toList().indexWhere((e) => e.table == widget.autoForm.table);
                var allForms = AutoList.singleton.loadedForms.toList();
                allForms[f] = widget.autoForm;
                AutoList.singleton.loadedForms = Set.from(allForms);
                await AutoList.singleton.saveConfig!(AutoList.singleton);
                await AutoList.singleton.reload();
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }
}

class AutoListEditor extends StatefulWidget {
  AutoListEditor() {
    AutoList.singleton.reload();
  }

  @override
  _AutoListEditorState createState() => _AutoListEditorState();
}

class _AutoListEditorState extends State<AutoListEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          ...AutoList.singleton.loadedForms.map((e) => ExpansionTile(
                  title: Text(
                    e.table ?? 'S',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    SingleFormEditor(autoForm: e),
                  ])),
        ],
      ),
    ));
  }
}
