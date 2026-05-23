/// Tests for utility functions

///|
test "utils indexmap_from_pairs" {
  let pairs = [(1, "a"), (2, "b"), (3, "c")]
  let m = @indexmap.indexmap_from_pairs(pairs)
  assert_eq(m.length(), 3)
  assert_eq(m.get(1), Some("a"))
  assert_eq(m.get(2), Some("b"))
}

///|
test "utils indexset_from_values" {
  let values = [1, 2, 3, 2, 1]
  let s = @indexmap.indexset_from_values(values)
  assert_eq(s.length(), 3)
  assert_true(s.contains(1))
  assert_true(s.contains(2))
  assert_true(s.contains(3))
}

///|
test "utils zip_to_indexmap" {
  let keys = ["a", "b", "c"]
  let values = [1, 2, 3]
  let m = @indexmap.zip_to_indexmap(keys, values)
  assert_eq(m.length(), 3)
  assert_eq(m.get("a"), Some(1))
  assert_eq(m.get("c"), Some(3))
}

///|
test "utils zip_to_indexmap different lengths" {
  let keys = ["a", "b", "c", "d"]
  let values = [1, 2]
  let m = @indexmap.zip_to_indexmap(keys, values)
  assert_eq(m.length(), 2)
}

///|
test "utils unzip_indexmap" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("x", 10)
  m.set("y", 20)
  let (keys, values) = @indexmap.unzip_indexmap(m)
  assert_eq(keys.length(), 2)
  assert_eq(values.length(), 2)
}

///|
test "utils filter_indexmap" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  m.set(3, 30)
  let filtered = @indexmap.filter_indexmap(m, fn(_k, v) { v > 15 })
  assert_eq(filtered.length(), 2)
  assert_true(filtered.contains_key(2))
  assert_true(filtered.contains_key(3))
}

///|
test "utils map_indexmap_values" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("b", 2)
  let mapped = @indexmap.map_indexmap_values(m, fn(v) { v * 10 })
  assert_eq(mapped.get("a"), Some(10))
  assert_eq(mapped.get("b"), Some(20))
}

///|
test "utils map_indexmap_keys" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("b", 2)
  let mapped = @indexmap.map_indexmap_keys(m, fn(k) { k + k })
  assert_eq(mapped.get("aa"), Some(1))
  assert_eq(mapped.get("bb"), Some(2))
}

///|
test "utils fold_left_indexmap" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  let sum = @indexmap.fold_left_indexmap(m, 0, fn(acc, _k, v) { acc + v })
  assert_eq(sum, 6)
}

///|
test "utils fold_right_indexmap" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  let result = @indexmap.fold_right_indexmap(m, "", fn(k, _v, acc) { k + acc })
  assert_eq(result, "abc")
}

///|
test "utils any_indexmap" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  assert_true(@indexmap.any_indexmap(m, fn(_k, v) { v > 15 }))
  assert_true(!@indexmap.any_indexmap(m, fn(_k, v) { v > 100 }))
}

///|
test "utils all_indexmap" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  assert_true(@indexmap.all_indexmap(m, fn(_k, v) { v > 0 }))
  assert_true(!@indexmap.all_indexmap(m, fn(_k, v) { v > 15 }))
}

///|
test "utils find_indexmap" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  m.set(3, 30)
  let result = @indexmap.find_indexmap(m, fn(_k, v) { v == 20 })
  assert_eq(result, Some((2, 20)))
  let none = @indexmap.find_indexmap(m, fn(_k, v) { v == 99 })
  assert_eq(none, None)
}

///|
test "utils count_indexmap" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  m.set(3, 30)
  assert_eq(@indexmap.count_indexmap(m, fn(_k, v) { v > 15 }), 2)
  assert_eq(@indexmap.count_indexmap(m, fn(_k, v) { v > 100 }), 0)
}

///|
test "utils invert_indexmap" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("a", 1)
  m.set("b", 2)
  let inverted = @indexmap.invert_indexmap(m)
  assert_eq(inverted.get(1), Some("a"))
  assert_eq(inverted.get(2), Some("b"))
}

///|
test "utils merge_indexmap" {
  let m1 : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m1.set("a", 1)
  m1.set("b", 2)
  let m2 : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m2.set("b", 20)
  m2.set("c", 30)
  let merged = @indexmap.merge_indexmap(m1, m2, fn(_k, v1, v2) { v1 + v2 })
  assert_eq(merged.get("a"), Some(1))
  assert_eq(merged.get("b"), Some(22))
  assert_eq(merged.get("c"), Some(30))
}

///|
test "utils indexmap_to_pairs" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("x", 10)
  m.set("y", 20)
  let pairs = @indexmap.indexmap_to_pairs(m)
  assert_eq(pairs.length(), 2)
}

///|
test "utils have_same_keys" {
  let m1 : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  m1.set(1, "a")
  m1.set(2, "b")
  let m2 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m2.set(1, 10)
  m2.set(2, 20)
  assert_true(@indexmap.have_same_keys(m1, m2))
}

///|
test "utils have_same_keys different" {
  let m1 : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  m1.set(1, "a")
  let m2 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m2.set(2, 20)
  assert_true(!@indexmap.have_same_keys(m1, m2))
}

///|
test "utils diff_keys" {
  let m1 : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  m1.set(1, "a")
  m1.set(2, "b")
  m1.set(3, "c")
  let m2 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m2.set(2, 20)
  let diff = @indexmap.diff_keys(m1, m2)
  assert_eq(diff.length(), 2)
}

///|
test "utils intersect_keys" {
  let m1 : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  m1.set(1, "a")
  m1.set(2, "b")
  m1.set(3, "c")
  let m2 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m2.set(2, 20)
  m2.set(3, 30)
  let inter = @indexmap.intersect_keys(m1, m2)
  assert_eq(inter.length(), 2)
}

///|
test "utils filter_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  let filtered = @indexmap.filter_indexset(s, fn(v) { v > 3 })
  assert_eq(filtered.length(), 2)
  assert_true(filtered.contains(4))
  assert_true(filtered.contains(5))
}

///|
test "utils map_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  let mapped = @indexmap.map_indexset(s, fn(v) { v * 10 })
  assert_eq(mapped.length(), 3)
  assert_true(mapped.contains(10))
  assert_true(mapped.contains(20))
  assert_true(mapped.contains(30))
}

///|
test "utils fold_left_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  let sum = @indexmap.fold_left_indexset(s, 0, fn(acc, v) { acc + v })
  assert_eq(sum, 6)
}

///|
test "utils any_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  assert_true(@indexmap.any_indexset(s, fn(v) { v > 2 }))
  assert_true(!@indexmap.any_indexset(s, fn(v) { v > 10 }))
}

///|
test "utils all_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  assert_true(@indexmap.all_indexset(s, fn(v) { v > 0 }))
  assert_true(!@indexmap.all_indexset(s, fn(v) { v > 1 }))
}

///|
test "utils find_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  assert_eq(@indexmap.find_indexset(s, fn(v) { v == 2 }), Some(2))
  assert_eq(@indexmap.find_indexset(s, fn(v) { v == 99 }), None)
}

///|
test "utils count_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  assert_eq(@indexmap.count_indexset(s, fn(v) { v > 3 }), 2)
}

///|
test "utils partition_indexset" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  let (evens, odds) = @indexmap.partition_indexset(s, fn(v) { v % 2 == 0 })
  assert_eq(evens.length(), 2)
  assert_eq(odds.length(), 3)
  assert_true(evens.contains(2))
  assert_true(odds.contains(1))
}

///|
test "utils group_by_indexmap" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("a1", 10)
  m.set("b1", 20)
  m.set("a2", 30)
  let groups = @indexmap.group_by_indexmap(m, fn(k, _v) { k[0:1] })
  assert_eq(groups.length(), 2)
}

///|
test "utils any_indexmap empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_true(!@indexmap.any_indexmap(m, fn(_k, v) { v > 0 }))
}

///|
test "utils all_indexmap empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_true(@indexmap.all_indexmap(m, fn(_k, v) { v > 0 }))
}

///|
test "utils count_indexmap empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_eq(@indexmap.count_indexmap(m, fn(_k, v) { v > 0 }), 0)
}
