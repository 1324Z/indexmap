#!/usr/bin/env python3
"""Generate Chinese project declaration PDF for indexmap"""

from fpdf import FPDF
import os

class DeclarationPDF(FPDF):
    def __init__(self):
        super().__init__()
        # Add Chinese font
        self.add_font('MicrosoftYaHei', '', 'C:/Windows/Fonts/msyh.ttc', uni=True)
        self.add_font('MicrosoftYaHei', 'B', 'C:/Windows/Fonts/msyhbd.ttc', uni=True)

    def header(self):
        if self.page_no() == 1:
            self.set_font('MicrosoftYaHei', 'B', 18)
            self.cell(0, 12, 'MoonBit 国产基础软件生态开源大赛 2026', new_x="LMARGIN", new_y="NEXT", align='C')
            self.set_font('MicrosoftYaHei', 'B', 16)
            self.cell(0, 10, '项目申报书', new_x="LMARGIN", new_y="NEXT", align='C')
            self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('MicrosoftYaHei', '', 8)
        self.cell(0, 10, f'第 {self.page_no()} 页 / 共 {{nb}} 页', align='C')

    def section_title(self, title):
        self.set_font('MicrosoftYaHei', 'B', 14)
        self.set_fill_color(230, 230, 230)
        self.cell(0, 10, title, new_x="LMARGIN", new_y="NEXT", fill=True)
        self.ln(3)

    def subsection_title(self, title):
        self.set_font('MicrosoftYaHei', 'B', 12)
        self.cell(0, 8, title, new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def body_text(self, text):
        self.set_font('MicrosoftYaHei', '', 10)
        self.multi_cell(0, 6, text)
        self.ln(2)

    def bullet_point(self, text):
        self.set_font('MicrosoftYaHei', '', 10)
        x = self.get_x()
        self.cell(5, 6, '•')
        self.multi_cell(0, 6, text)
        self.ln(1)

    def code_block(self, code):
        # Check if code contains Chinese characters
        has_chinese = any('一' <= c <= '鿿' for c in code)
        if has_chinese:
            self.set_font('MicrosoftYaHei', '', 9)
        else:
            self.set_font('Courier', '', 9)
        self.set_fill_color(245, 245, 245)
        for line in code.split('\n'):
            self.cell(0, 5, line, new_x="LMARGIN", new_y="NEXT", fill=True)
        self.ln(3)

    def table_row(self, col1, col2, bold=False):
        if bold:
            self.set_font('MicrosoftYaHei', 'B', 10)
        else:
            self.set_font('MicrosoftYaHei', '', 10)
        self.cell(70, 7, col1, border=1)
        self.cell(0, 7, col2, border=1, new_x="LMARGIN", new_y="NEXT")


def main():
    pdf = DeclarationPDF()
    pdf.alias_nb_pages()
    pdf.add_page()

    # 第一节：参赛方向
    pdf.section_title('一、参赛方向')
    pdf.body_text('基础数据结构与算法')

    # 第二节：项目名称
    pdf.section_title('二、项目名称')
    pdf.body_text('indexmap — 插入顺序保持哈希映射与集合')

    # 第三节：项目简介
    pdf.section_title('三、项目简介')
    pdf.body_text(
        'indexmap 是一个为 MoonBit 语言实现的插入顺序保持哈希映射（Insertion-Order-Preserving Hash Map）'
        '及配套数据结构库。它结合了哈希表的 O(1) 平均查找效率和数组的顺序访问能力，同时保证迭代时元素始终保持插入顺序。'
        '项目包含 IndexMap、IndexSet、MultiMap、Entry API、Benchmark 工具和丰富的实用函数，'
        '总计 4062 行 MoonBit 代码，207 个测试全部通过。'
    )

    # 第四节：项目方向与适用场景
    pdf.section_title('四、项目方向与适用场景')
    pdf.subsection_title('4.1 项目方向')
    pdf.body_text('本项目属于「基础数据结构与算法」方向，为 MoonBit 语言生态系统提供一套完整的有序哈希数据结构库。')

    pdf.subsection_title('4.2 适用场景')
    pdf.bullet_point('需要保持插入顺序的键值存储场景（如配置管理、缓存系统）')
    pdf.bullet_point('需要通过索引快速访问元素的场景（如 LRU 缓存、历史记录）')
    pdf.bullet_point('需要高效去重同时保持顺序的场景（如去重日志、有序集合）')
    pdf.bullet_point('需要一个键对应多个值的场景（如标签系统、多对多关系）')
    pdf.bullet_point('JSON 序列化、API 响应等需要确定性输出顺序的场景')

    # 第五节：项目特色
    pdf.section_title('五、项目特色')

    pdf.subsection_title('5.1 核心功能')
    pdf.bullet_point('O(1) 平均时间复杂度的键值查找')
    pdf.bullet_point('O(1) 时间复杂度的插入顺序索引访问')
    pdf.bullet_point('迭代始终按插入顺序进行')
    pdf.bullet_point('向后移动删除策略：修复了探查链断裂问题，确保哈希表正确性')
    pdf.bullet_point('IndexSet 集合运算：union、intersection、difference、symmetric_difference')
    pdf.bullet_point('MultiMap 多值映射：一个键关联多个值')

    pdf.subsection_title('5.2 数据结构设计')
    pdf.body_text('采用以下核心设计：')
    pdf.bullet_point('开放寻址哈希表：使用线性探测解决冲突，与 MoonBit 标准库 HashMap 一致')
    pdf.bullet_point('分离的顺序数组：单独维护插入顺序，与哈希表解耦')
    pdf.bullet_point('键存储策略：顺序数组存储键而非索引，使 rehash 操作不影响顺序')
    pdf.bullet_point('向后移动删除：删除时将后续条目向前移动，保持探查链完整性')

    pdf.subsection_title('5.3 模块概览')
    pdf.table_row('模块', '功能', bold=True)
    pdf.table_row('IndexMap', '核心有序哈希映射（653 行）')
    pdf.table_row('IndexSet', '有序哈希集合（304 行）')
    pdf.table_row('MultiMap', '多值映射（321 行）')
    pdf.table_row('Entry API', '惰性插入/更新模式（134 行）')
    pdf.table_row('Benchmark', '性能基准测试工具（201 行）')
    pdf.table_row('Utils', '实用函数库（379 行）')

    # 第六节：项目原创性说明
    pdf.section_title('六、项目原创性说明')
    pdf.body_text('本项目为原创项目。')
    pdf.subsection_title('6.1 设计灵感')
    pdf.body_text(
        '项目设计参考了 Rust 语言的 indexmap 库和 MoonBit 标准库的 HashMap 实现，'
        '但代码完全使用 MoonBit 语言从零实现，未直接移植任何现有代码。'
    )
    pdf.subsection_title('6.2 原创性体现')
    pdf.bullet_point('使用 MoonBit 特有的语法特性（如 #alias、guard 模式匹配、for-loop state）')
    pdf.bullet_point('针对 MoonBit 类型系统进行泛型设计优化')
    pdf.bullet_point('采用 MoonBit 标准库一致的哈希策略（Robin Hood hashing）')
    pdf.bullet_point('独立实现的向后移动删除算法，正确处理探查链')
    pdf.bullet_point('为 MoonBit 生态系统定制的 API 设计')
    pdf.bullet_point('完整的 Entry API 实现（or_insert、or_insert_with、and_modify）')

    # 第七节：API 设计
    pdf.section_title('七、API 设计')

    pdf.subsection_title('7.1 IndexMap 构造函数')
    pdf.table_row('函数', '说明', bold=True)
    pdf.table_row('IndexMap::new()', '创建空映射')
    pdf.table_row('IndexMap::with_capacity(n)', '创建至少 n 个槽位的映射')
    pdf.table_row('IndexMap::from(arr)', '从数组创建映射')

    pdf.ln(3)
    pdf.subsection_title('7.2 IndexMap 核心操作')
    pdf.table_row('方法', '说明', bold=True)
    pdf.table_row('m.set(key, value)', '插入或更新')
    pdf.table_row('m.get(key) -> V?', '查找，返回 Option')
    pdf.table_row('m.at(key) -> V', '查找，缺失时 panic')
    pdf.table_row('m.contains_key(key)', '键存在性检查')
    pdf.table_row('m.remove(key) -> V?', '删除并返回值')
    pdf.table_row('m.entry(key)', '获取 Entry 用于惰性操作')

    pdf.ln(3)
    pdf.subsection_title('7.3 IndexSet 操作')
    pdf.table_row('方法', '说明', bold=True)
    pdf.table_row('s.add(value)', '添加元素，返回是否新增')
    pdf.table_row('s.contains(value)', '元素存在性检查')
    pdf.table_row('s.remove(value)', '删除元素')
    pdf.table_row('s.union(other)', '集合并集')
    pdf.table_row('s.intersection(other)', '集合交集')
    pdf.table_row('s.difference(other)', '集合差集')

    pdf.ln(3)
    pdf.subsection_title('7.4 Entry API')
    pdf.table_row('方法', '说明', bold=True)
    pdf.table_row('entry.or_insert(v)', '空时插入默认值')
    pdf.table_row('entry.or_insert_with(f)', '空时用函数生成值')
    pdf.table_row('entry.and_modify(f)', '存在时修改值')
    pdf.table_row('entry.or_default()', '空时插入类型默认值')

    pdf.ln(3)
    pdf.subsection_title('7.5 工具函数')
    pdf.table_row('函数', '说明', bold=True)
    pdf.table_row('filter_indexmap(m, pred)', '过滤映射')
    pdf.table_row('map_indexmap_values(m, f)', '映射值')
    pdf.table_row('fold_left_indexmap(m, init, f)', '左折叠')
    pdf.table_row('merge_indexmap(m1, m2, resolve)', '合并两个映射')
    pdf.table_row('partition_indexset(s, pred)', '分区集合')

    # 第八节：特性实现
    pdf.section_title('八、特性实现')

    pdf.subsection_title('8.1 Eq 特性')
    pdf.body_text(
        'IndexMap 和 IndexSet 均实现了 Eq 特性。由于使用哈希表实现，比较是无序的'
        '（不同插入顺序但相同内容的映射/集合相等）。'
    )

    pdf.subsection_title('8.2 Debug 特性')
    pdf.body_text('支持调试输出，显示为 IndexMap({key: value, ...}) 和 IndexSet([values]) 格式。')

    pdf.subsection_title('8.3 Hash 特性')
    pdf.body_text('IndexSet 实现了 Hash 特性，支持作为其他哈希表的键使用。')

    # 第九节：测试覆盖
    pdf.section_title('九、测试覆盖')
    pdf.body_text('项目包含 207 个测试用例，覆盖所有模块和边界情况：')

    pdf.subsection_title('9.1 测试分类统计')
    pdf.table_row('模块', '测试数', bold=True)
    pdf.table_row('IndexMap 基础', '30')
    pdf.table_row('IndexMap 边界/压力', '36')
    pdf.table_row('IndexSet 基础', '18')
    pdf.table_row('IndexSet 边界', '27')
    pdf.table_row('MultiMap 基础', '20')
    pdf.table_row('MultiMap 边界', '16')
    pdf.table_row('Entry API', '14')
    pdf.table_row('工具函数', '33')
    pdf.table_row('文档测试', '13')

    pdf.ln(3)
    pdf.subsection_title('9.2 测试详细结果')
    pdf.body_text('所有 207 个测试均通过，0 个失败。测试覆盖：')
    pdf.bullet_point('基本 CRUD 操作（创建、读取、更新、删除）')
    pdf.bullet_point('插入顺序保持和向后移动删除')
    pdf.bullet_point('自动扩容和大规模数据正确性（200+ 条目）')
    pdf.bullet_point('哈希碰撞处理和探查链完整性')
    pdf.bullet_point('集合运算（并集、交集、差集、对称差集）')
    pdf.bullet_point('Entry API 惰性操作')
    pdf.bullet_point('MultiMap 多值操作')
    pdf.bullet_point('工具函数（filter、map、fold、partition 等）')

    # 第十节：使用示例
    pdf.section_title('十、使用示例')
    pdf.code_block('''test {
  // IndexMap 基本使用
  let m = @indexmap.IndexMap::from([("b", 2), ("a", 1), ("c", 3)])
  assert_eq(m.get("a"), Some(1))
  assert_eq(m["b"], 2)  // 缺失时 panic

  // Entry API 惰性插入
  let counter = m.entry("count").or_insert(0)

  // IndexSet 集合运算
  let s1 = @indexmap.IndexSet::from([1, 2, 3])
  let s2 = @indexmap.IndexSet::from([2, 3, 4])
  let union = s1.union(s2)        // {1, 2, 3, 4}
  let inter = s1.intersection(s2)  // {2, 3}

  // MultiMap 多值映射
  let mm = @indexmap.MultiMap::new()
  mm.insert("fruits", "apple")
  mm.insert("fruits", "banana")

  // 工具函数
  let filtered = @indexmap.filter_indexmap(m, fn(k, v) { v > 1 })
}''')

    # 第十一节：安装方式
    pdf.section_title('十一、安装方式')
    pdf.code_block('moon add moonbit-community/indexmap')
    pdf.body_text('然后在 .mbt 文件中导入：')
    pdf.code_block('''let m = @indexmap.IndexMap::new()
let s = @indexmap.IndexSet::new()
let mm = @indexmap.MultiMap::new()''')

    # 第十二节：项目结构
    pdf.section_title('十二、项目结构')
    pdf.code_block('''indexmap/
  indexmap.mbt               # IndexMap 核心实现（653 行）
  indexset.mbt               # IndexSet 实现（304 行）
  multimap.mbt               # MultiMap 实现（321 行）
  entry.mbt                  # Entry API（134 行）
  benchmark.mbt              # 性能测试工具（201 行）
  utils.mbt                  # 工具函数库（379 行）
  indexmap_test.mbt          # IndexMap 测试（327 行）
  indexmap_edge_test.mbt     # IndexMap 边界测试（441 行）
  indexset_test.mbt          # IndexSet 测试（175 行）
  indexset_edge_test.mbt     # IndexSet 边界测试（312 行）
  multimap_test.mbt          # MultiMap 测试（211 行）
  multimap_edge_test.mbt     # MultiMap 边界测试（160 行）
  entry_test.mbt             # Entry API 测试（132 行）
  utils_test.mbt             # 工具函数测试（309 行）
  moon.mod.json              # 模块元数据''')

    pdf.body_text('总计：4062 行 MoonBit 代码，15 个源文件。')

    # 第十三节：技术亮点
    pdf.section_title('十三、技术亮点')
    pdf.bullet_point('与标准库一致的设计：采用与 MoonBit 标准库 HashMap 相同的开放寻址 + 线性探测策略')
    pdf.bullet_point('高效的内存布局：使用 FixedArray 存储哈希表，内存连续')
    pdf.bullet_point('智能扩容策略：负载因子 0.5，平衡空间和性能')
    pdf.bullet_point('向后移动删除：正确处理探查链断裂问题，确保删除后查找仍正确')
    pdf.bullet_point('类型安全：完整的泛型支持，编译时类型检查')
    pdf.bullet_point('MoonBit 惯用语法：使用 #alias 实现运算符重载，guard 模式匹配等')
    pdf.bullet_point('丰富的实用函数：filter、map、fold、find、count、partition 等')
    pdf.bullet_point('完整的测试覆盖：207 个测试用例，覆盖所有功能和边界情况')

    # 第十四节：未来扩展
    pdf.section_title('十四、未来扩展')
    pdf.bullet_point('有序迭代（按排序顺序）')
    pdf.bullet_point('序列化/反序列化支持')
    pdf.bullet_point('并发安全版本')
    pdf.bullet_point('更多集合操作（笛卡尔积、幂集等）')
    pdf.bullet_point('性能优化（SIMD 哈希、内存池）')

    # 第十五节：许可证
    pdf.section_title('十五、许可证')
    pdf.body_text('Apache-2.0')

    # 第十六节：联系方式
    pdf.section_title('十六、联系方式')
    pdf.bullet_point('项目地址：https://gitlink.org.cn/yangayang/indexmap')
    pdf.bullet_point('问题反馈：GitLink Issues')

    # 页脚
    pdf.ln(10)
    pdf.set_font('MicrosoftYaHei', '', 9)
    pdf.cell(0, 6, '本项目参加 MoonBit 国产基础软件生态开源大赛 2026', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, '方向：基础数据结构与算法', align='C')

    # 保存 PDF
    output_path = 'E:/moonbit/indexmap/DECLARATION_V4.pdf'
    pdf.output(output_path)
    print(f'PDF 生成成功: {output_path}')


if __name__ == '__main__':
    main()
