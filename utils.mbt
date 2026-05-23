/// Utility functions for IndexMap and IndexSet

///|
/// Creates an IndexMap from key-value pairs.
pub fn[K : Hash + Eq, V] indexmap_from_pairs(pairs : Array[(K, V)]) -> IndexMap[K, V] {
  let m = IndexMap::new()
  for pair in pairs {
    m.set(pair.0, pair.1)
  }
  m
}

///|
/// Creates an IndexSet from values.
pub fn[T : Hash + Eq] indexset_from_values(values : Array[T]) -> IndexSet[T] {
  let s = IndexSet::new()
  for v in values {
    let _ = s.add(v)
  }
  s
}

///|
/// Zips two arrays into an IndexMap.
pub fn[K : Hash + Eq, V] zip_to_indexmap(keys : Array[K], values : Array[V]) -> IndexMap[K, V] {
  let m = IndexMap::new()
  let len = keys.length().min(values.length())
  for i = 0 {
    if i >= len {
      break
    }
    m.set(keys[i], values[i])
    continue i + 1
  }
  m
}

///|
/// Unzips an IndexMap into keys and values arrays.
pub fn[K : Hash + Eq, V] unzip_indexmap(m : IndexMap[K, V]) -> (Array[K], Array[V]) {
  let keys : Array[K] = []
  let values : Array[V] = []
  for kv in m {
    keys.push(kv.0)
    values.push(kv.1)
  }
  (keys, values)
}

///|
/// Filters an IndexMap by a predicate.
pub fn[K : Hash + Eq, V] filter_indexmap(
  m : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> IndexMap[K, V] {
  let result = IndexMap::new()
  for kv in m {
    if pred(kv.0, kv.1) {
      result.set(kv.0, kv.1)
    }
  }
  result
}

///|
/// Maps values in an IndexMap.
pub fn[K : Hash + Eq, V, W] map_indexmap_values(
  m : IndexMap[K, V],
  f : (V) -> W,
) -> IndexMap[K, W] {
  let result = IndexMap::new()
  for kv in m {
    result.set(kv.0, f(kv.1))
  }
  result
}

///|
/// Maps keys in an IndexMap.
pub fn[K : Hash + Eq, L : Hash + Eq, V] map_indexmap_keys(
  m : IndexMap[K, V],
  f : (K) -> L,
) -> IndexMap[L, V] {
  let result = IndexMap::new()
  for kv in m {
    result.set(f(kv.0), kv.1)
  }
  result
}

///|
/// Folds an IndexMap from left to right.
pub fn[K : Hash + Eq, V, A] fold_left_indexmap(
  m : IndexMap[K, V],
  init : A,
  f : (A, K, V) -> A,
) -> A {
  let mut acc = init
  for kv in m {
    acc = f(acc, kv.0, kv.1)
  }
  acc
}

///|
/// Folds an IndexMap from right to left.
pub fn[K : Hash + Eq, V, A] fold_right_indexmap(
  m : IndexMap[K, V],
  init : A,
  f : (K, V, A) -> A,
) -> A {
  let mut acc = init
  let keys = m.keys()
  let len = keys.length()
  for i = 0 {
    if i >= len {
      break
    }
    let idx = len - 1 - i
    let key = keys[idx]
    match m.get(key) {
      None => ()
      Some(value) => acc = f(key, value, acc)
    }
    continue i + 1
  }
  acc
}

///|
/// Checks if any entry satisfies the predicate.
pub fn[K : Hash + Eq, V] any_indexmap(
  m : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> Bool {
  for kv in m {
    if pred(kv.0, kv.1) {
      return true
    }
  } nobreak {
    false
  }
}

///|
/// Checks if all entries satisfy the predicate.
pub fn[K : Hash + Eq, V] all_indexmap(
  m : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> Bool {
  for kv in m {
    if !pred(kv.0, kv.1) {
      return false
    }
  } nobreak {
    true
  }
}

///|
/// Finds the first entry satisfying the predicate.
pub fn[K : Hash + Eq, V] find_indexmap(
  m : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> (K, V)? {
  for kv in m {
    if pred(kv.0, kv.1) {
      return Some(kv)
    }
  } nobreak {
    None
  }
}

///|
/// Counts entries satisfying the predicate.
pub fn[K : Hash + Eq, V] count_indexmap(
  m : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> Int {
  let mut count = 0
  for kv in m {
    if pred(kv.0, kv.1) {
      count = count + 1
    }
  }
  count
}

///|
/// Groups entries by a key function. Returns array of (group_key, entries_count) pairs.
pub fn[K : Hash + Eq, V, G : Hash + Eq] group_by_indexmap(
  m : IndexMap[K, V],
  key_fn : (K, V) -> G,
) -> Array[G] {
  let groups : IndexMap[G, Int] = IndexMap::new()
  for kv in m {
    let group_key = key_fn(kv.0, kv.1)
    match groups.get(group_key) {
      None => groups.set(group_key, 1)
      Some(n) => groups.set(group_key, n + 1)
    }
  }
  groups.keys()
}

///|
/// Inverts an IndexMap (keys become values, values become keys).
pub fn[K : Hash + Eq, V : Hash + Eq] invert_indexmap(m : IndexMap[K, V]) -> IndexMap[V, K] {
  let result = IndexMap::new()
  for kv in m {
    result.set(kv.1, kv.0)
  }
  result
}

///|
/// Merges two IndexMaps with a conflict resolution function.
pub fn[K : Hash + Eq, V] merge_indexmap(
  m1 : IndexMap[K, V],
  m2 : IndexMap[K, V],
  resolve : (K, V, V) -> V,
) -> IndexMap[K, V] {
  let result = IndexMap::new()
  for kv in m1 {
    result.set(kv.0, kv.1)
  }
  for kv in m2 {
    match result.get(kv.0) {
      None => result.set(kv.0, kv.1)
      Some(existing) => result.set(kv.0, resolve(kv.0, existing, kv.1))
    }
  }
  result
}

///|
/// Converts an IndexMap to an array of key-value pairs.
pub fn[K : Hash + Eq, V] indexmap_to_pairs(m : IndexMap[K, V]) -> Array[(K, V)] {
  m.iter().to_array()
}

///|
/// Checks if two IndexMaps have the same keys.
pub fn[K : Hash + Eq, V, W] have_same_keys(m1 : IndexMap[K, V], m2 : IndexMap[K, W]) -> Bool {
  if m1.length() != m2.length() {
    return false
  }
  for kv in m1 {
    if !m2.contains_key(kv.0) {
      return false
    }
  }
  true
}

///|
/// Returns the difference between two IndexMaps (keys in m1 but not in m2).
pub fn[K : Hash + Eq, V, W] diff_keys(m1 : IndexMap[K, V], m2 : IndexMap[K, W]) -> Array[K] {
  let result : Array[K] = []
  for kv in m1 {
    if !m2.contains_key(kv.0) {
      result.push(kv.0)
    }
  }
  result
}

///|
/// Returns the intersection of keys between two IndexMaps.
pub fn[K : Hash + Eq, V, W] intersect_keys(m1 : IndexMap[K, V], m2 : IndexMap[K, W]) -> Array[K] {
  let result : Array[K] = []
  for kv in m1 {
    if m2.contains_key(kv.0) {
      result.push(kv.0)
    }
  }
  result
}

// ===================== IndexSet utilities =====================

///|
/// Filters an IndexSet by a predicate.
pub fn[T : Hash + Eq] filter_indexset(s : IndexSet[T], pred : (T) -> Bool) -> IndexSet[T] {
  let result = IndexSet::new()
  for value in s {
    if pred(value) {
      let _ = result.add(value)
    }
  }
  result
}

///|
/// Maps values in an IndexSet.
pub fn[T : Hash + Eq, U : Hash + Eq] map_indexset(s : IndexSet[T], f : (T) -> U) -> IndexSet[U] {
  let result = IndexSet::new()
  for value in s {
    let _ = result.add(f(value))
  }
  result
}

///|
/// Folds an IndexSet from left to right.
pub fn[T : Hash + Eq, A] fold_left_indexset(s : IndexSet[T], init : A, f : (A, T) -> A) -> A {
  let mut acc = init
  for value in s {
    acc = f(acc, value)
  }
  acc
}

///|
/// Checks if any value satisfies the predicate.
pub fn[T : Hash + Eq] any_indexset(s : IndexSet[T], pred : (T) -> Bool) -> Bool {
  for value in s {
    if pred(value) {
      return true
    }
  } nobreak {
    false
  }
}

///|
/// Checks if all values satisfy the predicate.
pub fn[T : Hash + Eq] all_indexset(s : IndexSet[T], pred : (T) -> Bool) -> Bool {
  for value in s {
    if !pred(value) {
      return false
    }
  } nobreak {
    true
  }
}

///|
/// Finds the first value satisfying the predicate.
pub fn[T : Hash + Eq] find_indexset(s : IndexSet[T], pred : (T) -> Bool) -> T? {
  for value in s {
    if pred(value) {
      return Some(value)
    }
  } nobreak {
    None
  }
}

///|
/// Counts values satisfying the predicate.
pub fn[T : Hash + Eq] count_indexset(s : IndexSet[T], pred : (T) -> Bool) -> Int {
  let mut count = 0
  for value in s {
    if pred(value) {
      count = count + 1
    }
  }
  count
}

///|
/// Partitions an IndexSet into two sets based on a predicate.
pub fn[T : Hash + Eq] partition_indexset(
  s : IndexSet[T],
  pred : (T) -> Bool,
) -> (IndexSet[T], IndexSet[T]) {
  let true_set = IndexSet::new()
  let false_set = IndexSet::new()
  for value in s {
    if pred(value) {
      let _ = true_set.add(value)
    } else {
      let _ = false_set.add(value)
    }
  }
  (true_set, false_set)
}
