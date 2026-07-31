import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class BodyLg extends StatelessWidget {
  final String text;
  final Color? color;
  const BodyLg(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16, color: color ?? AppColors.textPrimary));
  }
}

class TitleMd extends StatelessWidget {
  final String text;
  final Color? color;
  const TitleMd(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary));
  }
}

class TitleLg extends StatelessWidget {
  final String text;
  final Color? color;
  const TitleLg(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color ?? AppColors.textPrimary));
  }
}
