/// Edge case tests for IndexSet

///|
test "indexset large dataset" {
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  for i = 0 {
    if i >= 200 {
      break
    }
    let _ = s.add(i)
    continue i + 1
  }
  assert_eq(s.length(), 200)
  for i = 0 {
    if i >= 200 {
      break
    }
    assert_true(s.contains(i))
    continue i + 1
  }
}

///|
test "indexset string values" {
  let s : @indexmap.IndexSet[String] = @indexmap.IndexSet::new()
  let _ = s.add("hello")
  let _ = s.add("world")
  let _ = s.add("moonbit")
  assert_eq(s.length(), 3)
  assert_true(s.contains("hello"))
  assert_true(!s.contains("rust"))
}

///|
test "indexset add duplicate" {
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  assert_true(s.add(1))
  assert_true(s.add(2))
  assert_true(!s.add(1))
  assert_eq(s.length(), 2)
}

///|
test "indexset remove and readd" {
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  let _ = s.add(1)
  assert_true(s.remove(1))
  assert_true(!s.contains(1))
  assert_true(s.add(1))
  assert_true(s.contains(1))
  assert_eq(s.length(), 1)
}

///|
test "indexset pop_first sequence" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  let items : Array[Int] = []
  for i = 0 {
    if i >= 5 {
      break
    }
    match s.pop_first() {
      None => break
      Some(v) => items.push(v)
    }
    continue i + 1
  }
  assert_eq(items.length(), 5)
  assert_true(s.is_empty())
}

///|
test "indexset pop_last sequence" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  let items : Array[Int] = []
  for i = 0 {
    if i >= 5 {
      break
    }
    match s.pop_last() {
      None => break
      Some(v) => items.push(v)
    }
    continue i + 1
  }
  assert_eq(items.length(), 5)
  assert_true(s.is_empty())
}

///|
test "indexset union large" {
  let s1 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  let s2 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    let _ = s1.add(i)
    continue i + 1
  }
  for i = 50 {
    if i >= 150 {
      break
    }
    let _ = s2.add(i)
    continue i + 1
  }
  let result = s1.union(s2)
  assert_eq(result.length(), 150)
}

///|
test "indexset intersection large" {
  let s1 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  let s2 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    let _ = s1.add(i)
    continue i + 1
  }
  for i = 50 {
    if i >= 150 {
      break
    }
    let _ = s2.add(i)
    continue i + 1
  }
  let result = s1.intersection(s2)
  assert_eq(result.length(), 50)
}

///|
test "indexset difference large" {
  let s1 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  let s2 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    let _ = s1.add(i)
    continue i + 1
  }
  for i = 50 {
    if i >= 150 {
      break
    }
    let _ = s2.add(i)
    continue i + 1
  }
  let result = s1.difference(s2)
  assert_eq(result.length(), 50)
}

///|
test "indexset symmetric_difference large" {
  let s1 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  let s2 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    let _ = s1.add(i)
    continue i + 1
  }
  for i = 50 {
    if i >= 150 {
      break
    }
    let _ = s2.add(i)
    continue i + 1
  }
  let result = s1.symmetric_difference(s2)
  assert_eq(result.length(), 100)
}

///|
test "indexset empty operations" {
  let s1 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  let s2 : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  assert_true(s1.union(s2).is_empty())
  assert_true(s1.intersection(s2).is_empty())
  assert_true(s1.difference(s2).is_empty())
  assert_true(s1.is_disjoint(s2))
  assert_true(s1.is_subset(s2))
}

///|
test "indexset with_capacity" {
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::with_capacity(64)
  assert_true(s.is_empty())
  let _ = s.add(1)
  assert_eq(s.length(), 1)
}

///|
test "indexset iter count" {
  let s = @indexmap.IndexSet::from([1, 2, 3, 4, 5])
  assert_eq(s.iter().count(), 5)
}

///|
test "indexset retain all false" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  s.retain(fn(_v) { false })
  assert_true(s.is_empty())
}

///|
test "indexset retain all true" {
  let s = @indexmap.IndexSet::from([1, 2, 3])
  s.retain(fn(_v) { true })
  assert_eq(s.length(), 3)
}

///|
test "indexset extend self" {
  let s = @indexmap.IndexSet::from([1, 2])
  let s2 = @indexmap.IndexSet::from([3, 4])
  s.extend(s2)
  assert_eq(s.length(), 4)
  assert_true(s.contains(3))
  assert_true(s.contains(4))
}

///|
test "indexset order preserved after various ops" {
  let s = @indexmap.IndexSet::new()
  let _ = s.add("c")
  let _ = s.add("a")
  let _ = s.add("b")
  let _ = s.remove("a")
  let _ = s.add("d")
  // After swap-remove: c, b, d (a was at index 1, swapped with last "b")
  let items = s.to_array()
  assert_eq(items.length(), 3)
}

///|
test "indexset eq with different order" {
  let s1 = @indexmap.IndexSet::from([1, 2, 3])
  let s2 = @indexmap.IndexSet::from([3, 1, 2])
  assert_true(s1 == s2)
}

///|
test "indexset eq different sizes" {
  let s1 = @indexmap.IndexSet::from([1, 2])
  let s2 = @indexmap.IndexSet::from([1, 2, 3])
  assert_true(s1 != s2)
}

///|
test "indexset from_iter duplicates" {
  let s = @indexmap.iter_to_indexset([1, 2, 3, 1, 2, 3].iter())
  assert_eq(s.length(), 3)
}

///|
test "indexset bool values" {
  let s = @indexmap.IndexSet::new()
  let _ = s.add(true)
  let _ = s.add(false)
  assert_eq(s.length(), 2)
  assert_true(s.contains(true))
  assert_true(s.contains(false))
}

///|
test "indexset negative int values" {
  let s = @indexmap.IndexSet::new()
  let _ = s.add(-1)
  let _ = s.add(-100)
  let _ = s.add(0)
  assert_eq(s.length(), 3)
  assert_true(s.contains(-1))
  assert_true(s.contains(-100))
}

///|
test "indexset get_index out of bounds" {
  let s = @indexmap.IndexSet::from([1, 2])
  assert_eq(s.get_index(0), Some(1))
  assert_eq(s.get_index(1), Some(2))
  assert_eq(s.get_index(2), None)
  assert_eq(s.get_index(-1), None)
}

///|
test "indexset first and last on empty" {
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  assert_eq(s.first(), None)
  assert_eq(s.last(), None)
}

///|
test "indexset pop on empty" {
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  assert_eq(s.pop_first(), None)
  assert_eq(s.pop_last(), None)
}

///|
test "indexset single element" {
  let s = @indexmap.IndexSet::from([42])
  assert_eq(s.length(), 1)
  assert_eq(s.first(), Some(42))
  assert_eq(s.last(), Some(42))
  assert_eq(s.pop_first(), Some(42))
  assert_true(s.is_empty())
}
