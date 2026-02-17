# 敏感信息清理清单
## GreenQuote 项目开源准备

**生成日期**: 2026-02-16
**项目状态**: 清理前

---

## 1. 品牌名称和标识符清理

### 1.1 需要替换的品牌名称
| 当前名称 | 通用替换 | 出现位置 |
|---------|---------|---------|
| **GreenQuote** | QuoteManager / EstimateBuilder | 16 个文件（见下表） |
| **Paint Estimator** | Estimation Tool / Quote Application | PRD.md, DATA_CONTRACT.md |
| **Green Tech v3** | Generic Project / Sample Project | PRD.md, DATA_CONTRACT.md, settings.local.json |
| **com.greenquote.*** | com.example.quotemanager.* | GreenQuote-Info.plist, project.pbxproj |

### 1.2 需要更新的文件列表
```
✓ GreenQuoteTests/GreenQuoteTests.swift
✓ GreenQuoteUITests/GreenQuoteUITestsLaunchTests.swift
✓ GreenQuoteUITests/GreenQuoteUITests.swift
✓ GreenQuote.xcodeproj/project.pbxproj
✓ GreenQuote.xcodeproj/xcshareddata/xcschemes/GreenQuote.xcscheme
✓ GreenQuote.xcodeproj/xcuserdata/samguan.xcuserdatad/xcschemes/xcschememanagement.plist
✓ GreenQuoteTests/Mocks/MockRepositories.swift
✓ GreenQuoteTests/FormattingTests.swift
✓ GreenQuoteTests/ValidationTests.swift
✓ GreenQuoteTests/RoomCalculatorTests.swift
✓ GreenQuote-Info.plist
✓ docs/DATA_CONTRACT.md
✓ docs/ARCHITECTURE.md
✓ docs/PRD.md
✓ docs/UI_SPEC.md
✓ .claude/settings.local.json
```

### 1.3 Bundle Identifier 和后台任务标识符
| 类型 | 当前值 | 通用替换 |
|------|--------|---------|
| Bundle ID | com.greenquote.* | com.example.quotemanager |
| 后台刷新任务 | com.greenquote.sync.refresh | com.example.quotemanager.sync.refresh |
| 后台处理任务 | com.greenquote.sync.process | com.example.quotemanager.sync.process |

**文件位置**: `GreenQuote-Info.plist:7-8`, `project.pbxproj`

---

## 2. 开发者个人信息清理

### 2.1 开发者用户名和路径
| 敏感信息 | 替换方案 | 出现位置 |
|---------|---------|---------|
| **samguan** | developer / user | settings.local.json, xcschemes |
| **/Users/samguan/Desktop/** | <PROJECT_ROOT> | .claude/settings.local.json:4,11,12 |
| **/Users/samguan/Desktop/green tech app/green tech v3/** | <PROJECT_ROOT> | .claude/settings.local.json:11 |
| **/Users/samguan/Library/Developer/Xcode/DerivedData** | <DERIVED_DATA> | .claude/settings.local.json:13 |

### 2.2 需要清理的文件
```
✓ .claude/settings.local.json - 完全重写，移除所有本地路径
✓ xcuserdata/samguan.xcuserdatad/* - 考虑添加到 .gitignore 或删除
```

---

## 3. 业务敏感数据清理

### 3.1 真实价格数据
| 数据类型 | 当前值 | 替换方案 |
|---------|--------|---------|
| **人工单价（Commercial）** | 0.45 CAD/ft² | 示例：0.40 USD/ft² |
| **人工单价（Standard）** | 0.58 CAD/ft² | 示例：0.50 USD/ft² |
| **人工单价（Special）** | 0.68 CAD/ft² | 示例：0.60 USD/ft² |
| **特殊人工费** | 65 CAD/小时 | 示例：50 USD/小时 |
| **货币单位** | CAD | USD（通用示例） |

**文件位置**:
- `docs/PRD.md:274,276`（BR-08 业务规则）
- `docs/PRD.md:275`（BR-09 业务规则）
- `docs/DATA_CONTRACT.md:88-90`（Room 实体业务规则）

### 3.2 客户类型
| 当前名称 | 通用替换 | 说明 |
|---------|---------|------|
| Commercial | Type A / Premium | 示例客户类型 |
| Standard | Type B / Standard | 示例客户类型 |
| Special | Type C / Economy | 示例客户类型 |

**备注**: 可以保留这些名称作为示例，但需在文档中标注"示例数据"

---

## 4. 外部集成信息清理

### 4.1 QuickBooks 集成
| 敏感信息 | 通用替换 | 出现位置 |
|---------|---------|---------|
| **QuickBooks Online (QBO)** | External ERP System / Accounting System | 所有文档 |
| **QuickBooks API 端点** | <ERP_API_ENDPOINT> | 代码注释（如有） |
| **OAuth 配置示例** | 通用 OAuth 示例 | PRD.md, ARCHITECTURE.md |

**替换策略**:
- 将所有 "QuickBooks" 引用改为 "External Accounting System" 或 "ERP Integration"
- 保留 OAuth 2.0 PKCE 流程的技术描述，但移除具体 API 端点
- 在文档中添加说明："本项目演示了与外部会计系统的集成。实际使用时可适配任何支持 OAuth 2.0 的 API。"

### 4.2 需要通用化的文件
```
✓ docs/PRD.md - 所有 "QuickBooks" 引用
✓ docs/DATA_CONTRACT.md - QBO API 契约部分
✓ docs/ARCHITECTURE.md - QBO 集成描述
✓ docs/UI_SPEC.md - QBO 相关 UI 说明
✓ 源代码文件名：QBOClient.swift → ERPClient.swift（如需重命名）
✓ 源代码类名：QBOAuthService → ERPAuthService（如需重命名）
```

---

## 5. 配置文件清理

### 5.1 GreenQuote-Info.plist
| 配置项 | 当前值 | 处理方案 |
|--------|--------|---------|
| 自定义字体 | Fashion Fetish Heavy.ttf | 删除或替换为系统字体/开源字体 |
| 后台任务标识符 | com.greenquote.* | 改为 com.example.quotemanager.* |

**操作**:
```xml
<!-- 删除或替换此部分 -->
<key>UIAppFonts</key>
<array>
    <string>Fashion Fetish Heavy.ttf</string>
</array>
```

**备注**: 如果该字体有版权问题，需要：
1. 删除字体文件（如果存在于项目中）
2. 从 Info.plist 中移除引用
3. 更新 UI_SPEC.md 中的字体说明，改为 SF Pro 或其他系统字体

### 5.2 .claude/settings.local.json
**处理方案**: 完全重写或删除，替换为示例文件

**新内容**:
```json
{
  "permissions": {
    "allow": [
      "Read(**/*.swift)",
      "Bash(xcodebuild:*)"
    ],
    "additionalDirectories": [
      "<PROJECT_ROOT>"
    ]
  }
}
```

---

## 6. 文档清理详细计划

### 6.1 PRD.md 清理项
| 位置 | 内容 | 操作 |
|------|------|------|
| 第 6 行 | "Paint Estimator（油漆估算器 - Green Tech v3）" | 改为 "Quote Estimation Tool (Sample Project)" |
| 第 7 行 | 证据来源路径 | 删除具体路径引用 |
| 第 28 行 | QuickBooks Online 描述 | 改为 "External Accounting System" |
| 第 274-276 行 | BR-08 业务规则（价格） | 标注"示例数据"或使用占位符 |
| 第 275 行 | BR-09 特殊人工费 | 标注"示例数据" |
| 全文 | QuickBooks | 全局替换为 "External Accounting System" |

### 6.2 DATA_CONTRACT.md 清理项
| 位置 | 内容 | 操作 |
|------|------|------|
| 第 6 行 | "Paint Estimator（Green Tech v3）" | 改为 "Quote Estimation Tool" |
| 第 88-90 行 | 人工单价数据 | 标注"示例数据" |
| QBO API 契约部分 | QuickBooks API 详情 | 通用化为 "External API Integration" |

### 6.3 ARCHITECTURE.md 清理项
- 通用化 QuickBooks 集成描述
- 保留 OAuth 2.0 PKCE 技术实现细节
- 移除任何具体 API 端点或公司特定配置

### 6.4 UI_SPEC.md 清理项
- 检查是否有品牌颜色/logo 引用
- 更新自定义字体说明
- 移除任何公司特定的 UI 元素描述

---

## 7. Git 历史清理（如适用）

### 7.1 检查项
```bash
# 检查是否是 git 仓库
[ -d .git ] && echo "是 Git 仓库" || echo "不是 Git 仓库"

# 搜索历史中的敏感信息
git log --all --full-history --source --oneline | grep -i "password\|secret\|key\|token"

# 检查是否有 .env 文件提交
git log --all --full-history -- "*.env" "*.env.*"

# 检查是否有大文件
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  awk '/^blob/ {print substr($0,6)}' | sort -n -k 2 | tail -20
```

### 7.2 清理方案（如需要）
**选项 A**: 如果历史中有敏感信息，使用 BFG Repo-Cleaner 或 git-filter-repo
**选项 B**: 创建全新仓库（推荐用于开源发布）

```bash
# 选项 B：创建干净的新仓库
cd ..
git init GreenQuote-Clean
cd GreenQuote-Clean
# 复制已清理的文件
# 创建首次提交
```

---

## 8. 新增文件清单

### 8.1 必须创建的文件
```
□ README.md - 项目介绍、快速开始
□ LICENSE - 开源许可证（MIT/Apache 2.0/其他）
□ .gitignore - 完整的 Xcode .gitignore
□ CONTRIBUTING.md - 贡献指南（可选）
□ SECURITY.md - 安全政策（可选）
□ CODE_OF_CONDUCT.md - 行为准则（可选）
```

### 8.2 .gitignore 必须包含的内容
```gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
xcuserdata/
*.xcuserdatad
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# CocoaPods / SPM
Pods/
.build/

# Secrets & Config
.env
.env.*
!.env.example
*.pem
*.p12
*.key
*.mobileprovision
.claude/settings.local.json

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Custom fonts (if proprietary)
*.ttf
*.otf
!SystemFonts/
```

---

## 9. 验证清单

### 9.1 自动化检查
```bash
# 在项目根目录运行以下命令

# 1. 搜索残留的敏感品牌名称
echo "=== 检查 GreenQuote 引用 ==="
grep -r "GreenQuote" --exclude-dir=".git" --exclude="CLEANUP_CHECKLIST.md" .

echo "=== 检查开发者名称 ==="
grep -r "samguan" --exclude-dir=".git" --exclude="CLEANUP_CHECKLIST.md" .

echo "=== 检查 QuickBooks 引用 ==="
grep -r "QuickBooks\|QBO" --exclude-dir=".git" --exclude="CLEANUP_CHECKLIST.md" --include="*.md" docs/

echo "=== 检查价格数据 ==="
grep -r "0\.45\|0\.58\|0\.68\|65.*CAD" --exclude-dir=".git" docs/

echo "=== 检查本地路径 ==="
grep -r "/Users/samguan" --exclude-dir=".git" .
```

### 9.2 手动验证清单
```
□ 所有文档中不再包含 "GreenQuote" （除示例）
□ 所有文档中不再包含真实价格数据（或已标注"示例"）
□ 所有文件路径不再包含 "/Users/samguan"
□ Bundle Identifier 已更新为通用名称
□ Info.plist 中无专有字体引用（或已替换）
□ README.md 已创建并包含正确信息
□ LICENSE 文件已添加
□ .gitignore 已创建并完整
□ 构建系统正常（Xcode 可编译）
□ 测试可运行（至少不崩溃）
```

---

## 10. 发布前最终检查

### 10.1 法律和合规
```
□ 确认所有代码由自己编写或有使用权
□ 确认依赖项的许可证兼容性
□ 确认没有包含公司专有代码
□ 确认没有包含客户数据或示例数据来自真实客户
□ 确认自定义字体已移除或替换为开源/系统字体
```

### 10.2 技术检查
```
□ 项目在干净环境下可构建
□ 单元测试可运行
□ UI 测试可运行（或已标注需要配置）
□ 文档中的代码示例与实际代码一致
□ 所有外部链接有效
□ README 中的快速开始指南可用
```

### 10.3 文档完整性
```
□ README.md 包含项目目的、功能、安装、使用说明
□ ARCHITECTURE.md 技术准确
□ PRD.md 和 DATA_CONTRACT.md 反映通用化后的项目
□ UI_SPEC.md 不包含专有设计元素引用
□ 存在贡献指南（CONTRIBUTING.md）
□ 存在许可证文件（LICENSE）
```

---

## 11. 推荐替换名称

### 11.1 项目名称建议
**选项 1**: `QuoteEstimator`
- Bundle ID: `com.example.quoteestimator`
- Display Name: "Quote Estimator"

**选项 2**: `EstimateBuilder`
- Bundle ID: `com.example.estimatebuilder`
- Display Name: "Estimate Builder"

**选项 3**: `GenericQuoteApp`（明确示例性质）
- Bundle ID: `com.example.genericquoteapp`
- Display Name: "Generic Quote App"

### 11.2 推荐选用
**建议**: 使用 `QuoteEstimator`
- 优点：简洁、描述性强、不与现有产品冲突
- 易于搜索和引用
- 适合用作示例/模板项目

---

## 12. 执行时间表

### Phase 1: 准备（30分钟）
1. 创建项目备份
2. 确认清理清单
3. 准备替换脚本

### Phase 2: 批量替换（1小时）
1. 品牌名称全局替换
2. 开发者信息清理
3. 配置文件更新

### Phase 3: 文档更新（1.5小时）
1. PRD.md 清理和通用化
2. DATA_CONTRACT.md 清理
3. ARCHITECTURE.md 清理
4. UI_SPEC.md 清理

### Phase 4: 新文件创建（1小时）
1. README.md 编写
2. LICENSE 选择和添加
3. .gitignore 创建
4. 其他可选文件

### Phase 5: 验证和测试（1小时）
1. 运行自动化检查脚本
2. 手动验证清单
3. 构建和测试
4. 最终审查

**总预计时间**: 5 小时

---

## 13. 完成标志

清理完成后，你的项目应该：

✓ 可以安全地公开发布到 GitHub
✓ 不包含任何公司专有信息
✓ 不包含任何个人身份信息
✓ 不包含真实客户数据或定价
✓ 具有清晰的通用化命名
✓ 包含完整的开源文档
✓ 可以作为学习/模板项目使用
✓ 符合所选开源许可证的要求

---

**清理负责人**: _________________
**审核人**: _________________
**完成日期**: _________________

**备注**: 保留此文档作为清理过程的记录，但在最终发布时可以选择不包含在公开仓库中。
