---
title: "Bycrypt Rounds"
date: 2025-12-03T09:07:31+08:00
draft: true
description: "a description"
tags: ["技術"]
---

最近在寫專案的時候，偶然發現 PHP Unit 有一個有趣的設定：

```xml {linenos=inline hl_lines=[4] style=github-dark}
<php>
    <ini name="memory_limit" value="512M"/>
    <env name="APP_ENV" value="testing"/>
    <env name="BCRYPT_ROUNDS" value="4"/>
    <env name="CACHE_DRIVER" value="array"/>
    <env name="MAIL_DRIVER" value="array"/>
    <env name="PULSE_ENABLED" value="false"/>
    <env name="QUEUE_CONNECTION" value="sync"/>
    <env name="SESSION_DRIVER" value="array"/>
    <env name="TELESCOPE_ENABLED" value="false"/>
</php>
```

為什麼會需要特別限制 Bcrypt 次數呢？