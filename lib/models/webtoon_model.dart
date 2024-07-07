class WebtoonModel {
  final String title, thumb, id;

  // * named constructor를 사용하여 각각의 값들을 initialise하기
  WebtoonModel.fronJson(Map<String, dynamic> json)
      : title = json['title'],
        thumb = json['thumb'],
        id = json['id'];
}
