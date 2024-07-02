import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  String audioTitle = "";
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isPaused = false;
  bool isStopped = true;
  Duration duration = Duration();
  Duration position = Duration();
  String currentUrl = ""; // URL atual do áudio
  final List<Map<String, String>> audioList = [
    {"title": "Tenor", "url": "audio/Tenor.wav"},
    {"title": "Soprano", "url": "audio/Soprano.wav"},
    {"title": "Contralto", "url": "audio/Contralto.wav"},
  ];

  void _moveToTop(String url) {
    print("Removendo do topo: " + url);
    print(audioTitle);
    setState(() {
      audioList.removeWhere((audio) => audio["url"] == url);
      audioList.add({"title": (audioTitle), "url": url});
    });
  }

  @override
  void initState() {
    super.initState();
    audioTitle = "Tenor";
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        isPaused = false;
        isStopped = true;
        position = Duration();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _play(String url) {
    if (currentUrl != url) {
      _audioPlayer.stop();
      currentUrl = url;
      _audioPlayer.play(AssetSource(url));
    } else {
      if (isPaused) {
        _audioPlayer.resume();
      } else {
        _audioPlayer.play(AssetSource(url));
      }
    }
    setState(() {
      isPlaying = true;
      isPaused = false;
      isStopped = false;
      _moveToTop(url);
    });
  }

  void _pause() {
    _audioPlayer.pause();
    setState(() {
      isPlaying = false;
      isPaused = true;
    });
  }

  void _stop() {
    _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      isPaused = false;
      isStopped = true;
      position = Duration();
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player via Internet'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 315,
                height: 274,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24)),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(24)),
                    child: Text(
                      '$audioTitle',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Slider(
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                });
              },
              thumbColor: Colors.orange,
              activeColor: Colors.orange,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_formatDuration(position)}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  iconSize: 24,
                  onPressed: isPlaying ? null : () => _play(currentUrl),
                ),
                IconButton(
                  icon: Icon(Icons.pause),
                  iconSize: 24.0,
                  onPressed: isPlaying ? _pause : null,
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 24,
                  onPressed: isStopped ? null : _stop,
                ),
                Text(
                  '${_formatDuration(duration)}',
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kit Ensaio",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...audioList.map((audio) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          audioTitle = audio["title"]!;
                          print(audioTitle);
                        });
                        _play(audio["url"]!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              height: 106,
                              width: 116,
                              child: Center(
                                child: Text(
                                  audio["title"]!,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Enche-me | " + audio["title"]!,
                                ),
                                Text(
                                  '6 min',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
