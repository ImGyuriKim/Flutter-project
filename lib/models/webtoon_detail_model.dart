class WebtoonDetailModel {
  final String title, about, genre, age, thumb;

  WebtoonDetailModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        about = json['about'],
        age = json['age'],
        genre = json['genre'],
        thumb = json['thumb'];
}
