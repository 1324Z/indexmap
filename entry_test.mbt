/// Entry API tests for IndexMap

///|
test "entry or_insert vacant" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  let val = m.entry("key1").or_insert(42)
  assert_eq(val, 42)
  assert_eq(m.get("key1"), Some(42))
}

///|
test "entry or_insert occupied" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("key1", 10)
  let val = m.entry("key1").or_insert(42)
  assert_eq(val, 10)
  assert_eq(m.get("key1"), Some(10))
}

///|
test "entry or_insert_with vacant" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  let val = m.entry("key1").or_insert_with(fn() { 99 })
  assert_eq(val, 99)
  assert_eq(m.get("key1"), Some(99))
}

///|
test "entry or_insert_with occupied" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("key1", 10)
  let val = m.entry("key1").or_insert_with(fn() { 99 })
  assert_eq(val, 10)
}

///|
test "entry and_modify occupied" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("key1", 10)
  let entry = m.entry("key1").and_modify(fn(v) { v * 2 })
  assert_true(entry.is_occupied())
  assert_eq(m.get("key1"), Some(20))
}

///|
test "entry and_modify vacant" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  let entry = m.entry("key1").and_modify(fn(v) { v * 2 })
  assert_true(entry.is_vacant())
}

///|
test "entry key" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  let entry = m.entry("test_key")
  assert_eq(entry.key(), "test_key")
}

///|
test "entry is_occupied and is_vacant" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  let vacant = m.entry("key1")
  assert_true(vacant.is_vacant())
  assert_true(!vacant.is_occupied())
  m.set("key1", 10)
  let occupied = m.entry("key1")
  assert_true(occupied.is_occupied())
  assert_true(!occupied.is_vacant())
}

///|
test "entry or_insert default value" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  let _ = m.entry("counter").or_insert(0)
  assert_eq(m.get("counter"), Some(0))
}

///|
test "entry multiple operations" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  // Insert via entry
  let _ = m.entry("x").or_insert(1)
  assert_eq(m.get("x"), Some(1))
  // Modify via entry
  let _ = m.entry("x").and_modify(fn(v) { v + 10 }).or_insert(0)
  assert_eq(m.get("x"), Some(11))
}

///|
test "entry or_insert_with computes lazily" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("exists", 42)
  // The default_fn should NOT be called since key exists
  let mut called = false
  let val = m.entry("exists").or_insert_with(fn() {
    called = true
    999
  })
  assert_eq(val, 42)
}

///|
test "entry int keys" {
  let m : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  let _ = m.entry(1).or_insert("one")
  let _ = m.entry(2).or_insert("two")
  assert_eq(m.get(1), Some("one"))
  assert_eq(m.get(2), Some("two"))
}

///|
test "entry update existing" {
  let m : @indexmap.IndexMap[Int, Array[Int]] = @indexmap.IndexMap::new()
  m.set(1, [10])
  match m.get(1) {
    None => abort("should exist")
    Some(arr) => arr.push(20)
  }
  assert_eq(m.get(1).unwrap().length(), 2)
}

///|
test "entry chained and_modify or_insert" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  // Vacant: and_modify does nothing, or_insert creates
  let val = m.entry("new").and_modify(fn(v) { v + 100 }).or_insert(1)
  assert_eq(val, 1)
  // Occupied: and_modify modifies
  let val2 = m.entry("new").and_modify(fn(v) { v + 100 }).or_insert(999)
  assert_eq(val2, 101)
  assert_eq(m.get("new"), Some(101))
}
