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
    pdf.body_text('indexmap — 插入顺序保持哈希映射')

    # 第三节：项目简介
    pdf.section_title('三、项目简介')
    pdf.body_text(
        'indexmap 是一个为 MoonBit 语言实现的插入顺序保持哈希映射（Insertion-Order-Preserving Hash Map）。'
        '它结合了哈希表的 O(1) 平均查找效率和数组的顺序访问能力，同时保证迭代时元素始终保持插入顺序。'
    )

    # 第四节：项目特色
    pdf.section_title('四、项目特色')

    pdf.subsection_title('4.1 核心功能')
    pdf.bullet_point('O(1) 平均时间复杂度的键值查找')
    pdf.bullet_point('O(1) 时间复杂度的插入顺序索引访问')
    pdf.bullet_point('迭代始终按插入顺序进行')
    pdf.bullet_point('Swap-remove 语义：删除操作使用交换-移除策略，保持内部数组紧凑')

    pdf.subsection_title('4.2 数据结构设计')
    pdf.body_text('采用以下核心设计：')
    pdf.bullet_point('开放寻址哈希表：使用线性探测解决冲突，与 MoonBit 标准库 HashMap 一致')
    pdf.bullet_point('分离的顺序数组：单独维护插入顺序，与哈希表解耦')
    pdf.bullet_point('键存储策略：顺序数组存储键而非索引，使 rehash 操作不影响顺序')

    pdf.subsection_title('4.3 实现细节')
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

    pdf.bullet_point('哈希表：使用 FixedArray[Slot[K, V]?] 存储键值对')
    pdf.bullet_point('顺序数组：使用 Array[K] 按插入顺序存储键')
    pdf.bullet_point('容量管理：自动扩容，负载因子为 0.5')

    # 第五节：API 设计
    pdf.section_title('五、API 设计')

    pdf.subsection_title('5.1 构造函数')
    pdf.table_row('函数', '说明', bold=True)
    pdf.table_row('IndexMap::new()', '创建空映射')
    pdf.table_row('IndexMap::with_capacity(n)', '创建至少 n 个槽位的映射')
    pdf.table_row('IndexMap::from(arr)', '从数组创建映射')

    pdf.ln(3)
    pdf.subsection_title('5.2 核心操作')
    pdf.table_row('方法', '说明', bold=True)
    pdf.table_row('m.set(key, value)', '插入或更新')
    pdf.table_row('m.get(key) -> V?', '查找，返回 Option')
    pdf.table_row('m.at(key) -> V', '查找，缺失时 panic')
    pdf.table_row('m.contains_key(key)', '键存在性检查')
    pdf.table_row('m.remove(key) -> V?', '删除并返回值')

    pdf.ln(3)
    pdf.subsection_title('5.3 索引访问')
    pdf.table_row('方法', '说明', bold=True)
    pdf.table_row('m.get_index(i)', '位置 i 的键值对')
    pdf.table_row('m.get_index_key(i)', '位置 i 的键')
    pdf.table_row('m.get_index_value(i)', '位置 i 的值')

    pdf.ln(3)
    pdf.subsection_title('5.4 迭代器')
    pdf.table_row('方法', '说明', bold=True)
    pdf.table_row('m.iter()', '按顺序遍历键值对')
    pdf.table_row('m.keys_iter()', '按顺序遍历键')
    pdf.table_row('m.values_iter()', '按顺序遍历值')

    pdf.ln(3)
    pdf.subsection_title('5.5 运算符')
    pdf.bullet_point('m[key] — 括号读取（缺失时 panic）')
    pdf.bullet_point('m[key] = value — 括号写入')

    # 第六节：特性实现
    pdf.section_title('六、特性实现')

    pdf.subsection_title('6.1 Eq 特性')
    pdf.body_text(
        '支持两个 IndexMap 的相等性比较。由于使用哈希表实现，比较是无序的'
        '（不同插入顺序但相同内容的映射相等）。'
    )

    pdf.subsection_title('6.2 Debug 特性')
    pdf.body_text('支持调试输出，显示为 IndexMap({key: value, ...}) 格式。')

    # 第七节：测试覆盖
    pdf.section_title('七、测试覆盖')
    pdf.body_text('项目包含 30 个测试用例，覆盖：')
    pdf.bullet_point('基本 CRUD 操作（创建、读取、更新、删除）')
    pdf.bullet_point('括号运算符（读取和写入）')
    pdf.bullet_point('插入顺序保持')
    pdf.bullet_point('Swap-remove 语义')
    pdf.bullet_point('自动扩容（100 个条目）')
    pdf.bullet_point('大规模数据正确性（1000 个条目）')
    pdf.bullet_point('字符串和整数键')
    pdf.bullet_point('重复键处理')
    pdf.bullet_point('Eq 特性')
    pdf.bullet_point('空映射迭代')

    pdf.body_text('测试结果：共 30 个测试，全部通过，0 个失败。')

    pdf.subsection_title('7.1 测试分类统计')
    pdf.table_row('类别', '测试数', bold=True)
    pdf.table_row('基本操作', '6（new、from、set/get、overwrite、contains_key）')
    pdf.table_row('删除操作', '3（remove、remove nonexistent、remove all）')
    pdf.table_row('顺序保持', '3（insertion order、update preserves order、swap_remove）')
    pdf.table_row('扩容', '2（grow on many 100、large map 1000）')
    pdf.table_row('类型支持', '2（string keys、int keys）')
    pdf.table_row('索引访问', '2（get_index、get_index_key/value）')
    pdf.table_row('迭代器', '2（iter、empty map iter）')
    pdf.table_row('相等性', '2（eq、eq different values）')
    pdf.table_row('文档测试', '6（代码注释中的示例测试）')

    pdf.ln(3)
    pdf.subsection_title('7.2 测试详细结果')
    pdf.body_text('所有测试均通过：')
    pdf.bullet_point('"new empty map" ok')
    pdf.bullet_point('"with_capacity" ok')
    pdf.bullet_point('"from array" ok')
    pdf.bullet_point('"set and get" ok')
    pdf.bullet_point('"set overwrite" ok')
    pdf.bullet_point('"bracket operator" ok')
    pdf.bullet_point('"contains_key" ok')
    pdf.bullet_point('"remove" ok')
    pdf.bullet_point('"remove nonexistent" ok')
    pdf.bullet_point('"remove all" ok')
    pdf.bullet_point('"insertion order preserved" ok')
    pdf.bullet_point('"iter" ok')
    pdf.bullet_point('"get_index" ok')
    pdf.bullet_point('"get_index_key and get_index_value" ok')
    pdf.bullet_point('"update preserves order" ok')
    pdf.bullet_point('"swap_remove preserves contiguity" ok')
    pdf.bullet_point('"grow on many insertions" ok')
    pdf.bullet_point('"string keys" ok')
    pdf.bullet_point('"int keys" ok')
    pdf.bullet_point('"from with duplicate keys" ok')
    pdf.bullet_point('"large map correctness" ok')
    pdf.bullet_point('"eq" ok')
    pdf.bullet_point('"eq different values" ok')
    pdf.bullet_point('"empty map iter" ok')
    pdf.bullet_point('文档测试 #0-#5 共 6 个 ok')

    # 第八节：使用示例
    pdf.section_title('八、使用示例')
    pdf.code_block('''test {
  // 创建并填充
  let m = @indexmap.IndexMap::from([("b", 2), ("a", 1), ("c", 3)])

  // 键查找 — O(1)
  assert_eq(m.get("a"), Some(1))
  assert_eq(m["b"], 2)  // 缺失时 panic

  // 迭代保持插入顺序
  let keys = m.keys_iter().to_array()  // ["b", "a", "c"]

  // 索引访问
  assert_eq(m.get_index_key(0), Some("b"))
  assert_eq(m.get_index(1), Some(("a", 1)))

  // 更新（保持原始位置）
  m.set("a", 99)
  // 仍然: ["b", "a", "c"], 但 m["a"] == 99

  // 删除
  assert_eq(m.remove("a"), Some(99))
  // 现在: ["b", "c"]
}''')

    # 第九节：安装方式
    pdf.section_title('九、安装方式')
    pdf.code_block('moon add moonbit-community/indexmap')
    pdf.body_text('然后在 .mbt 文件中导入：')
    pdf.code_block('let m = @indexmap.IndexMap::new()')

    # 第十节：项目结构
    pdf.section_title('十、项目结构')
    pdf.code_block('''indexmap/
  .github/workflows/ci.yml  # GitHub Actions CI
  indexmap.mbt               # 主实现文件
  indexmap_test.mbt          # 测试文件
  moon.mod.json              # 模块元数据
  moon.pkg                   # 包依赖
  README.md                  # 英文文档
  DECLARATION.md             # 项目申报书
  DECLARATION.pdf            # 项目申报书 PDF
  LICENSE                    # Apache-2.0 许可证''')

    # 第十一节：技术亮点
    pdf.section_title('十一、技术亮点')
    pdf.bullet_point('与标准库一致的设计：采用与 MoonBit 标准库 HashMap 相同的开放寻址 + 线性探测策略')
    pdf.bullet_point('高效的内存布局：使用 FixedArray 存储哈希表，内存连续')
    pdf.bullet_point('智能扩容策略：负载因子 0.5，平衡空间和性能')
    pdf.bullet_point('类型安全：完整的泛型支持，编译时类型检查')
    pdf.bullet_point('MoonBit 惯用语法：使用 #alias 实现运算符重载，guard 模式匹配等')

    # 第十二节：未来扩展
    pdf.section_title('十二、未来扩展')
    pdf.bullet_point('Entry API（entry(key).or_insert(default)）')
    pdf.bullet_point('有序迭代（按排序顺序）')
    pdf.bullet_point('序列化/反序列化支持')
    pdf.bullet_point('并发安全版本')
    pdf.bullet_point('更多集合操作（union, intersection, difference）')

    # 第十三节：许可证
    pdf.section_title('十三、许可证')
    pdf.body_text('Apache-2.0')

    # 第十四节：联系方式
    pdf.section_title('十四、联系方式')
    pdf.bullet_point('项目地址：https://gitlink.org.cn/yangayang/indexmap')
    pdf.bullet_point('问题反馈：GitLink Issues')

    # 页脚
    pdf.ln(10)
    pdf.set_font('MicrosoftYaHei', '', 9)
    pdf.cell(0, 6, '本项目参加 MoonBit 国产基础软件生态开源大赛 2026', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, '方向：基础数据结构与算法', align='C')

    # 保存 PDF
    output_path = 'E:/moonbit/indexmap/DECLARATION_V2.pdf'
    pdf.output(output_path)
    print(f'PDF 生成成功: {output_path}')


if __name__ == '__main__':
    main()
