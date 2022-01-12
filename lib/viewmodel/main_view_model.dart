import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:craps_simulator_flutter/model/craps.dart';

class MainViewModel {
  final StreamController<Snapshot> _snapshotStreamController;

  bool _running;

  Stream<Snapshot> get snapshotStream => _snapshotStreamController.stream;

  MainViewModel()
      : _snapshotStreamController = StreamController<Snapshot>(),
        _running = false {}

  static void _startSimulation(message) {
    int wins = 0;
    int losses = 0;
    Random rng = Random();
    SendPort sendPort = message as SendPort;

    void sendSnapshot(Snapshot snapshot) {
      sendPort.send({'snapshot': snapshot});
    }

    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      final map = message as Map<String, Object>;
      if (map.containsKey('init')) {
        wins = 0;
        losses = 0;
        sendSnapshot(Snapshot(0, 0, null));
      } else if (map.containsKey('simulate')) {
        int numRounds = map['simulate'] as int;
        Round? round;
        for (var i = 0; i < numRounds; i++) {
          round = Round(rng);
          if (round.win) {
            wins++;
          } else {
            losses++;
          }
        }
        sendSnapshot(Snapshot(wins, losses, round));
      }
    });
  }
}
