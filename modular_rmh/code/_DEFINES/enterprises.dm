// What a room of an enterprise is, by the locks on its doors.
/// Every way in is a door under one of the owner's keys that the staff do not carry: a room let to a guest.
#define ENTERPRISE_ROOM_GUEST "guest"
/// Every way in is a door the staff can open: a kitchen, a store, a cellar.
#define ENTERPRISE_ROOM_SERVICE "service"
/// Anything else: halls and corridors.
#define ENTERPRISE_ROOM_COMMON "common"

/// A room smaller than this gets no label on the floor's picture, unless it is a guest room.
#define ENTERPRISE_ROOM_LABEL_MIN_TILES 4
