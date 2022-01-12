import 'dart:math';

enum State { comeOut, point, win, loss }

class Roll {
  final int _die1;
  final int _die2;

  int get value => _die1 + _die2;

  int get die1 => _die1;

  int get die2 => _die2;

  Roll(Random rng)
      : _die1 = rng.nextInt(6),
        _die2 = 1 + rng.nextInt(6);
}
class Round {
  final List<Roll> _rolls;
  late final bool _win;

  List<Roll> get rolls => List.unmodifiable(_rolls);

  bool get win => _win;

  Round(Random rng) : _rolls = <Roll>[] {
    State state = State.comeOut;
    int point = 0;
    do {
      Roll roll = Roll(rng);
      _rolls.add(roll);
      switch (state) {
        case State.comeOut:
          switch (roll.value) {
            case 2:
            case 3:
            case 12:
              state = State.loss;
              break;
            case 7:
            case 11:
              state = State.win;
              break;
            default:
              state = State.point;
              point = roll.value;
              break;
          }
          break;
        case State.point:
          if (roll.value == point) {
            state = State.win;
          } else if (roll.value == 7) {
            state = State.loss;
          }
          break;
        default:
        // DO NOTHING.
      }
    } while (state == State.point);
    _win = (state == State.win);
  }
}
class Snapshot {
 final int _wins;
 final int _losses;
 final Round? _round;

 int get wins => _wins;
 int get losses => _losses;
 Round? get round => _round;

Snapshot(this._wins, this._losses, this._round);

}
