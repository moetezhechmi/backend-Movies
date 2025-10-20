class Movie {
  final String id;
  final String title;
  final String image;

  Movie({
   required this.id,
   required this.title,
   required this.image,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['_id'],
      title: json['title'],
      image: json['image'],
    );
  }


}