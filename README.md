# indexmap

An insertion-order-preserving hash map for [MoonBit](https://www.moonbitlang.com/).

## Features

- **O(1) average** lookup by key (hash map)
- **O(1)** access by insertion-order index
- **Iteration always in insertion order**
- **Swap-remove** for O(1) removal
- Compatible with MoonBit's `Eq` and `Debug` traits

## Installation

```bash
moon add moonbit-community/indexmap
```

Then import in your `.mbt` files:

```mbt
let m = @indexmap.IndexMap::new()
```

## Quick Start

```mbt
test {
  // Create and populate
  let m = @indexmap.IndexMap::from([("b", 2), ("a", 1), ("c", 3)])

  // Lookup by key — O(1)
  assert_eq(m.get("a"), Some(1))
  assert_eq(m["b"], 2)  // panics if missing

  // Iteration preserves insertion order
  let keys = m.keys_iter().to_array()  // ["b", "a", "c"]

  // Access by index
  assert_eq(m.get_index_key(0), Some("b"))
  assert_eq(m.get_index(1), Some(("a", 1)))

  // Update (keeps original position)
  m.set("a", 99)
  // still: ["b", "a", "c"], but m["a"] == 99

  // Remove
  assert_eq(m.remove("a"), Some(99))
  // now: ["b", "c"]
}
```

## API Reference

### Construction

| Function | Description |
|---|---|
| `IndexMap::new()` | Create an empty map |
| `IndexMap::with_capacity(n)` | Create with at least `n` slots |
| `IndexMap::from(arr)` | Create from `ArrayView[(K, V)]` |

### Core Operations

| Method | Description |
|---|---|
| `m.set(key, value)` | Insert or update |
| `m.get(key) -> V?` | Lookup, returns `Option` |
| `m.at(key) -> V` | Lookup, panics if missing |
| `m.contains_key(key) -> Bool` | Key existence check |
| `m.remove(key) -> V?` | Remove and return value |

### Index Access

| Method | Description |
|---|---|
| `m.get_index(i) -> (K, V)?` | Pair at position `i` |
| `m.get_index_key(i) -> K?` | Key at position `i` |
| `m.get_index_value(i) -> V?` | Value at position `i` |

### Iteration

| Method | Description |
|---|---|
| `m.iter() -> Iter[(K, V)]` | Key-value pairs in order |
| `m.keys_iter() -> Iter[K]` | Keys in order |
| `m.values_iter() -> Iter[V]` | Values in order |

### Collection Info

| Method | Description |
|---|---|
| `m.length() -> Int` | Number of entries |
| `m.is_empty() -> Bool` | Whether empty |

### Operators

- `m[key]` — bracket read (panics if missing)
- `m[key] = value` — bracket write

## Design

Internally uses:
- **Robin Hood hashing** (open addressing with linear probing) for the hash table
- A separate **order array** storing keys in insertion order
- **Swap-remove** semantics: removing an entry swaps it with the last, keeping the order array contiguous

## License

Apache-2.0
