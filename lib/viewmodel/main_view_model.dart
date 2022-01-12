import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:craps_simulator_flutter/model/craps.dart';

class MainViewModel {
  final StreamController<Snapshot> _snapshotStreamController;
  final ReceivePort _receivePort;
  late final SendPort _sendPort;
  late final Isolate _simulator;

  bool _running;

  Stream<Snapshot> get snapshotStream => _snapshotStreamController.stream;

  MainViewModel()
      : _snapshotStreamController = StreamController<Snapshot>(),
        _receivePort = ReceivePort(),
        _running = false {
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else {
        _snapshotStreamController.add(message as  Snapshot);
        _checkAndSimulate();
      }
    });
    Isolate
        .spawn(_startSimulation , _receivePort.sendPort)
        .then((isolate) => _simulator = isolate);
  }

  void _checkAndSimulate() {
    if (_running) {
      _sendPort.send({'simulate' : 10000});
    }
  }

  void toggleRunning() {
    _running = ! _running;
    _checkAndSimulate();
  }
  void reset() {
    _sendPort.send({'init': null});
  }
  static void _startSimulation(message) {
    int wins = 0;
    int losses = 0;
    Random rng = Random();
    SendPort sendPort = message as SendPort;

    void sendSnapshot(Snapshot snapshot) {
      sendPort.send(snapshot);
    }

    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      final map = message as Map<String, Object?>;
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




    sendPort.send(receivePort.sendPort);
  }
}
