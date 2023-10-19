import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterbloc/data/models/posts.dart';
import 'package:flutterbloc/data/repository/post_repository.dart';
import 'package:flutterbloc/mainbloc/main_bloc.dart';
import 'package:flutterbloc/mainbloc/main_bloc_event.dart';
import 'package:flutterbloc/postsbloc/posts_cubit.dart';
import 'package:flutterbloc/screens%20/comments/bloc/comments_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(create: (context) => AppBloc()),
        BlocProvider<PostsCubit>(create: (context) => PostsCubit(postRepository: PostRepository())),
        BlocProvider<CommentsCubit>(create: (context) => CommentsCubit(postRepository: PostRepository()))
      ],
      child: MaterialApp(
        title: 'Flutter Bloc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Posts'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PostsCubit>(context).fetchPosts();
    return RefreshIndicator(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: BlocConsumer<PostsCubit, PostsState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is PostsLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is PostsLoaded) {
                  return ListView.builder(
                      itemCount: state.posts.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Posts posts = state.posts.elementAt(index);
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                posts.title!,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(posts.body!),
                              Divider(),
                            ],
                          ),
                        );
                      });
                }

                return Container();
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.read<AppBloc>().add(const IncreamentCounter());
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        onRefresh: () async {
          BlocProvider.of<PostsCubit>(context).fetchPosts();
        });
  }
}

_buildWidget(BuildContext context, int i) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$i',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    ),
  );
}
