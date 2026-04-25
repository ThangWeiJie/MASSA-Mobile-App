import 'package:flutter/material.dart';
import 'package:massa/models/navtab.dart';

const String homePath = "/";
const String profilePath = "/profile";

final List<NavTab> tabs = [
  NavTab(path: homePath, icon: Icons.home, label: "Home"),
  NavTab(path: profilePath, icon: Icons.account_box, label: "Profile")
];