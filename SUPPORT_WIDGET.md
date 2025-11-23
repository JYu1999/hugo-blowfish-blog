# 贊助按鈕配置說明

## 功能概述

此展開式贊助按鈕支援同時顯示多個贊助平台（Buy Me a Coffee 和 Portaly），並完全支援多語言。

## 配置方式

### 1. 主配置文件 (`config/_default/params.toml`)

```toml
[buymeacoffee]
identifier = "jyu1999"          # 你的 BMC 用戶名
globalWidget = false            # 關閉官方 widget（使用自定義按鈕）

[portaly]
url = "https://portaly.cc/jyu1999/support"  # 你的 Portaly 贊助連結

[supportWidget]
enabled = true                  # 啟用展開式贊助按鈕
position = "right"              # 按鈕位置: "right" 或 "left"
color = "#FF5F5F"               # 按鈕主色調（可選，預設為 #FF5F5F）
```

### 2. 多語言翻譯

#### 繁體中文 (`i18n/zh-tw.yaml`)
```yaml
support:
  button_aria_label: "贊助選項"
  bmc_title: "Buy Me a Coffee"
  bmc_currency: "💵 美金"
  portaly_title: "Portaly 贊助"
  portaly_currency: "💰 台幣"
```

#### 英文 (`i18n/en.yaml`)
```yaml
support:
  button_aria_label: "Support Options"
  bmc_title: "Buy Me a Coffee"
  bmc_currency: "💵 USD"
  portaly_title: "Support via Portaly"
  portaly_currency: "💰 TWD"
```

### 3. 自定義翻譯

你可以修改 `i18n/` 目錄下的語言文件來自定義顯示文字：

- `button_aria_label`: 主按鈕的無障礙標籤
- `bmc_title`: Buy Me a Coffee 的顯示名稱
- `bmc_currency`: BMC 的貨幣標示
- `portaly_title`: Portaly 的顯示名稱
- `portaly_currency`: Portaly 的貨幣標示

## 參數優化說明

### 移除的冗餘參數

以下參數已被移除，因為統一使用 `supportWidget` 配置：

- ~~`buymeacoffee.globalWidgetColor`~~
- ~~`buymeacoffee.globalWidgetPosition`~~
- ~~`portaly.buttonColor`~~
- ~~`portaly.buttonPosition`~~

### 統一管理

所有按鈕樣式和位置現在通過 `supportWidget` 統一管理，更易於維護。

## 使用情境

### 只顯示 BMC
```toml
[buymeacoffee]
identifier = "jyu1999"

[supportWidget]
enabled = true
```

### 只顯示 Portaly
```toml
[portaly]
url = "https://portaly.cc/jyu1999/support"

[supportWidget]
enabled = true
```

### 同時顯示兩者（當前配置）
```toml
[buymeacoffee]
identifier = "jyu1999"

[portaly]
url = "https://portaly.cc/jyu1999/support"

[supportWidget]
enabled = true
```

## 設計優勢

1. **好維護**: 參數精簡，職責清晰
2. **多語言**: 完整的 i18n 支援
3. **靈活性**: 可輕鬆添加或移除贊助平台
4. **一致性**: 統一的樣式管理

## 測試

運行以下命令測試：

```bash
hugo server -D
```

訪問 `http://localhost:1313` 查看效果。

