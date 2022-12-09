import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const GITHUB_AUTH_TOKEN = "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";
const GITHUB_USER = "freeCodeCamp";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> repositories = [];
  bool isFetching = true;

  Future<dynamic> getAllPublicRepositories() async {
    http.get(Uri.parse("https://api.github.com/users/$GITHUB_USER/repos"),
        headers: {
          "Authorization": "Bearer $GITHUB_AUTH_TOKEN"
        }).then((response) {
      if (kDebugMode) {
        print(json.decode(response.body));
      }
      setState(() {
        isFetching = false;
        repositories = json.decode(response.body);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllPublicRepositories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("taskApp"),
      ),
      body: isFetching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: repositories.length,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: Image.network(
                    "https://cdn-icons-png.flaticon.com/512/25/25231.png",
                    width: 35.0,
                  ),
                  title: Text(repositories[i]["full_name"]),
                  subtitle: Commits(repositories[i]["name"]),
                  onTap: () {},
                );
              },
            ),
    );
  }
}

class Commits extends StatefulWidget {
  String repoName;

  Commits(this.repoName, {Key? key}) : super(key: key);

  @override
  State<Commits> createState() => _CommitsState();
}

class _CommitsState extends State<Commits> {
  Future<int> getAllRepositoriesCommits() async {
    return http.get(
        Uri.parse(
            "https://api.github.com/repos/$GITHUB_USER/${widget.repoName}/commits"),
        headers: {
          "Authorization": "Bearer $GITHUB_AUTH_TOKEN"
        }).then((response) => json.decode(response.body).length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getAllRepositoriesCommits(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text("Fetching commits..");
          case ConnectionState.done:
            return Text("commits : ${snapshot.data} ");
          default:
            return const Text("Fetching error");
        }
      },
    );
  }
}
