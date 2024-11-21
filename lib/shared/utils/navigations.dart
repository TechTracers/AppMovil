import 'package:flutter/material.dart';

class Navigations {
  static Future<Ty?> to<Ty>(BuildContext context, Widget objective) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => objective));

  static void back<Ty>(BuildContext context, [Ty? result]) =>
      Navigator.pop(context, result);

  static void replace(BuildContext context, Widget widget) =>
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => widget));

  static void namedReplace(BuildContext context, String name) =>
      Navigator.pushReplacementNamed(
          context, name.startsWith("/") ? name : '/$name');

  static void namedTo(BuildContext context, String name) =>
      Navigator.pushNamed(context, name.startsWith("/") ? name : '/$name');
}
