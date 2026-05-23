///|
test "new empty map" {
  let m : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  assert_true(m.is_empty())
  assert_eq(m.length(), 0)
}

///|
test "with_capacity" {
  let m : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::with_capacity(
    32,
  )
  assert_true(m.is_empty())
  assert_eq(m.length(), 0)
}

///|
test "from array" {
  let m = @indexmap.IndexMap::from([("x", 1), ("y", 2), ("z", 3)])
  debug_inspect(m.get("x"), content="Some(1)")
  debug_inspect(m.get("y"), content="Some(2)")
  debug_inspect(m.get("z"), content="Some(3)")
  assert_eq(m.length(), 3)
}

///|
test "set and get" {
  let m = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  debug_inspect(m.get("a"), content="Some(1)")
  debug_inspect(m.get("b"), content="Some(2)")
  debug_inspect(m.get("c"), content="Some(3)")
  debug_inspect(m.get("d"), content="None")
}

///|
test "set overwrite" {
  let m = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("a", 42)
  debug_inspect(m.get("a"), content="Some(42)")
  assert_eq(m.length(), 1)
}

///|
test "bracket operator" {
  let m = @indexmap.IndexMap::from([("a", 10), ("b", 20)])
  assert_eq(m["a"], 10)
  assert_eq(m["b"], 20)
  m["a"] = 99
  assert_eq(m["a"], 99)
}

///|
test "contains_key" {
  let m = @indexmap.IndexMap::from([("a", 1)])
  assert_true(m.contains_key("a"))
  assert_true(!m.contains_key("z"))
}

///|
test "remove" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  debug_inspect(m.remove("b"), content="Some(2)")
  assert_eq(m.length(), 2)
  debug_inspect(m.get("b"), content="None")
  debug_inspect(m.get("a"), content="Some(1)")
  debug_inspect(m.get("c"), content="Some(3)")
}

///|
test "remove nonexistent" {
  let m = @indexmap.IndexMap::from([("a", 1)])
  debug_inspect(m.remove("z"), content="None")
  assert_eq(m.length(), 1)
}

///|
test "remove all" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  debug_inspect(m.remove("a"), content="Some(1)")
  debug_inspect(m.remove("b"), content="Some(2)")
  debug_inspect(m.remove("c"), content="Some(3)")
  assert_true(m.is_empty())
}

///|
test "insertion order preserved" {
  let m = @indexmap.IndexMap::new()
  m.set("c", 3)
  m.set("a", 1)
  m.set("b", 2)
  let keys = m.keys_iter().to_array()
  debug_inspect(keys, content="[\"c\", \"a\", \"b\"]")
  let values = m.values_iter().to_array()
  debug_inspect(values, content="[3, 1, 2]")
}

///|
test "iter" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  let pairs = m.iter().to_array()
  debug_inspect(pairs, content="[(\"a\", 1), (\"b\", 2), (\"c\", 3)]")
}

///|
test "get_index" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  debug_inspect(m.get_index(0), content="Some((\"a\", 1))")
  debug_inspect(m.get_index(1), content="Some((\"b\", 2))")
  debug_inspect(m.get_index(2), content="Some((\"c\", 3))")
  debug_inspect(m.get_index(3), content="None")
  debug_inspect(m.get_index(-1), content="None")
}

///|
test "get_index_key and get_index_value" {
  let m = @indexmap.IndexMap::from([("a", 10), ("b", 20)])
  debug_inspect(m.get_index_key(0), content="Some(\"a\")")
  debug_inspect(m.get_index_value(1), content="Some(20)")
}

///|
test "update preserves order" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  m.set("b", 99)
  let keys = m.keys_iter().to_array()
  debug_inspect(keys, content="[\"a\", \"b\", \"c\"]")
  assert_eq(m["b"], 99)
}

///|
test "swap_remove preserves contiguity" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
  debug_inspect(m.remove("b"), content="Some(2)")
  let keys = m.keys_iter().to_array()
  debug_inspect(keys, content="[\"a\", \"d\", \"c\"]")
}

///|
test "grow on many insertions" {
  let m = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    m.set(i, i * 10)
    continue i + 1
  }
  assert_eq(m.length(), 100)
  debug_inspect(m.get(0), content="Some(0)")
  debug_inspect(m.get(50), content="Some(500)")
  debug_inspect(m.get(99), content="Some(990)")
}

///|
test "string keys" {
  let m = @indexmap.IndexMap::new()
  m.set("hello", 1)
  m.set("world", 2)
  debug_inspect(m.get("hello"), content="Some(1)")
  debug_inspect(m.get("world"), content="Some(2)")
}

///|
test "int keys" {
  let m = @indexmap.IndexMap::new()
  m.set(42, "answer")
  m.set(0, "zero")
  debug_inspect(m.get(42), content="Some(\"answer\")")
  debug_inspect(m.get(0), content="Some(\"zero\")")
}

///|
test "from with duplicate keys" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("a", 10)])
  assert_eq(m.length(), 2)
  debug_inspect(m.get("a"), content="Some(10)")
  debug_inspect(m.get_index_key(0), content="Some(\"a\")")
}

///|
test "large map correctness" {
  let m = @indexmap.IndexMap::new()
  let n = 1000
  for i = 0 {
    if i >= n {
      break
    }
    m.set(i, i.to_string())
    continue i + 1
  }
  assert_eq(m.length(), n)
  for i = 0 {
    if i >= n {
      break
    }
    debug_inspect(m.get(i), content="Some(\"\{i.to_string()}\")")
    continue i + 1
  }
  for i = 0 {
    if i >= n {
      break
    }
    debug_inspect(m.get_index_key(i), content="Some(\{i})")
    continue i + 1
  }
}

///|
test "eq" {
  let m1 = @indexmap.IndexMap::from([("a", 1), ("b", 2)])
  let m2 = @indexmap.IndexMap::from([("b", 2), ("a", 1)])
  assert_true(m1 == m2)
}

///|
test "eq different values" {
  let m1 = @indexmap.IndexMap::from([("a", 1)])
  let m2 = @indexmap.IndexMap::from([("a", 2)])
  assert_true(m1 != m2)
}

///|
test "empty map iter" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_eq(m.iter().count(), 0)
  assert_eq(m.keys_iter().count(), 0)
  assert_eq(m.values_iter().count(), 0)
}

///|
test "clear" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  assert_eq(m.length(), 3)
  m.clear()
  assert_true(m.is_empty())
  assert_eq(m.length(), 0)
  debug_inspect(m.get("a"), content="None")
}

///|
test "get_mut" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2)])
  debug_inspect(m.get_mut("a"), content="Some(1)")
  debug_inspect(m.get_mut("z"), content="None")
}

///|
test "retain" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
  m.retain(fn(_k, v) { v > 2 })
  assert_eq(m.length(), 2)
  debug_inspect(m.get("c"), content="Some(3)")
  debug_inspect(m.get("d"), content="Some(4)")
  debug_inspect(m.get("a"), content="None")
}

///|
test "first and last" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  debug_inspect(m.first(), content="Some((\"a\", 1))")
  debug_inspect(m.last(), content="Some((\"c\", 3))")
  debug_inspect(m.first_key(), content="Some(\"a\")")
  debug_inspect(m.last_key(), content="Some(\"c\")")
}

///|
test "first and last on empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  debug_inspect(m.first(), content="None")
  debug_inspect(m.last(), content="None")
  debug_inspect(m.first_key(), content="None")
  debug_inspect(m.last_key(), content="None")
}

///|
test "pop_first and pop_last" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  debug_inspect(m.pop_first(), content="Some((\"a\", 1))")
  assert_eq(m.length(), 2)
  // After removing "a" (swap-remove), order becomes ["c", "b"]
  debug_inspect(m.pop_last(), content="Some((\"b\", 2))")
  assert_eq(m.length(), 1)
  debug_inspect(m.first_key(), content="Some(\"c\")")
}

///|
test "pop on empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  debug_inspect(m.pop_first(), content="None")
  debug_inspect(m.pop_last(), content="None")
}

///|
test "keys and values arrays" {
  let m = @indexmap.IndexMap::from([("a", 1), ("b", 2), ("c", 3)])
  let keys = m.keys()
  debug_inspect(keys, content="[\"a\", \"b\", \"c\"]")
  let values = m.values()
  debug_inspect(values, content="[1, 2, 3]")
}
