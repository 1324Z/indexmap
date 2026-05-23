#!/usr/bin/env python3
"""Generate project declaration PDF for indexmap"""

from fpdf import FPDF

class DeclarationPDF(FPDF):
    def header(self):
        if self.page_no() == 1:
            self.set_font('Helvetica', 'B', 16)
            self.cell(0, 10, 'MoonBit Open Source Software Ecosystem Competition 2026', new_x="LMARGIN", new_y="NEXT", align='C')
            self.set_font('Helvetica', 'B', 14)
            self.cell(0, 10, 'Project Declaration', new_x="LMARGIN", new_y="NEXT", align='C')
            self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}/{{nb}}', align='C')

    def section_title(self, title):
        self.set_font('Helvetica', 'B', 12)
        self.set_fill_color(230, 230, 230)
        self.cell(0, 8, title, new_x="LMARGIN", new_y="NEXT", fill=True)
        self.ln(3)

    def subsection_title(self, title):
        self.set_font('Helvetica', 'B', 11)
        self.cell(0, 7, title, new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def body_text(self, text):
        self.set_font('Helvetica', '', 10)
        self.multi_cell(0, 5, text)
        self.ln(2)

    def bullet_point(self, text):
        self.set_font('Helvetica', '', 10)
        x = self.get_x()
        self.cell(5, 5, '-')
        self.multi_cell(0, 5, text)
        self.ln(1)

    def code_block(self, code):
        self.set_font('Courier', '', 9)
        self.set_fill_color(245, 245, 245)
        for line in code.split('\n'):
            self.cell(0, 5, line, new_x="LMARGIN", new_y="NEXT", fill=True)
        self.ln(3)

    def table_row(self, col1, col2, bold=False):
        if bold:
            self.set_font('Helvetica', 'B', 10)
        else:
            self.set_font('Helvetica', '', 10)
        self.cell(60, 6, col1, border=1)
        self.cell(0, 6, col2, border=1, new_x="LMARGIN", new_y="NEXT")


def main():
    pdf = DeclarationPDF()
    pdf.alias_nb_pages()
    pdf.add_page()

    # Section 1: Direction
    pdf.section_title('1. Competition Direction')
    pdf.body_text('Basic Data Structures and Algorithms')

    # Section 2: Project Name
    pdf.section_title('2. Project Name')
    pdf.body_text('indexmap - Insertion-Order-Preserving Hash Map')

    # Section 3: Introduction
    pdf.section_title('3. Project Introduction')
    pdf.body_text(
        'indexmap is an insertion-order-preserving hash map implemented for the MoonBit language. '
        'It combines the O(1) average lookup efficiency of hash tables with the sequential access '
        'capability of arrays, while guaranteeing that iteration always maintains insertion order.'
    )

    # Section 4: Features
    pdf.section_title('4. Project Features')

    pdf.subsection_title('4.1 Core Functionality')
    pdf.bullet_point('O(1) average time complexity for key-value lookup')
    pdf.bullet_point('O(1) time complexity for insertion-order index access')
    pdf.bullet_point('Iteration always in insertion order')
    pdf.bullet_point('Swap-remove semantics: removal uses swap-remove strategy, keeping internal array compact')

    pdf.subsection_title('4.2 Data Structure Design')
    pdf.body_text('Core design choices:')
    pdf.bullet_point('Open addressing hash table: Uses linear probing for collision resolution, consistent with MoonBit standard library HashMap')
    pdf.bullet_point('Separate order array: Maintains insertion order separately, decoupled from hash table')
    pdf.bullet_point('Key storage strategy: Order array stores keys rather than indices, so rehash operations do not affect order')

    pdf.subsection_title('4.3 Implementation Details')
    pdf.code_block('''struct Slot[K, V] {
  hash : Int
  key : K
  mut value : V
}

struct IndexMap[K, V] {
  mut entries : FixedArray[Slot[K, V]?]
  order : Array[K]
  mut capacity : Int
  mut capacity_mask : Int
  mut size : Int
}''')

    pdf.bullet_point('Hash table: Uses FixedArray[Slot[K, V]?] to store key-value pairs')
    pdf.bullet_point('Order array: Uses Array[K] to store keys in insertion order')
    pdf.bullet_point('Capacity management: Auto-resize with load factor 0.5')

    # Section 5: API Design
    pdf.section_title('5. API Design')

    pdf.subsection_title('5.1 Constructors')
    pdf.table_row('Function', 'Description', bold=True)
    pdf.table_row('IndexMap::new()', 'Create empty map')
    pdf.table_row('IndexMap::with_capacity(n)', 'Create map with at least n slots')
    pdf.table_row('IndexMap::from(arr)', 'Create map from array')

    pdf.ln(3)
    pdf.subsection_title('5.2 Core Operations')
    pdf.table_row('Method', 'Description', bold=True)
    pdf.table_row('m.set(key, value)', 'Insert or update')
    pdf.table_row('m.get(key) -> V?', 'Lookup, returns Option')
    pdf.table_row('m.at(key) -> V', 'Lookup, panics if missing')
    pdf.table_row('m.contains_key(key)', 'Key existence check')
    pdf.table_row('m.remove(key) -> V?', 'Remove and return value')

    pdf.ln(3)
    pdf.subsection_title('5.3 Index Access')
    pdf.table_row('Method', 'Description', bold=True)
    pdf.table_row('m.get_index(i)', 'Key-value pair at position i')
    pdf.table_row('m.get_index_key(i)', 'Key at position i')
    pdf.table_row('m.get_index_value(i)', 'Value at position i')

    pdf.ln(3)
    pdf.subsection_title('5.4 Iterators')
    pdf.table_row('Method', 'Description', bold=True)
    pdf.table_row('m.iter()', 'Iterate key-value pairs in order')
    pdf.table_row('m.keys_iter()', 'Iterate keys in order')
    pdf.table_row('m.values_iter()', 'Iterate values in order')

    pdf.ln(3)
    pdf.subsection_title('5.5 Operators')
    pdf.bullet_point('m[key] - bracket read (panics if missing)')
    pdf.bullet_point('m[key] = value - bracket write')

    # Section 6: Trait Implementation
    pdf.section_title('6. Trait Implementation')

    pdf.subsection_title('6.1 Eq Trait')
    pdf.body_text('Supports equality comparison between two IndexMaps. Since implemented with hash table, comparison is unordered (maps with same content but different insertion order are equal).')

    pdf.subsection_title('6.2 Debug Trait')
    pdf.body_text('Supports debug output, displayed as IndexMap({key: value, ...}) format.')

    # Section 7: Test Coverage
    pdf.section_title('7. Test Coverage')
    pdf.body_text('The project includes 30 test cases covering:')
    pdf.bullet_point('Basic CRUD operations (create, read, update, delete)')
    pdf.bullet_point('Bracket operators (read and write)')
    pdf.bullet_point('Insertion order preservation')
    pdf.bullet_point('Swap-remove semantics')
    pdf.bullet_point('Auto-resize (100 entries)')
    pdf.bullet_point('Large-scale data correctness (1000 entries)')
    pdf.bullet_point('String and integer keys')
    pdf.bullet_point('Duplicate key handling')
    pdf.bullet_point('Eq trait')
    pdf.bullet_point('Empty map iteration')

    pdf.body_text('Test result: Total tests: 30, passed: 30, failed: 0.')

    # Section 8: Usage Example
    pdf.section_title('8. Usage Example')
    pdf.code_block('''test {
  // Create and populate
  let m = @indexmap.IndexMap::from([("b", 2), ("a", 1), ("c", 3)])

  // Key lookup - O(1)
  assert_eq(m.get("a"), Some(1))
  assert_eq(m["b"], 2)  // panics if missing

  // Iteration preserves insertion order
  let keys = m.keys_iter().to_array()  // ["b", "a", "c"]

  // Index access
  assert_eq(m.get_index_key(0), Some("b"))
  assert_eq(m.get_index(1), Some(("a", 1)))

  // Update (keeps original position)
  m.set("a", 99)
  // still: ["b", "a", "c"], but m["a"] == 99

  // Remove
  assert_eq(m.remove("a"), Some(99))
  // now: ["b", "c"]
}''')

    # Section 9: Installation
    pdf.section_title('9. Installation')
    pdf.code_block('moon add moonbit-community/indexmap')
    pdf.body_text('Then import in your .mbt files:')
    pdf.code_block('let m = @indexmap.IndexMap::new()')

    # Section 10: Project Structure
    pdf.section_title('10. Project Structure')
    pdf.code_block('''indexmap/
  .github/workflows/ci.yml  # GitHub Actions CI
  indexmap.mbt               # Main implementation file
  indexmap_test.mbt          # Test file
  moon.mod.json              # Module metadata
  moon.pkg                   # Package dependencies
  README.md                  # English documentation
  DECLARATION.md             # Project declaration
  LICENSE                    # Apache-2.0 license''')

    # Section 11: Technical Highlights
    pdf.section_title('11. Technical Highlights')
    pdf.bullet_point('Consistent design with standard library: Uses same open addressing + linear probing strategy as MoonBit standard library HashMap')
    pdf.bullet_point('Efficient memory layout: Uses FixedArray for hash table, memory contiguous')
    pdf.bullet_point('Smart resize strategy: Load factor 0.5, balancing space and performance')
    pdf.bullet_point('Type safety: Complete generic support, compile-time type checking')
    pdf.bullet_point('Idiomatic MoonBit syntax: Uses #alias for operator overloading, guard pattern matching, etc.')

    # Section 12: Future Extensions
    pdf.section_title('12. Future Extensions')
    pdf.bullet_point('Entry API (entry(key).or_insert(default))')
    pdf.bullet_point('Ordered iteration (sorted order)')
    pdf.bullet_point('Serialization/deserialization support')
    pdf.bullet_point('Thread-safe version')
    pdf.bullet_point('More set operations (union, intersection, difference)')

    # Section 13: License
    pdf.section_title('13. License')
    pdf.body_text('Apache-2.0')

    # Section 14: Contact
    pdf.section_title('14. Contact')
    pdf.bullet_point('Project URL: https://gitlink.org.cn/yangayang/indexmap')
    pdf.bullet_point('Issue tracking: GitLink Issues')

    # Footer
    pdf.ln(10)
    pdf.set_font('Helvetica', 'I', 9)
    pdf.cell(0, 5, 'This project participates in MoonBit Open Source Software Ecosystem Competition 2026', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 5, 'Direction: Basic Data Structures and Algorithms', align='C')

    # Save PDF
    pdf.output('E:/moonbit/indexmap/DECLARATION.pdf')
    print('PDF generated successfully: E:/moonbit/indexmap/DECLARATION.pdf')


if __name__ == '__main__':
    main()
