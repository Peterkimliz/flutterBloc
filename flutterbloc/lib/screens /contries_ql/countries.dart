import 'package:flutter/material.dart';
import 'package:flutterbloc/data/models/continents.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Countries extends StatelessWidget {
  const Countries({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String readRepositories = """
  query GetContinents{
  continents{
  name
    countries{
      name
      phone
      emoji
    }
  }
}
""";
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text("Countries"),
      ),
      body: Query(
          options: QueryOptions(
            document: gql(readRepositories),
            pollInterval: const Duration(seconds: 10),
          ),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }

            if (result.isLoading) {
              return Center(child: const CircularProgressIndicator());
            }
            List jsonContinents = result.data?["continents"];
            List<Continents> continents =
                jsonContinents.map((e) => Continents.fromJson(e)).toList();
            print("data is ${continents.length}");
            if (continents.isEmpty) {
              return Text("No Continents found");
            }

            return ListView.builder(
              itemCount: continents.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                Continents continent = continents.elementAt(index);
                return Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                        continent.name.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: continent.countries!
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(e.emoji!),
                                          Text(e.name.toString()),
                                        ],
                                      ),
                                      Text(e.code.toString()),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
