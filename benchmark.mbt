/// Benchmark utilities for IndexMap and IndexSet
///
/// Provides functions to measure performance of common operations.

///|
/// Result of a benchmark run.
struct BenchResult {
  name : String
  iterations : Int
  elapsed_ms : Int
  ops_per_sec : Double
}

///|
/// Runs a benchmark and returns the result.
pub fn bench(name : String, iterations : Int, f : () -> Unit) -> BenchResult {
  let start = current_time_ms()
  for i = 0 {
    if i >= iterations {
      break
    }
    f()
    continue i + 1
  }
  let end = current_time_ms()
  let elapsed = end - start
  let ops_per_sec = if elapsed > 0 {
    iterations.to_double() / (elapsed.to_double() / 1000.0)
  } else {
    0.0
  }
  { name, iterations, elapsed_ms: elapsed, ops_per_sec }
}

///|
/// Returns current time in milliseconds (placeholder implementation).
fn current_time_ms() -> Int {
  // In real implementation, this would use system time
  // For now, return a placeholder value
  0
}

///|
/// Formats a benchmark result as a string.
pub fn BenchResult::to_string(self : BenchResult) -> String {
  "\{self.name}: \{self.iterations} iterations, \{self.elapsed_ms}ms, \{self.ops_per_sec} ops/sec"
}

///|
/// Runs insert benchmark for IndexMap.
pub fn bench_insert(n : Int) -> BenchResult {
  bench("IndexMap::insert", n, fn() {
    let m : IndexMap[Int, Int] = IndexMap::new()
    for i = 0 {
      if i >= 100 {
        break
      }
      m.set(i, i)
      continue i + 1
    }
  })
}

///|
/// Runs lookup benchmark for IndexMap.
pub fn bench_lookup(n : Int) -> BenchResult {
  let m : IndexMap[Int, Int] = IndexMap::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    m.set(i, i)
    continue i + 1
  }
  bench("IndexMap::lookup", n, fn() {
    for i = 0 {
      if i >= 100 {
        break
      }
      let _ = m.get(i)
      continue i + 1
    }
  })
}

///|
/// Runs remove benchmark for IndexMap.
pub fn bench_remove(n : Int) -> BenchResult {
  bench("IndexMap::remove", n, fn() {
    let m : IndexMap[Int, Int] = IndexMap::new()
    for i = 0 {
      if i >= 100 {
        break
      }
      m.set(i, i)
      continue i + 1
    }
    for i = 0 {
      if i >= 100 {
        break
      }
      let _ = m.remove(i)
      continue i + 1
    }
  })
}

///|
/// Runs iteration benchmark for IndexMap.
pub fn bench_iter(n : Int) -> BenchResult {
  let m : IndexMap[Int, Int] = IndexMap::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    m.set(i, i)
    continue i + 1
  }
  bench("IndexMap::iter", n, fn() {
    let _ = m.iter().count()
  })
}

///|
/// Runs add benchmark for IndexSet.
pub fn bench_set_add(n : Int) -> BenchResult {
  bench("IndexSet::add", n, fn() {
    let s : IndexSet[Int] = IndexSet::new()
    for i = 0 {
      if i >= 100 {
        break
      }
      let _ = s.add(i)
      continue i + 1
    }
  })
}

///|
/// Runs contains benchmark for IndexSet.
pub fn bench_set_contains(n : Int) -> BenchResult {
  let s : IndexSet[Int] = IndexSet::new()
  for i = 0 {
    if i >= 100 {
      break
    }
    let _ = s.add(i)
    continue i + 1
  }
  bench("IndexSet::contains", n, fn() {
    for i = 0 {
      if i >= 100 {
        break
      }
      let _ = s.contains(i)
      continue i + 1
    }
  })
}

///|
/// Runs union benchmark for IndexSet.
pub fn bench_set_union(n : Int) -> BenchResult {
  let s1 : IndexSet[Int] = IndexSet::new()
  let s2 : IndexSet[Int] = IndexSet::new()
  for i = 0 {
    if i >= 50 {
      break
    }
    let _ = s1.add(i)
    let _ = s2.add(i + 25)
    continue i + 1
  }
  bench("IndexSet::union", n, fn() {
    let _ = s1.union(s2)
  })
}

///|
/// Runs all benchmarks and returns results.
pub fn run_all_benchmarks(iterations : Int) -> Array[BenchResult] {
  let results : Array[BenchResult] = []
  results.push(bench_insert(iterations))
  results.push(bench_lookup(iterations))
  results.push(bench_remove(iterations))
  results.push(bench_iter(iterations))
  results.push(bench_set_add(iterations))
  results.push(bench_set_contains(iterations))
  results.push(bench_set_union(iterations))
  results
}

///|
/// Formats all benchmark results as a string.
pub fn format_benchmark_results(results : Array[BenchResult]) -> String {
  let mut output = "Benchmark Results:\n"
  for result in results {
    output = output + "  " + result.to_string() + "\n"
  }
  output
}
