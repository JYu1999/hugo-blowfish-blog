# 贊助按鈕配置說明

## 快速配置

在 `config/_default/params.toml` 中设置：

```toml
[buymeacoffee]
identifier = "jyu1999"          # 你的 BMC 用户名
globalWidget = false            # 關閉官方 widget

[portaly]
url = "https://portaly.cc/jyu1999/support"  # Portaly 赞助链接

[supportWidget]
enabled = true                  # 启用展开式按钮
position = "right"              # 位置: "right" 或 "left"
color = "#FF5F5F"               # 按钮颜色（可选）
```

## 多语言翻译

在 `i18n/` 目录下修改对应语言文件：

- `i18n/zh-tw.yaml` - 繁體中文
- `i18n/en.yaml` - English

## 特效说明

点击爱心按钮时会触发：
- 💓 **心跳动画**：按钮会有跳动效果
- 💫 **涟漪效果**：从点击位置扩散的涟漪
- ✨ **粒子爆炸**：彩色粒子向四周飞散
- ❤️ **爱心泡泡**：8个爱心表情从按钮周围像泡泡一样飘出来
- 🌊 **脉冲光环**：展开时按钮周围的脉冲效果

## 测试

```bash
hugo server -D
```

