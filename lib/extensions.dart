extension IntExtension on int {
  String withSign() => sign >= 0 ? "+$this" : "$this";
}
