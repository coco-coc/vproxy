/// for generating unique id for database rows
class SnowflakeId {
  static int _lastTimestamp = 0;
  static int _sequence = 0;
  static int _machineId = 1; // Your machine ID (0-1023)
  static const int _epoch = 1609459200000; // Custom epoch (2021-01-01)

  static void setMachineId(int machineId) {
    _machineId = machineId;
  }

  static int generate() {
    var timestamp = DateTime.now().millisecondsSinceEpoch - _epoch;

    if (timestamp < _lastTimestamp) {
      throw Exception('Clock moved backwards');
    }

    if (timestamp == _lastTimestamp) {
      _sequence = (_sequence + 1) % 4096; // 12-bit sequence
      if (_sequence == 0) {
        // Wait for next millisecond
        while (timestamp <= _lastTimestamp) {
          timestamp = DateTime.now().millisecondsSinceEpoch - _epoch;
        }
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;

    return (timestamp << 22) | (_machineId << 12) | _sequence;
  }
}
