/// Entry API for IndexMap
///
/// Provides a more ergonomic way to insert or update values.

///|
enum Entry[K, V] {
  Occupied(OccupiedEntry[K, V])
  Vacant(VacantEntry[K, V])
}

///|
struct OccupiedEntry[K, V] {
  map : IndexMap[K, V]
  key : K
  hash : Int
  index : Int
}

///|
struct VacantEntry[K, V] {
  map : IndexMap[K, V]
  key : K
  hash : Int
}

///|
/// Returns an entry for the given key.
pub fn[K : Hash + Eq, V] IndexMap::entry(self : IndexMap[K, V], key : K) -> Entry[K, V] {
  let hash = key.hash()
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => {
        break Vacant({ map: self, key, hash })
      }
      Some(slot) =>
        if slot.hash == hash && slot.key == key {
          break Occupied({ map: self, key, hash, index: idx })
        } else {
          continue i + 1, (idx + 1) & self.capacity_mask
        }
    }
  }
}

///|
/// Returns the value if occupied, or inserts and returns the default.
pub fn[K : Hash + Eq, V] Entry::or_insert(self : Entry[K, V], default : V) -> V {
  match self {
    Occupied(entry) => {
      match entry.map.entries[entry.index] {
        None => abort("corrupt entry")
        Some(slot) => slot.value
      }
    }
    Vacant(entry) => {
      entry.map.set(entry.key, default)
      default
    }
  }
}

///|
/// Returns the value if occupied, or inserts and returns the result of the function.
pub fn[K : Hash + Eq, V] Entry::or_insert_with(
  self : Entry[K, V],
  default_fn : () -> V,
) -> V {
  match self {
    Occupied(entry) => {
      match entry.map.entries[entry.index] {
        None => abort("corrupt entry")
        Some(slot) => slot.value
      }
    }
    Vacant(entry) => {
      let value = default_fn()
      entry.map.set(entry.key, value)
      value
    }
  }
}

///|
/// Returns the value if occupied, or inserts and returns the default value of the type.
pub fn[K : Hash + Eq, V : Default] Entry::or_default(self : Entry[K, V]) -> V {
  self.or_insert(V::default())
}

///|
/// Modifies the value if occupied.
pub fn[K : Hash + Eq, V] Entry::and_modify(
  self : Entry[K, V],
  f : (V) -> V,
) -> Entry[K, V] {
  match self {
    Occupied(entry) => {
      match entry.map.entries[entry.index] {
        None => abort("corrupt entry")
        Some(slot) => {
          slot.value = f(slot.value)
          Occupied(entry)
        }
      }
    }
    Vacant(entry) => Vacant(entry)
  }
}

///|
/// Returns the key associated with the entry.
pub fn[K, V] Entry::key(self : Entry[K, V]) -> K {
  match self {
    Occupied(entry) => entry.key
    Vacant(entry) => entry.key
  }
}

///|
/// Returns `true` if the entry is occupied.
pub fn[K, V] Entry::is_occupied(self : Entry[K, V]) -> Bool {
  match self {
    Occupied(_) => true
    Vacant(_) => false
  }
}

///|
/// Returns `true` if the entry is vacant.
pub fn[K, V] Entry::is_vacant(self : Entry[K, V]) -> Bool {
  match self {
    Occupied(_) => false
    Vacant(_) => true
  }
}
