import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double xsVal   = 6.0;
  static const double smVal   = 10.0;
  static const double mdVal   = 14.0;
  static const double lgVal   = 20.0;
  static const double xlVal   = 28.0;
  static const double roundVal= 100.0;

  static BorderRadius get xs    => BorderRadius.circular(xsVal);
  static BorderRadius get sm    => BorderRadius.circular(smVal);
  static BorderRadius get md    => BorderRadius.circular(mdVal);
  static BorderRadius get lg    => BorderRadius.circular(lgVal);
  static BorderRadius get xl    => BorderRadius.circular(xlVal);
  static BorderRadius get round => BorderRadius.circular(roundVal);
}
