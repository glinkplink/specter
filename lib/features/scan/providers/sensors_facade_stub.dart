class MagnetometerEvent {
  final double x;
  final double y;
  final double z;

  const MagnetometerEvent(this.x, this.y, this.z);
}

class AccelerometerEvent {
  final double x;
  final double y;
  final double z;

  const AccelerometerEvent(this.x, this.y, this.z);
}

Stream<MagnetometerEvent> magnetometerEventStream() => const Stream.empty();

Stream<AccelerometerEvent> accelerometerEventStream() => const Stream.empty();
