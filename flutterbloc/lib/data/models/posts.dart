class Posts{

  final int ?userId;
  final int ? id;
  final String ?title;
  final String ?body;
  Posts({this.userId,this.body,this.id,this.title});

  factory Posts.fromJson(Map<String,dynamic>json)=>Posts(
    id: json["id"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
  );
}