library autoform;
import 'package:flutter/foundation.dart' as foundation;



void pprint(dynamic data) {
  if (foundation.kDebugMode) {
    var s = StackTrace.current.toString().split('\n');
    print(s[1]);
    print(data);
  }
}