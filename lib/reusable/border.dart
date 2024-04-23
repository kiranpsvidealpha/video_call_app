import 'package:flutter/material.dart';

import 'colors.dart';

OutlineInputBorder enableBorder = inOIB.copyWith(
  borderSide: const BorderSide(color: bgColor),
);
OutlineInputBorder foucsBorder = inOIB.copyWith(
  borderSide: const BorderSide(color: bgColor),
);
OutlineInputBorder foucsBorderError = inOIB.copyWith(
  borderSide: const BorderSide(color: red),
);
OutlineInputBorder errorBorder = inOIB.copyWith(
  borderSide: const BorderSide(color: red),
);

const inBRad = BorderRadius.all(Radius.circular(10));
const inOIB = OutlineInputBorder(borderRadius: inBRad);
