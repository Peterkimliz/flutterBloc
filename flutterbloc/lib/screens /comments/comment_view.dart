import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterbloc/data/models/comments.dart';
import 'package:flutterbloc/screens%20/comments/bloc/comments_cubit.dart';

class CommentsPage extends StatelessWidget {
   CommentsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer(
          builder: (context, state) {
            if (state is CommentsLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is CommentsLoaded) {
              return ListView.builder(
                  itemCount: state.comments.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Comments comments = state.comments.elementAt(index);
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comments.name!,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(comments
                              .body!),
                          Divider(),
                        ],
                      ),
                    );
                  });
            }

            return Container();
          },
          listener: (context, state) {}),
    );
  }
}
