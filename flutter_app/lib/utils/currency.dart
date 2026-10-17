String inr(num amount) {
  final parts = amount.abs().toStringAsFixed(2).split('.');
  var whole = parts[0];
  if (whole.length > 3) {
    final tail = whole.substring(whole.length - 3);
    var head = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (head.length > 2) {
      groups.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    groups.insert(0, head);
    whole = '${groups.join(',')},$tail';
  }
  return '${amount < 0 ? '-' : ''}\u20b9$whole.${parts[1]}';
}
