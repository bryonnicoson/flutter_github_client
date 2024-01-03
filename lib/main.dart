import 'package:flutter/material.dart';
import 'package:github_client/github_oauth_credentials.dart';
import 'package:github_client/src/github_login.dart';
import 'package:github/github.dart';
import 'package:window_to_front/window_to_front.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Github Client'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return GithubLoginWidget(
      builder: (context, httpClient) {
        WindowToFront.activate();
        return FutureBuilder<List<PullRequest>>(
            future: _getPullRequests(httpClient.credentials.accessToken),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return (Center(child: Text('${snapshot.error}')));
              }
              if (!snapshot.hasData) {
                return (const Center(child: CircularProgressIndicator()));
              }
              final pullRequests = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  elevation: 2,
                ),
                body: Center(
                  child: ListView.builder(
                    itemCount: pullRequests.length,
                    itemBuilder: (context, index) {
                      final pullRequest = pullRequests.elementAt(index);
                      return ListTile(
                        title: Text(pullRequest.title ?? ''),
                      );
                    },
                  ),
                ),
              );
            });
      },
      githubClientId: githubClientId,
      githubClientSecret: githubClientSecret,
      githubScopes: githubScopes,
    );
  }
}

Future<List<PullRequest>> _getPullRequests(accessToken) {
  final github = GitHub(auth: Authentication.withToken(accessToken));
  return github.pullRequests
      .list(RepositorySlug('flutter', 'flutter'))
      .toList();
}
