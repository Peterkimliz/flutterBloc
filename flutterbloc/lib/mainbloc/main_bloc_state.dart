import 'package:flutter/material.dart';

@immutable
abstract class AppState {
}

class InitialState extends AppState{

}
class UpdatedState extends AppState{
  final int count;
   UpdatedState({required this.count});

}