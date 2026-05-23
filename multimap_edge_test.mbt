/// Edge case tests for MultiMap

///|
test "multimap large dataset" {
  let m = @indexmap.MultiMap::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    m.insert(i % 10, i)
    continue i + 1
  }
  assert_eq(m.key_count(), 10)
  assert_eq(m.value_count(), 100)
  for i = 0 {
    if i >= 10 {
      break
    }
    assert_eq(m.count_for_key(i), 10)
    continue i + 1
  }
}

///|
test "multimap stress insert remove" {
  let m = @indexmap.MultiMap::new()
  for i = 0 {
    if i >= 50 {
      break
    }
    m.insert("key", i)
    continue i + 1
  }
  assert_eq(m.count_for_key("key"), 50)
  // Remove specific values
  for i = 0 {
    if i >= 25 {
      break
    }
    let _ = m.remove_value("key", i)
    continue i + 1
  }
  assert_eq(m.count_for_key("key"), 25)
}

///|
test "multimap many keys few values each" {
  let m = @indexmap.MultiMap::new()
  for i = 0 {
    if i >= 50 {
      break
    }
    m.insert(i, i * 2)
    continue i + 1
  }
  assert_eq(m.key_count(), 50)
  assert_eq(m.value_count(), 50)
}

///|
test "multimap remove nonexistent key" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  let result = m.remove_key("nonexistent")
  assert_eq(result, None)
}

///|
test "multimap remove nonexistent value" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  assert_true(!m.remove_value("a", 99))
  assert_true(!m.remove_value("b", 1))
}

///|
test "multimap contains nonexistent" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  assert_true(!m.contains("a", 2))
  assert_true(!m.contains("b", 1))
}

///|
test "multimap get nonexistent" {
  let m = @indexmap.MultiMap::new()
  assert_eq(m.get("nonexistent"), None)
}

///|
test "multimap first_value nonexistent" {
  let m = @indexmap.MultiMap::new()
  assert_eq(m.first_value("nonexistent"), None)
}

///|
test "multimap last_value nonexistent" {
  let m = @indexmap.MultiMap::new()
  assert_eq(m.last_value("nonexistent"), None)
}

///|
test "multimap from_pairs empty" {
  let pairs : Array[(String, Int)] = []
  let m = @indexmap.MultiMap::from_pairs(pairs)
  assert_true(m.is_empty())
}

///|
test "multimap to_pairs roundtrip" {
  let pairs = [("a", 1), ("a", 2), ("b", 3)]
  let m = @indexmap.MultiMap::from_pairs(pairs)
  let back = m.to_pairs()
  assert_eq(back.length(), 3)
}

///|
test "multimap equal empty" {
  let m1 : @indexmap.MultiMap[Int, Int] = @indexmap.MultiMap::new()
  let m2 : @indexmap.MultiMap[Int, Int] = @indexmap.MultiMap::new()
  assert_true(m1.equal(m2))
}

///|
test "multimap merge empty" {
  let m1 = @indexmap.MultiMap::new()
  m1.insert("a", 1)
  let m2 : @indexmap.MultiMap[String, Int] = @indexmap.MultiMap::new()
  m1.merge(m2)
  assert_eq(m1.value_count(), 1)
}

///|
test "multimap retain empty" {
  let m : @indexmap.MultiMap[Int, Int] = @indexmap.MultiMap::new()
  m.retain(fn(_k, _v) { false })
  assert_true(m.is_empty())
}

///|
test "multimap clear idempotent" {
  let m = @indexmap.MultiMap::new()
  m.insert("a", 1)
  m.clear()
  m.clear()
  assert_true(m.is_empty())
}

///|
test "multimap int keys and string values" {
  let m = @indexmap.MultiMap::new()
  m.insert(1, "one")
  m.insert(1, "ein")
  m.insert(2, "two")
  assert_eq(m.key_count(), 2)
  assert_eq(m.count_for_key(1), 2)
  assert_true(m.contains(1, "one"))
  assert_true(m.contains(1, "ein"))
  assert_true(!m.contains(1, "three"))
}
