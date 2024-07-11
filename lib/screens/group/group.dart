import 'package:flutter/material.dart';

import '../../data/group.dart';

class GroupDetailsScreen extends StatelessWidget {
  final Group group;

  const GroupDetailsScreen({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Details",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Created by ${group.createdBy.firstName} ${group.createdBy.lastName}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(.5)),
                  ),
                ]),
                const Spacer(),
                Chip(
                  shape: StadiumBorder(side: BorderSide()),
                  label: Text(
                    group.visibility.toString().split('.').last,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: group.visibility == GroupVisibility.public
                            ? const Color.fromRGBO(65, 136, 254, 100)
                            : Colors.white),
                  ),
                  backgroundColor: group.visibility == GroupVisibility.public
                      ? const Color.fromRGBO(172, 204, 255, 100)
                      : const Color.fromRGBO(65, 136, 254, 100),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Members:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: group.members.length,
                itemBuilder: (context, index) {
                  final member = group.members[index];
                  return ListTile(
                    title: Text('${member.firstName} ${member.lastName}'),
                    subtitle: Text(member.email),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
