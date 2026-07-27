import 'package:flutter/material.dart';
import 'package:navstack/first.dart';
import 'package:navstack/second.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => FirstRoute()),
    GoRoute(path: '/second', builder: (context, state) => SecondRoute()),
  ],
);

void main() {
  runApp(MaterialApp.router(title: 'Nav Demo', routerConfig: _router));
}
