class Comments{
  final int ?postId;
  final int ?id;
  final String ?name;
  final String ? email;
  final String? body;
  Comments({this.postId,this.body,this.id,this.name,this.email});

  factory Comments.fromJson(Map<String,dynamic>json)=>Comments(
    id: json["id"],
    postId: json["postId"],
    name: json["name"],
    body: json["body"],
    email: json["email"],
  );
}