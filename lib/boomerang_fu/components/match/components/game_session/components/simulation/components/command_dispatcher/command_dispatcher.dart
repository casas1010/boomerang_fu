/// Base class for all game actions.
/// Designed for deterministic simulation and multiplayer packet serialization.
abstract class GameCommand {
  final int characterId;
  const GameCommand({required this.characterId});
}

class MoveCommand extends GameCommand {
  final double moveX;
  final double moveZ;
  final bool updateYaw;

  const MoveCommand({
    required super.characterId,
    required this.moveX,
    required this.moveZ,
    this.updateYaw = true,
  });
}

class ThrowBoomerangCommand extends GameCommand {
  final double targetVx;
  final double targetVz;

  const ThrowBoomerangCommand({
    required super.characterId,
    required this.targetVx,
    required this.targetVz,
  });
}

class SlashCommand extends GameCommand {
  const SlashCommand({required super.characterId});
}

class DashCommand extends GameCommand {
  final double dirX;
  final double dirZ;

  const DashCommand({
    required super.characterId,
    required this.dirX,
    required this.dirZ,
  });
}

/// Buffer for incoming commands (local inputs + bot inputs + future remote player inputs).
class CommandDispatcher {
  final List<GameCommand> _inbox = [];

  void enqueue(GameCommand cmd) => _inbox.add(cmd);
  void enqueueAll(Iterable<GameCommand> cmds) => _inbox.addAll(cmds);

  List<GameCommand> drain() {
    final list = List<GameCommand>.from(_inbox);
    _inbox.clear();
    return list;
  }
}
