///|
let default_capacity : Int = 8

///|
priv struct Slot[K, V] {
  hash : Int
  key : K
  mut value : V
}

/// An insertion-order-preserving hash map.
///
/// Provides O(1) average lookup by key and O(1) access by insertion index.
/// Iteration always yields entries in insertion order.
///
/// # Example
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::new()
///   m.set("b", 2)
///   m.set("a", 1)
///   m.set("c", 3)
///   let keys = m.keys_iter().to_array()
///   debug_inspect(keys, content="[\"b\", \"a\", \"c\"]")
/// }
/// ```

///|
struct IndexMap[K, V] {
  mut entries : FixedArray[Slot[K, V]?]
  order : Array[K]
  mut capacity : Int
  mut capacity_mask : Int
  mut size : Int
}

///|
fn[K, V] new_indexmap(cap : Int) -> IndexMap[K, V] {
  let cap = cap.next_power_of_two()
  {
    entries: FixedArray::make(cap, None),
    order: Array::new(),
    capacity: cap,
    capacity_mask: cap - 1,
    size: 0,
  }
}

///|
fn capacity_for(length : Int) -> Int {
  (length * 2).next_power_of_two()
}

/// Creates a new empty `IndexMap`.
///
/// ```mbt check
/// test {
///   let m : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
///   assert_true(m.is_empty())
///   assert_eq(m.length(), 0)
/// }
/// ```

///|
pub fn[K, V] IndexMap::new() -> IndexMap[K, V] {
  new_indexmap(default_capacity)
}

/// Creates a new `IndexMap` with at least the specified capacity.
///
/// ```mbt check
/// test {
///   let m : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::with_capacity(32)
///   assert_eq(m.length(), 0)
/// }
/// ```

///|
pub fn[K, V] IndexMap::with_capacity(cap : Int) -> IndexMap[K, V] {
  new_indexmap(cap.max(default_capacity))
}

/// Creates a new `IndexMap` from an array of key-value pairs.
/// Later pairs with duplicate keys overwrite earlier values (the key keeps
/// its original insertion position).
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::from([("x", 1), ("y", 2), ("z", 3)])
///   assert_eq(m.get("y"), Some(2))
///   assert_eq(m.length(), 3)
/// }
/// ```

///|
pub fn[K : Hash + Eq, V] IndexMap::from(
  arr : ArrayView[(K, V)],
) -> IndexMap[K, V] {
  let m = new_indexmap(capacity_for(arr.length().max(1)))
  for e in arr {
    m.set(e.0, e.1)
  }
  m
}

// ===================== core operations =====================

///|
/// Inserts or updates a key-value pair.
/// If the key already exists the value is updated in place (the key keeps
/// its original insertion position).
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::new()
///   m.set("a", 1)
///   m.set("a", 42)
///   debug_inspect(m.get("a"), content="Some(42)")
///   assert_eq(m.length(), 1)
/// }
/// ```
#alias("_[_]=_")
pub fn[K : Hash + Eq, V] IndexMap::set(
  self : IndexMap[K, V],
  key : K,
  value : V,
) -> Unit {
  let hash = key.hash()
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => {
        if self.size >= self.capacity / 2 {
          self.grow()
          self.insert_fresh(hash, key, value)
          return
        }
        self.entries[idx] = Some({ hash, key, value })
        self.order.push(key)
        self.size += 1
        return
      }
      Some(slot) =>
        if slot.hash == hash && slot.key == key {
          slot.value = value
          return
        } else {
          continue i + 1, (idx + 1) & self.capacity_mask
        }
    }
  }
}

///|
/// Internal: insert into the hash table without grow check.
fn[K, V] IndexMap::insert_fresh(
  self : IndexMap[K, V],
  hash : Int,
  key : K,
  value : V,
) -> Unit {
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => {
        self.entries[idx] = Some({ hash, key, value })
        self.order.push(key)
        self.size += 1
        return
      }
      Some(_) => continue i + 1, (idx + 1) & self.capacity_mask
    }
  }
}

///|
/// Returns the value associated with `key`, or `None`.
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::from([("a", 1), ("b", 2)])
///   debug_inspect(m.get("a"), content="Some(1)")
///   debug_inspect(m.get("c"), content="None")
/// }
/// ```
pub fn[K : Hash + Eq, V] IndexMap::get(self : IndexMap[K, V], key : K) -> V? {
  let hash = key.hash()
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => break None
      Some(slot) =>
        if slot.hash == hash && slot.key == key {
          break Some(slot.value)
        } else {
          continue i + 1, (idx + 1) & self.capacity_mask
        }
    }
  }
}

///|
/// Returns the value associated with `key`. Panics if the key is absent.
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::from([("a", 10), ("b", 20)])
///   assert_eq(m["a"], 10)
///   assert_eq(m["b"], 20)
/// }
/// ```
#alias("_[_]")
pub fn[K : Hash + Eq, V] IndexMap::at(self : IndexMap[K, V], key : K) -> V {
  let hash = key.hash()
  for i = 0, idx = hash & self.capacity_mask {
    guard self.entries[idx] is Some(slot)
    if slot.hash == hash && slot.key == key {
      break slot.value
    }
    continue i + 1, (idx + 1) & self.capacity_mask
  }
}

///|
/// Returns `true` if the map contains the given key.
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::from([("a", 1)])
///   assert_true(m.contains_key("a"))
///   assert_true(!m.contains_key("z"))
/// }
/// ```
pub fn[K : Hash + Eq, V] IndexMap::contains_key(
  self : IndexMap[K, V],
  key : K,
) -> Bool {
  self.get(key) is Some(_)
}

///|
/// Returns a mutable reference to the value associated with `key`.
pub fn[K : Hash + Eq, V] IndexMap::get_mut(
  self : IndexMap[K, V],
  key : K,
) -> V? {
  let hash = key.hash()
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => break None
      Some(slot) =>
        if slot.hash == hash && slot.key == key {
          break Some(slot.value)
        } else {
          continue i + 1, (idx + 1) & self.capacity_mask
        }
    }
  }
}

///|
/// Removes a key from the map, returning its value if present.
/// Uses swap-remove semantics: the removed entry is replaced by the last
/// entry in iteration order.
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
///   debug_inspect(m.remove("b"), content="Some(2)")
///   assert_eq(m.length(), 2)
///   let keys = m.keys_iter().to_array()
///   debug_inspect(keys, content="[\"a\", \"c\"]")
/// }
/// ```
pub fn[K : Hash + Eq, V] IndexMap::remove(self : IndexMap[K, V], key : K) -> V? {
  let hash = key.hash()
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => break None
      Some(slot) =>
        if slot.hash == hash && slot.key == key {
          let value = slot.value
          self.entries[idx] = None
          self.size -= 1
          // swap-remove from order
          for j = 0 {
            if j >= self.order.length() {
              break
            }
            if self.order[j] == key {
              let last = self.order.length() - 1
              if j != last {
                self.order[j] = self.order[last]
              }
              let _ = self.order.pop()
              break
            }
            continue j + 1
          }
          break Some(value)
        } else {
          continue i + 1, (idx + 1) & self.capacity_mask
        }
    }
  }
}

///|
/// Internal: rehash the map to double capacity.
fn[K, V] IndexMap::grow(self : IndexMap[K, V]) -> Unit {
  let old_entries = self.entries
  let new_cap = self.capacity * 2
  self.entries = FixedArray::make(new_cap, None)
  self.capacity = new_cap
  self.capacity_mask = new_cap - 1
  // rebuild entries; order array stays intact (it stores keys, not indices)
  self.size = 0
  for entry in old_entries {
    match entry {
      None => ()
      Some(slot) => self.insert_no_order(slot.hash, slot.key, slot.value)
    }
  }
}

///|
/// Internal: insert into hash table only (order already tracked).
fn[K, V] IndexMap::insert_no_order(
  self : IndexMap[K, V],
  hash : Int,
  key : K,
  value : V,
) -> Unit {
  for i = 0, idx = hash & self.capacity_mask {
    match self.entries[idx] {
      None => {
        self.entries[idx] = Some({ hash, key, value })
        self.size += 1
        return
      }
      Some(_) => continue i + 1, (idx + 1) & self.capacity_mask
    }
  }
}

// ===================== index-based access =====================

///|
/// Returns the number of entries.
pub fn[K, V] IndexMap::length(self : IndexMap[K, V]) -> Int {
  self.size
}

///|
/// Returns `true` if the map has no entries.
pub fn[K, V] IndexMap::is_empty(self : IndexMap[K, V]) -> Bool {
  self.size == 0
}

///|
/// Removes all entries from the map.
pub fn[K, V] IndexMap::clear(self : IndexMap[K, V]) -> Unit {
  for i in 0..<self.capacity {
    self.entries[i] = None
  }
  self.order.clear()
  self.size = 0
}

///|
/// Returns the key-value pair at the given insertion-order index.
///
/// ```mbt check
/// test {
///   let m = @indexmap.IndexMap::from([("a", 1), ("b", 2)])
///   debug_inspect(m.get_index(0), content="Some((\"a\", 1))")
///   debug_inspect(m.get_index(1), content="Some((\"b\", 2))")
///   debug_inspect(m.get_index(2), content="None")
/// }
/// ```
pub fn[K : Hash + Eq, V] IndexMap::get_index(
  self : IndexMap[K, V],
  index : Int,
) -> (K, V)? {
  if index < 0 || index >= self.order.length() {
    None
  } else {
    let key = self.order[index]
    match self.get(key) {
      None => None
      Some(v) => Some((key, v))
    }
  }
}

///|
/// Returns the value at the given insertion-order index.
pub fn[K : Hash + Eq, V] IndexMap::get_index_value(
  self : IndexMap[K, V],
  index : Int,
) -> V? {
  match self.get_index(index) {
    None => None
    Some((_, v)) => Some(v)
  }
}

///|
/// Returns the key at the given insertion-order index.
pub fn[K, V] IndexMap::get_index_key(self : IndexMap[K, V], index : Int) -> K? {
  if index < 0 || index >= self.order.length() {
    None
  } else {
    Some(self.order[index])
  }
}

// ===================== iteration =====================

///|
/// Iterates over key-value pairs in insertion order.
pub fn[K : Hash + Eq, V] IndexMap::iter(self : IndexMap[K, V]) -> Iter[(K, V)] {
  self.order
  .iter()
  .map(fn(key) {
    let v = match self.get(key) {
      Some(v) => v
      None => abort("corrupt indexmap: key in order but not in entries")
    }
    (key, v)
  })
}

///|
/// Iterates over keys in insertion order.
pub fn[K, V] IndexMap::keys_iter(self : IndexMap[K, V]) -> Iter[K] {
  self.order.iter()
}

///|
/// Iterates over values in insertion order.
pub fn[K : Hash + Eq, V] IndexMap::values_iter(
  self : IndexMap[K, V],
) -> Iter[V] {
  self.order
  .iter()
  .map(fn(key) {
    match self.get(key) {
      Some(v) => v
      None => abort("corrupt indexmap: key in order but not in entries")
    }
  })
}

// ===================== trait impls =====================

///|
pub impl[K : Hash + Eq, V : Eq] Eq for IndexMap[K, V] with fn equal(
  self : IndexMap[K, V],
  that : IndexMap[K, V],
) -> Bool {
  guard self.size == that.size else { return false }
  for kv in self {
    guard that.get(kv.0) == Some(kv.1) else { return false }
  } nobreak {
    true
  }
}

///|
pub impl[K : Hash + Eq + Debug, V : Debug] Debug for IndexMap[K, V] with fn to_repr(
  self : IndexMap[K, V],
) {
  let entries : Array[(Repr, Repr)] = self
    .iter()
    .to_array()
    .map(kv => (@debug.to_repr(kv.0), @debug.to_repr(kv.1)))
  Repr::opaque_("IndexMap", Repr::map(entries))
}
