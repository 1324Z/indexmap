///|
/// An insertion-order-preserving hash set.
///
/// Provides O(1) average lookup and O(1) access by insertion index.
/// Iteration always yields entries in insertion order.
///
/// # Example
///
/// ```mbt check
/// test {
///   let s = @indexmap.IndexSet::new()
///   let _ = s.add("b")
///   let _ = s.add("a")
///   let _ = s.add("c")
///   let items = s.iter().to_array()
///   debug_inspect(items, content="[\"b\", \"a\", \"c\"]")
/// }
/// ```
struct IndexSet[T] {
  inner : IndexMap[T, Unit]
}

///|
fn[T] new_indexset(cap : Int) -> IndexSet[T] {
  { inner: new_indexmap(cap) }
}

/// Creates a new empty `IndexSet`.
///
/// ```mbt check
/// test {
///   let s : @indexmap.IndexSet[String] = @indexmap.IndexSet::new()
///   assert_true(s.is_empty())
///   assert_eq(s.length(), 0)
/// }
/// ```
pub fn[T : Hash + Eq] IndexSet::new() -> IndexSet[T] {
  new_indexset(default_capacity)
}

/// Creates a new `IndexSet` with at least the specified capacity.
pub fn[T : Hash + Eq] IndexSet::with_capacity(cap : Int) -> IndexSet[T] {
  new_indexset(cap.max(default_capacity))
}

/// Creates a new `IndexSet` from an array of values.
///
/// ```mbt check
/// test {
///   let s = @indexmap.IndexSet::from(["x", "y", "z"])
///   assert_true(s.contains("x"))
///   assert_eq(s.length(), 3)
/// }
/// ```
pub fn[T : Hash + Eq] IndexSet::from(arr : ArrayView[T]) -> IndexSet[T] {
  let s = new_indexset(capacity_for(arr.length().max(1)))
  for e in arr {
    let _ = s.add(e)
  }
  s
}

// ===================== core operations =====================

///|
/// Adds a value to the set. Returns `true` if the value was newly inserted.
pub fn[T : Hash + Eq] IndexSet::add(self : IndexSet[T], value : T) -> Bool {
  let before = self.inner.size
  self.inner.set(value, ())
  self.inner.size > before
}

///|
/// Returns `true` if the set contains the given value.
pub fn[T : Hash + Eq] IndexSet::contains(self : IndexSet[T], value : T) -> Bool {
  self.inner.contains_key(value)
}

///|
/// Removes a value from the set. Returns `true` if the value was present.
pub fn[T : Hash + Eq] IndexSet::remove(self : IndexSet[T], value : T) -> Bool {
  match self.inner.remove(value) {
    None => false
    Some(_) => true
  }
}

///|
/// Removes all values from the set.
pub fn[T] IndexSet::clear(self : IndexSet[T]) -> Unit {
  self.inner.clear()
}

///|
/// Returns the number of values in the set.
pub fn[T] IndexSet::length(self : IndexSet[T]) -> Int {
  self.inner.length()
}

///|
/// Returns `true` if the set has no values.
pub fn[T] IndexSet::is_empty(self : IndexSet[T]) -> Bool {
  self.inner.is_empty()
}

// ===================== index access =====================

///|
/// Returns the value at the given insertion-order index.
pub fn[T : Hash + Eq] IndexSet::get_index(self : IndexSet[T], index : Int) -> T? {
  self.inner.get_index_key(index)
}

///|
/// Returns the first value in insertion order.
pub fn[T : Hash + Eq] IndexSet::first(self : IndexSet[T]) -> T? {
  self.inner.first_key()
}

///|
/// Returns the last value in insertion order.
pub fn[T : Hash + Eq] IndexSet::last(self : IndexSet[T]) -> T? {
  self.inner.last_key()
}

///|
/// Removes and returns the first value in insertion order.
pub fn[T : Hash + Eq] IndexSet::pop_first(self : IndexSet[T]) -> T? {
  self.inner.pop_first().map(fn(kv) { kv.0 })
}

///|
/// Removes and returns the last value in insertion order.
pub fn[T : Hash + Eq] IndexSet::pop_last(self : IndexSet[T]) -> T? {
  self.inner.pop_last().map(fn(kv) { kv.0 })
}

// ===================== iteration =====================

///|
/// Iterates over values in insertion order.
pub fn[T] IndexSet::iter(self : IndexSet[T]) -> Iter[T] {
  self.inner.keys_iter()
}

///|
/// Returns an array of all values in insertion order.
pub fn[T] IndexSet::to_array(self : IndexSet[T]) -> Array[T] {
  self.inner.keys()
}

// ===================== set operations =====================

///|
/// Returns a new set containing the union of this set and another.
pub fn[T : Hash + Eq] IndexSet::union(self : IndexSet[T], other : IndexSet[T]) -> IndexSet[T] {
  let result = iter_to_indexset(self.to_array().iter())
  for value in other {
    let _ = result.add(value)
  }
  result
}

///|
/// Returns a new set containing the intersection of this set and another.
pub fn[T : Hash + Eq] IndexSet::intersection(
  self : IndexSet[T],
  other : IndexSet[T],
) -> IndexSet[T] {
  let result = IndexSet::new()
  for value in self {
    if other.contains(value) {
      let _ = result.add(value)
    }
  }
  result
}

///|
/// Returns a new set containing the difference (self - other).
pub fn[T : Hash + Eq] IndexSet::difference(self : IndexSet[T], other : IndexSet[T]) -> IndexSet[T] {
  let result = IndexSet::new()
  for value in self {
    if !other.contains(value) {
      let _ = result.add(value)
    }
  }
  result
}

///|
/// Returns a new set containing the symmetric difference.
pub fn[T : Hash + Eq] IndexSet::symmetric_difference(
  self : IndexSet[T],
  other : IndexSet[T],
) -> IndexSet[T] {
  let result = IndexSet::new()
  for value in self {
    if !other.contains(value) {
      let _ = result.add(value)
    }
  }
  for value in other {
    if !self.contains(value) {
      let _ = result.add(value)
    }
  }
  result
}

///|
/// Returns `true` if this set is a subset of another.
pub fn[T : Hash + Eq] IndexSet::is_subset(self : IndexSet[T], other : IndexSet[T]) -> Bool {
  if self.length() > other.length() {
    return false
  }
  for value in self {
    if !other.contains(value) {
      return false
    }
  }
  true
}

///|
/// Returns `true` if this set is a superset of another.
pub fn[T : Hash + Eq] IndexSet::is_superset(self : IndexSet[T], other : IndexSet[T]) -> Bool {
  other.is_subset(self)
}

///|
/// Returns `true` if this set has no elements in common with another.
pub fn[T : Hash + Eq] IndexSet::is_disjoint(self : IndexSet[T], other : IndexSet[T]) -> Bool {
  for value in self {
    if other.contains(value) {
      return false
    }
  }
  true
}

///|
/// Retains only the values for which the predicate returns `true`.
pub fn[T : Hash + Eq] IndexSet::retain(self : IndexSet[T], pred : (T) -> Bool) -> Unit {
  let to_remove : Array[T] = []
  for value in self {
    if !pred(value) {
      to_remove.push(value)
    }
  }
  for value in to_remove {
    let _ = self.remove(value)
  }
}

///|
/// Extends this set with all values from another set.
pub fn[T : Hash + Eq] IndexSet::extend(self : IndexSet[T], other : IndexSet[T]) -> Unit {
  for value in other {
    let _ = self.add(value)
  }
}

// ===================== trait impls =====================

///|
pub impl[T : Hash + Eq] Eq for IndexSet[T] with fn equal(
  self : IndexSet[T],
  that : IndexSet[T],
) -> Bool {
  guard self.length() == that.length() else { return false }
  for value in self {
    guard that.contains(value) else { return false }
  } nobreak {
    true
  }
}

///|
pub impl[T : Hash + Eq + Debug] Debug for IndexSet[T] with fn to_repr(
  self : IndexSet[T],
) {
  let entries : Array[Repr] = self.iter().to_array().map(fn(v) { @debug.to_repr(v) })
  Repr::opaque_("IndexSet", Repr::array(entries))
}

///|
pub impl[T : Hash + Eq] Hash for IndexSet[T] with hash_combine(
  self : IndexSet[T],
  hasher : Hasher,
) -> Unit {
  for value in self {
    hasher.combine(value.hash())
  }
}

///|
pub fn[T : Hash + Eq] iter_to_indexset(iter : Iter[T]) -> IndexSet[T] {
  let s = IndexSet::new()
  for value in iter {
    let _ = s.add(value)
  }
  s
}
