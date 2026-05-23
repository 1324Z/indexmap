///|
test "multimap new" {
  let m : @indexmap.MultiMap[String, Int] = @indexmap.MultiMap::new()
  assert_true(m.is_empty())
  assert_eq(m.key_count(), 0)
  assert_eq(m.value_count(), 0)
}

///|
test "multimap insert and get" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("b", 3)
  assert_eq(m.key_count(), 2)
  assert_eq(m.value_count(), 3)
  let vals = m.get("a")
  assert_true(vals.is_some())
}

///|
test "multimap contains_key" {
  let m = @indexmap.MultiMap::new()
  m.insert("x", 10)
  assert_true(m.contains_key("x"))
  assert_true(!m.contains_key("y"))
}

///|
test "multimap contains value" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("a", 3)
  assert_true(m.contains("a", 2))
  assert_true(!m.contains("a", 5))
  assert_true(!m.contains("b", 1))
}

///|
test "multimap remove_key" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("b", 3)
  let removed = m.remove_key("a")
  assert_true(removed.is_some())
  assert_eq(m.key_count(), 1)
  assert_eq(m.value_count(), 1)
}

///|
test "multimap remove_value" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("a", 3)
  assert_true(m.remove_value("a", 2))
  assert_eq(m.value_count(), 2)
  assert_eq(m.count_for_key("a"), 2)
  assert_true(!m.remove_value("a", 5))
}

///|
test "multimap remove_value last value removes key" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  assert_true(m.remove_value("a", 1))
  assert_true(!m.contains_key("a"))
  assert_eq(m.key_count(), 0)
}

///|
test "multimap clear" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("b", 2)
  m.clear()
  assert_true(m.is_empty())
  assert_eq(m.key_count(), 0)
  assert_eq(m.value_count(), 0)
}

///|
test "multimap count_for_key" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("a", 3)
  m.insert("b", 4)
  assert_eq(m.count_for_key("a"), 3)
  assert_eq(m.count_for_key("b"), 1)
  assert_eq(m.count_for_key("c"), 0)
}

///|
test "multimap keys" {
  let m = @indexmap.MultiMap::new()
  m.insert("c", 1)
  m.insert("a", 2)
  m.insert("b", 3)
  let keys = m.keys()
  debug_inspect(keys, content="[\"c\", \"a\", \"b\"]")
}

///|
test "multimap all_values" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("b", 3)
  let vals = m.all_values()
  debug_inspect(vals, content="[1, 2, 3]")
}

///|
test "multimap first_value and last_value" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 10)
  m.insert("a", 20)
  m.insert("a", 30)
  assert_eq(m.first_value("a"), Some(10))
  assert_eq(m.last_value("a"), Some(30))
  assert_eq(m.first_value("b"), None)
}

///|
test "multimap to_pairs" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("b", 3)
  let pairs = m.to_pairs()
  assert_eq(pairs.length(), 3)
}

///|
test "multimap from_pairs" {
  let pairs = [("a", 1), ("a", 2), ("b", 3)]
  let m = @indexmap.MultiMap::from_pairs(pairs)
  assert_eq(m.key_count(), 2)
  assert_eq(m.value_count(), 3)
  assert_eq(m.count_for_key("a"), 2)
}

///|
test "multimap merge" {
  let m1 = @indexmap.MultiMap::new()
  m1.insert("a", 1)
  m1.insert("b", 2)
  let m2 = @indexmap.MultiMap::new()
  m2.insert("a", 3)
  m2.insert("c", 4)
  m1.merge(m2)
  assert_eq(m1.key_count(), 3)
  assert_eq(m1.value_count(), 4)
  assert_eq(m1.count_for_key("a"), 2)
}

///|
test "multimap retain" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 5)
  m.insert("b", 3)
  m.insert("b", 7)
  m.retain(fn(_k, v) { v > 2 })
  assert_eq(m.value_count(), 3)
  assert_eq(m.count_for_key("a"), 1)
  assert_eq(m.count_for_key("b"), 2)
}

///|
test "multimap equal" {
  let m1 = @indexmap.MultiMap::new()
  m1.insert("a", 1)
  m1.insert("a", 2)
  m1.insert("b", 3)
  let m2 = @indexmap.MultiMap::new()
  m2.insert("a", 1)
  m2.insert("a", 2)
  m2.insert("b", 3)
  assert_true(m1.equal(m2))
}

///|
test "multimap not equal" {
  let m1 = @indexmap.MultiMap::new()
  m1.insert("a", 1)
  let m2 = @indexmap.MultiMap::new()
  m2.insert("a", 2)
  assert_true(!m1.equal(m2))
}

///|
test "multimap with_capacity" {
  let m : @indexmap.MultiMap[Int, String] = @indexmap.MultiMap::with_capacity(64)
  assert_true(m.is_empty())
  m.insert(1, "a")
  assert_eq(m.key_count(), 1)
}

///|
test "multimap iter" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.insert("a", 2)
  m.insert("b", 3)
  let pairs = m.iter().to_array()
  assert_eq(pairs.length(), 3)
}
