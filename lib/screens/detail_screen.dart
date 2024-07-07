import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_detail_model.dart';
import 'package:toonflix/models/webtoon_episode_model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/episode_widget.dart';

// * 유저가 클릭한 웹툰이 뭔지 알려줘!
class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');

    // * 앱에 해당 리스트가 있는지 체크!
    if (likedToons != null) {
      // ? 리스트 안에 현재 웹툰 id가 있는지 없는지 체크!
      if (likedToons.contains(widget.id) == true) {
        // ! setState 빼먹으면 UI에 반영이 안된다 ^^ 까먹지말자!
        setState(() {
          isLiked = true;
        });
      }
    } else {
      // * 딱 한번 실행된다. 유저가 처음 앱을 열었을 때 리스트 생성!
      await prefs.setStringList('likedToons', []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPrefs();
  }

  onHeartTap() async {
    // ! 일단 폰에서 데이터를 가져오세요!
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      // * 이제, 있으면 삭제하고 없으면 추가하기
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
      // * 휴대폰에 해당 데이터를 다시 저장하기!
      await prefs.setStringList('likedToons', likedToons);
    }

    // * state 값 또한 변경해주기
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ! HomeScreen에서 빠져나가서 route를 통해 여기로 접속하므로, Scaffold를 렌더링해주어야 함.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 5,
        foregroundColor: Colors.green,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon:
                Icon(isLiked ? Icons.favorite : Icons.favorite_border_outlined),
          ),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 40,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Container(
                      width: 250,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 15,
                              offset: Offset(10, 5),
                              color: Colors.black38,
                            ),
                          ]),
                      child: Image.network(widget.thumb),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              FutureBuilder(
                future: webtoon,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          '${snapshot.data!.age} / ${snapshot.data!.genre}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  }
                  return const Text('...');
                },
              ),
              const SizedBox(
                height: 50,
              ),
              FutureBuilder(
                future: episodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var limitedEpisodes = snapshot.data!.take(10).toList();
                    return Column(
                      children: [
                        for (var episode in limitedEpisodes)
                          Episode(episode: episode, webtoonId: widget.id),
                      ],
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
