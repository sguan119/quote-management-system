# 数据契约文档
## Data Contract

**文档版本**：v1.0
**生成日期**：2026-01-12
**项目名称**：Quote Estimator（通用示例项目）
**说明**：本文档已通用化处理，所有业务数据仅供示例参考

---

## 目录

1. [领域模型（CoreData Entities）](#1-领域模型coredata-entities)
2. [API 契约（External Accounting System Online）](#2-api-契约quickbooks-online)
3. [本地存储契约](#3-本地存储契约)
4. [页面数据需求映射](#4-页面数据需求映射)
5. [样例数据](#5-样例数据)
6. [待确认项（Open Questions）](#6-待确认项open-questions)

---

## 1. 领域模型（CoreData Entities）

### 1.1 Customer（客户）

**用途**：存储客户基本信息

**证据来源**：`PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents:3-18`

| 字段名 | 类型 | 可空 | 默认值 | 含义 | 备注 |
|--------|------|------|--------|------|------|
| **id** | UUID | NO | - | 唯一标识符 | 主键 |
| **firstName** | String | YES | - | 名字 | - |
| **lastName** | String | YES | - | 姓氏 | - |
| **email** | String | YES | - | 电子邮箱 | 同步到 External Accounting System 时必填 |
| **mobile** | String | YES | - | 手机号码 | - |
| **address** | String | YES | - | 地址（街道） | - |
| **city** | String | YES | - | 城市 | - |
| **province** | String | YES | - | 省份/州 | - |
| **postal** | String | YES | - | 邮政编码 | - |
| **country** | String | YES | - | 国家 | - |
| **customerType** | String | YES | - | 客户类型 | 可能关联 External Accounting System CustomerType |
| **qboCustomerId** | String | YES | - | External Accounting System 客户 ID | 同步后存储 |
| **lastSyncedAt** | Date | YES | - | 最后同步时间 | 用于跟踪同步状态 |

**关系**：
- `rooms`：1-N → Room（级联删除）

**业务规则**：
- `email` 必须为有效格式才能同步到 External Accounting System
- 删除客户时自动删除关联的 Room（Cascade）

---

### 1.2 Room（房间）

**用途**：存储房间配置与估算数据

**证据来源**：`PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents:19-39`

| 字段名 | 类型 | 可空 | 默认值 | 含义 | 备注 |
|--------|------|------|--------|------|------|
| **id** | UUID | NO | - | 唯一标识符 | 主键 |
| **name** | String | YES | - | 房间名称 | 例如："Living Room", "Bedroom 1" |
| **lengthFt** | Double | YES | 0.0 | 房间长度（英尺） | - |
| **widthFt** | Double | YES | 0.0 | 房间宽度（英尺） | - |
| **heightFt** | Double | YES | 0.0 | 房间高度（英尺） | - |
| **primerCoats** | Int16 | YES | 0 | 底漆涂层数 | 范围：0-N |
| **finishCoats** | Int16 | YES | 0 | 面漆涂层数 | 范围：0-N |
| **unitPricePerFt2** | Decimal | YES | 0.0 | 每平方英尺单价 | 可能已弃用，未在计算中使用 |
| **selectedPaintId** | String | YES | - | 选中的油漆 ID（UUID 字符串） | 遗留字段，可能已被分离的 primer/finish 替代 |
| **selectedPrimerPaintId** | String | YES | - | 选中的底漆 ID（UUID 字符串） | - |
| **selectedFinishPaintId** | String | YES | - | 选中的面漆 ID（UUID 字符串） | - |
| **selectedCeilingFinishPaintId** | String | YES | - | 选中的天花板油漆 ID（UUID 字符串） | 仅在 paintCeiling=true 时使用 |
| **projectType** | String | YES | - | 项目类型 | 枚举："Type A", "Type B", "Type C" |
| **paintCeiling** | Boolean | YES | NO | 是否粉刷天花板 | - |
| **specialLabour** | Boolean | YES | NO | 是否使用特殊人工 | - |
| **specialLabourHour** | Decimal | YES | 0.0 | 特殊人工小时数 | 仅在 specialLabour=true 时使用 |
| **discount** | Boolean | YES | NO | 是否应用折扣 | - |
| **discountPercent** | Decimal | YES | 0.0 | 折扣百分比 | 范围：0-100 |

**关系**：
- `customer`：N-1 → Customer（Nullify）

**业务规则**：
- 墙面面积计算公式：`((primerCoats + finishCoats) * 2 * (widthFt * heightFt + lengthFt * heightFt) + (paintCeiling ? (primerCoats + finishCoats) * widthFt * lengthFt : 0))`
- 人工单价根据 `projectType` 决定：
  - Type A: **[示例]** 0.40 USD/ft²
  - Type B: **[示例]** 0.50 USD/ft²
  - Type C: **[示例]** 0.60 USD/ft²
- 特殊人工费：**[示例]** 50 USD/小时
- 油漆选择优先级：selectedFinishPaintId > selectedPrimerPaintId > selectedPaintId（遗留）

**证据来源**：
- `RoomCalculator.swift:26-48` - 面积公式
- `RoomCalculator.swift:62-74` - 人工单价

---

### 1.3 PaintItem（油漆项）

**用途**：存储油漆产品信息

**证据来源**：`PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents:40-53`

| 字段名 | 类型 | 可空 | 默认值 | 含义 | 备注 |
|--------|------|------|--------|------|------|
| **id** | UUID | NO | - | 唯一标识符 | 主键 |
| **brand** | String | YES | - | 品牌 | 例如："Benjamin Moore", "Sherwin-Williams" |
| **series** | String | YES | - | 系列 | 例如："Aura", "Duration" |
| **finish** | String | YES | - | 光泽度/名称 | 例如："Matte", "Eggshell", "Semi-Gloss" |
| **sku** | String | YES | - | SKU 编码 | 产品唯一编码 |
| **pricePerFt2** | Decimal | YES | 0.0 | 每平方英尺价格 | 可能已弃用，未在计算中使用 |
| **source** | String | YES | - | 数据来源 | 枚举："Manual", "API", "CSV Import" |
| **wallOrCeiling** | String | YES | - | 适用范围 | 枚举："Wall", "Ceiling", "Both" |
| **paintType** | String | YES | - | 油漆类型 | 枚举："Primer", "Finish" |
| **coverageSf** | Decimal | YES | 0.0 | 覆盖率（平方英尺/加仑） | 用于计算所需油漆量 |
| **pricePerGallon** | Decimal | YES | 0.0 | 每加仑价格（CAD） | 用于计算油漆成本 |
| **lastUpdatedAt** | Date | YES | - | 最后更新时间 | - |

**关系**：无

**业务规则**：
- 油漆用量计算：`totalArea / coverageSf`（加仑）
- 油漆成本：`(totalArea / coverageSf) * pricePerGallon`

**证据来源**：
- `Formatting.swift:124-128` - 油漆用量计算

---

### 1.4 Settings（设置）

**用途**：存储应用设置与 OAuth 凭证

**证据来源**：`PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents:54-70`

| 字段名 | 类型 | 可空 | 默认值 | 含义 | 备注 |
|--------|------|------|--------|------|------|
| **environment** | String | YES | "Sandbox" | External Accounting System 环境 | 枚举："Sandbox", "Production" |
| **clientId** | String | YES | - | OAuth Client ID | External Accounting System 应用凭证 |
| **clientSecretEnc** | Binary | YES | - | 加密后的 Client Secret | 加密存储 |
| **redirectUri** | String | YES | - | OAuth Redirect URI | 例如："http://localhost:8080/callback" |
| **qboItemRefIdOrName** | String | YES | - | External Accounting System Item 引用 ID 或名称 | 用于创建 Estimate Line Item |
| **paintSourceMode** | String | YES | "Manual" | 油漆数据来源模式 | 枚举："Manual", "API", "Both" |
| **accessTokenEnc** | Binary | YES | - | 加密后的 Access Token | 加密存储 |
| **refreshTokenEnc** | Binary | YES | - | 加密后的 Refresh Token | 加密存储 |
| **tokenExpiry** | Date | YES | - | Token 过期时间 | 用于判断是否需要刷新 |
| **realmId** | String | YES | - | External Accounting System Realm ID（公司 ID） | 登录后存储 |
| **typeAUsdPerSf** | Decimal | YES | 0.40 | Type A 项目人工单价（**示例** USD/ft²） | - |
| **typeBUsdPerSf** | Decimal | YES | 0.50 | Type B 项目人工单价（**示例** USD/ft²） | - |
| **typeCUsdPerSf** | Decimal | YES | 0.60 | Type C 项目人工单价（**示例** USD/ft²） | - |
| **qboCustomerTypesJson** | String | YES | - | External Accounting System CustomerTypes JSON 数据 | 缓存 External System 数据 |
| **qboWallPaintingId** | String | YES | - | External Accounting System "WALL PAINTING" Item ID | 用于创建 Estimate Line Item |

**关系**：无

**业务规则**：
- `environment` 在已登录时不可更改（必须先登出）
- Token 加密方式：使用 `CryptoManager` 加密，存储在 CoreData Binary 字段
- Token 刷新：在 `tokenExpiry` 前自动刷新

**证据来源**：
- `SettingsView.swift:148-152` - 环境切换限制
- `CryptoManager.swift`, `KeychainStore.swift` - 加密存储

---

### 1.5 SyncJob（同步任务）

**用途**：管理 External Accounting System 同步队列

**证据来源**：`PaintEstimator.xcdatamodeld/PaintEstimator.xcdatamodel/contents:71-83`

| 字段名 | 类型 | 可空 | 默认值 | 含义 | 备注 |
|--------|------|------|--------|------|------|
| **id** | UUID | NO | - | 唯一标识符 | 主键 |
| **type** | String | YES | - | 任务类型 | 枚举："UpsertCustomer", "CreateEstimate"（推断） |
| **customerId** | UUID | YES | - | 关联的客户 ID | - |
| **payloadSnapshot** | Binary | YES | - | 序列化的任务数据快照 | 存储任务所需的完整数据 |
| **state** | String | YES | "Queued" | 任务状态 | 枚举："Queued", "Processing", "Success", "Failed" |
| **retries** | Int16 | YES | 0 | 重试次数 | 用于重试逻辑 |
| **lastError** | String | YES | - | 最后错误消息 | 失败时存储错误信息 |
| **lastUpdatedAt** | Date | YES | - | 最后更新时间 | - |
| **nextRunAt** | Date | YES | - | 下次运行时间 | 用于延迟重试 |
| **createdAt** | Date | YES | - | 创建时间 | - |
| **environment** | String | YES | - | 创建时的环境 | 关联 Settings.environment |

**关系**：无

**业务规则**：
- 状态机：Queued → Processing → Success/Failed
- 失败任务会自动重试（最大重试次数：待确认）
- `payloadSnapshot` 存储任务创建时的完整数据，避免原始数据被修改影响同步

**证据来源**：
- `SyncQueue.swift` - 任务队列管理

---

## 2. API 契约（External Accounting System Online）

### 2.1 认证 API

#### 2.1.1 OAuth 2.0 授权流程

**证据来源**：`External SystemAuthService.swift`

**1. 授权请求**

```
GET https://appcenter.intuit.com/connect/oauth2
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| client_id | String | YES | OAuth Client ID |
| response_type | String | YES | 固定值："code" |
| scope | String | YES | 权限范围："com.intuit.quickbooks.accounting" |
| redirect_uri | String | YES | 回调地址 |
| state | String | YES | 随机生成的状态码（安全验证） |
| code_challenge | String | YES | PKCE Code Challenge (SHA256) |
| code_challenge_method | String | YES | 固定值："S256" |

**2. 回调响应**

```
GET {redirect_uri}?code={authorization_code}&state={state}&realmId={realm_id}
```

| 参数 | 类型 | 说明 |
|------|------|------|
| code | String | 授权码（用于换取 Token） |
| state | String | 状态码（需验证） |
| realmId | String | External Accounting System 公司 ID |

**3. Token 交换**

```
POST https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
Content-Type: application/x-www-form-urlencoded
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| grant_type | String | YES | 固定值："authorization_code" |
| code | String | YES | 授权码 |
| redirect_uri | String | YES | 回调地址（需与授权请求一致） |
| code_verifier | String | YES | PKCE Code Verifier |

**响应**：

```json
{
  "access_token": "eyJlbmMiOiJBMTI4Q0JDLUhTMjU2...",
  "refresh_token": "L011546037884HmSpcxl9A7sHLlB...",
  "token_type": "bearer",
  "expires_in": 3600,
  "x_refresh_token_expires_in": 8726400
}
```

**4. Token 刷新**

```
POST https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
Content-Type: application/x-www-form-urlencoded
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| grant_type | String | YES | 固定值："refresh_token" |
| refresh_token | String | YES | Refresh Token |

---

### 2.2 External Accounting System API（v3）

**Base URL**：
- Sandbox: `https://sandbox-quickbooks.api.intuit.com/v3`
- Production: `https://quickbooks.api.intuit.com/v3`

**通用 Headers**：

| Header | 值 | 说明 |
|--------|-----|------|
| Authorization | `Bearer {access_token}` | 访问令牌 |
| Accept | `application/json` | 响应格式 |
| Content-Type | `application/json` | 请求格式 |

#### 2.2.1 获取公司信息

**证据来源**：`External SystemClient.swift`（推断）

```
GET /company/{realmId}/companyinfo/{realmId}
```

**响应**：

```json
{
  "CompanyInfo": {
    "CompanyName": "Sandbox Company_US_1",
    "CompanyAddr": {
      "Line1": "123 Main St",
      "City": "Mountain View",
      "CountrySubDivisionCode": "CA",
      "PostalCode": "94043",
      "Country": "USA"
    }
  }
}
```

**对应模型**：`External SystemClient.swift:9-16`

```swift
struct CompanyInfo: Codable {
    let companyInfo: CompanyInfoDetail?
}

struct CompanyInfoDetail: Codable {
    let companyName: String?
    let companyAddr: Address?
}
```

#### 2.2.2 查询客户列表

```
GET /company/{realmId}/query?query=SELECT * FROM Customer
```

**响应**：

```json
{
  "QueryResponse": {
    "Customer": [
      {
        "Id": "1",
        "SyncToken": "0",
        "GivenName": "John",
        "FamilyName": "Doe",
        "DisplayName": "John Doe",
        "Active": true,
        "PrimaryEmailAddr": {
          "Address": "john.doe@example.com"
        },
        "PrimaryPhone": {
          "FreeFormNumber": "(555) 123-4567"
        },
        "BillAddr": {
          "Line1": "123 Main St",
          "City": "San Francisco",
          "CountrySubDivisionCode": "CA",
          "PostalCode": "94105",
          "Country": "USA"
        }
      }
    ],
    "maxResults": 1,
    "startPosition": 1,
    "totalCount": 1
  }
}
```

**对应模型**：`External SystemClient.swift:18-72`

```swift
struct External SystemCustomer: Codable {
    let id: String?              // "Id"
    let syncToken: String?       // "SyncToken"
    let givenName: String?       // "GivenName"
    let familyName: String?      // "FamilyName"
    let displayName: String?     // "DisplayName"
    let active: Bool?            // "Active"
    let primaryEmailAddr: EmailAddress?  // "PrimaryEmailAddr"
    let primaryPhone: PhoneNumber?       // "PrimaryPhone"
    let billAddr: Address?       // "BillAddr"
}
```

#### 2.2.3 创建客户

```
POST /company/{realmId}/customer
Content-Type: application/json
```

**请求体**：

```json
{
  "GivenName": "John",
  "FamilyName": "Doe",
  "DisplayName": "John Doe",
  "PrimaryEmailAddr": {
    "Address": "john.doe@example.com"
  },
  "PrimaryPhone": {
    "FreeFormNumber": "(555) 123-4567"
  },
  "BillAddr": {
    "Line1": "123 Main St",
    "City": "San Francisco",
    "CountrySubDivisionCode": "CA",
    "PostalCode": "94105",
    "Country": "USA"
  }
}
```

**响应**：

```json
{
  "Customer": {
    "Id": "123",
    "SyncToken": "0",
    "GivenName": "John",
    "FamilyName": "Doe",
    ...
  },
  "time": "2026-01-12T10:30:00Z"
}
```

#### 2.2.4 更新客户

```
POST /company/{realmId}/customer
Content-Type: application/json
```

**请求体**（必须包含 Id 和 SyncToken）：

```json
{
  "Id": "123",
  "SyncToken": "0",
  "GivenName": "John",
  "FamilyName": "Smith",
  ...
}
```

#### 2.2.5 创建估算（Estimate）

**证据来源**：`External SystemClient.swift:74-114`（推断）

```
POST /company/{realmId}/estimate
Content-Type: application/json
```

**请求体**：

```json
{
  "CustomerRef": {
    "value": "123"
  },
  "Line": [
    {
      "DetailType": "SalesItemLineDetail",
      "Amount": 1250.00,
      "Description": "Room: Living Room\nDimensions: 15.0×12.0×9.0 ft\nProject Type: Type B\n...",
      "SalesItemLineDetail": {
        "ItemRef": {
          "value": "1",
          "name": "WALL PAINTING"
        },
        "Qty": 1,
        "UnitPrice": 1250.00
      }
    }
  ]
}
```

**对应模型**：`External SystemClient.swift:74-114`

```swift
struct External SystemEstimate: Codable {
    let id: String?
    let syncToken: String?
    let customerRef: ItemRef?
    let line: [Line]?
    let totalAmt: Decimal?
}

struct Line: Codable {
    let detailType: String              // "DetailType" = "SalesItemLineDetail"
    let amount: Decimal?                // "Amount"
    let description: String?            // "Description"
    let salesItemLineDetail: SalesItemLineDetail?
}

struct SalesItemLineDetail: Codable {
    let itemRef: ItemRef                // "ItemRef"
    let qty: Decimal                    // "Qty"
    let unitPrice: Decimal              // "UnitPrice"
}
```

#### 2.2.6 查询 CustomerTypes

```
GET /company/{realmId}/query?query=SELECT * FROM CustomerType
```

**响应**：

```json
{
  "QueryResponse": {
    "CustomerType": [
      {
        "Id": "1",
        "Name": "Residential",
        "Active": true
      },
      {
        "Id": "2",
        "Name": "Type A",
        "Active": true
      }
    ]
  }
}
```

**对应模型**：`External SystemClient.swift:126-136`

```swift
struct External SystemCustomerType: Codable {
    let id: String?       // "Id"
    let name: String?     // "Name"
    let active: Bool?     // "Active"
}
```

#### 2.2.7 查询 Items

```
GET /company/{realmId}/query?query=SELECT * FROM Item WHERE Name='WALL PAINTING'
```

**响应**：

```json
{
  "QueryResponse": {
    "Item": [
      {
        "Id": "1",
        "Name": "WALL PAINTING",
        "Active": true,
        "Type": "Service"
      }
    ]
  }
}
```

**对应模型**：`External SystemClient.swift:138-150`

```swift
struct External SystemItem: Codable {
    let id: String?       // "Id"
    let name: String?     // "Name"
    let active: Bool?     // "Active"
    let type: String?     // "Type"
}
```

---

### 2.3 错误响应

**External Accounting System API 错误格式**：

```json
{
  "Fault": {
    "Error": [
      {
        "Message": "Duplicate Name Exists Error",
        "Detail": "The name supplied already exists. : Duplicate DisplayName",
        "code": "6240"
      }
    ],
    "type": "ValidationFault"
  },
  "time": "2026-01-12T10:30:00Z"
}
```

**常见错误码**：

| 错误码 | 说明 | 处理方式 |
|--------|------|---------|
| 401 | Unauthorized（Token 无效） | 刷新 Token 或重新登录 |
| 403 | Forbidden（权限不足） | 检查 OAuth Scope |
| 6240 | Duplicate Name Exists | 使用更新而非创建 |
| 500 | Internal Server Error | 重试 |

---

## 3. 本地存储契约

### 3.1 CoreData 存储

**位置**：`PersistenceController.shared.container`

**存储路径**：应用沙盒 `Application Support/` 目录

**数据库文件**：`PaintEstimator.sqlite`

**证据来源**：`PersistenceController.swift`

---

### 3.2 Keychain 存储

**用途**：存储加密密钥与敏感信息

**证据来源**：`Services/Crypto/KeychainStore.swift`

**推断存储项**：

| Key | 值类型 | 用途 |
|-----|--------|------|
| `encryption_key` | Data | 用于加密 OAuth Token 的密钥 |

**访问方式**：通过 `KeychainStore` 类访问

---

### 3.3 UserDefaults 存储

**推断**：项目未使用 UserDefaults，所有设置存储在 CoreData Settings 表。

---

### 3.4 文件系统存储

**CSV 导入**：
- 路径：用户选择（通过 FileImporter）
- 格式：Tab-separated 或 Comma-separated
- 字段：Brand, Series, Finish, SKU, Coverage Sf, Price per Gallon, Wall or Ceiling, Paint Type

**证据来源**：`SettingsView.swift:579-592`, `PaintDataImporter.swift`

---

## 4. 页面数据需求映射

### 4.1 CustomerListView（客户列表页）

**数据需求**：

| 字段 | 来源 | 用途 | 证据来源 |
|------|------|------|----------|
| `Customer.id` | CoreData | 导航标识 | `CustomerListView.swift:33` |
| `Customer.firstName` | CoreData | 显示客户名 | `CustomerRowView.swift:176` |
| `Customer.lastName` | CoreData | 显示客户名 | `CustomerRowView.swift:176` |
| `Customer.mobile` | CoreData | 显示联系方式 | `CustomerRowView.swift:182-193` |
| `Customer.email` | CoreData | 显示联系方式 | `CustomerRowView.swift:195-206` |
| `SyncJob[]` | CoreData | 显示最近任务（右侧面板） | `RecentJobsView.swift:106-113` |

**加载方式**：
- ViewModel 初始化时加载：`CustomerListViewModel.loadCustomers()`
- 返回根视图时刷新：`navigationPath.count == 0`

**证据来源**：`CustomerListView.swift:131-141`

---

### 4.2 CustomerDetailView（客户详情页）

#### 4.2.1 Tab 0: CustomerInfoTabView

**数据需求**：

| 字段 | 来源 | 用途 | 证据来源 |
|------|------|------|----------|
| `Customer.firstName` | CoreData | 编辑名字 | 推断 |
| `Customer.lastName` | CoreData | 编辑姓氏 | 推断 |
| `Customer.email` | CoreData | 编辑邮箱 | 推断 |
| `Customer.mobile` | CoreData | 编辑手机 | 推断 |
| `Customer.address` | CoreData | 编辑地址 | 推断 |
| `Customer.city` | CoreData | 编辑城市 | 推断 |
| `Customer.province` | CoreData | 编辑省份 | 推断 |
| `Customer.postal` | CoreData | 编辑邮编 | 推断 |
| `Customer.country` | CoreData | 编辑国家 | 推断 |

#### 4.2.2 Tab 1: RoomsTabView

**数据需求**：

| 字段 | 来源 | 用途 | 证据来源 |
|------|------|------|----------|
| `Room[]` | CoreData | 显示房间列表 | 推断 |
| `Room.name` | CoreData | 显示房间名 | 推断 |
| `Room.subtotal` | 计算（RoomCalculator） | 显示房间价格 | `RoomCalculator.swift:53-143` |

#### 4.2.3 Tab 2: EstimateTabView

**数据需求**：

| 字段 | 来源 | 用途 | 证据来源 |
|------|------|------|----------|
| `Customer.email` | CoreData | 验证邮箱有效性 | `EstimateTabView.swift:68-74` |
| `Room[]` | CoreData | 验证是否有有效房间 | `EstimateTabView.swift:76-82` |
| `Settings.accessTokenEnc` | CoreData | 验证是否已登录 | `EstimateTabView.swift:60-66` |
| `Customer.*` | CoreData | 生成 External System 描述 | `EstimateTabView.swift:43` |
| `Room.*` | CoreData | 生成 External System 描述 | `EstimateTabView.swift:43` |

---

### 4.3 RoomEditorView（房间编辑器）

**数据需求**：

| 字段 | 来源 | 用途 | 证据来源 |
|------|------|------|----------|
| `Room.name` | CoreData | 输入/编辑房间名 | `RoomEditorView.swift:17` |
| `Room.lengthFt` | CoreData | 输入长度 | `RoomEditorView.swift:18` |
| `Room.widthFt` | CoreData | 输入宽度 | `RoomEditorView.swift:19` |
| `Room.heightFt` | CoreData | 输入高度 | `RoomEditorView.swift:20` |
| `Room.primerCoats` | CoreData | 选择底漆涂层数 | `RoomEditorView.swift:21` |
| `Room.finishCoats` | CoreData | 选择面漆涂层数 | `RoomEditorView.swift:22` |
| `Room.selectedPrimerPaintId` | CoreData | 选择底漆 | `RoomEditorView.swift:32-34` |
| `Room.selectedFinishPaintId` | CoreData | 选择面漆 | `RoomEditorView.swift:36-38` |
| `Room.selectedCeilingFinishPaintId` | CoreData | 选择天花板油漆 | `RoomEditorView.swift:40-42` |
| `Room.projectType` | CoreData | 选择项目类型 | `RoomEditorView.swift:29` |
| `Room.paintCeiling` | CoreData | 是否粉刷天花板 | `RoomEditorView.swift:44` |
| `Room.specialLabour` | CoreData | 是否特殊人工 | `RoomEditorView.swift:45` |
| `Room.specialLabourHour` | CoreData | 特殊人工小时数 | `RoomEditorView.swift:46` |
| `Room.discount` | CoreData | 是否折扣 | `RoomEditorView.swift:47` |
| `Room.discountPercent` | CoreData | 折扣百分比 | `RoomEditorView.swift:48` |
| `PaintItem[]` | CoreData | 油漆选择列表 | `RoomEditorView.swift:50` |
| `Settings.commercialCadPerSf` | CoreData | Type A 人工单价 | `RoomEditorView.swift:220-234` |
| `Settings.standardCadPerSf` | CoreData | Type B 人工单价 | `RoomEditorView.swift:220-234` |
| `Settings.specialCadPerSf` | CoreData | Type C 人工单价 | `RoomEditorView.swift:220-234` |
| **计算字段** | - | - | - |
| `wallArea` | RoomCalculator | 墙面面积 | `RoomEditorView.swift:153-180` |
| `roomSubtotal` | RoomCalculator + Formatting | 房间小计 | `RoomEditorView.swift:236-298` |

---

### 4.4 SettingsView（设置页）

**数据需求**：

| 字段 | 来源 | 用途 | 证据来源 |
|------|------|------|----------|
| `Settings.environment` | CoreData | 显示/编辑环境 | `SettingsView.swift:144-147` |
| `Settings.clientId` | CoreData | 显示/编辑 Client ID | `SettingsView.swift:156` |
| `Settings.clientSecretEnc` | CoreData | 显示/编辑 Client Secret | `SettingsView.swift:157` |
| `Settings.redirectUri` | CoreData | 显示/编辑 Redirect URI | `SettingsView.swift:158` |
| `Settings.qboItemRefIdOrName` | CoreData | 显示/编辑 External System Item Ref | `SettingsView.swift:349` |
| `Settings.paintSourceMode` | CoreData | 显示/编辑油漆数据模式 | `SettingsView.swift:371-375` |
| `Settings.accessTokenEnc` | CoreData | 验证登录状态 | `SettingsView.swift:78` |
| `Settings.realmId` | CoreData | 显示公司 ID | `SettingsView.swift:110-118` |
| `Settings.commercialCadPerSf` | CoreData | 显示/编辑 Type A 单价 | `SettingsView.swift:449-455` |
| `Settings.standardCadPerSf` | CoreData | 显示/编辑 Type B 单价 | `SettingsView.swift:459-465` |
| `Settings.specialCadPerSf` | CoreData | 显示/编辑 Type C 单价 | `SettingsView.swift:469-475` |
| `Settings.qboCustomerTypesJson` | CoreData | 显示 CustomerTypes | `SettingsView.swift:239-255` |
| `PaintItem[]` | CoreData | 显示油漆列表 | `SettingsView.swift:527-562` |
| **远程数据** | - | - | - |
| `CompanyInfo.companyName` | External Accounting System API | 显示公司名 | `SettingsView.swift:101-108` |
| `External SystemCustomerType[]` | External Accounting System API | 显示 CustomerTypes 表格 | `SettingsView.swift:209-258` |
| `External SystemItem[]` | External Accounting System API | 显示 Items 表格 | `SettingsView.swift:265-315` |

---

## 5. 样例数据

### 5.1 Customer 样例数据

#### 样例 1：正常客户

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "mobile": "(555) 123-4567",
  "address": "123 Main St",
  "city": "San Francisco",
  "province": "CA",
  "postal": "94105",
  "country": "USA",
  "customerType": "Residential",
  "qboCustomerId": "123",
  "lastSyncedAt": "2026-01-12T10:30:00Z"
}
```

#### 样例 2：空客户（新建）

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "firstName": null,
  "lastName": null,
  "email": null,
  "mobile": null,
  "address": null,
  "city": null,
  "province": null,
  "postal": null,
  "country": null,
  "customerType": null,
  "qboCustomerId": null,
  "lastSyncedAt": null
}
```

#### 样例 3：已同步客户

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "jane.smith@example.com",
  "mobile": "(555) 987-6543",
  "address": "456 Oak Ave",
  "city": "Los Angeles",
  "province": "CA",
  "postal": "90001",
  "country": "USA",
  "customerType": "Type A",
  "qboCustomerId": "456",
  "lastSyncedAt": "2026-01-11T14:20:00Z"
}
```

---

### 5.2 Room 样例数据

#### 样例 1：标准房间

```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "name": "Living Room",
  "lengthFt": 15.0,
  "widthFt": 12.0,
  "heightFt": 9.0,
  "primerCoats": 1,
  "finishCoats": 2,
  "unitPricePerFt2": null,
  "selectedPaintId": null,
  "selectedPrimerPaintId": "770e8400-e29b-41d4-a716-446655440001",
  "selectedFinishPaintId": "770e8400-e29b-41d4-a716-446655440002",
  "selectedCeilingFinishPaintId": null,
  "projectType": "Type B",
  "paintCeiling": false,
  "specialLabour": false,
  "specialLabourHour": null,
  "discount": false,
  "discountPercent": null
}
```

**计算结果**：
- 墙面面积：`(1+2)*2*(15*9+12*9) = 1458 ft²`
- 人工费：`1458 * 0.50 = $729` (**示例数据**)
- 油漆成本：假设底漆覆盖率 350 ft²/gal，价格 $45/gal，面漆覆盖率 400 ft²/gal，价格 $55/gal
  - 底漆：`(1*486)/350*45 = $62.49`
  - 面漆：`(2*486)/400*55 = $133.65`
- 总价：`$62.49 + $133.65 + $845.64 = $1041.78`

#### 样例 2：带天花板的房间

```json
{
  "id": "660e8400-e29b-41d4-a716-446655440002",
  "name": "Master Bedroom",
  "lengthFt": 18.0,
  "widthFt": 14.0,
  "heightFt": 9.0,
  "primerCoats": 1,
  "finishCoats": 2,
  "unitPricePerFt2": null,
  "selectedPaintId": null,
  "selectedPrimerPaintId": "770e8400-e29b-41d4-a716-446655440001",
  "selectedFinishPaintId": "770e8400-e29b-41d4-a716-446655440002",
  "selectedCeilingFinishPaintId": "770e8400-e29b-41d4-a716-446655440003",
  "projectType": "Type C",
  "paintCeiling": true,
  "specialLabour": true,
  "specialLabourHour": 3.0,
  "discount": true,
  "discountPercent": 10.0
}
```

**计算结果**：
- 墙面面积：`(1+2)*2*(18*9+14*9) + (1+2)*18*14 = 2484 ft²`
- 人工费（墙面）：`(1+2)*2*(18*9+14*9) * 0.60 = $1036.80` (**示例数据**)
- 人工费（天花板）：`(1+2)*18*14 * 0.60 = $453.60` (**示例数据**)
- 特殊人工：`65 * 3.0 = $195`
- 油漆成本（略）
- 小计：假设 $2500
- 折扣：`$2500 * 10% = $250`
- 总价：`$2500 - $250 = $2250`

#### 样例 3：空房间（新建）

```json
{
  "id": "660e8400-e29b-41d4-a716-446655440003",
  "name": null,
  "lengthFt": 0.0,
  "widthFt": 0.0,
  "heightFt": 0.0,
  "primerCoats": 0,
  "finishCoats": 0,
  "unitPricePerFt2": null,
  "selectedPaintId": null,
  "selectedPrimerPaintId": null,
  "selectedFinishPaintId": null,
  "selectedCeilingFinishPaintId": null,
  "projectType": null,
  "paintCeiling": false,
  "specialLabour": false,
  "specialLabourHour": null,
  "discount": false,
  "discountPercent": null
}
```

---

### 5.3 PaintItem 样例数据

#### 样例 1：底漆

```json
{
  "id": "770e8400-e29b-41d4-a716-446655440001",
  "brand": "Benjamin Moore",
  "series": "ben",
  "finish": "Primer",
  "sku": "N023-00",
  "pricePerFt2": null,
  "source": "CSV Import",
  "wallOrCeiling": "Wall",
  "paintType": "Primer",
  "coverageSf": 350.0,
  "pricePerGallon": 45.00,
  "lastUpdatedAt": "2026-01-10T08:00:00Z"
}
```

#### 样例 2：面漆

```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "brand": "Sherwin-Williams",
  "series": "Emerald",
  "finish": "Eggshell",
  "sku": "K38W01151",
  "pricePerFt2": null,
  "source": "Manual",
  "wallOrCeiling": "Wall",
  "paintType": "Finish",
  "coverageSf": 400.0,
  "pricePerGallon": 68.99,
  "lastUpdatedAt": "2026-01-11T12:30:00Z"
}
```

#### 样例 3：天花板专用漆

```json
{
  "id": "770e8400-e29b-41d4-a716-446655440003",
  "brand": "Benjamin Moore",
  "series": "Waterborne Ceiling Paint",
  "finish": "Flat",
  "sku": "508",
  "pricePerFt2": null,
  "source": "API",
  "wallOrCeiling": "Ceiling",
  "paintType": "Finish",
  "coverageSf": 400.0,
  "pricePerGallon": 42.99,
  "lastUpdatedAt": "2026-01-12T09:15:00Z"
}
```

---

### 5.4 Settings 样例数据

#### 样例 1：已配置并登录

```json
{
  "environment": "Production",
  "clientId": "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij",
  "clientSecretEnc": "<binary_encrypted_data>",
  "redirectUri": "http://localhost:8080/callback",
  "qboItemRefIdOrName": "1",
  "paintSourceMode": "Both",
  "accessTokenEnc": "<binary_encrypted_data>",
  "refreshTokenEnc": "<binary_encrypted_data>",
  "tokenExpiry": "2026-01-12T11:30:00Z",
  "realmId": "1234567890",
  "typeAUsdPerSf": 0.40,
  "typeBUsdPerSf": 0.50,
  "typeCUsdPerSf": 0.60,
  "qboCustomerTypesJson": "[{\"id\":\"1\",\"name\":\"Residential\",\"active\":true},{\"id\":\"2\",\"name\":\"Type A\",\"active\":true}]",
  "qboWallPaintingId": "1"
}
```

#### 样例 2：未登录

```json
{
  "environment": "Sandbox",
  "clientId": "",
  "clientSecretEnc": null,
  "redirectUri": "http://localhost:8080/callback",
  "qboItemRefIdOrName": "",
  "paintSourceMode": "Manual",
  "accessTokenEnc": null,
  "refreshTokenEnc": null,
  "tokenExpiry": null,
  "realmId": null,
  "typeAUsdPerSf": 0.40,
  "typeBUsdPerSf": 0.50,
  "typeCUsdPerSf": 0.60,
  "qboCustomerTypesJson": null,
  "qboWallPaintingId": null
}
```

---

### 5.5 SyncJob 样例数据

#### 样例 1：待处理任务

```json
{
  "id": "880e8400-e29b-41d4-a716-446655440001",
  "type": "UpsertCustomer",
  "customerId": "550e8400-e29b-41d4-a716-446655440001",
  "payloadSnapshot": "<binary_serialized_data>",
  "state": "Queued",
  "retries": 0,
  "lastError": null,
  "lastUpdatedAt": "2026-01-12T10:00:00Z",
  "nextRunAt": "2026-01-12T10:00:00Z",
  "createdAt": "2026-01-12T10:00:00Z",
  "environment": "Production"
}
```

#### 样例 2：成功任务

```json
{
  "id": "880e8400-e29b-41d4-a716-446655440002",
  "type": "CreateEstimate",
  "customerId": "550e8400-e29b-41d4-a716-446655440001",
  "payloadSnapshot": "<binary_serialized_data>",
  "state": "Success",
  "retries": 0,
  "lastError": null,
  "lastUpdatedAt": "2026-01-12T10:05:00Z",
  "nextRunAt": null,
  "createdAt": "2026-01-12T10:00:00Z",
  "environment": "Production"
}
```

#### 样例 3：失败任务（重试中）

```json
{
  "id": "880e8400-e29b-41d4-a716-446655440003",
  "type": "CreateEstimate",
  "customerId": "550e8400-e29b-41d4-a716-446655440002",
  "payloadSnapshot": "<binary_serialized_data>",
  "state": "Failed",
  "retries": 2,
  "lastError": "Network timeout: The request timed out.",
  "lastUpdatedAt": "2026-01-12T10:10:00Z",
  "nextRunAt": "2026-01-12T10:20:00Z",
  "createdAt": "2026-01-12T10:00:00Z",
  "environment": "Production"
}
```

---

## 6. 待确认项（Open Questions）

### 6.1 数据模型不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-D01 | `Customer.customerType` 是否关联 External Accounting System CustomerType？ | 字段存在但未在 UI 中使用 | 该字段的业务用途、如何填充 |
| OQ-D02 | `Room.unitPricePerFt2` 是否已弃用？ | 字段存在但未在计算中使用 | 是否应删除或保留以兼容旧数据 |
| OQ-D03 | `Room.selectedPaintId` 是否已被 selectedPrimerPaintId/selectedFinishPaintId 替代？ | 存在优先级逻辑 | 是否可删除遗留字段 |
| OQ-D04 | `SyncJob.payloadSnapshot` 的序列化格式是什么？ | Binary 类型 | JSON? Protocol Buffers? NSKeyedArchiver? |
| OQ-D05 | 为什么存在两个 CoreData 模型文件？ | PaintEstimator.xcdatamodeld 和 green_tech_v3.xcdatamodeld | 哪个是主模型、是否在迁移中 |

### 6.2 API 契约不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-D06 | External Accounting System API 的完整请求/响应是什么？ | External SystemClient.swift 未完整读取 | 完整的 API 文档链接、字段映射 |
| OQ-D07 | Token 刷新的触发时机和策略是什么？ | 推断在 tokenExpiry 前触发 | 提前多久刷新、失败处理 |
| OQ-D08 | 是否有批量同步 API？ | 当前看到单个客户/估算同步 | 是否支持批量操作、性能优化 |
| OQ-D09 | External Accounting System Estimate 的 Description 字段有字符限制吗？ | 未看到验证逻辑 | 最大字符数、格式要求 |

### 6.3 计算逻辑不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-D10 | 为什么存在两套价格计算方法？ | calculateRoomPrice 和 calculateRoomPriceWithSeparatePaints | 何时使用哪一个、是否应统一 |
| OQ-D11 | 特殊人工费固定为 50 USD/小时 (**示例数据**)，是否可配置？ | Formatting.swift:138 硬编码 | 是否需要存入 Settings |
| OQ-D12 | 折扣百分比是否有范围限制？ | 未看到验证逻辑 | 0-100% 限制、输入验证 |
| OQ-D13 | 油漆用量是否需要向上取整到加仑？ | 未明确看到 roundUp 逻辑 | 如何处理小数加仑 |

### 6.4 同步队列不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-D14 | 同步队列的最大重试次数是多少？ | SyncJob.retries 存在但未看到上限 | 最大重试次数、退避策略 |
| OQ-D15 | 任务失败后的重试间隔是什么？ | SyncJob.nextRunAt 存在 | 固定间隔？指数退避？ |
| OQ-D16 | 是否支持并发同步？ | 未完整读取 SyncQueue 实现 | 串行还是并发、并发数限制 |
| OQ-D17 | 网络恢复后如何自动重试？ | NetworkMonitor 存在 | 监听机制、触发逻辑 |

### 6.5 数据迁移不确定性

| ID | 问题 | 推断来源 | 需要确认的点 |
|----|------|---------|-------------|
| OQ-D18 | 是否需要 CoreData 迁移策略？ | 当前模型可能需要新增字段 | 轻量级迁移 vs 自定义迁移、版本号管理 |
| OQ-D19 | 历史数据的兼容性如何处理？ | 存在遗留字段（selectedPaintId, unitPricePerFt2） | 数据迁移脚本、向后兼容 |
| OQ-D20 | 是否有数据导出/备份功能？ | 只看到 CSV 导入，未看到导出 | 用户数据备份策略、iCloud 同步 |

---

## 附录：数据关系图

### A1. CoreData 实体关系图

```
┌────────────────────────────────────────────────────────────┐
│                        Customer                            │
├────────────────────────────────────────────────────────────┤
│ PK: id (UUID)                                              │
│ firstName, lastName, email, mobile                         │
│ address, city, province, postal, country                   │
│ customerType, qboCustomerId, lastSyncedAt                  │
└────────────────────┬───────────────────────────────────────┘
                     │ 1:N (Cascade Delete)
                     ↓
┌────────────────────────────────────────────────────────────┐
│                         Room                               │
├────────────────────────────────────────────────────────────┤
│ PK: id (UUID)                                              │
│ FK: customer (N:1 → Customer)                              │
│ name, lengthFt, widthFt, heightFt                          │
│ primerCoats, finishCoats                                   │
│ selectedPrimerPaintId, selectedFinishPaintId               │
│ selectedCeilingFinishPaintId                               │
│ projectType, paintCeiling                                  │
│ specialLabour, specialLabourHour                           │
│ discount, discountPercent                                  │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                       PaintItem                            │
├────────────────────────────────────────────────────────────┤
│ PK: id (UUID)                                              │
│ brand, series, finish, sku                                 │
│ wallOrCeiling, paintType                                   │
│ coverageSf, pricePerGallon                                 │
│ source, lastUpdatedAt                                      │
└────────────────────────────────────────────────────────────┘
         ↑ (Reference by UUID String)
         │
         └─ Room.selectedPrimerPaintId
         └─ Room.selectedFinishPaintId
         └─ Room.selectedCeilingFinishPaintId

┌────────────────────────────────────────────────────────────┐
│                       Settings                             │
├────────────────────────────────────────────────────────────┤
│ environment, clientId, clientSecretEnc, redirectUri        │
│ accessTokenEnc, refreshTokenEnc, tokenExpiry, realmId      │
│ commercialCadPerSf, standardCadPerSf, specialCadPerSf      │
│ qboItemRefIdOrName, qboWallPaintingId                      │
│ paintSourceMode, qboCustomerTypesJson                      │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                       SyncJob                              │
├────────────────────────────────────────────────────────────┤
│ PK: id (UUID)                                              │
│ type, customerId (UUID, not FK)                            │
│ payloadSnapshot (Binary)                                   │
│ state, retries, lastError                                  │
│ lastUpdatedAt, nextRunAt, createdAt                        │
│ environment                                                │
└────────────────────────────────────────────────────────────┘
         │ (Soft Reference by UUID)
         ↓
    Customer.id
```

---

**文档结束**
