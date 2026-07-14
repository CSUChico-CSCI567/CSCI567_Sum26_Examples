
flybyObjects.where((name) => name.contains('turn')).forEach(print);

flybyObjects.where((name){
    var contains = name.contains('turn');
    return contains;
}).forEach(print);

bool val_contains(String name){
    var contains = name.contains('turn');
    return contains;
}

flybyObjects.where(val_contains).forEach(print);

/// Sets the [bold] and [hidden] flags ...
void enableFlags({bool? bold, required bool? hidden}) {
  ...
}

enableFlags(bold: true, hidden: false);
enableFlags(hidden: false, bold: true);
enableFlags(hidden: false);
// enableFlags();