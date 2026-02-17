# 产品需求文档（PRD）
## 基于现有实现反推

**文档版本**：v1.0
**生成日期**：2026-01-12
**项目名称**：Quote Estimator（报价估算工具 - 通用示例项目）
**说明**：本文档已通用化处理，所有业务数据仅供示例参考

---

## 目录

1. [产品概述](#1-产品概述)
2. [角色与用户故事](#2-角色与用户故事)
3. [功能清单](#3-功能清单)
4. [页面清单与导航结构](#4-页面清单与导航结构)
5. [关键流程](#5-关键流程)
6. [业务规则](#6-业务规则)
7. [状态与边界](#7-状态与边界)
8. [待确认项（Open Questions）](#8-待确认项open-questions)

---

## 1. 产品概述

### 1.1 产品定位

Quote Estimator 是一款面向服务承包商的 iPad 应用，用于管理客户信息、计算项目估算、并与外部会计系统（ERP/Accounting System）集成实现客户和报价的自动同步。

**技术说明**：
- 本项目演示了 MVVM 架构和 CoreData 集成
- 展示了 OAuth 2.0 PKCE 认证流程
- 可适配任何支持 REST API 的外部系统

### 1.2 主要场景

1. **客户管理场景**：创建、编辑、查看客户信息
2. **房间估算场景**：为客户的每个房间配置尺寸、油漆类型、涂层数量，自动计算价格
3. **报价生成场景**：将估算结果同步到外部会计系统生成正式报价
4. **后台同步场景**：使用后台任务队列自动同步数据到外部系统

**证据来源**：
- `CustomerDetailView.swift` - Tab 导航：Info/Rooms/Estimate
- `RoomEditorView.swift` - 房间配置表单
- `EstimateTabView.swift` - 报价预览与同步

---

## 2. 角色与用户故事

### 2.1 角色定义

| 角色 | 描述 | 证据来源 |
|------|------|----------|
| **油漆承包商** | 应用的主要使用者，负责管理客户、估算报价、同步到 External Accounting System | 全局业务逻辑 |

### 2.2 用户故事（按 Feature 分类）

#### Feature 1：客户管理

| ID | 用户故事 | 优先级 | 证据来源 |
|----|---------|--------|----------|
| US-01 | 作为承包商，我想查看所有客户的列表，以便快速找到需要的客户 | Must | `CustomerListView.swift:32-55` |
| US-02 | 作为承包商，我想创建新客户，以便添加新的业务联系人 | Must | `CustomerListView.swift:78-84` |
| US-03 | 作为承包商，我想编辑客户信息（姓名、邮箱、电话、地址），以便保持信息准确 | Must | `CustomerInfoTabView.swift`（未直接读取，推断自 Tab 结构） |
| US-04 | 作为承包商，我想删除客户，以便清理无效数据 | Must | `CustomerListView.swift:39-53` |
| US-05 | 作为承包商，当我创建空客户后返回，系统应自动删除该客户，避免脏数据 | Should | `CustomerDetailView.swift:121-136` |

#### Feature 2：房间管理

| ID | 用户故事 | 优先级 | 证据来源 |
|----|---------|--------|----------|
| US-06 | 作为承包商，我想为每个客户添加多个房间，以便分别估算 | Must | `RoomsTabView.swift`（推断自 Tab 导航） |
| US-07 | 作为承包商，我想输入房间尺寸（长、宽、高），系统自动计算墙面面积 | Must | `RoomEditorView.swift:17-20` |
| US-08 | 作为承包商，我想选择项目类型（Type A/Type B/Type C），以便应用不同的人工单价 | Must | `RoomEditorView.swift:29`, `RoomCalculator.swift:62-74` |
| US-09 | 作为承包商，我想选择底漆和面漆，分别指定涂层数量 | Must | `RoomEditorView.swift:21-22,36-38` |
| US-10 | 作为承包商，我想选择是否粉刷天花板，并单独选择天花板用漆 | Should | `RoomEditorView.swift:44,40-42` |
| US-11 | 作为承包商，我想添加特殊人工费（按小时），以应对复杂项目 | Should | `RoomEditorView.swift:45-46` |
| US-12 | 作为承包商，我想添加折扣（百分比），以便灵活定价 | Should | `RoomEditorView.swift:47-48` |
| US-13 | 作为承包商，我想实时看到房间小计价格，以便确认估算 | Must | `RoomEditorView.swift:236-298` |

#### Feature 3：报价生成与同步

| ID | 用户故事 | 优先级 | 证据来源 |
|----|---------|--------|----------|
| US-14 | 作为承包商，我想预览发送到 External Accounting System 的报价描述格式 | Must | `EstimateTabView.swift:43` |
| US-15 | 作为承包商，我想一键创建/更新客户和估算到 External Accounting System | Must | `EstimateTabView.swift:111-135` |
| US-16 | 作为承包商，当客户邮箱无效或未配置房间时，系统应阻止同步并提示 | Must | `EstimateTabView.swift:60-82` |
| US-17 | 作为承包商，我想看到同步任务的状态（队列/处理中/成功/失败） | Must | `RecentJobsView.swift:90-113` |
| US-18 | 作为承包商，我想手动触发同步队列处理 | Should | `RecentJobsView.swift:38-62` |
| US-19 | 作为承包商，我想清空失败的同步任务 | Could | `RecentJobsView.swift:65-77` |

#### Feature 4：设置与配置

| ID | 用户故事 | 优先级 | 证据来源 |
|----|---------|--------|----------|
| US-20 | 作为承包商，我想配置 External Accounting System OAuth 凭证（Client ID/Secret/Redirect URI） | Must | `SettingsView.swift:144-161` |
| US-21 | 作为承包商，我想在 Sandbox 和 Production 环境之间切换 | Must | `SettingsView.swift:144-152` |
| US-22 | 作为承包商，我想登录和登出 External Accounting System 账户 | Must | `SettingsView.swift:164-186` |
| US-23 | 作为承包商，我想导入油漆数据（CSV 或粘贴），以便快速配置油漆库 | Should | `SettingsView.swift:383-405` |
| US-24 | 作为承包商，我想查看已导入的油漆项列表（品牌、覆盖率、价格） | Should | `SettingsView.swift:489-566` |
| US-25 | 作为承包商，我想配置不同项目类型的人工单价（Type A/Type B/Type C） | Must | `SettingsView.swift:447-481` |
| US-26 | 作为承包商，我想查看 External Accounting System 数据（CustomerTypes 和 Items），以便验证连接 | Could | `SettingsView.swift:198-319` |

---

## 3. 功能清单

### 3.1 Must Have（核心功能）

| 功能模块 | 功能项 | 描述 | 证据来源 |
|---------|--------|------|----------|
| **客户管理** | 客户列表 | 展示所有客户，支持点击进入详情 | `CustomerListView.swift:32-55` |
| | 创建客户 | 新建空客户，自动跳转到详情页 | `CustomerListView.swift:78-84` |
| | 编辑客户 | 编辑姓名、邮箱、电话、地址等信息 | `CustomerDetailView.swift` |
| | 删除客户 | 滑动删除或长按删除，需确认 | `CustomerListView.swift:38-53` |
| **房间管理** | 添加房间 | 为客户创建房间记录 | 推断自 `RoomsTabView.swift` |
| | 配置房间 | 输入尺寸、选择油漆、设置涂层数 | `RoomEditorView.swift:17-130` |
| | 计算价格 | 自动计算墙面面积、油漆用量、人工费 | `RoomCalculator.swift:14-143` |
| **油漆估算** | 墙面面积公式 | ((底漆+面漆)*2*(宽*高+长*高)+天花板面积) | `RoomCalculator.swift:26-48` |
| | 价格公式 | 油漆成本+墙面人工+天花板人工+特殊人工-折扣 | `Formatting.swift:98-186` |
| **External Accounting System 集成** | OAuth 登录 | PKCE 流程，本地 HTTP 服务器接收回调 | `External SystemAuthService.swift` |
| | 同步客户 | 创建或更新 External Accounting System 客户记录 | `External SystemClient.swift` |
| | 同步估算 | 创建 External Accounting System Estimate | `External SystemClient.swift` |
| | 后台队列 | 任务队列、重试机制、状态管理 | `SyncQueue.swift` |

### 3.2 Should Have（重要但非关键）

| 功能模块 | 功能项 | 描述 | 证据来源 |
|---------|--------|------|----------|
| **房间管理** | 天花板粉刷 | 可选粉刷天花板，单独选择油漆 | `RoomEditorView.swift:44,40-42` |
| | 特殊人工 | 添加特殊工时费（65$/小时） | `RoomEditorView.swift:45-46` |
| | 折扣 | 按百分比折扣 | `RoomEditorView.swift:47-48` |
| **设置管理** | 油漆数据导入 | CSV 导入或粘贴导入 | `SettingsView.swift:383-405` |
| | 项目类型配置 | 配置 Type A/Type B/Type C 人工单价 | `SettingsView.swift:447-481` |
| **后台同步** | 手动触发 | 手动发送队列 | `RecentJobsView.swift:38-62` |

### 3.3 Could Have（次要功能）

| 功能模块 | 功能项 | 描述 | 证据来源 |
|---------|--------|------|----------|
| **后台同步** | 清空队列 | 批量清除失败任务 | `RecentJobsView.swift:65-77` |
| **设置管理** | External Accounting System 数据查看 | 查看 CustomerTypes 和 Items 列表 | `SettingsView.swift:198-319` |

---

## 4. 页面清单与导航结构

### 4.1 页面树结构

```
ContentView (Root)
└── CustomerListView（客户列表，黄金分割布局：左侧客户，右侧最近任务）
    ├── CustomerDetailView（客户详情，TabView）
    │   ├── [Tab 0] CustomerInfoTabView（客户信息）
    │   ├── [Tab 1] RoomsTabView（房间列表）
    │   │   └── RoomEditorView（房间编辑器）
    │   │       └── PaintSelectionSheet（油漆选择弹窗）
    │   └── [Tab 2] EstimateTabView（报价预览与同步）
    └── SettingsView（设置入口）
        ├── OAuthSettingsView（OAuth 配置）
        ├── External Accounting SystemSettingsView（External Accounting System 配置）
        └── PaintDataView（油漆数据管理）
            └── PasteImportView（粘贴导入弹窗）
```

**证据来源**：
- `ContentView.swift:14-28` - 根视图是 `CustomerListView`
- `CustomerListView.swift:28-67` - 黄金分割布局（1.0 : 0.618）
- `CustomerDetailView.swift:60-79` - TabView 三个标签页
- `SettingsView.swift:17-135` - 设置页层级

### 4.2 页面清单表

| 页面名称 | 路径/层级 | 用途 | 关键组件 | 证据来源 |
|---------|---------|------|---------|----------|
| **CustomerListView** | Root | 展示客户列表与最近任务 | List, NavigationLink, GeometryReader | `CustomerListView.swift:26-146` |
| **CustomerDetailView** | Level 1 | 客户详情容器 | TabView | `CustomerDetailView.swift:60-138` |
| **CustomerInfoTabView** | Level 2, Tab 0 | 编辑客户基本信息 | TextField, Picker | 推断自 `CustomerDetailView.swift:62-66` |
| **RoomsTabView** | Level 2, Tab 1 | 房间列表 | List, NavigationLink | 推断自 `CustomerDetailView.swift:68-72` |
| **RoomEditorView** | Level 3 | 编辑房间详情 | Form, TextField, Picker, Sheet | `RoomEditorView.swift:9-1620` |
| **PaintSelectionSheet** | Sheet | 选择油漆弹窗 | List, Picker, ScrollView | `PaintSelectionSheet.swift`（推断自引用） |
| **EstimateTabView** | Level 2, Tab 2 | 预览报价与同步 | Button, StatusRow, Alert | `EstimateTabView.swift:28-150` |
| **SettingsView** | Level 1 | 设置入口 | List, NavigationLink | `SettingsView.swift:17-135` |
| **OAuthSettingsView** | Level 2 | OAuth 配置 | Picker, TextField, SecureField, Button | `SettingsView.swift:137-340` |
| **External Accounting SystemSettingsView** | Level 2 | External Accounting System 配置 | TextField | `SettingsView.swift:342-362` |
| **PaintDataView** | Level 2 | 油漆数据管理 | List, Button, ScrollView, Table | `SettingsView.swift:364-597` |
| **PasteImportView** | Sheet | 粘贴导入油漆数据 | TextEditor, Button | `SettingsView.swift:700-757` |
| **RecentJobsView** | 右侧面板 | 最近同步任务 | List, Button, Timer | `RecentJobsView.swift:24-148` |

---

## 5. 关键流程

### 5.1 流程 1：创建客户与房间

**步骤**：
1. 在客户列表点击 "Create Customer" 按钮
2. 系统创建空客户记录，跳转到客户详情页
3. 用户填写客户信息（姓名、邮箱、电话、地址）
4. 点击 "Save" 保存客户信息
5. 切换到 "Rooms" 标签页
6. 点击添加房间按钮，进入房间编辑器
7. 填写房间名称、尺寸、选择油漆、设置涂层数
8. 系统实时计算价格并显示
9. 点击 "Save" 保存房间
10. 返回房间列表，查看所有房间

**证据来源**：
- `CustomerListView.swift:78-84` - 创建客户流程
- `CustomerDetailView.swift:121-136` - 空客户自动删除逻辑
- `RoomEditorView.swift:75-130` - 房间初始化与保存

### 5.2 流程 2：生成并同步报价到 External Accounting System

**步骤**：
1. 在客户详情页切换到 "Estimate" 标签页
2. 系统预览 External System 描述格式
3. 系统校验：是否已登录 External Accounting System、客户邮箱是否有效、是否有有效房间
4. 如果校验通过，启用 "Create/Update Customer & Estimate" 按钮
5. 点击按钮，系统显示加载状态
6. 系统先同步客户信息到 External Accounting System（如果不存在则创建）
7. 系统创建 Estimate 并关联到客户
8. 显示成功或失败消息
9. 任务被添加到同步队列（如果失败会自动重试）

**证据来源**：
- `EstimateTabView.swift:111-135` - 同步按钮与流程
- `EstimateTabView.swift:60-82` - 校验逻辑
- `EstimateViewModel.swift`（推断自视图调用）
- `SyncQueue.swift` - 后台队列管理

### 5.3 流程 3：OAuth 登录 External Accounting System

**步骤**：
1. 进入设置 → OAuth Configuration
2. 选择环境（Sandbox 或 Production）
3. 输入 Client ID、Client Secret、Redirect URI
4. 点击 "Sign in with Intuit" 按钮
5. 系统启动本地 HTTP 服务器监听回调
6. 打开 Safari 显示 External Accounting System 登录页
7. 用户授权应用
8. External Accounting System 重定向到本地服务器
9. 应用接收 authorization code
10. 交换 access token 和 refresh token
11. 加密存储 token 到 Keychain
12. 显示连接状态为 "Connected"

**证据来源**：
- `SettingsView.swift:176-185` - 登录按钮
- `External SystemAuthService.swift` - OAuth 流程实现
- `KeychainStore.swift` - Token 存储

---

## 6. 业务规则

### 6.1 数据验证规则

| 规则 ID | 描述 | 验证时机 | 错误提示 | 证据来源 |
|---------|------|---------|---------|----------|
| BR-01 | 客户邮箱必须为有效格式才能同步到 External Accounting System | 同步前 | "Email address is invalid or missing" | `EstimateTabView.swift:68-74` |
| BR-02 | 客户必须至少有一个有效房间才能生成估算 | 同步前 | "No valid rooms configured" | `EstimateTabView.swift:76-82` |
| BR-03 | 必须登录 External Accounting System 才能同步 | 同步前 | "Not signed in to External Accounting System" | `EstimateTabView.swift:60-66` |
| BR-04 | 如果客户所有字段为空，返回时自动删除客户 | 返回时 | 无提示，静默删除 | `CustomerDetailView.swift:122-130` |
| BR-05 | 删除客户需要二次确认 | 删除操作时 | 确认对话框："Are you sure you want to delete this customer? This action cannot be undone." | `CustomerListView.swift:119-130` |

### 6.2 计算规则

| 规则 ID | 描述 | 公式 | 证据来源 |
|---------|------|------|----------|
| BR-06 | 墙面面积计算 | ((底漆涂层数 + 面漆涂层数) * 2 * (宽*高 + 长*高) + (是否粉刷天花板 ? (底漆涂层数 + 面漆涂层数) * 宽*长 : 0)) | `RoomCalculator.swift:26-48` |
| BR-07 | 油漆用量（加仑） | 墙面面积（包含涂层） / 油漆覆盖率（ft²/gal） | `Formatting.swift:124-128` |
| BR-08 | 人工单价（按项目类型） | **[示例数据]** Type A: 0.40 USD/ft², Type B: 0.50 USD/ft², Type C: 0.60 USD/ft² | `RoomCalculator.swift:62-74` |
| BR-09 | 特殊人工费 | **[示例数据]** 50 USD/小时 * 特殊人工小时数 | `Formatting.swift:138-139` |
| BR-10 | 折扣计算 | 小计 * (折扣百分比 / 100) | `Formatting.swift:145-150` |
| BR-11 | 房间总价 | 油漆成本 + 墙面人工 + 天花板人工 + 特殊人工 - 折扣金额 | `Formatting.swift:142-151` |

### 6.3 同步规则

| 规则 ID | 描述 | 行为 | 证据来源 |
|---------|------|------|----------|
| BR-12 | 同步任务失败后自动重试 | 最大重试次数推断为有限次（具体次数需查看 SyncQueue 实现） | `SyncQueue.swift` |
| BR-13 | Token 过期时自动刷新 | 使用 refresh token 换取新的 access token | `External SystemAuthService.swift`（推断） |
| BR-14 | 应用激活时自动测试连接并处理队列 | 前台激活时触发 | `ContentView.swift:35-42` |
| BR-15 | 同步任务状态：Queued/Processing/Success/Failed | 状态机管理 | 推断自 Core Data 模型 `SyncJob.state` |

### 6.4 环境切换规则

| 规则 ID | 描述 | 约束 | 证据来源 |
|---------|------|------|----------|
| BR-16 | 已登录时不允许切换环境（Sandbox ↔ Production） | 必须先登出 | `SettingsView.swift:148-152` |

---

## 7. 状态与边界

### 7.1 按页面列出状态

#### 7.1.1 CustomerListView

| 状态类型 | 描述 | UI 表现 | 证据来源 |
|---------|------|---------|----------|
| **加载状态** | 从 CoreData 加载客户列表 | 无显式 loading 指示器（推断为即时加载） | `CustomerListView.swift:131-133` |
| **空状态** | 无客户记录 | 显示空列表（无特殊空状态 UI） | 推断 |
| **错误状态** | CoreData 读取失败 | 打印日志，不显示给用户 | `CustomerListViewModel.swift:24` |

#### 7.1.2 RoomEditorView

| 状态类型 | 描述 | UI 表现 | 证据来源 |
|---------|------|---------|----------|
| **编辑模式** | 编辑已存在的房间 | 显示现有数据 | `RoomEditorView.swift:71-73` |
| **新建模式** | 创建新房间 | 所有字段为空 | `RoomEditorView.swift:71-73` |
| **验证错误** | 输入不合法 | 显示验证错误提示（validationErrors 数组） | `RoomEditorView.swift:51` |

#### 7.1.3 EstimateTabView

| 状态类型 | 描述 | UI 表现 | 证据来源 |
|---------|------|---------|----------|
| **未登录** | 未连接 External Accounting System | 橙色警告："Not signed in to External Accounting System" | `EstimateTabView.swift:60-66` |
| **邮箱无效** | 客户邮箱缺失或格式错误 | 橙色警告："Email address is invalid or missing" | `EstimateTabView.swift:68-74` |
| **无有效房间** | 客户没有配置房间 | 橙色警告："No valid rooms configured" | `EstimateTabView.swift:76-82` |
| **就绪状态** | 所有条件满足 | 绿色勾选："Ready to sync with External Accounting System" | `EstimateTabView.swift:84-90` |
| **同步中** | 正在创建客户或估算 | 按钮显示 ProgressView，禁用按钮 | `EstimateTabView.swift:117-134` |
| **同步成功** | 成功创建估算 | 绿色勾选：成功消息 | `EstimateTabView.swift:100-106` |
| **同步失败** | 创建失败 | 红色错误消息 | `EstimateTabView.swift:92-98` |

#### 7.1.4 RecentJobsView

| 状态类型 | 描述 | UI 表现 | 证据来源 |
|---------|------|---------|----------|
| **空状态** | 无同步任务 | 显示图标和文字："No recent jobs" | `RecentJobsView.swift:91-104` |
| **队列状态** | 显示任务列表 | 按客户分组展示，包含状态标识 | `RecentJobsView.swift:106-113` |
| **自动刷新** | 每 2 秒自动刷新任务状态 | 后台 Timer 触发 | `RecentJobsView.swift:134-136` |

#### 7.1.5 SettingsView

| 状态类型 | 描述 | UI 表现 | 证据来源 |
|---------|------|---------|----------|
| **已连接** | External Accounting System 登录成功 | 绿色圆点 + "Connected"，显示公司名和 Realm ID | `SettingsView.swift:78-122` |
| **未连接** | 未登录 | 不显示连接状态区域 | `SettingsView.swift:78` |
| **登录中** | 正在进行 OAuth 流程 | 按钮禁用 | `SettingsView.swift:185` |
| **加载 External System 数据** | 正在加载 CustomerTypes/Items | 显示 ProgressView + "Loading External System data..." | `SettingsView.swift:199-207` |

### 7.2 离线状态处理

| 场景 | 行为 | 证据来源 |
|------|------|----------|
| **无网络连接时同步** | 任务进入队列，等待网络恢复后自动重试 | `NetworkMonitor.swift`（推断自 CompositionRoot） |
| **无网络连接时登录** | 无法完成 OAuth 流程（依赖网络） | 推断 |

### 7.3 权限状态

| 权限类型 | 用途 | 请求时机 | 证据来源 |
|---------|------|---------|----------|
| **通知权限** | 后台同步完成时推送通知 | 应用启动时 | `PaintEstimatorApp.swift:41-44` |
| **后台任务权限** | 后台同步队列 | 系统自动授予（已配置 Info.plist） | `green-tech-v3-Info.plist` |

---

## 8. 待确认项（Open Questions）

### 8.1 功能不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-01 | 客户信息 Tab（CustomerInfoTabView）的具体字段和布局是什么？ | 未读取该文件，仅从 Tab 结构推断 | 完整字段列表、必填项、验证规则 |
| OQ-02 | 房间列表（RoomsTabView）的具体 UI 和交互是什么？ | 未读取该文件，仅从导航结构推断 | 是否支持排序、筛选、批量操作 |
| OQ-03 | PaintSelectionSheet 的具体实现和筛选逻辑是什么？ | 引用自 RoomEditorView，但未读取文件 | 如何筛选油漆（按类型/墙面或天花板/品牌） |
| OQ-04 | 同步队列的最大重试次数是多少？ | SyncQueue.swift 未完整读取 | 重试次数、退避策略 |
| OQ-05 | Token 刷新机制的具体实现是什么？ | External SystemAuthService.swift 未完整读取 | 何时触发刷新、刷新失败的处理 |
| OQ-06 | 是否支持离线编辑客户和房间？ | 未在代码中明确体现 | 离线数据是否保存、同步策略 |

### 8.2 UI/UX 不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-07 | 客户列表是否支持搜索和排序？ | CustomerListView 未看到搜索框 | 是否需要搜索功能 |
| OQ-08 | 房间编辑器的具体布局和分区是什么？ | RoomEditorView.swift 仅读取前 300 行 | 完整的 UI 区块划分、组件顺序 |
| OQ-09 | 是否有预览房间 3D/2D 视图？ | 看到 RoomPreviewSection 组件，但未读取 | 预览功能的具体实现 |
| OQ-10 | Recent Jobs 的任务详情展示什么内容？ | CustomerJobGroupView 未读取 | 每个任务显示的字段、状态图标 |

### 8.3 业务规则不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-11 | 油漆覆盖率和价格的数据来源是什么？ | 可从 CSV 导入或手动输入，但是否有默认数据？ | 是否预置油漆数据库 |
| OQ-12 | 特殊人工费固定为 50 USD/小时 (**示例数据**)，是否可配置？ | Formatting.swift:138 硬编码 | 是否需要可配置 |
| OQ-13 | 折扣百分比是否有范围限制（如 0-100%）？ | 未看到验证逻辑 | 验证规则 |
| OQ-14 | External Accounting System 同步失败后，用户如何手动重试？ | 可手动触发 "Send" 按钮，但是否有单个任务重试？ | 单任务重试 UI |

### 8.4 数据不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-15 | Customer 的 customerType 字段用途是什么？ | Core Data 模型中存在，但未在 UI 中看到使用 | 是否与 External Accounting System CustomerType 关联 |
| OQ-16 | Room 的 unitPricePerFt2 字段用途是什么？ | Core Data 模型中存在，但未在计算中使用 | 是否已弃用 |
| OQ-17 | SyncJob 的 payloadSnapshot 存储什么内容？ | Binary 类型，推断为序列化的同步数据 | 具体序列化格式、用途 |
| OQ-18 | 是否存在另一个 Core Data 模型 green_tech_v3.xcdatamodel？ | Glob 搜索结果显示两个模型 | 为什么有两个模型、是否迁移中 |

### 8.5 技术架构不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-19 | 为什么使用两套价格计算方法（calculateRoomPrice 和 calculateRoomPriceWithSeparatePaints）？ | Formatting.swift 中存在两个函数 | 何时使用哪一个、是否已废弃一个 |
| OQ-20 | CompositionRoot 是否应该每次创建新实例，还是应该使用单例？ | 多处直接 `CompositionRoot()` | 依赖注入的最佳实践 |
| OQ-21 | 为什么 RoomEditorView 使用 KVC 访问 selectedCeilingFinishPaintId？ | `room.value(forKey: "selectedCeilingFinishPaintId")` | Core Data 模型是否未重新生成 |

---

## 附录：关键证据片段引用

### A1. 墙面面积计算公式（RoomCalculator.swift:26-48）

```swift
static func wallArea(
    width: Double,
    depth: Double,
    height: Double,
    finishCoats: Int,
    primerCoats: Int,
    paintCeiling: Bool
) -> Decimal {
    let totalCoats = Decimal(finishCoats + primerCoats)
    let widthDecimal = Decimal(width)
    let depthDecimal = Decimal(depth)
    let heightDecimal = Decimal(height)

    // 2*(width*height+depth*height) = 2*height*(width+depth)
    let wallAreaPart = 2 * heightDecimal * (widthDecimal + depthDecimal)

    // IF ceiling=True: (# of finish coats+# of primer coats)*width*depth, else: 0
    let ceilingAreaPart = paintCeiling ? totalCoats * widthDecimal * depthDecimal : 0

    let totalArea = totalCoats * wallAreaPart + ceilingAreaPart

    return totalArea
}
```

### A2. 客户列表黄金分割布局（CustomerListView.swift:28-66）

```swift
GeometryReader { geometry in
    HStack(spacing: 0) {
        // Left side: Customers (1.0 width)
        VStack(spacing: 0) {
            List { ... }
        }
        .frame(width: geometry.size.width * (1.0 / (1.0 + 0.618)))

        Divider()

        // Right side: Recent Jobs (0.618 width)
        RecentJobsView(...)
            .frame(width: geometry.size.width * (0.618 / (1.0 + 0.618)))
    }
}
```

---

**文档结束**
