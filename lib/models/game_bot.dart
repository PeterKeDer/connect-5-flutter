import 'package:connect_5/models/game.dart';

abstract class GameBot {
  /// Initialize the bot with game and bot side. Called initially and whenever a new game is started
  void initialize(Game game, Side botSide);

  /// This method is called whenever there is a new move in the game
  void notifyMove(Point point, Side side);

  /// Get the next ideal move
  Point getNextMove(Game game);
}
