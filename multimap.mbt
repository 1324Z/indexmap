/// MultiMap - A map that associates multiple values with each key.
///
/// Backed by IndexMap, so iteration preserves insertion order of keys,
/// and within each key, values are in insertion order.

///|
/// A map that can store multiple values per key.
struct MultiMap[K, V] {
  inner : IndexMap[K, Array[V]]
  mut total_size : Int
}

///|
/// Creates a new empty MultiMap.
pub fn[K : Hash + Eq, V] MultiMap::new() -> MultiMap[K, V] {
  { inner: IndexMap::new(), total_size: 0 }
}

///|
/// Creates a new MultiMap with at least the specified capacity.
pub fn[K : Hash + Eq, V] MultiMap::with_capacity(cap : Int) -> MultiMap[K, V] {
  { inner: IndexMap::with_capacity(cap), total_size: 0 }
}

///|
/// Inserts a value for the given key.
/// If the key already exists, the value is appended to its list.
pub fn[K : Hash + Eq, V] MultiMap::insert(self : MultiMap[K, V], key : K, value : V) -> Unit {
  match self.inner.get(key) {
    None => {
      self.inner.set(key, [value])
    }
    Some(arr) => {
      arr.push(value)
      self.inner.set(key, arr)
    }
  }
  self.total_size = self.total_size + 1
}

///|
/// Returns all values for the given key, or None if the key doesn't exist.
pub fn[K : Hash + Eq, V] MultiMap::get(self : MultiMap[K, V], key : K) -> Array[V]? {
  self.inner.get(key)
}

///|
/// Returns `true` if the map contains the given key.
pub fn[K : Hash + Eq, V] MultiMap::contains_key(self : MultiMap[K, V], key : K) -> Bool {
  self.inner.contains_key(key)
}

///|
/// Returns `true` if the map contains the given key-value pair.
pub fn[K : Hash + Eq, V : Eq] MultiMap::contains(
  self : MultiMap[K, V],
  key : K,
  value : V,
) -> Bool {
  match self.inner.get(key) {
    None => false
    Some(arr) => {
      for v in arr {
        if v == value {
          return true
        }
      } nobreak {
        false
      }
    }
  }
}

///|
/// Removes all values for the given key. Returns the removed values, or None.
pub fn[K : Hash + Eq, V] MultiMap::remove_key(self : MultiMap[K, V], key : K) -> Array[V]? {
  match self.inner.remove(key) {
    None => None
    Some(arr) => {
      self.total_size = self.total_size - arr.length()
      Some(arr)
    }
  }
}

///|
/// Removes a specific value for the given key.
/// Returns `true` if the value was found and removed.
pub fn[K : Hash + Eq, V : Eq] MultiMap::remove_value(
  self : MultiMap[K, V],
  key : K,
  value : V,
) -> Bool {
  match self.inner.get(key) {
    None => false
    Some(arr) => {
      let new_arr : Array[V] = []
      let mut found = false
      for v in arr {
        if !found && v == value {
          found = true
        } else {
          new_arr.push(v)
        }
      }
      if found {
        self.total_size = self.total_size - 1
        if new_arr.length() == 0 {
          let _ = self.inner.remove(key)
        } else {
          self.inner.set(key, new_arr)
        }
      }
      found
    }
  }
}

///|
/// Removes all values from the map.
pub fn[K : Hash + Eq, V] MultiMap::clear(self : MultiMap[K, V]) -> Unit {
  self.inner.clear()
  self.total_size = 0
}

///|
/// Returns the number of keys in the map.
pub fn[K : Hash + Eq, V] MultiMap::key_count(self : MultiMap[K, V]) -> Int {
  self.inner.length()
}

///|
/// Returns the total number of values across all keys.
pub fn[K : Hash + Eq, V] MultiMap::value_count(self : MultiMap[K, V]) -> Int {
  self.total_size
}

///|
/// Returns `true` if the map has no values.
pub fn[K : Hash + Eq, V] MultiMap::is_empty(self : MultiMap[K, V]) -> Bool {
  self.total_size == 0
}

///|
/// Returns all keys in insertion order.
pub fn[K : Hash + Eq, V] MultiMap::keys(self : MultiMap[K, V]) -> Array[K] {
  self.inner.keys()
}

///|
/// Returns all values across all keys in insertion order.
pub fn[K : Hash + Eq, V] MultiMap::all_values(self : MultiMap[K, V]) -> Array[V] {
  let result : Array[V] = []
  for kv in self.inner {
    for v in kv.1 {
      result.push(v)
    }
  }
  result
}

///|
/// Iterates over all key-value pairs.
pub fn[K : Hash + Eq, V] MultiMap::iter(self : MultiMap[K, V]) -> Iter[(K, V)] {
  let pairs : Array[(K, V)] = []
  for kv in self.inner {
    for v in kv.1 {
      pairs.push((kv.0, v))
    }
  }
  pairs.iter()
}

///|
/// Returns the number of values for the given key.
pub fn[K : Hash + Eq, V] MultiMap::count_for_key(self : MultiMap[K, V], key : K) -> Int {
  match self.inner.get(key) {
    None => 0
    Some(arr) => arr.length()
  }
}

///|
/// Retains only the key-value pairs for which the predicate returns `true`.
pub fn[K : Hash + Eq, V : Eq] MultiMap::retain(
  self : MultiMap[K, V],
  pred : (K, V) -> Bool,
) -> Unit {
  let keys_to_check = self.inner.keys()
  for key in keys_to_check {
    match self.inner.get(key) {
      None => ()
      Some(arr) => {
        let new_arr : Array[V] = []
        for v in arr {
          if pred(key, v) {
            new_arr.push(v)
          } else {
            self.total_size = self.total_size - 1
          }
        }
        if new_arr.length() == 0 {
          let _ = self.inner.remove(key)
        } else {
          self.inner.set(key, new_arr)
        }
      }
    }
  }
}

///|
/// Returns `true` if two MultiMaps have the same keys and values.
pub fn[K : Hash + Eq, V : Eq] MultiMap::equal(
  self : MultiMap[K, V],
  other : MultiMap[K, V],
) -> Bool {
  if self.key_count() != other.key_count() {
    return false
  }
  if self.total_size != other.total_size {
    return false
  }
  for kv in self.inner {
    match other.inner.get(kv.0) {
      None => return false
      Some(other_arr) => {
        if kv.1.length() != other_arr.length() {
          return false
        }
        for i = 0 {
          if i >= kv.1.length() {
            break
          }
          if kv.1[i] != other_arr[i] {
            return false
          }
          continue i + 1
        }
      }
    }
  }
  true
}

///|
/// Merges another MultiMap into this one.
pub fn[K : Hash + Eq, V] MultiMap::merge(
  self : MultiMap[K, V],
  other : MultiMap[K, V],
) -> Unit {
  for kv in other.inner {
    for v in kv.1 {
      self.insert(kv.0, v)
    }
  }
}

///|
/// Returns the first value for the given key.
pub fn[K : Hash + Eq, V] MultiMap::first_value(self : MultiMap[K, V], key : K) -> V? {
  match self.inner.get(key) {
    None => None
    Some(arr) => {
      if arr.length() > 0 {
        Some(arr[0])
      } else {
        None
      }
    }
  }
}

///|
/// Returns the last value for the given key.
pub fn[K : Hash + Eq, V] MultiMap::last_value(self : MultiMap[K, V], key : K) -> V? {
  match self.inner.get(key) {
    None => None
    Some(arr) => {
      if arr.length() > 0 {
        Some(arr[arr.length() - 1])
      } else {
        None
      }
    }
  }
}

///|
/// Converts a MultiMap to an array of (key, value) pairs.
pub fn[K : Hash + Eq, V] MultiMap::to_pairs(self : MultiMap[K, V]) -> Array[(K, V)] {
  let result : Array[(K, V)] = []
  for kv in self.inner {
    for v in kv.1 {
      result.push((kv.0, v))
    }
  }
  result
}

///|
/// Creates a MultiMap from an array of (key, value) pairs.
pub fn[K : Hash + Eq, V] MultiMap::from_pairs(pairs : Array[(K, V)]) -> MultiMap[K, V] {
  let m = MultiMap::new()
  for pair in pairs {
    m.insert(pair.0, pair.1)
  }
  m
}

///|
pub impl[K : Hash + Eq + Debug, V : Debug] Debug for MultiMap[K, V] with fn to_repr(
  self : MultiMap[K, V],
) {
  let entries : Array[Repr] = []
  for kv in self.inner {
    let values_repr : Array[Repr] = kv.1.map(fn(v) { @debug.to_repr(v) })
    entries.push(Repr::array([@debug.to_repr(kv.0), Repr::array(values_repr)]))
  }
  Repr::opaque_("MultiMap", Repr::array(entries))
}
