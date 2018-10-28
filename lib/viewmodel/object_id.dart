part of cuscus.viewmodel;

/**
 * Functionality for objects that require an id.
 */

Map<int, ObjectWithId> objectsWithId = {};

abstract class ObjectWithId {
  int _id;
  int get id => _id;

  ObjectWithId([int id]) {
    if (objectsWithId.containsKey(id)) {
      throw "Cannot create object: another object with the same ID already exists";
    } else if (id == null) {
      _id = _generateObjectId();
    } else {
      _id = id;
    }

    objectsWithId[_id] = this;
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
