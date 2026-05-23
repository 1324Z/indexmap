///|
test "indexset new" {
  let s : @indexmap.IndexSet[String] = @indexmap.IndexSet::new()
  assert_true(s.is_empty())
  assert_eq(s.length(), 0)
}

///|
test "indexset from" {
  let s = @indexmap.IndexSet::from(["x", "y", "z"])
  assert_true(s.contains("x"))
  assert_true(s.contains("y"))
  assert_true(s.contains("z"))
  assert_eq(s.length(), 3)
}

///|
test "indexset add and contains" {
  let s = @indexmap.IndexSet::new()
  assert_true(s.add("a"))
  assert_true(s.add("b"))
  assert_true(!s.add("a"))
  assert_true(s.contains("a"))
  assert_true(s.contains("b"))
  assert_true(!s.contains("c"))
}

///|
test "indexset remove" {
  let s = @indexmap.IndexSet::from(["a", "b", "c"])
  assert_true(s.remove("b"))
  assert_eq(s.length(), 2)
  assert_true(!s.contains("b"))
  assert_true(!s.remove("z"))
}

///|
test "indexset order preserved" {
  let s = @indexmap.IndexSet::new()
  let _ = s.add("c")
  let _ = s.add("a")
  let _ = s.add("b")
  let items = s.to_array()
  debug_inspect(items, content="[\"c\", \"a\", \"b\"]")
}

///|
test "indexset iter" {
  let s = @indexmap.IndexSet::from(["a", "b", "c"])
  let items = s.iter().to_array()
  debug_inspect(items, content="[\"a\", \"b\", \"c\"]")
}

///|
test "indexset get_index" {
  let s = @indexmap.IndexSet::from(["a", "b", "c"])
  debug_inspect(s.get_index(0), content="Some(\"a\")")
  debug_inspect(s.get_index(1), content="Some(\"b\")")
  debug_inspect(s.get_index(2), content="Some(\"c\")")
  debug_inspect(s.get_index(3), content="None")
}

///|
test "indexset first and last" {
  let s = @indexmap.IndexSet::from(["a", "b", "c"])
  debug_inspect(s.first(), content="Some(\"a\")")
  debug_inspect(s.last(), content="Some(\"c\")")
}

///|
test "indexset pop_first and pop_last" {
  let s = @indexmap.IndexSet::from(["a", "b", "c"])
  debug_inspect(s.pop_first(), content="Some(\"a\")")
  assert_eq(s.length(), 2)
  // After removing "a" (swap-remove), order becomes ["c", "b"]
  debug_inspect(s.pop_last(), content="Some(\"b\")")
  assert_eq(s.length(), 1)
}

///|
test "indexset clear" {
  let s = @indexmap.IndexSet::from(["a", "b", "c"])
  s.clear()
  assert_true(s.is_empty())
}

///|
test "indexset union" {
  let s1 = @indexmap.IndexSet::from(["a", "b"])
  let s2 = @indexmap.IndexSet::from(["b", "c"])
  let result = s1.union(s2)
  assert_eq(result.length(), 3)
  assert_true(result.contains("a"))
  assert_true(result.contains("b"))
  assert_true(result.contains("c"))
}

///|
test "indexset intersection" {
  let s1 = @indexmap.IndexSet::from(["a", "b", "c"])
  let s2 = @indexmap.IndexSet::from(["b", "c", "d"])
  let result = s1.intersection(s2)
  assert_eq(result.length(), 2)
  assert_true(result.contains("b"))
  assert_true(result.contains("c"))
}

///|
test "indexset difference" {
  let s1 = @indexmap.IndexSet::from(["a", "b", "c"])
  let s2 = @indexmap.IndexSet::from(["b", "c", "d"])
  let result = s1.difference(s2)
  assert_eq(result.length(), 1)
  assert_true(result.contains("a"))
}

///|
test "indexset symmetric_difference" {
  let s1 = @indexmap.IndexSet::from(["a", "b", "c"])
  let s2 = @indexmap.IndexSet::from(["b", "c", "d"])
  let result = s1.symmetric_difference(s2)
  assert_eq(result.length(), 2)
  assert_true(result.contains("a"))
  assert_true(result.contains("d"))
}

///|
test "indexset is_subset and is_superset" {
  let s1 = @indexmap.IndexSet::from(["a", "b"])
  let s2 = @indexmap.IndexSet::from(["a", "b", "c"])
  assert_true(s1.is_subset(s2))
  assert_true(s2.is_superset(s1))
  assert_true(!s1.is_superset(s2))
}

///|
test "indexset is_disjoint" {
  let s1 = @indexmap.IndexSet::from(["a", "b"])
  let s2 = @indexmap.IndexSet::from(["c", "d"])
  let s3 = @indexmap.IndexSet::from(["b", "c"])
  assert_true(s1.is_disjoint(s2))
  assert_true(!s1.is_disjoint(s3))
}

///|
test "indexset retain" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  s.retain(fn(v) { v > 3 })
  assert_eq(s.length(), 2)
  assert_true(s.contains(4))
  assert_true(s.contains(5))
}

///|
test "indexset extend" {
  let s1 = @indexmap.IndexSet::from(["a", "b"])
  let s2 = @indexmap.IndexSet::from(["b", "c"])
  s1.extend(s2)
  assert_eq(s1.length(), 3)
  assert_true(s1.contains("c"))
}

///|
test "indexset eq" {
  let s1 = @indexmap.IndexSet::from(["a", "b", "c"])
  let s2 = @indexmap.IndexSet::from(["c", "b", "a"])
  assert_true(s1 == s2)
}

///|
test "indexset from_iter" {
  let s = @indexmap.iter_to_indexset(["a", "b", "c", "a", "b"].iter())
  assert_eq(s.length(), 3)
  debug_inspect(s.to_array(), content="[\"a\", \"b\", \"c\"]")
}
