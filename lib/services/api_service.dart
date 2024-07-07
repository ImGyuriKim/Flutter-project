// * get 함수 등 이름이 제너럴하니, 네임스페이스 지정해주고 http.get 으로 사용
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toonflix/models/webtoon_detail_model.dart';
import 'package:toonflix/models/webtoon_episode_model.dart';
import 'package:toonflix/models/webtoon_model.dart';

class ApiService {
  static const String baseUrl =
      "https://webtoon-crawler.nomadcoders.workers.dev";
  static const String today = "today";

  // * baseUrl + endpoint로 데이터를 가져오는 메서드
  // 반환하는 값의 타입을 Future로 지정해준다.
  static Future<List<WebtoonModel>> getTodaysToons() async {
    List<WebtoonModel> webtoonInstances = [];
    final url = Uri.parse('$baseUrl/$today');

    // * Future - 미래의 받을 값의 타입
    // * 비동기 프로그래밍, 다음 줄로 넘어가지 말고 응답 올때까지 기다려! (async-await)
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // ? body -> String 타입임. json으로 변형하기
      final List<dynamic> webtoons = jsonDecode(response.body);

      for (var webtoon in webtoons) {
        // 인스턴스로 만들어 리스트에 넣기!
        webtoonInstances.add(WebtoonModel.fronJson(webtoon));
      }
      return webtoonInstances;
    }

    throw Error();
  }

  static Future<WebtoonDetailModel> getToonById(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final webtoon = jsonDecode(response.body);
      return WebtoonDetailModel.fromJson(webtoon);
    }
    throw Error();
  }

  static Future<List<WebtoonEpisodeModel>> getLatestEpisodesById(
      String id) async {
    List<WebtoonEpisodeModel> episodesInstances = [];
    final url = Uri.parse('$baseUrl/$id/episodes');
    final reponse = await http.get(url);

    if (reponse.statusCode == 200) {
      final episodes = jsonDecode(reponse.body);
      for (var episode in episodes) {
        episodesInstances.add(WebtoonEpisodeModel.fromJson(episode));
      }
      return episodesInstances;
    }
    throw Error();
  }
}
