// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
