import 'package:flutter/material.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';
import 'package:provider/provider.dart';

class ExcoGuard extends StatelessWidget {
  final Widget child;
  const ExcoGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<UserRepository>();

    return StreamBuilder<UserModel?>(
        stream: repo.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.data?.role == Role.exco || snapshot.data?.role == Role.admin) {
            return child;
          }

          return Scaffold(
            body: Center(
              child: Text("You do not have permission to view this page"),
            ),
          );
        }
    );
  }
}
