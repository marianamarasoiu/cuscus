part of cuscus.viewmodel;

/**
 * Functionality for objects that require an id.
 */

Map<int, ObjectWithId> objectsWithId = {};

abstract class ObjectWithId {
  final int id;

  ObjectWithId() : id = _generateObjectId() {
    objectsWithId.putIfAbsent(id, () => this);
  }
}


math.Random randomGenerator = new math.Random();

int _generateObjectId() {
  int timestamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
  int objectID = timestamp * 100000 + randomGenerator.nextInt(100000);
  while (objectsWithId.containsKey(objectID)) {
    timestamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    objectID = timestamp * 100000 + randomGenerator.nextInt(100000);
  }
  return objectID;
}
