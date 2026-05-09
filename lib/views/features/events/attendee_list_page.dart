// views/features/events/attendee_list_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../view_models/features/events/attendee_list_viewmodel.dart';

class AttendeeListPage extends StatelessWidget {
  const AttendeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendeeListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Participants List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[800]!, Colors.amber[50]!],
            stops: const [0.0, 0.2],
          ),
        ),
        child: viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _buildList(viewModel),
      ),
    );
  }

  Widget _buildList(AttendeeListViewModel viewModel) {
    if (viewModel.participants.isEmpty) {
      return const Center(
        child: Text(
          "No students registered yet.",
          style: TextStyle(fontSize: 16, color: Colors.brown),
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryHeader(viewModel.participants.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: viewModel.participants.length,
            itemBuilder: (context, index) {
              final participant = viewModel.participants[index];
              return _buildParticipantTile(participant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Registered",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "$count Students",
            style: TextStyle(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(Map<String, dynamic> data) {
    final DateTime joinedAt = (data['joinedAt'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.amber[100],
          child: Text(
            data['fullName']?[0] ?? '?',
            style: TextStyle(color: Colors.orange[900]),
          ),
        ),
        title: Text(
          data['fullName'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Matric: ${data['matricNumber'] ?? 'N/A'}"),
            Text(
              "Registered: ${DateFormat('jm').format(joinedAt)}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Icon(Icons.check_circle_outline, color: Colors.green[600]),
      ),
    );
  }
}
