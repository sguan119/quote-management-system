# 架构与代码约束文档
## 供重构与 AI 协作开发遵循

**文档版本**：v1.0
**生成日期**：2026-01-12
**项目名称**：Quote Estimator（Generic Project）
**证据来源**：基于 `/green tech v3/` 目录下的源代码分析

---

## 目录

1. [当前架构识别](#1-当前架构识别)
2. [分层与模块边界](#2-分层与模块边界)
3. [状态管理方式](#3-状态管理方式)
4. [依赖注入与可测试性策略](#4-依赖注入与可测试性策略)
5. [网络层与错误处理约定](#5-网络层与错误处理约定)
6. [持久化策略](#6-持久化策略)
7. [并发与线程模型](#7-并发与线程模型)
8. [目录结构规范与命名规范](#8-目录结构规范与命名规范)
9. [重构禁区](#9-重构禁区)
10. [待确认项（Open Questions）](#10-待确认项open-questions)

---

## 1. 当前架构识别

### 1.1 架构模式

**识别结果**：**MVVM（Model-View-ViewModel）+ Repository Pattern**

#### 证据：

| 层级 | 代表类型 | 证据文件 |
|------|---------|----------|
| **View** | SwiftUI Views | `CustomerListView.swift`, `RoomEditorView.swift`, `EstimateTabView.swift` |
| **ViewModel** | ObservableObject 类 | `CustomerListViewModel.swift`, `RoomsViewModel.swift`, `EstimateViewModel.swift`, `SettingsViewModel.swift` |
| **Model** | CoreData Entities | `PaintEstimator.xcdatamodeld`: `Customer`, `Room`, `PaintItem`, `Settings`, `SyncJob` |
| **Repository** | Protocol + Concrete | `CustomerRepository.swift`, `RoomRepository.swift`, `PaintItemRepository.swift` |
| **Service** | 业务服务 | `QBOClient.swift`, `QBOAuthService.swift`, `SyncQueue.swift` |

#### 关键类与文件

```
App 入口：PaintEstimatorApp.swift (@main)
├── CompositionRoot.swift (依赖注入容器)
└── ContentView.swift (根视图)

View 层：
├── CustomerListView.swift
├── CustomerDetailView.swift
├── RoomEditorView.swift
└── EstimateTabView.swift

ViewModel 层：
├── CustomerListViewModel.swift
├── CustomerDetailViewModel.swift
├── RoomsViewModel.swift
├── RoomEditorViewModel.swift
├── EstimateViewModel.swift
└── SettingsViewModel.swift

Repository 层：
├── CustomerRepository.swift
├── RoomRepository.swift
├── PaintItemRepository.swift
├── SettingsRepository.swift
└── SyncJobRepository.swift

Service 层：
├── QBOClient.swift
├── QBOAuthService.swift
├── SyncQueue.swift
└── NetworkMonitor.swift

Model 层：
└── CoreData Models (Customer, Room, PaintItem, Settings, SyncJob)
```

**证据来源**：
- `PaintEstimatorApp.swift:10-50` - 应用入口，初始化 CompositionRoot
- `CompositionRoot.swift:9-43` - 依赖注入容器
- `CustomerListViewModel.swift:10-52` - ViewModel 示例，使用 `ObservableObject` 和 `@Published`
- `CustomerRepository.swift` - Repository 示例
- `PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents` - Core Data 模型定义

### 1.2 架构决策记录（ADR）

| 决策 | 理由（推断） | 证据来源 |
|------|------------|----------|
| 使用 MVVM 而非 TCA/Redux | SwiftUI 原生模式，简单易维护 | 全局架构 |
| Repository Pattern | 分离数据访问逻辑，便于测试和 Mock | `Repositories/` 目录结构 |
| Protocol-Oriented Repository | 支持依赖注入和单元测试 | `PaintItemRepositoryProtocol.swift`, `RoomRepositoryProtocol.swift` |
| CompositionRoot 手动依赖注入 | 避免引入第三方 DI 框架（如 Swinject） | `CompositionRoot.swift:9-43` |
| CoreData 而非 SwiftData | 项目可能在 SwiftData 发布前启动 | `PersistenceController.swift` |
| 单一 PersistenceController.shared | 全局单例，简化 CoreData 管理 | `PersistenceController.swift` |

---

## 2. 分层与模块边界

### 2.1 架构分层图

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│                (SwiftUI Views + ViewModels)                 │
├─────────────────────────────────────────────────────────────┤
│  CustomerListView    CustomerDetailView    SettingsView    │
│       ↓                     ↓                    ↓          │
│  CustomerListVM      CustomerDetailVM      SettingsVM      │
│  RoomsViewModel      EstimateViewModel                      │
└─────────────────────┬──────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│                  (Repositories + Services)                  │
├─────────────────────────────────────────────────────────────┤
│  Repositories:                                              │
│    CustomerRepository, RoomRepository, PaintItemRepository  │
│    SettingsRepository, SyncJobRepository                    │
│                                                             │
│  Services:                                                  │
│    QBOClient, QBOAuthService, SyncQueue                     │
│    NetworkMonitor, CryptoManager, PaintDataImporter         │
└─────────────────────┬──────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│                (CoreData + Network + Keychain)              │
├─────────────────────────────────────────────────────────────┤
│  CoreData:     PersistenceController + Entities             │
│  Network:      URLSession + QuickBooks API                  │
│  Keychain:     KeychainStore (Token 存储)                   │
│  FileSystem:   CSV 导入/导出                                │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块依赖规则

#### 规则 1：单向依赖

**约束**：上层可以依赖下层，下层不得依赖上层。

```
View → ViewModel → Repository/Service → CoreData/Network/Keychain
❌ 禁止：CoreData → Repository
❌ 禁止：Repository → ViewModel
❌ 禁止：Service → View
```

**证据来源**：
- `CustomerListView.swift:10-12` - View 依赖 ViewModel
- `CustomerListViewModel.swift:13-15` - ViewModel 依赖 Repository
- `CustomerRepository.swift` - Repository 依赖 CoreData Context

#### 规则 2：ViewModel 不直接访问 CoreData

**约束**：ViewModel 必须通过 Repository 访问数据，不得直接使用 `NSManagedObjectContext`。

**例外**：某些 View 直接使用 `@Environment(\.managedObjectContext)` 传递给 Repository（可接受）。

**证据来源**：
- `CustomerListViewModel.swift:14` - `private let customerRepository: CustomerRepository`
- `CustomerListViewModel.swift:20-26` - 通过 Repository 加载数据

#### 规则 3：Service 之间可相互依赖

**约束**：Service 层可以相互依赖，但需通过 CompositionRoot 注入。

**示例**：
- `SyncQueue` 依赖 `QBOClient`, `QBOAuthService`, `NetworkMonitor`, `SettingsRepository`, `SyncJobRepository`

**证据来源**：
- `CompositionRoot.swift:35-41` - SyncQueue 依赖注入

### 2.3 模块边界清单

| 模块 | 职责 | 可访问的模块 | 禁止访问的模块 | 证据来源 |
|------|------|-------------|---------------|----------|
| **View** | UI 展示与交互 | ViewModel, Environment | Repository, Service, CoreData | 全局 |
| **ViewModel** | UI 状态管理、业务逻辑协调 | Repository, Service | CoreData, Network | 全局 |
| **Repository** | 数据访问抽象 | CoreData Context | ViewModel, View | `Repositories/` |
| **Service** | 业务服务（网络、加密、同步） | Repository, Network, Keychain | View, ViewModel | `Services/` |
| **Utils** | 纯函数工具类 | 无依赖 | 禁止依赖任何层 | `Utils/` |

---

## 3. 状态管理方式

### 3.1 ViewModel 状态管理

**模式**：`ObservableObject` + `@Published` + `Combine`

#### 示例：

```swift
// 证据来源：CustomerListViewModel.swift:10-17
class CustomerListViewModel: ObservableObject {
    @Published var customers: [Customer] = []

    private let customerRepository: CustomerRepository

    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
        loadCustomers()
    }
}
```

#### 关键约定：

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **使用 @Published** | 所有需要触发 UI 更新的属性必须标记为 `@Published` | `CustomerListViewModel.swift:11` |
| **初始化时加载数据** | ViewModel 在 `init()` 中调用 `load` 方法加载初始数据 | `CustomerListViewModel.swift:17` |
| **错误处理** | 错误打印到控制台，不抛出异常 | `CustomerListViewModel.swift:24` |

### 3.2 View 状态管理

**模式**：`@State`, `@StateObject`, `@ObservedObject`, `@Environment`

#### 状态类型与用途：

| 状态类型 | 用途 | 示例 | 证据来源 |
|---------|------|------|----------|
| **@StateObject** | View 拥有并初始化 ViewModel | `@StateObject private var viewModel: CustomerListViewModel` | `CustomerListView.swift:10` |
| **@ObservedObject** | View 观察外部传入的 ViewModel | `@ObservedObject var viewModel: SettingsViewModel` | `SettingsView.swift:11` |
| **@State** | View 内部 UI 状态（如 Sheet 显示/隐藏） | `@State private var showingDeleteConfirmation = false` | `CustomerListView.swift:14` |
| **@Environment** | 系统环境依赖（如 CoreData Context） | `@Environment(\.managedObjectContext)` | `CustomerListView.swift:17` |

#### 关键约定：

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **@StateObject vs @ObservedObject** | 谁创建 ViewModel 谁用 `@StateObject`，外部传入用 `@ObservedObject` | `CustomerListView.swift:10` vs `SettingsView.swift:11` |
| **private 修饰符** | 内部状态必须标记为 `private` | `CustomerListView.swift:13-16` |

### 3.3 全局状态管理

**模式**：`CompositionRoot` 单例 + `PersistenceController.shared`

#### 全局单例清单：

| 单例 | 用途 | 生命周期 | 证据来源 |
|------|------|---------|----------|
| **PersistenceController.shared** | CoreData 持久化控制器 | 应用生命周期 | `PersistenceController.swift` |
| **CompositionRoot** | 依赖注入容器（但在多处实例化，推断为伪单例） | 按需创建 | `CompositionRoot.swift:9` |
| **NotificationService.shared** | 通知服务 | 应用生命周期 | `PaintEstimatorApp.swift:43` |

**⚠️ 注意**：`CompositionRoot` 在多处被实例化（`CustomerListView:18`, `CustomerDetailView:19-37`, `ContentView:12`），可能导致重复创建 Repository 和 Service 实例。

**建议**：改为单例模式或通过 `@EnvironmentObject` 传递。

**证据来源**：
- `CustomerListView.swift:18` - `private let compositionRoot = CompositionRoot()`
- `CustomerDetailView.swift:22-37` - 重新创建 CompositionRoot
- `ContentView.swift:12` - 又一次创建 CompositionRoot

---

## 4. 依赖注入与可测试性策略

### 4.1 依赖注入模式

**模式**：**Constructor Injection（构造函数注入）** + **CompositionRoot**

#### 示例：

```swift
// 证据来源：CustomerListViewModel.swift:14-17
class CustomerListViewModel: ObservableObject {
    private let customerRepository: CustomerRepository

    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
        loadCustomers()
    }
}
```

#### 依赖注入规则：

| 规则 | 描述 | 证据来源 |
|------|------|----------|
| **使用 Protocol** | Repository 必须定义 Protocol，ViewModel 依赖 Protocol | `PaintItemRepositoryProtocol.swift`, `RoomRepositoryProtocol.swift` |
| **构造函数注入** | 所有依赖通过 `init()` 参数传入 | `CustomerListViewModel.swift:14-17` |
| **CompositionRoot 初始化** | 所有 Repository 和 Service 在 CompositionRoot 中初始化 | `CompositionRoot.swift:21-41` |

### 4.2 CompositionRoot 结构

**证据来源**：`CompositionRoot.swift:9-43`

```swift
struct CompositionRoot {
    let persistenceController: PersistenceController
    let customerRepository: CustomerRepository
    let roomRepository: RoomRepository
    let settingsRepository: SettingsRepository
    let syncJobRepository: SyncJobRepository
    let paintItemRepository: PaintItemRepository
    let networkMonitor: NetworkMonitor
    let syncQueue: SyncQueue
    let authService: QBOAuthService
    let qboClient: QBOClient

    init() {
        persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext

        customerRepository = CustomerRepository(context: context)
        roomRepository = RoomRepository(context: context)
        settingsRepository = SettingsRepository(context: context)
        syncJobRepository = SyncJobRepository(context: context)
        paintItemRepository = PaintItemRepository(context: context)
        networkMonitor = NetworkMonitor()

        authService = QBOAuthService(settingsRepository: settingsRepository)
        qboClient = QBOClient(authService: authService, settingsRepository: settingsRepository)

        syncQueue = SyncQueue(
            syncJobRepository: syncJobRepository,
            networkMonitor: networkMonitor,
            qboClient: qboClient,
            authService: authService,
            settingsRepository: settingsRepository
        )
    }
}
```

### 4.3 可测试性策略

#### 4.3.1 Mock 对象

**证据来源**：`green tech v3Tests/Mocks/`

| Mock 类 | 用途 | 文件路径 |
|---------|------|---------|
| **MockPaintItemRepository** | 测试 ViewModel 不依赖真实 CoreData | `Mocks/MockPaintItemRepository.swift` |
| **MockRoomRepository** | 测试房间相关逻辑 | `Mocks/MockRoomRepository.swift` |
| **MockSettingsRepository** | 测试设置相关逻辑 | `Mocks/MockSettingsRepository.swift` |

#### 4.3.2 测试策略

| 测试类型 | 范围 | 证据来源 |
|---------|------|----------|
| **单元测试** | ViewModel、Utils、Calculator | `RoomCalculatorTests.swift`, `ValidationTests.swift` |
| **UI 测试** | 关键用户流程 | `green tech v3UITests/` |

#### 4.3.3 依赖注入 for 测试

**示例**：

```swift
// 测试时注入 Mock Repository
let mockRepository = MockCustomerRepository()
let viewModel = CustomerListViewModel(customerRepository: mockRepository)
```

**关键原则**：
- ViewModel 依赖 Protocol，不依赖具体实现
- 测试时注入 Mock 实现
- 不直接依赖 CoreData Context

---

## 5. 网络层与错误处理约定

### 5.1 网络层架构

**实现方式**：原生 `URLSession` + `async/await`

#### 关键组件：

| 组件 | 职责 | 证据来源 |
|------|------|----------|
| **QBOClient** | QuickBooks API 客户端 | `QBOClient.swift:1-200` |
| **QBOAuthService** | OAuth 2.0 认证 | `QBOAuthService.swift` |
| **NetworkMonitor** | 网络状态监听 | `NetworkMonitor.swift` |
| **LocalHTTPServer** | OAuth 回调本地服务器 | `LocalHTTPServer.swift` |

#### 网络请求模式：

**证据来源**：`QBOClient.swift`（推断）

```swift
// 推断的请求模式
func fetchCustomers() async throws -> [QBOCustomer] {
    let url = baseURL.appendingPathComponent("/v3/company/\(realmId)/query")
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)
    // 解析响应...
}
```

### 5.2 错误处理约定

#### 5.2.1 错误类型定义

**推断**：项目未定义自定义 Error enum，使用系统 Error。

#### 5.2.2 错误处理策略

| 层级 | 错误处理方式 | 证据来源 |
|------|------------|----------|
| **View** | 显示 Alert、ErrorMessage、Toast | `EstimateTabView.swift:92-98` |
| **ViewModel** | 捕获错误，设置 `@Published var errorMessage: String?` | 推断 |
| **Repository** | 抛出错误或打印日志 | `CustomerListViewModel.swift:24` |
| **Service** | 抛出错误，由调用者处理 | 推断 |

#### 5.2.3 错误展示模式

**模式 1：Alert**

```swift
// 证据来源：CustomerListView.swift:119-130
.alert("Delete Customer", isPresented: $showingDeleteConfirmation) {
    Button("Cancel", role: .cancel) { }
    Button("Delete", role: .destructive) {
        deleteCustomer(customer)
    }
} message: {
    Text("Are you sure you want to delete this customer?")
}
```

**模式 2：Inline Error Message**

```swift
// 证据来源：EstimateTabView.swift:92-98
if let errorMessage = viewModel.errorMessage {
    StatusRow(
        icon: "exclamationmark.circle.fill",
        message: errorMessage,
        color: .red
    )
}
```

### 5.3 网络层约定

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **使用 async/await** | 所有网络请求使用 `async throws` | 推断自 SwiftUI 现代实践 |
| **Token 自动刷新** | Token 过期时自动调用 refresh token 接口 | 推断自 OAuth 流程 |
| **离线队列** | 网络不可用时任务进入队列，待恢复后自动重试 | `SyncQueue.swift` + `NetworkMonitor.swift` |
| **HTTPS Only** | 所有 API 请求使用 HTTPS | 推断自 QuickBooks API 要求 |

---

## 6. 持久化策略

### 6.1 CoreData 配置

**证据来源**：`PersistenceController.swift`, `PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents`

#### 6.1.1 数据模型

| Entity | 属性数量 | 关系 | 用途 | 证据来源 |
|--------|---------|------|------|----------|
| **Customer** | 13 | 1-N → Room | 客户信息 | `PaintEstimator.xcdatamodel/contents:3-18` |
| **Room** | 18 | N-1 → Customer | 房间配置与估算 | `PaintEstimator.xcdatamodel/contents:19-39` |
| **PaintItem** | 12 | 无 | 油漆产品库 | `PaintEstimator.xcdatamodel/contents:40-53` |
| **Settings** | 15 | 无 | 应用设置与 OAuth 凭证 | `PaintEstimator.xcdatamodel/contents:54-70` |
| **SyncJob** | 11 | 无 | 同步任务队列 | `PaintEstimator.xcdatamodel/contents:71-83` |

#### 6.1.2 关系约束

| 关系 | 类型 | 删除规则 | 证据来源 |
|------|------|---------|----------|
| Customer → Room | 1-N | Cascade（级联删除） | `PaintEstimator.xcdatamodel/contents:17` |
| Room → Customer | N-1 | Nullify | `PaintEstimator.xcdatamodel/contents:38` |

### 6.2 Repository 模式

#### 6.2.1 Repository 接口示例

**证据来源**：`Repositories/Protocols/PaintItemRepositoryProtocol.swift`（推断）

```swift
protocol PaintItemRepositoryProtocol {
    func fetchAll() throws -> [PaintItem]
    func fetch(by id: UUID) throws -> PaintItem?
    func create() -> PaintItem
    func delete(_ item: PaintItem)
    func save() throws
}
```

#### 6.2.2 Repository 实现约定

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **使用 NSManagedObjectContext** | Repository 持有 CoreData Context | `CustomerRepository.swift`（推断） |
| **fetchAll() 返回数组** | 所有查询返回数组，不返回 Optional | `CustomerListViewModel.swift:22` |
| **create() 返回实体** | 创建方法返回新实体，但不自动保存 | `CustomerListViewModel.swift:30-34` |
| **save() 显式调用** | 需要手动调用 `save()` 提交更改 | `CustomerListViewModel.swift:35` |

### 6.3 Keychain 存储

**用途**：存储敏感信息（OAuth Token、Client Secret）

**证据来源**：`Services/Crypto/KeychainStore.swift`, `Settings` Entity 的加密字段

| 存储字段 | 类型 | 加密方式 | 证据来源 |
|---------|------|---------|----------|
| **clientSecretEnc** | Binary | 加密后的 Client Secret | `PaintEstimator.xcdatamodel/contents:57` |
| **accessTokenEnc** | Binary | 加密后的 Access Token | `PaintEstimator.xcdatamodel/contents:61` |
| **refreshTokenEnc** | Binary | 加密后的 Refresh Token | `PaintEstimator.xcdatamodel/contents:62` |

**加密策略**：
- 使用 `CryptoManager.swift` 加密
- 加密后的数据存储在 CoreData 的 Binary 字段
- Keychain 用作密钥存储（推断）

### 6.4 持久化约定

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **单一 Context** | 全局使用 `PersistenceController.shared.container.viewContext` | `PersistenceController.swift` |
| **主线程操作** | 所有 CoreData 操作在主线程执行 | SwiftUI 默认行为 |
| **级联删除** | 删除 Customer 自动删除关联 Room | `PaintEstimator.xcdatamodel/contents:17` |
| **不使用 CloudKit** | `usedWithCloudKit="false"` | `PaintEstimator.xcdatamodel/contents:2` |

---

## 7. 并发与线程模型

### 7.1 并发模型

**模式**：**Swift Concurrency（async/await）** + **主线程 UI 更新**

#### 7.1.1 异步任务模式

**示例**：

```swift
// 证据来源：ContentView.swift:31-42
.onAppear {
    Task {
        await checkConnectionAndProcessQueue()
    }
}

.onChange(of: scenePhase) { phase in
    if phase == .active {
        Task {
            await checkConnectionAndProcessQueue()
        }
    }
}
```

#### 7.1.2 并发约定

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **使用 async/await** | 所有异步操作使用 `async/await`，不使用回调 | `ContentView.swift:31-42` |
| **Task {} 包装** | 在 SwiftUI 生命周期中启动异步任务使用 `Task {}` | `ContentView.swift:31-33` |
| **主线程更新 UI** | `@Published` 属性自动在主线程更新 UI | SwiftUI 默认行为 |
| **避免 DispatchQueue** | 不使用 `DispatchQueue.main.async`（除特殊情况） | 推断 |

### 7.2 后台任务

**模式**：**BackgroundTasks Framework**

**证据来源**：
- `PaintEstimatorApp.swift:8` - `import BackgroundTasks`
- `green-tech-v3-Info.plist` - `BGTaskSchedulerPermittedIdentifiers`

#### 后台任务标识符：

| 标识符 | 用途 | 证据来源 |
|--------|------|----------|
| `com.paintestimator.sync.refresh` | 刷新同步队列 | `green-tech-v3-Info.plist` |
| `com.paintestimator.sync.process` | 处理同步任务 | `green-tech-v3-Info.plist` |

### 7.3 线程安全约定

| 约定 | 描述 | 证据来源 |
|------|------|----------|
| **CoreData 主线程** | CoreData 操作仅在主线程 Context 执行 | `PersistenceController.shared.container.viewContext` |
| **ViewModel 主线程** | ViewModel 的 `@Published` 更新自动在主线程 | `@Published` 默认行为 |
| **网络层线程无关** | `async/await` 自动管理线程切换 | Swift Concurrency |

---

## 8. 目录结构规范与命名规范

### 8.1 目录结构规范

#### 8.1.1 当前目录树

```
green tech v3/
├── App/                              # 应用入口与全局配置
│   ├── PaintEstimatorApp.swift
│   ├── AppDelegate.swift
│   └── CompositionRoot.swift
├── Features/                         # 功能模块（按业务领域划分）
│   ├── Customers/                    # 客户管理模块
│   │   ├── ViewModels/               # 视图模型
│   │   ├── Components/               # 可复用组件
│   │   ├── CustomerListView.swift
│   │   ├── CustomerDetailView.swift
│   │   ├── RoomEditorView.swift
│   │   └── ...
│   └── Settings/                     # 设置模块
│       ├── ViewModels/
│       └── SettingsView.swift
├── Data/                             # 数据层
│   ├── PersistenceController.swift
│   ├── Models/                       # DTO/数据模型（空）
│   └── Repositories/                 # Repository 实现
│       ├── Protocols/                # Repository 协议
│       ├── CustomerRepository.swift
│       └── ...
├── Services/                         # 业务服务
│   ├── Networking/                   # 网络服务
│   │   ├── QBOClient.swift
│   │   ├── QBOAuthService.swift
│   │   └── SyncQueue.swift
│   ├── Crypto/                       # 加密服务
│   ├── Import/                       # 导入服务
│   └── Notifications/                # 通知服务
├── Utils/                            # 工具类
│   ├── RoomCalculator.swift
│   ├── Formatting.swift
│   ├── Validation.swift
│   └── UI/                           # UI 工具
│       └── DesignSystem/
├── DesignSystem/                     # 设计系统（空）
├── Assets.xcassets/                  # 资源文件
├── PaintEstimator.xcdatamodeld/      # CoreData 模型
├── Debug/                            # 调试工具
│   ├── DebugSeeder.swift
│   └── SyncLog.swift
└── ContentView.swift                 # 根视图
```

#### 8.1.2 目录规范

| 规则 | 描述 | 证据来源 |
|------|------|----------|
| **按功能模块划分** | `Features/` 下按业务领域（Customers, Settings）划分 | 当前结构 |
| **ViewModel 在模块内** | ViewModel 放在 `Features/{Module}/ViewModels/` | `Features/Customers/ViewModels/` |
| **共享组件** | 模块内可复用组件放在 `Components/` | `Features/Customers/Components/` |
| **Utils 无依赖** | `Utils/` 只包含纯函数工具类，不依赖其他层 | `Utils/` 结构 |
| **Data 和 Services 分离** | Data 层负责持久化，Services 负责业务逻辑 | 当前结构 |

### 8.2 命名规范

#### 8.2.1 文件命名

| 类型 | 命名规范 | 示例 | 证据来源 |
|------|---------|------|----------|
| **View** | `{Name}View.swift` | `CustomerListView.swift` | `Features/Customers/` |
| **ViewModel** | `{Name}ViewModel.swift` | `CustomerListViewModel.swift` | `Features/Customers/ViewModels/` |
| **Repository** | `{Entity}Repository.swift` | `CustomerRepository.swift` | `Data/Repositories/` |
| **Protocol** | `{Name}Protocol.swift` | `PaintItemRepositoryProtocol.swift` | `Data/Repositories/Protocols/` |
| **Service** | `{Name}Service.swift` 或 `{Name}Client.swift` | `QBOAuthService.swift`, `QBOClient.swift` | `Services/Networking/` |
| **Utility** | `{Name}.swift` (驼峰式) | `RoomCalculator.swift`, `Formatting.swift` | `Utils/` |
| **Component** | `{Name}View.swift` 或 `{Name}.swift` | `RoomRowView.swift`, `PaintSelectionSheet.swift` | `Features/Customers/Components/` |

#### 8.2.2 类型命名

| 类型 | 命名规范 | 示例 | 证据来源 |
|------|---------|------|----------|
| **View** | `{Name}View` | `CustomerListView`, `RoomEditorView` | 全局 |
| **ViewModel** | `{Name}ViewModel` | `CustomerListViewModel` | 全局 |
| **Repository** | `{Entity}Repository` | `CustomerRepository` | 全局 |
| **Service** | `{Name}Service` 或 `{Name}Client` | `QBOAuthService`, `QBOClient` | 全局 |
| **Model（CoreData）** | 实体名（无后缀） | `Customer`, `Room`, `PaintItem` | CoreData 模型 |
| **DTO** | `QBO{Name}` (QuickBooks 数据) | `QBOCustomer`, `QBOEstimate` | `QBOClient.swift:18-150` |

#### 8.2.3 变量命名

| 类型 | 命名规范 | 示例 | 证据来源 |
|------|---------|------|----------|
| **私有属性** | `private let/var {name}` | `private let customerRepository` | `CustomerListViewModel.swift:13` |
| **Published 属性** | `@Published var {name}` | `@Published var customers: [Customer]` | `CustomerListViewModel.swift:11` |
| **State 属性** | `@State private var {name}` | `@State private var showingDeleteConfirmation` | `CustomerListView.swift:14` |
| **环境属性** | `@Environment(\.{name})` | `@Environment(\.managedObjectContext)` | `CustomerListView.swift:17` |

---

## 9. 重构禁区

以下接口、类型、命名约定不应在重构中随意更改，以确保 UI 不变、数据契约稳定。

### 9.1 Core Data 模型（绝对禁止更改）

**原因**：Core Data 模型更改需要迁移策略，否则会导致数据丢失。

| Entity | 属性 | 禁止操作 | 证据来源 |
|--------|------|---------|----------|
| **Customer** | id, firstName, lastName, email, mobile, address, city, province, postal, country, customerType, qboCustomerId, lastSyncedAt | 重命名、删除、更改类型 | `PaintEstimator.xcdatamodel/contents:3-18` |
| **Room** | id, name, lengthFt, widthFt, heightFt, primerCoats, finishCoats, unitPricePerFt2, selectedPaintId, selectedPrimerPaintId, selectedFinishPaintId, selectedCeilingFinishPaintId, projectType, paintCeiling, specialLabour, specialLabourHour, discount, discountPercent | 重命名、删除、更改类型 | `PaintEstimator.xcdatamodel/contents:19-39` |
| **PaintItem** | id, brand, series, finish, sku, pricePerFt2, source, wallOrCeiling, paintType, coverageSf, pricePerGallon, lastUpdatedAt | 重命名、删除、更改类型 | `PaintEstimator.xcdatamodel/contents:40-53` |
| **Settings** | environment, clientId, clientSecretEnc, redirectUri, qboItemRefIdOrName, paintSourceMode, accessTokenEnc, refreshTokenEnc, tokenExpiry, realmId, commercialCadPerSf, standardCadPerSf, specialCadPerSf, qboCustomerTypesJson, qboWallPaintingId | 重命名、删除、更改类型 | `PaintEstimator.xcdatamodel/contents:54-70` |
| **SyncJob** | id, type, customerId, payloadSnapshot, state, retries, lastError, lastUpdatedAt, nextRunAt, createdAt, environment | 重命名、删除、更改类型 | `PaintEstimator.xcdatamodel/contents:71-83` |

**例外**：可以添加新字段（需设置 Optional=YES），但不得修改现有字段。

### 9.2 公共 API 接口（禁止更改签名）

| 接口 | 签名 | 禁止操作 | 证据来源 |
|------|------|---------|----------|
| **RoomCalculator.wallArea()** | `static func wallArea(for room: Room) -> Decimal` | 更改参数、返回类型 | `RoomCalculator.swift:14-23` |
| **RoomCalculator.subtotal()** | `static func subtotal(for room: Room, paintItemRepository: PaintItemRepository, settingsRepository: SettingsRepository) -> Decimal` | 更改参数、返回类型 | `RoomCalculator.swift:53-143` |
| **Formatting.currency()** | `static func currency(_ value: Decimal) -> String` | 更改参数、返回类型 | `Formatting.swift:9-16` |
| **Formatting.wallArea 公式** | 见 `RoomCalculator.swift:34-48` | 修改公式逻辑 | `RoomCalculator.swift:34-48` |

### 9.3 导航路径（禁止更改层级）

| 路径 | 描述 | 禁止操作 | 证据来源 |
|------|------|---------|----------|
| `CustomerListView` → `CustomerDetailView` | 客户列表到详情 | 更改导航方式（NavigationPath） | `CustomerListView.swift:68-75` |
| `CustomerDetailView` → Tab[0/1/2] | 三个标签页（Info/Rooms/Estimate） | 更改 Tab 顺序、标签名 | `CustomerDetailView.swift:60-79` |
| `CustomerListView` → `SettingsView` | 设置入口 | 更改导航方式 | `CustomerListView.swift:106-117` |

### 9.4 CompositionRoot（禁止更改公开属性）

| 属性 | 类型 | 禁止操作 | 证据来源 |
|------|------|---------|----------|
| `customerRepository` | `CustomerRepository` | 重命名、更改类型 | `CompositionRoot.swift:11` |
| `roomRepository` | `RoomRepository` | 重命名、更改类型 | `CompositionRoot.swift:12` |
| `settingsRepository` | `SettingsRepository` | 重命名、更改类型 | `CompositionRoot.swift:13` |
| `syncJobRepository` | `SyncJobRepository` | 重命名、更改类型 | `CompositionRoot.swift:14` |
| `paintItemRepository` | `PaintItemRepository` | 重命名、更改类型 | `CompositionRoot.swift:15` |
| `qboClient` | `QBOClient` | 重命名、更改类型 | `CompositionRoot.swift:19` |
| `authService` | `QBOAuthService` | 重命名、更改类型 | `CompositionRoot.swift:18` |
| `syncQueue` | `SyncQueue` | 重命名、更改类型 | `CompositionRoot.swift:17` |

### 9.5 URL Scheme（绝对禁止更改）

**原因**：OAuth 回调依赖 URL Scheme，更改后需重新配置 QuickBooks。

| URL Scheme | 用途 | 证据来源 |
|------------|------|----------|
| Redirect URI | OAuth 回调地址 | `Settings.redirectUri` |

### 9.6 房间价格计算公式（禁止更改逻辑）

**公式（必须保持一致）**：

```
墙面面积 = ((底漆涂层数 + 面漆涂层数) * 2 * (宽*高 + 长*高)
           + (是否粉刷天花板 ? (底漆涂层数 + 面漆涂层数) * 宽*长 : 0))

总价 = 油漆成本 + 墙面人工 + 天花板人工 + 特殊人工 - 折扣金额
```

**证据来源**：
- `RoomCalculator.swift:26-48` - 墙面面积公式
- `Formatting.swift:95-186` - 价格计算公式

---

## 10. 待确认项（Open Questions）

### 10.1 架构不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-A01 | CompositionRoot 是否应该改为单例模式？ | 多处实例化 `CompositionRoot()` | 当前多次创建是否会导致性能问题或状态不一致 |
| OQ-A02 | 为什么存在两个 CoreData 模型文件？ | `PaintEstimator.xcdatamodeld` 和 `green_tech_v3.xcdatamodeld` | 是否在迁移中、哪个是主模型 |
| OQ-A03 | DesignSystem 目录为空，是否规划中？ | `DesignSystem/` 目录存在但为空 | 是否计划统一设计系统 |
| OQ-A04 | Repository Protocol 是否完整定义？ | 只看到部分 Protocol | 所有 Repository 是否都有对应 Protocol |
| OQ-A05 | 为什么 RoomEditorView 使用 KVC 访问 selectedCeilingFinishPaintId？ | `room.value(forKey: "selectedCeilingFinishPaintId")` | Core Data 类是否未重新生成 |

### 10.2 依赖注入不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-A06 | 为什么不使用 @EnvironmentObject 传递 CompositionRoot？ | 当前每个 View 自己创建 CompositionRoot | 是否应该改为全局 EnvironmentObject |
| OQ-A07 | Mock 对象是否覆盖所有 Repository？ | 只看到 3 个 Mock | CustomerRepository、SyncJobRepository 是否有 Mock |
| OQ-A08 | 测试覆盖率是多少？ | 只看到少量测试文件 | 当前测试覆盖率、是否需要补充测试 |

### 10.3 并发与线程不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-A09 | 后台任务的调度策略是什么？ | BackgroundTasks 已注册，但具体调度逻辑未完全读取 | 何时触发、频率、执行逻辑 |
| OQ-A10 | 是否使用 Actor 隔离状态？ | 未看到 `actor` 关键字 | 是否需要引入 Actor 模式 |
| OQ-A11 | SyncQueue 的并发控制策略是什么？ | SyncQueue.swift 未完整读取 | 是否串行处理任务、并发数限制 |

### 10.4 错误处理不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-A12 | 是否需要定义统一的 AppError 枚举？ | 当前使用系统 Error | 是否需要自定义错误类型 |
| OQ-A13 | 网络错误的重试策略是什么？ | SyncQueue 有重试逻辑，但具体策略未完全读取 | 重试次数、退避策略、失败处理 |
| OQ-A14 | CoreData 保存失败的处理逻辑是什么？ | 只看到 `print(error)`，未看到恢复机制 | 是否需要错误恢复、用户提示 |

### 10.5 持久化不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-A15 | 是否需要 CoreData 迁移策略？ | 当前模型可能需要新增字段 | 轻量级迁移 vs 自定义迁移 |
| OQ-A16 | Keychain 是否使用了 Access Group？ | KeychainStore.swift 未读取 | 是否支持多 App 共享 Keychain |
| OQ-A17 | 是否需要数据导出/备份功能？ | 只看到 CSV 导入，未看到导出 | 用户数据备份策略 |

---

## 附录：架构图

### A1. 完整架构分层图

```
┌─────────────────────────────────────────────────────────────┐
│                      App Layer                              │
│              PaintEstimatorApp (@main)                      │
│              AppDelegate                                    │
│              CompositionRoot (DI Container)                 │
└─────────────────────┬──────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                  Presentation Layer                         │
│                (SwiftUI Views + ViewModels)                 │
├─────────────────────────────────────────────────────────────┤
│  Features/Customers/                                        │
│    ├── CustomerListView ← CustomerListViewModel            │
│    ├── CustomerDetailView ← CustomerDetailViewModel        │
│    ├── RoomEditorView ← RoomsViewModel                     │
│    └── EstimateTabView ← EstimateViewModel                 │
│                                                             │
│  Features/Settings/                                         │
│    └── SettingsView ← SettingsViewModel                    │
└─────────────────────┬──────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│              (Repositories + Services + Utils)              │
├─────────────────────────────────────────────────────────────┤
│  Data/Repositories/                                         │
│    ├── CustomerRepository (Protocol)                        │
│    ├── RoomRepository (Protocol)                            │
│    ├── PaintItemRepository (Protocol)                       │
│    ├── SettingsRepository (Protocol)                        │
│    └── SyncJobRepository                                    │
│                                                             │
│  Services/                                                  │
│    ├── Networking/                                          │
│    │   ├── QBOClient (QuickBooks API)                      │
│    │   ├── QBOAuthService (OAuth 2.0 + PKCE)               │
│    │   ├── SyncQueue (后台同步队列)                         │
│    │   └── NetworkMonitor (网络状态监听)                    │
│    ├── Crypto/                                              │
│    │   ├── CryptoManager (加密服务)                         │
│    │   └── KeychainStore (Keychain 存储)                    │
│    └── Notifications/                                       │
│        └── NotificationService (本地通知)                    │
│                                                             │
│  Utils/                                                     │
│    ├── RoomCalculator (房间计算)                            │
│    ├── Formatting (格式化工具)                              │
│    └── Validation (验证工具)                                │
└─────────────────────┬──────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│         (CoreData + Network + Keychain + FileSystem)        │
├─────────────────────────────────────────────────────────────┤
│  CoreData:                                                  │
│    ├── PersistenceController.shared                         │
│    └── Entities: Customer, Room, PaintItem, Settings,      │
│                  SyncJob                                    │
│                                                             │
│  Network:                                                   │
│    ├── URLSession (QuickBooks API)                          │
│    └── LocalHTTPServer (OAuth 回调)                         │
│                                                             │
│  Keychain:                                                  │
│    └── KeychainStore (OAuth Token 存储)                     │
│                                                             │
│  FileSystem:                                                │
│    └── CSV 导入/导出                                         │
└─────────────────────────────────────────────────────────────┘
```

---

**文档结束**
