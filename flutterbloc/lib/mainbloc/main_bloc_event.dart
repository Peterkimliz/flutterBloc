import 'package:flutter/material.dart';

@immutable
abstract class AppBlocEvent{
  const AppBlocEvent();
}

@immutable
class IncreamentCounter extends AppBlocEvent{
   const IncreamentCounter();
}