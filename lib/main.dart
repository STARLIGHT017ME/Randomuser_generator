import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<dynamic>?> userList;
  @override
  void initState() {
    super.initState();
    userList = fetchuser();
  }

  Future<List<dynamic>?> fetchuser() async {
    final uri = Uri.parse("https://randomuser.me/api/?results=50");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["results"];
    } else {
      throw "Failed to Load data";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: fetchuser(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator.adaptive());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No data available here");
            } else if (snapshot.hasError) {
              return Text("{$snapshot.error}");
            } else {
              final users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user['picture']['thumbnail'],
                      ),
                    ),
                    title: Text(
                        "#${user['name']['first']} ${user['name']['last']}"),
                    subtitle: Text(user['email']),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              userList = fetchuser();
            });
          },
          child: const Icon(Icons.refresh_outlined),
        ),
      ),
    );
  }
}
