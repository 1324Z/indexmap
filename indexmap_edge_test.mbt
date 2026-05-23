/// Edge case and stress tests for IndexMap

///|
test "indexmap large dataset insert" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 200 {
      break
    }
    m.set(i, i * 10)
    continue i + 1
  }
  assert_eq(m.length(), 200)
  for i = 0 {
    if i >= 200 {
      break
    }
    assert_eq(m.get(i), Some(i * 10))
    continue i + 1
  }
}

///|
test "indexmap large dataset remove all" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    m.set(i, i)
    continue i + 1
  }
  // Remove all by repeatedly removing the first key (swap-remove safe)
  for i = 0 {
    if i >= 100 {
      break
    }
    match m.first() {
      None => break
      Some((k, _v)) => {
        let _ = m.remove(k)
      }
    }
    continue i + 1
  }
  assert_true(m.is_empty())
}

///|
test "indexmap large dataset remove reverse order" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    m.set(i, i)
    continue i + 1
  }
  for i = 99 {
    if i < 0 {
      break
    }
    let _ = m.remove(i)
    continue i - 1
  }
  assert_true(m.is_empty())
}

///|
test "indexmap stress insert remove cycles" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for cycle = 0 {
    if cycle >= 10 {
      break
    }
    // Insert 50 items
    for i = 0 {
      if i >= 50 {
        break
      }
      m.set(cycle * 50 + i, i)
      continue i + 1
    }
    // Remove 25 items by key using pop_last (swap-remove safe)
    for i = 0 {
      if i >= 25 {
        break
      }
      let _ = m.pop_last()
      continue i + 1
    }
    continue cycle + 1
  }
  assert_eq(m.length(), 250)
}

///|
test "indexmap string keys" {
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  m.set("hello", 1)
  m.set("world", 2)
  m.set("moonbit", 3)
  assert_eq(m.length(), 3)
  assert_eq(m.get("hello"), Some(1))
  assert_eq(m.get("world"), Some(2))
  assert_eq(m.get("moonbit"), Some(3))
  assert_eq(m.get("missing"), None)
}

///|
test "indexmap bool keys" {
  let m : @indexmap.IndexMap[Bool, String] = @indexmap.IndexMap::new()
  m.set(true, "yes")
  m.set(false, "no")
  assert_eq(m.get(true), Some("yes"))
  assert_eq(m.get(false), Some("no"))
}

///|
test "indexmap update preserves order" {
  let m : @indexmap.IndexMap[Int, String] = @indexmap.IndexMap::new()
  m.set(1, "a")
  m.set(2, "b")
  m.set(3, "c")
  m.set(2, "updated")
  let keys = m.keys()
  debug_inspect(keys, content="[1, 2, 3]")
  assert_eq(m.get(2), Some("updated"))
}

///|
test "indexmap with_capacity creates usable map" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::with_capacity(256)
  assert_true(m.is_empty())
  m.set(42, 100)
  assert_eq(m.get(42), Some(100))
}

///|
test "indexmap grow triggers rehash" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::with_capacity(4)
  for i = 0 {
    if i >= 20 {
      break
    }
    m.set(i, i * i)
    continue i + 1
  }
  assert_eq(m.length(), 20)
  // Verify all values survived rehash
  for i = 0 {
    if i >= 20 {
      break
    }
    assert_eq(m.get(i), Some(i * i))
    continue i + 1
  }
}

///|
test "indexmap iter count" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 50 {
      break
    }
    m.set(i, i)
    continue i + 1
  }
  assert_eq(m.iter().count(), 50)
}

///|
test "indexmap iter to_array roundtrip" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  m.set(3, 30)
  let pairs = m.iter().to_array()
  assert_eq(pairs.length(), 3)
  // First pair should be (1, 10)
  assert_eq(pairs[0].0, 1)
  assert_eq(pairs[0].1, 10)
}

///|
test "indexmap keys and values alignment" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(3, 30)
  m.set(1, 10)
  m.set(2, 20)
  let keys = m.keys()
  let values = m.values()
  assert_eq(keys.length(), 3)
  assert_eq(values.length(), 3)
  for i = 0 {
    if i >= keys.length() {
      break
    }
    assert_eq(m.get(keys[i]), Some(values[i]))
    continue i + 1
  }
}

///|
test "indexmap pop_first last remaining" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  let result = m.pop_first()
  assert_eq(result, Some((1, 10)))
  assert_true(m.is_empty())
}

///|
test "indexmap pop_last last remaining" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  let result = m.pop_last()
  assert_eq(result, Some((1, 10)))
  assert_true(m.is_empty())
}

///|
test "indexmap remove nonexistent" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  let result = m.remove(999)
  assert_eq(result, None)
  assert_eq(m.length(), 1)
}

///|
test "indexmap first and last on empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_eq(m.first(), None)
  assert_eq(m.last(), None)
}

///|
test "indexmap pop on empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_eq(m.pop_first(), None)
  assert_eq(m.pop_last(), None)
}

///|
test "indexmap double clear" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.clear()
  m.clear()
  assert_true(m.is_empty())
}

///|
test "indexmap set same key multiple times" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 10 {
      break
    }
    m.set(1, i)
    continue i + 1
  }
  assert_eq(m.length(), 1)
  assert_eq(m.get(1), Some(9))
}

///|
test "indexmap alternating insert remove" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  for i = 0 {
    if i >= 50 {
      break
    }
    m.set(i, i)
    let _ = m.remove(i - 1)
    continue i + 1
  }
  // Due to swap-remove, the exact keys remaining vary
  // But we know each insert adds 1 and each successful remove subtracts 1
  // Insert 0: remove -1 (no op) -> 1 item
  // Insert 1: remove 0 (succeeds, but 1 swaps to 0's spot... wait no)
  // Actually: set(0,0), remove(-1) -> {0:0} len=1
  // set(1,1), remove(0) -> {1:1} len=1 (0 was removed, 1 stays)
  // set(2,2), remove(1) -> {2:2} len=1
  // So at any time there's 1 item. After 50 iterations: 1 item.
  assert_eq(m.length(), 1)
}

///|
test "indexmap negative keys" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(-1, 10)
  m.set(-100, 20)
  m.set(0, 30)
  assert_eq(m.get(-1), Some(10))
  assert_eq(m.get(-100), Some(20))
  assert_eq(m.get(0), Some(30))
}

///|
test "indexmap get_index edge cases" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  assert_eq(m.get_index_value(0), Some(10))
  assert_eq(m.get_index_value(1), Some(20))
  assert_eq(m.get_index_value(2), None)
  assert_eq(m.get_index_value(-1), None)
}

///|
test "indexmap get_index_key edge cases" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  assert_eq(m.get_index_key(0), Some(1))
  assert_eq(m.get_index_key(1), Some(2))
  assert_eq(m.get_index_key(2), None)
}

///|
test "indexmap contains_key on empty" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_true(!m.contains_key(1))
}

///|
test "indexmap get_mut exists" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  let result = m.get_mut(1)
  assert_true(result.is_some())
}

///|
test "indexmap get_mut nonexistent" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  assert_eq(m.get_mut(1), None)
}

///|
test "indexmap retain removes all" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  m.set(3, 30)
  m.retain(fn(_k, _v) { false })
  assert_true(m.is_empty())
}

///|
test "indexmap retain keeps all" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  m.set(2, 20)
  m.retain(fn(_k, _v) { true })
  assert_eq(m.length(), 2)
}

///|
test "indexmap extend with empty" {
  let m1 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m1.set(1, 10)
  let m2 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m1.extend(m2)
  assert_eq(m1.length(), 1)
}

///|
test "indexmap extend empty with nonempty" {
  let m1 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  let m2 : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m2.set(1, 10)
  m1.extend(m2)
  assert_eq(m1.length(), 1)
}

///|
test "indexmap capacity" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::with_capacity(32)
  assert_true(m.capacity() >= 32)
}

///|
test "indexmap shrink_to_fit" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::with_capacity(128)
  for i = 0 {
    if i >= 5 {
      break
    }
    m.set(i, i)
    continue i + 1
  }
  m.shrink_to_fit()
  assert_true(m.capacity() >= 5)
  assert_eq(m.length(), 5)
}

///|
test "indexmap integer value type" {
  let m : @indexmap.IndexMap[String, Array[Int]] = @indexmap.IndexMap::new()
  m.set("numbers", [1, 2, 3])
  match m.get("numbers") {
    None => abort("should exist")
    Some(arr) => assert_eq(arr.length(), 3)
  }
}

///|
test "indexmap many collisions with small capacity" {
  // Using with_capacity(4) and inserting 20 items forces many collisions
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::with_capacity(4)
  for i = 0 {
    if i >= 20 {
      break
    }
    m.set(i, i * 2)
    continue i + 1
  }
  assert_eq(m.length(), 20)
  for i = 0 {
    if i >= 20 {
      break
    }
    assert_eq(m.get(i), Some(i * 2))
    continue i + 1
  }
}

///|
test "indexmap remove and reinsert" {
  let m : @indexmap.IndexMap[Int, Int] = @indexmap.IndexMap::new()
  m.set(1, 10)
  let _ = m.remove(1)
  assert_true(!m.contains_key(1))
  m.set(1, 20)
  assert_eq(m.get(1), Some(20))
  assert_eq(m.length(), 1)
}
