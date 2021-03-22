# autoform

A simple package to help you build forms.

## Getting Started

Straight forward form builder.


### Simple implementation

``` dart


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var form = AutoForm(
    values: {'name': 'Edwards'},
    properties: [
      AutoProperty(
        field: 'name',
        title: 'Name',
        validator: AutoValidators.isEmail,
        type: AutoPropertyType.text,
      ),
      AutoProperty(
          field: 'personality',
          title: 'Personality Type',
          validator: AutoValidators.isEmail,
          type: AutoPropertyType.multiselect,
          options: ['Simple', 'Complex', 'Other']),
    ],
  ).create();

  @override
  void initState() {
    super.initState();
    var s = AutoFormSettings();
    s.fieldMargin = EdgeInsets.symmetric(vertical: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            form.widget,
            ElevatedButton(
              onPressed: () {
                var isValid = form.form.validate();
                if (isValid) {
                  print("Form validated");
                } else {
                  print("Errors");
                }
              },
              child: Text("Validate"),
            ),
          ],
        ),
      ),
    );
  }
}


```



### Create a form from map


``` dart

  var personForm = AutoForm.fromMap({
      'properties': [
        {
          'title': 'Full Name',
          'field': 'fullName',
          'validator': 'isRequired',
          'type': 'text',
        },
        {
          'title': 'Age',
          'field': 'age',
          'type': 'number',
        },
        {
          'title': 'Gender',
          'field': 'gender',
          'type': 'select',
          "options": ["Male", "Female", "rather not say"]
        },
      ]
    }).create();

```