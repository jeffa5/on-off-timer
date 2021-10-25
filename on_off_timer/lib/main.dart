import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const OnOffTimerApp());
}

class OnOffTimerApp extends StatelessWidget {
  const OnOffTimerApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "On Off Timer",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OnOffTimerPage(title: "On Off Timer"),
    );
  }
}

class OnOffTimerPage extends StatefulWidget {
  const OnOffTimerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<OnOffTimerPage> createState() => _OnOffTimerPageState();
}

class _OnOffTimerPageState extends State<OnOffTimerPage> {
  bool isOn = true;
  Stopwatch sw = Stopwatch();
  int millisToWait = 0;
  Stopwatch t = Stopwatch();
  bool repeat = false;
  double offMultiplier = 1.0;

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (_timer) {
      setState(() {});
    });

    int minutesElapsed;
    int secondsElapsed;
    int millisecondsElapsed;

    if (isOn) {
      minutesElapsed = sw.elapsed.inMinutes;
      secondsElapsed = sw.elapsed.inSeconds;
      millisecondsElapsed = sw.elapsed.inMilliseconds;
    } else {
      // !isOn
      Duration duration = Duration(milliseconds: millisToWait) - t.elapsed;
      minutesElapsed = duration.inMinutes;
      secondsElapsed = duration.inSeconds;
      millisecondsElapsed = duration.inMilliseconds;
    }

    if (secondsElapsed > 0) {
      millisecondsElapsed %= secondsElapsed * 1000;
    }

    if (minutesElapsed > 0) {
      secondsElapsed %= minutesElapsed * 60;
    }

    millisecondsElapsed ~/= 10;
    String millisecondsElapsedString = millisecondsElapsed.toString();
    while (millisecondsElapsedString.length < 2) {
      millisecondsElapsedString = "0" + millisecondsElapsedString;
    }

    String state = "";
    if (isOn) {
      if (sw.isRunning) {
        state = "ON";
      } else {
        state = "PAUSED";
      }
    } else {
      state = "OFF";
    }

    Widget action;
    if (isOn) {
      if (!sw.isRunning) {
        // home state, offer the start button
        action = ElevatedButton(
            style:
                ElevatedButton.styleFrom(padding: const EdgeInsets.all(50.0)),
            onPressed: () {
              setState(() {
                sw.start();
              });
            },
            child: const Text("Start", style: TextStyle(fontSize: 25)));
      } else {
        // doing an action, offer to finish and move on to the off section
        action = ElevatedButton(
            style:
                ElevatedButton.styleFrom(padding: const EdgeInsets.all(50.0)),
            onPressed: () {
              setState(() {
                isOn = false;
                sw.stop();
                millisToWait =
                    (offMultiplier * sw.elapsed.inMilliseconds).round();
                t.start();
              });
            },
            child: const Text("Finish", style: TextStyle(fontSize: 25)));
      }
    } else {
      // in the off state, check the timer
      if (t.elapsed.inMilliseconds > millisToWait) {
        t.stop();
        sw.reset();
        t.reset();
        isOn = true;
        if (repeat) {
          sw.start();
          action = ElevatedButton(
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(50.0)),
              onPressed: () {
                setState(() {
                  isOn = false;
                  sw.stop();

                  t.start();
                });
              },
              child: const Text("Finish", style: TextStyle(fontSize: 25)));
        } else {
          action = ElevatedButton(
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(50.0)),
              onPressed: () {
                setState(() {
                  sw.start();
                });
              },
              child: const Text("Start", style: TextStyle(fontSize: 25)));
        }
      } else {
        action = ElevatedButton(
            style:
                ElevatedButton.styleFrom(padding: const EdgeInsets.all(50.0)),
            onPressed: null,
            child: const Text("Nothing to do but wait",
                style: TextStyle(fontSize: 25)));
      }
    }

    String minutesSecondsElapsed = "";
    if (minutesElapsed > 0) {
      minutesSecondsElapsed += "$minutesElapsed:";
    }
    minutesSecondsElapsed += secondsElapsed.toString();

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              state,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text.rich(TextSpan(children: <InlineSpan>[
              TextSpan(
                text: minutesSecondsElapsed,
                style: Theme.of(context).textTheme.headline1,
              ),
              TextSpan(
                text: ':$millisecondsElapsedString',
                style: Theme.of(context).textTheme.headline2,
              ),
            ])),
            action,
            const Divider(),
            CheckboxListTile(
                title: const Text("Repeat"),
                value: repeat,
                onChanged: (enabled) {
                  setState(() {
                    repeat = enabled!;
                  });
                }),
            const Divider(),
            ListTile(
                title: const Text("Off time multiplier"),
                trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text(
                    offMultiplier.toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          offMultiplier += 0.5;
                        });
                      },
                      icon: const Icon(Icons.add)),
                  IconButton(
                      onPressed: offMultiplier > 0
                          ? () {
                              setState(() {
                                if (offMultiplier > 0) {
                                  offMultiplier -= 0.5;
                                }
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove)),
                ])),
            const Divider(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isOn = true;
              sw.stop();
              sw.reset();
              t.stop();
              sw.stop();
            });
          },
          child: const Icon(Icons.close)),
    );
  }
}
