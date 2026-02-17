# UI 规格文档
## 用于"UI 不动"重构

**文档版本**：v1.0
**生成日期**：2026-01-12
**项目名称**：Quote Estimator（Generic Project）
**证据来源**：基于 `/green tech v3/` 目录下的源代码分析

---

## 目录

1. [Design Tokens](#1-design-tokens)
2. [通用组件库](#2-通用组件库)
3. [页面级 UI 规格](#3-页面级-ui-规格)
4. [不得更改清单](#4-不得更改清单)
5. [待确认项（Open Questions）](#5-待确认项open-questions)

---

## 1. Design Tokens

### 1.1 颜色系统

#### 1.1.1 Assets 颜色定义

**证据来源**：`Assets.xcassets/AccentColor.colorset/Contents.json`

| 颜色名称 | 值/用途 | 使用场景 | 证据来源 |
|---------|--------|---------|----------|
| **AccentColor** | 系统默认（未自定义） | 全局强调色 | `AccentColor.colorset/Contents.json:1-11` |

**⚠️ 注意**：项目未自定义 AccentColor，使用 iOS 系统默认蓝色。

#### 1.1.2 代码中的颜色定义

**证据来源**：从代码中提取的实际使用颜色

| 颜色 | Hex/SwiftUI | 用途 | 证据来源 |
|------|------------|------|----------|
| **蓝色（Blue）** | `Color.blue` | 主要操作按钮、图标、强调色 | `CustomerListView.swift:97`, `SettingsView.swift:28` |
| **蓝色渐变** | `[Color.blue, Color.blue.opacity(0.8)]` | 按钮背景、头像背景 | `CustomerListView.swift:96-101`, `CustomerRowView.swift:162-166` |
| **绿色（Green）** | `Color.green` | 成功状态、连接状态 | `SettingsView.swift:85`, `EstimateTabView.swift:88` |
| **绿色渐变** | `[Color.green, Color.green.opacity(0.8)]` | 设置项图标背景 | `SettingsView.swift:47-50` |
| **紫色渐变** | `[Color.purple, Color.purple.opacity(0.8)]` | 油漆数据图标背景 | `SettingsView.swift:66-69` |
| **红色（Red）** | `Color.red` | 错误状态、删除操作 | `CustomerListView.swift:42`, `EstimateTabView.swift:96` |
| **橙色（Orange）** | `Color.orange` | 警告状态 | `EstimateTabView.swift:64` |
| **灰色（Gray）** | `Color.gray` | 次要文本、禁用状态 | `RecentJobsView.swift:96` |
| **系统灰色背景** | `Color(.systemGray6)` | 表格头部、卡片背景 | `SettingsView.swift:236`, `EstimateTabView.swift:49` |
| **白色（White）** | `Color.white` | 按钮文字、图标 | `CustomerListView.swift:92` |
| **黑色（Primary）** | `Color.primary` | 主要文本 | `CustomerListView.swift:178` |
| **次要文本** | `Color.secondary` | 次要信息、说明文字 | `CustomerListView.swift:190` |

#### 1.1.3 颜色语义分类

| 语义 | 颜色 | 使用场景 | 证据来源 |
|------|------|---------|----------|
| **主要操作** | 蓝色 | "Create Customer"、"Send" 按钮 | `CustomerListView.swift:85-103` |
| **成功/连接** | 绿色 | "Connected" 状态、"Ready to sync" | `SettingsView.swift:78-98`, `EstimateTabView.swift:84-90` |
| **警告** | 橙色 | "Not signed in"、"Email invalid" | `EstimateTabView.swift:60-74` |
| **错误/删除** | 红色 | "Delete"、错误消息 | `CustomerListView.swift:39-44`, `EstimateTabView.swift:92-98` |
| **次要操作** | 红色透明背景 | "Clear" 按钮 | `RecentJobsView.swift:68-76` |

### 1.2 字体系统

#### 1.2.1 自定义字体

**证据来源**：`green-tech-v3-Info.plist`

| 字体名称 | 文件名 | 用途 | 证据来源 |
|---------|--------|------|----------|
| **Fashion Fetish Heavy** | `Fashion Fetish Heavy.ttf` | （未在代码中看到使用，可能用于品牌标题） | `green-tech-v3-Info.plist` |

#### 1.2.2 系统字体规范

**证据来源**：从代码中提取的实际字体使用

| 字体样式 | SwiftUI 代码 | 用途 | 字号/字重 | 证据来源 |
|---------|------------|------|---------|----------|
| **标题** | `.font(.title2)` | 页面区块标题 | System Large, Bold | `RecentJobsView.swift:30` |
| **导航标题** | `.navigationTitle()` | 导航栏标题 | System Large | `CustomerListView.swift:56` |
| **主要文本** | `.font(.headline)` | 列表主标题、按钮文字 | System Body, Semibold | `CustomerListView.swift:177` |
| **次要文本** | `.font(.subheadline)` | 次要信息、按钮辅助文字 | System Subheadline | `CustomerListView.swift:89` |
| **说明文字** | `.font(.caption)` | 小字说明、表格文字 | System Caption | `RecentJobsView.swift:33` |
| **等宽字体** | `.font(.system(.body, design: .monospaced))` | Realm ID、QBO 描述预览 | Monospaced Body | `SettingsView.swift:116`, `EstimateTabView.swift:44` |

#### 1.2.3 字体大小与字重组合

| 组合 | SwiftUI 代码 | 用途 | 证据来源 |
|------|------------|------|----------|
| **按钮主文字** | `.font(.headline).fontWeight(.semibold)` | 操作按钮 | `EstimateTabView.swift:126` |
| **图标 + 文字** | `.font(.system(size: 16, weight: .medium))` | 按钮图标 | `CustomerListView.swift:87` |
| **小图标** | `.font(.caption2)` | 次要图标 | `CustomerRowView.swift:185` |

### 1.3 间距/栅格系统

#### 1.3.1 常用间距值

**证据来源**：从代码中统计的高频间距值

| 间距值 | 用途 | 频率 | 证据来源 |
|-------|------|------|----------|
| **0** | 无间距、紧贴布局 | 高 | `CustomerListView.swift:29`, `HStack(spacing: 0)` |
| **4** | 极小间距（VStack 子元素） | 高 | `RecentJobsView.swift:29`, `VStack(spacing: 4)` |
| **6** | 小间距（图标与文字） | 高 | `CustomerListView.swift:85`, `HStack(spacing: 6)` |
| **8** | 标准小间距（VStack） | 高 | `EstimateTabView.swift:31`, `VStack(spacing: 8)` |
| **10** | 中等间距（HStack） | 中 | `EstimateTabView.swift:116`, `HStack(spacing: 10)` |
| **12** | 中等间距（Section） | 中 | `RecentJobsView.swift:92`, `VStack(spacing: 12)` |
| **14** | 按钮内边距（水平） | 高 | `CustomerListView.swift:93`, `.padding(.horizontal, 14)` |
| **16** | 标准边距（页面边距） | 高 | `CustomerListView.swift:37`, `.padding(.horizontal, 16)` |
| **20** | 大间距（Section 间隔） | 中 | `EstimateTabView.swift:30`, `VStack(spacing: 20)` |

#### 1.3.2 Padding 规范

| Padding 类型 | 值 | 用途 | 证据来源 |
|-------------|----|----|----------|
| **按钮水平内边距** | 14 | 按钮内文字左右间距 | `CustomerListView.swift:93` |
| **按钮垂直内边距** | 8 | 按钮内文字上下间距 | `CustomerListView.swift:94` |
| **页面水平边距** | 16 | 内容区域左右边距 | `EstimateTabView.swift:41` |
| **卡片内边距** | 16 | 卡片内容边距 | `EstimateTabView.swift:45` |
| **列表行内边距** | `EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)` | 列表单元格边距 | `CustomerListView.swift:37` |

### 1.4 圆角/阴影/描边

#### 1.4.1 圆角规范

| 圆角值 | 用途 | 证据来源 |
|-------|------|----------|
| **8** | 小组件圆角（图标背景） | `SettingsView.swift:33` |
| **10** | 按钮圆角 | `CustomerListView.swift:102`, `RecentJobsView.swift:60` |
| **12** | 卡片圆角 | `EstimateTabView.swift:48` |
| **Circle** | 头像、状态指示器 | `CustomerRowView.swift:160`, `SettingsView.swift:84` |
| **Capsule** | 胶囊形状（状态标签） | `SettingsView.swift:97` |

#### 1.4.2 阴影规范

| 阴影类型 | 参数 | 用途 | 证据来源 |
|---------|------|------|----------|
| **按钮阴影** | `color: .blue.opacity(0.3), radius: 4, x: 0, y: 2` | 主要操作按钮 | `RecentJobsView.swift:61` |
| **强调阴影** | `color: .blue.opacity(0.3), radius: 6, x: 0, y: 3` | 重要按钮（如 Create Estimate） | `EstimateTabView.swift:135` |
| **状态指示器阴影** | `color: .green.opacity(0.5), radius: 2, x: 0, y: 1` | "Connected" 绿点 | `SettingsView.swift:87` |

#### 1.4.3 描边规范

| 描边类型 | 参数 | 用途 | 证据来源 |
|---------|------|------|----------|
| **卡片描边** | `lineWidth: 1, color: .blue.opacity(0.2)` | 卡片边框 | `EstimateTabView.swift:52` |

---

## 2. 通用组件库

### 2.1 按钮组件

#### 2.1.1 主要操作按钮（Primary Button）

**样式规格**：
- 背景：蓝色渐变 `[Color.blue, Color.blue.opacity(0.8)]`
- 文字：白色，`.font(.headline).fontWeight(.semibold)`
- 圆角：10
- 阴影：`color: .blue.opacity(0.3), radius: 4~6, x: 0, y: 2~3`
- 内边距：水平 14，垂直 8

**证据来源**：`CustomerListView.swift:85-103`, `RecentJobsView.swift:38-62`

**代码示例**：
```swift
Button(action: { /* ... */ }) {
    HStack(spacing: 6) {
        Image(systemName: "plus.circle.fill")
            .font(.system(size: 16, weight: .medium))
        Text("Create Customer")
            .font(.subheadline)
            .fontWeight(.medium)
    }
    .foregroundColor(.white)
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(
        LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .cornerRadius(10)
}
```

#### 2.1.2 次要操作按钮（Secondary Button）

**样式规格**：
- 背景：红色半透明 `Color.red.opacity(0.1)`
- 文字：红色，`.font(.subheadline).fontWeight(.medium)`
- 圆角：10
- 无阴影

**证据来源**：`RecentJobsView.swift:65-77`

**代码示例**：
```swift
Button(action: { /* ... */ }) {
    Text("Clear")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.red)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
}
```

#### 2.1.3 大型确认按钮（Prominent Button）

**样式规格**：
- 样式：`.buttonStyle(.borderedProminent)`
- 控件大小：`.controlSize(.large)`
- 阴影：`color: .blue.opacity(0.3), radius: 6, x: 0, y: 3`
- 垂直内边距：14

**证据来源**：`EstimateTabView.swift:111-136`

**代码示例**：
```swift
Button(action: { /* ... */ }) {
    HStack(spacing: 10) {
        Image(systemName: "arrow.up.circle.fill")
            .font(.system(size: 18, weight: .medium))
        Text("Create/Update Customer & Estimate")
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
    }
    .foregroundColor(.white)
    .padding(.vertical, 14)
}
.buttonStyle(.borderedProminent)
.controlSize(.large)
.disabled(!canCreateEstimate)
.shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
```

### 2.2 列表单元格组件

#### 2.2.1 CustomerRowView（客户行视图）

**样式规格**：
- 布局：HStack（头像 + 信息列）
- 头像：
  - 尺寸：44x44
  - 形状：Circle
  - 背景：蓝色渐变 `[Color.blue.opacity(0.6), Color.blue.opacity(0.8)]`
  - 文字：客户首字母缩写，白色，字号 16，Semibold
- 信息列：
  - 主标题：`.font(.headline)`, Primary 颜色
  - 次要信息：`.font(.subheadline)`, Secondary 颜色
  - 图标：`.font(.caption2)`, 蓝色，14x14
- 间距：头像与信息间距 14，信息内间距 6

**证据来源**：`CustomerListView.swift:154-222`

**代码示例**：
```swift
HStack(alignment: .center, spacing: 14) {
    // Avatar
    Circle()
        .fill(
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(width: 44, height: 44)
        .overlay {
            Text(customerInitials)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }

    // Info
    VStack(alignment: .leading, spacing: 6) {
        Text("\(customer.firstName ?? "") \(customer.lastName ?? "")")
            .font(.headline)
            .foregroundColor(.primary)
            .lineLimit(1)

        VStack(alignment: .leading, spacing: 4) {
            if let mobile = customer.mobile, !mobile.isEmpty {
                HStack(alignment: .center, spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .frame(width: 14, height: 14, alignment: .center)
                    Text(mobile)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    Spacer()
}
.padding(.vertical, 10)
.padding(.horizontal, 4)
```

#### 2.2.2 StatusRow（状态行）

**样式规格**：
- 图标：SF Symbol，颜色根据状态（绿/橙/红）
- 文字：状态消息
- 用途：显示验证状态、错误信息、成功提示

**证据来源**：`EstimateTabView.swift:60-106`

**代码示例**：
```swift
struct StatusRow: View {
    let icon: String
    let message: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(message)
                .font(.subheadline)
                .foregroundColor(color)
        }
    }
}
```

### 2.3 表单组件

#### 2.3.1 TextField 样式

**证据来源**：`SettingsView.swift:156-158`, `RoomEditorView.swift`（推断）

**标准 TextField**：
- 无自定义样式，使用系统默认
- 用于输入文本、数字

#### 2.3.2 SecureField 样式

**证据来源**：`SettingsView.swift:157`

**标准 SecureField**：
- 用于密码输入（Client Secret）
- 无自定义样式

#### 2.3.3 Picker 样式

**证据来源**：`SettingsView.swift:144-147`

**标准 Picker**：
- 用于选择环境、项目类型等
- 无自定义样式，使用系统默认

### 2.4 卡片组件

#### 2.4.1 信息卡片（Info Card）

**样式规格**：
- 背景：`Color(.systemGray6)`
- 圆角：12
- 边框：`lineWidth: 1, color: .blue.opacity(0.2)`
- 内边距：16

**证据来源**：`EstimateTabView.swift:43-56`

**代码示例**：
```swift
VStack(alignment: .leading, spacing: 8) {
    HStack(alignment: .center, spacing: 8) {
        Image(systemName: "doc.text.fill")
            .font(.headline)
            .foregroundColor(.blue)
        Text("QBO Description Preview")
            .font(.headline)
            .fontWeight(.semibold)
    }

    Text(viewModel.generateQBODescription())
        .font(.system(.body, design: .monospaced))
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
}
```

### 2.5 状态指示器

#### 2.5.1 连接状态（Connected Status）

**样式规格**：
- 指示器：绿色圆点（直径 10），带阴影
- 文字："Connected"，绿色，Semibold
- 容器：Capsule 胶囊形，绿色半透明背景
- 内边距：水平 10，垂直 6

**证据来源**：`SettingsView.swift:81-99`

**代码示例**：
```swift
HStack(spacing: 8) {
    Circle()
        .fill(Color.green)
        .frame(width: 10, height: 10)
        .shadow(color: Color.green.opacity(0.5), radius: 2, x: 0, y: 1)
    Text("Connected")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.green)
}
.padding(.horizontal, 10)
.padding(.vertical, 6)
.background(
    Capsule()
        .fill(Color.green.opacity(0.15))
)
```

### 2.6 空状态组件（Empty State）

**样式规格**：
- 图标：大型 SF Symbol（字号 48），灰色半透明
- 主标题：`.font(.headline)`, Secondary 颜色
- 副标题：`.font(.caption)`, Secondary 颜色
- 垂直居中

**证据来源**：`RecentJobsView.swift:91-104`

**代码示例**：
```swift
VStack(spacing: 12) {
    Spacer()
    Image(systemName: "tray")
        .font(.system(size: 48))
        .foregroundColor(.gray.opacity(0.5))
    Text("No recent jobs")
        .font(.headline)
        .foregroundColor(.secondary)
    Text("Sync jobs will appear here")
        .font(.caption)
        .foregroundColor(.secondary)
    Spacer()
}
```

### 2.7 加载指示器（Loading Indicator）

**样式规格**：
- 样式：`ProgressView()` 系统默认
- 在按钮中：白色 `CircularProgressViewStyle(tint: .white)`
- 在页面中：默认颜色

**证据来源**：`EstimateTabView.swift:117-120`, `SettingsView.swift:202`

**代码示例**：
```swift
// 在按钮中
if viewModel.isLoading {
    ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
} else {
    Image(systemName: "arrow.up.circle.fill")
}

// 在页面中
if viewModel.isLoading {
    HStack {
        Spacer()
        ProgressView()
        Text("Loading...")
        Spacer()
    }
}
```

---

## 3. 页面级 UI 规格

### 3.1 CustomerListView（客户列表页）

#### 3.1.1 布局结构

**证据来源**：`CustomerListView.swift:26-146`

**布局方式**：黄金分割（Golden Ratio: 1.0 : 0.618）

```
┌─────────────────────────────────────────────────────────────┐
│                      NavigationStack                        │
├─────────────────────────────────────────────────────────────┤
│  GeometryReader                                             │
│  ├── HStack(spacing: 0)                                     │
│  │   ├── [左侧：客户列表] (61.8% 宽度)                       │
│  │   │   └── List                                           │
│  │   │       └── ForEach(customers)                         │
│  │   │           └── NavigationLink                         │
│  │   │               └── CustomerRowView                    │
│  │   ├── Divider                                            │
│  │   └── [右侧：最近任务] (38.2% 宽度)                       │
│  │       └── RecentJobsView                                 │
└─────────────────────────────────────────────────────────────┘
```

**宽度计算**：
- 左侧客户列表：`geometry.size.width * (1.0 / (1.0 + 0.618))`
- 右侧最近任务：`geometry.size.width * (0.618 / (1.0 + 0.618))`

#### 3.1.2 导航栏

**工具栏配置**：
- 左侧（leading）："Create Customer" 按钮（蓝色渐变）
- 右侧（trailing）：齿轮图标（跳转到设置）

**证据来源**：`CustomerListView.swift:76-113`

#### 3.1.3 列表单元格

**单元格样式**：
- 类型：NavigationLink
- 内容：CustomerRowView
- 行内边距：`EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)`
- 滑动操作：右滑显示删除按钮（红色）
- 长按菜单：显示删除选项

**证据来源**：`CustomerListView.swift:32-54`

#### 3.1.4 状态表现

| 状态 | UI 表现 | 证据来源 |
|------|---------|----------|
| **加载中** | 无显式加载指示器（推断为即时加载） | `CustomerListView.swift:131-133` |
| **空列表** | 显示空 List（无特殊空状态 UI） | 推断 |
| **删除确认** | Alert 对话框 | `CustomerListView.swift:119-130` |

### 3.2 CustomerDetailView（客户详情页）

#### 3.2.1 布局结构

**证据来源**：`CustomerDetailView.swift:60-119`

**布局方式**：TabView 三个标签页

```
┌─────────────────────────────────────────────────────────────┐
│  NavigationBar: "{firstName} {lastName}"                    │
│    [Back] ──────────────────────────────────── [Save]       │
├─────────────────────────────────────────────────────────────┤
│  TabView (selection: $selectedTab)                          │
│  ├── Tab 0: CustomerInfoTabView ("Info", person.circle)    │
│  ├── Tab 1: RoomsTabView ("Rooms", house)                  │
│  └── Tab 2: EstimateTabView ("Estimate", doc.text)         │
└─────────────────────────────────────────────────────────────┘
```

#### 3.2.2 导航栏

**工具栏配置**：
- 左侧：自定义 "Back" 按钮（隐藏系统返回）
- 右侧：仅在 Tab 0（Info）显示 "Save" 按钮，未更改时禁用

**证据来源**：`CustomerDetailView.swift:82-98`

#### 3.2.3 未保存更改提示

**Alert 对话框**：
- 标题："Unsaved Changes"
- 消息："You have unsaved changes. Do you want to save them before leaving?"
- 按钮：Save（默认）、Don't Save（红色）、Cancel

**证据来源**：`CustomerDetailView.swift:99-111`

### 3.3 RoomEditorView（房间编辑器）

#### 3.3.1 布局结构（推断）

**证据来源**：`RoomEditorView.swift:9-300`（仅读取前 300 行）

**推断布局**：
- 表单式布局（Form 或 ScrollView + VStack）
- 包含多个 Section：
  - RoomBasicInfoSection（房间名称）
  - RoomDimensionsSection（尺寸）
  - RoomProjectTypeSection（项目类型）
  - RoomPaintSelectionSection（油漆选择）
  - RoomPaintApplicationSection（涂层数）
  - RoomPreviewSection（预览）

**证据来源**：`Features/Customers/Components/` 目录下的组件文件

#### 3.3.2 实时价格计算

**显示位置**：底部或侧边
**样式**：大字体显示总价，带货币符号

**证据来源**：`RoomEditorView.swift:236-298` - 计算逻辑

### 3.4 EstimateTabView（报价预览页）

#### 3.4.1 布局结构

**证据来源**：`EstimateTabView.swift:28-150`

**布局方式**：ScrollView + VStack

```
┌─────────────────────────────────────────────────────────────┐
│  ScrollView                                                 │
│  └── VStack(spacing: 20)                                    │
│      ├── [QBO Description Preview 卡片]                     │
│      ├── [Validation Status 列表]                           │
│      │   ├── StatusRow (Not signed in) - 橙色               │
│      │   ├── StatusRow (Email invalid) - 橙色               │
│      │   ├── StatusRow (No valid rooms) - 橙色              │
│      │   ├── StatusRow (Ready to sync) - 绿色               │
│      │   ├── StatusRow (Error message) - 红色               │
│      │   └── StatusRow (Success message) - 绿色             │
│      └── [Create/Update Button]                            │
└─────────────────────────────────────────────────────────────┘
```

#### 3.4.2 QBO Description Preview 卡片

**样式**：
- 图标：蓝色 "doc.text.fill"
- 标题："QBO Description Preview"
- 内容：等宽字体 `.font(.system(.body, design: .monospaced))`
- 背景：`Color(.systemGray6)`，蓝色半透明边框
- 圆角：12
- 内边距：16

**证据来源**：`EstimateTabView.swift:31-56`

#### 3.4.3 状态列表

**StatusRow 样式**：
- 图标 + 文字水平排列
- 间距：8
- 颜色根据状态：橙色（警告）、绿色（成功）、红色（错误）

**证据来源**：`EstimateTabView.swift:60-106`

### 3.5 SettingsView（设置页）

#### 3.5.1 布局结构

**证据来源**：`SettingsView.swift:17-135`

**布局方式**：List + NavigationLink

```
┌─────────────────────────────────────────────────────────────┐
│  NavigationTitle: "Settings"                                │
├─────────────────────────────────────────────────────────────┤
│  List                                                       │
│  ├── Section 1                                              │
│  │   ├── NavigationLink: OAuth Configuration               │
│  │   │   (蓝色渐变图标: lock.shield.fill)                   │
│  │   ├── NavigationLink: QuickBooks Configuration          │
│  │   │   (绿色渐变图标: building.2.fill)                    │
│  │   └── NavigationLink: Paint Data                        │
│  │       (紫色渐变图标: paintpalette.fill)                  │
│  └── Section 2 (if isSignedIn)                             │
│      ├── Status: Connected (绿色胶囊)                       │
│      ├── Company Name                                       │
│      └── Realm ID (等宽字体)                                 │
└─────────────────────────────────────────────────────────────┘
```

#### 3.5.2 设置项图标样式

**样式规格**：
- 尺寸：36x36
- 形状：圆角矩形（圆角 8）
- 背景：渐变（根据功能不同）
- 图标：白色 SF Symbol，`.font(.title3)`

**证据来源**：`SettingsView.swift:20-75`

#### 3.5.3 连接状态展示

**样式**：
- 绿色圆点 + "Connected" 文字
- 胶囊形背景（绿色半透明）
- 显示公司名和 Realm ID

**证据来源**：`SettingsView.swift:78-122`

### 3.6 RecentJobsView（最近任务页）

#### 3.6.1 布局结构

**证据来源**：`RecentJobsView.swift:24-148`

**布局方式**：VStack(spacing: 0)

```
┌─────────────────────────────────────────────────────────────┐
│  [Header: 渐变背景]                                          │
│  ├── "Recent Jobs" (Title2, Bold)                          │
│  ├── "Sync status & queue" (Caption, Secondary)            │
│  ├── [Send Button] (蓝色渐变)                                │
│  └── [Clear Button] (红色半透明)                             │
├─────────────────────────────────────────────────────────────┤
│  [Jobs List]                                                │
│  └── List (if not empty)                                   │
│      └── ForEach(groupedJobs)                              │
│          └── CustomerJobGroupView                          │
│  或                                                          │
│  └── Empty State (if empty)                                │
│      ├── Tray Icon (48pt, 灰色)                             │
│      ├── "No recent jobs" (Headline)                        │
│      └── "Sync jobs will appear here" (Caption)            │
└─────────────────────────────────────────────────────────────┘
```

#### 3.6.2 Header 样式

**样式规格**：
- 背景：渐变 `[Color(.systemGray6), Color(.systemGray6).opacity(0.5)]`
- 内边距：水平 16，垂直 12
- 标题：`.font(.title2).fontWeight(.bold)`
- 副标题：`.font(.caption).foregroundColor(.secondary)`

**证据来源**：`RecentJobsView.swift:26-89`

#### 3.6.3 按钮布局

**HStack 排列**：
- 间距：10
- "Send" 按钮：蓝色渐变，带阴影
- "Clear" 按钮：红色半透明背景

**证据来源**：`RecentJobsView.swift:37-78`

---

## 4. 不得更改清单

以下 UI 规格不得在重构中更改，以确保"UI 不动"。

### 4.1 布局规格

| 规格项 | 值/描述 | 禁止操作 | 证据来源 |
|-------|---------|---------|----------|
| **客户列表黄金分割比例** | 左侧 1.0，右侧 0.618 | 更改比例 | `CustomerListView.swift:58,65` |
| **TabView 标签页顺序** | 0: Info, 1: Rooms, 2: Estimate | 更改顺序、标签名 | `CustomerDetailView.swift:62-78` |
| **TabView 图标** | Info: person.circle, Rooms: house, Estimate: doc.text | 更改图标 | `CustomerDetailView.swift:64,70,76` |

### 4.2 颜色规格

| 规格项 | 值 | 禁止操作 | 证据来源 |
|-------|-----|---------|----------|
| **主要操作按钮背景** | 蓝色渐变 `[Color.blue, Color.blue.opacity(0.8)]` | 更改颜色、去除渐变 | `CustomerListView.swift:96-101` |
| **连接状态颜色** | 绿色 `Color.green` | 更改颜色 | `SettingsView.swift:85` |
| **错误状态颜色** | 红色 `Color.red` | 更改颜色 | `EstimateTabView.swift:96` |
| **警告状态颜色** | 橙色 `Color.orange` | 更改颜色 | `EstimateTabView.swift:64` |
| **头像背景** | 蓝色渐变 `[Color.blue.opacity(0.6), Color.blue.opacity(0.8)]` | 更改颜色 | `CustomerRowView.swift:162-166` |

### 4.3 字体规格

| 规格项 | 值 | 禁止操作 | 证据来源 |
|-------|-----|---------|----------|
| **导航标题** | System Default (Large) | 更改字号、字重 | `CustomerListView.swift:56` |
| **按钮文字** | `.font(.subheadline).fontWeight(.medium)` | 更改字号、字重 | `CustomerListView.swift:89-90` |
| **客户名字** | `.font(.headline)` | 更改字号、字重 | `CustomerListView.swift:177` |
| **次要信息** | `.font(.subheadline)`, Secondary 颜色 | 更改字号、颜色 | `CustomerListView.swift:190` |
| **等宽字体场景** | `.font(.system(.body, design: .monospaced))` | 更改为非等宽字体 | `EstimateTabView.swift:44` |

### 4.4 间距规格

| 规格项 | 值 | 禁止操作 | 证据来源 |
|-------|-----|---------|----------|
| **按钮内边距** | 水平 14，垂直 8 | 更改间距 | `CustomerListView.swift:93-94` |
| **页面水平边距** | 16 | 更改间距 | `EstimateTabView.swift:41` |
| **列表行内边距** | `EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)` | 更改间距 | `CustomerListView.swift:37` |
| **头像尺寸** | 44x44 | 更改尺寸 | `CustomerRowView.swift:168` |

### 4.5 圆角规格

| 规格项 | 值 | 禁止操作 | 证据来源 |
|-------|-----|---------|----------|
| **按钮圆角** | 10 | 更改圆角值 | `CustomerListView.swift:102` |
| **卡片圆角** | 12 | 更改圆角值 | `EstimateTabView.swift:48` |
| **图标背景圆角** | 8 | 更改圆角值 | `SettingsView.swift:33` |

### 4.6 阴影规格

| 规格项 | 值 | 禁止操作 | 证据来源 |
|-------|-----|---------|----------|
| **按钮阴影** | `color: .blue.opacity(0.3), radius: 4, x: 0, y: 2` | 更改参数 | `RecentJobsView.swift:61` |
| **重要按钮阴影** | `color: .blue.opacity(0.3), radius: 6, x: 0, y: 3` | 更改参数 | `EstimateTabView.swift:135` |

### 4.7 组件样式

| 组件 | 样式规格 | 禁止操作 | 证据来源 |
|------|---------|---------|----------|
| **CustomerRowView** | 头像 44x44，间距 14，信息列间距 6 | 更改布局、尺寸、间距 | `CustomerListView.swift:154-222` |
| **StatusRow** | 图标 + 文字，间距 8 | 更改布局、间距 | 推断自 `EstimateTabView.swift:60-106` |
| **Empty State** | 图标 48pt，垂直间距 12 | 更改布局、图标大小 | `RecentJobsView.swift:91-104` |

---

## 5. 待确认项（Open Questions）

### 5.1 颜色系统不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-U01 | AccentColor 是否应该自定义为品牌色？ | 当前使用系统默认蓝色 | 是否需要统一品牌色 |
| OQ-U02 | 是否需要 Dark Mode 适配？ | 未看到明确的 Dark Mode 颜色定义 | 颜色是否支持自动适配 |
| OQ-U03 | 自定义字体 "Fashion Fetish Heavy" 在哪里使用？ | Info.plist 中注册但代码中未看到使用 | 是否已弃用、或用于特定场景 |

### 5.2 布局不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-U04 | RoomEditorView 的完整布局结构是什么？ | 仅读取前 300 行，未看到完整布局 | 完整的 Section 划分、组件顺序 |
| OQ-U05 | CustomerInfoTabView 的布局和字段是什么？ | 未读取该文件 | 完整的表单字段、布局方式 |
| OQ-U06 | RoomsTabView 的布局和交互是什么？ | 未读取该文件 | 房间列表的样式、操作按钮 |
| OQ-U07 | PaintSelectionSheet 的布局和筛选逻辑是什么？ | 未读取该文件 | 弹窗样式、筛选器布局 |

### 5.3 组件不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-U08 | 是否有统一的 Design System 组件库？ | DesignSystem/ 目录为空 | 是否计划统一组件、组件规范文档 |
| OQ-U09 | 是否有自定义的 ButtonStyle？ | 未看到自定义 ButtonStyle 定义 | 是否需要封装可复用按钮样式 |
| OQ-U10 | CustomerJobGroupView 的样式是什么？ | 在 RecentJobsView 中引用但未读取 | 任务分组的展示样式 |

### 5.4 交互不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-U11 | 列表滑动删除的动画时长和样式是什么？ | 使用系统默认 swipeActions | 是否需要自定义动画 |
| OQ-U12 | Alert 对话框的样式是否可自定义？ | 使用系统默认 Alert | 是否需要自定义 Alert UI |
| OQ-U13 | Sheet 弹窗的展示样式是什么？ | 未看到自定义 Sheet 样式 | 是否需要自定义 Sheet 高度、样式 |

### 5.5 响应式布局不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-U14 | 是否支持横屏布局？ | 客户列表使用黄金分割，推断为横屏优化 | 竖屏时的布局适配策略 |
| OQ-U15 | 是否支持不同尺寸 iPad？ | 使用 GeometryReader 动态布局 | 不同屏幕尺寸的适配规则 |
| OQ-U16 | 字体是否支持 Dynamic Type？ | 使用系统字体，理论支持 | 是否需要限制最大/最小字号 |

### 5.6 动画不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-U17 | 导航转场动画是什么？ | 使用系统默认 NavigationStack | 是否需要自定义转场 |
| OQ-U18 | 按钮点击是否有反馈动画？ | 未看到自定义动画 | 是否需要添加按压效果 |
| OQ-U19 | ProgressView 是否有自定义样式？ | 使用系统默认样式 | 是否需要自定义加载动画 |

---

## 附录：UI 组件速查表

### A1. 按钮样式速查

| 按钮类型 | 背景 | 文字颜色 | 圆角 | 阴影 | 证据来源 |
|---------|------|---------|------|------|----------|
| 主要操作 | 蓝色渐变 | 白色 | 10 | 蓝色 0.3 透明度，radius 4 | `CustomerListView.swift:85-103` |
| 次要操作 | 红色 0.1 透明度 | 红色 | 10 | 无 | `RecentJobsView.swift:65-77` |
| 大型确认 | borderedProminent | 白色 | 系统默认 | 蓝色 0.3 透明度，radius 6 | `EstimateTabView.swift:111-136` |

### A2. 字体样式速查

| 用途 | SwiftUI 代码 | 字号 | 字重 | 证据来源 |
|------|------------|------|------|----------|
| 页面标题 | `.font(.title2)` | Large | Bold | `RecentJobsView.swift:30` |
| 主要文本 | `.font(.headline)` | Body | Semibold | `CustomerListView.swift:177` |
| 次要文本 | `.font(.subheadline)` | Subheadline | Regular | `CustomerListView.swift:89` |
| 说明文字 | `.font(.caption)` | Caption | Regular | `RecentJobsView.swift:33` |
| 等宽文本 | `.font(.system(.body, design: .monospaced))` | Body | Regular | `EstimateTabView.swift:44` |

### A3. 颜色语义速查

| 语义 | 颜色 | Hex/SwiftUI | 用途 | 证据来源 |
|------|------|------------|------|----------|
| 主要操作 | 蓝色 | `Color.blue` | 按钮、图标、链接 | 全局 |
| 成功 | 绿色 | `Color.green` | 成功状态、连接状态 | `SettingsView.swift:85` |
| 警告 | 橙色 | `Color.orange` | 警告提示 | `EstimateTabView.swift:64` |
| 错误 | 红色 | `Color.red` | 错误消息、删除操作 | `EstimateTabView.swift:96` |
| 次要信息 | 灰色 | `Color.secondary` | 次要文本 | `CustomerListView.swift:190` |

---

**文档结束**
