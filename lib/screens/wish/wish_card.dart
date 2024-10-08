import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swiftgift_app/util.dart';

import '../../data/wish.dart';
import '../../main.dart';

class WishCard extends StatelessWidget {
  final Wish wish;

  const WishCard({super.key, required this.wish});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wish.title.toCapitalized(),
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
              if (wish.description != null &&
                  wish.description!.trim().isNotEmpty)
                Text(
                  wish.description!.toCapitalized().trim(),
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
            ],
          )),
          FutureBuilder<File?>(
            future: apiClient.getImage(wish.img),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const SizedBox.shrink();
              } else if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  width: 130,
                  constraints:
                      const BoxConstraints(maxHeight: 110, minHeight: 80),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
