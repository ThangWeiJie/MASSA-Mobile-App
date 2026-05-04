import 'package:flutter/material.dart';
import 'package:massa/models/navtab.dart';

const String homePath = "/";
const String profilePath = "/profile";
const String eventPath = "/events";

final List<NavTab> tabs = [
  NavTab(path: homePath, icon: Icons.home, label: "Home"),
  NavTab(path: eventPath, icon: Icons.event, label: "Programs"),
  NavTab(path: profilePath, icon: Icons.account_box, label: "Profile")
];