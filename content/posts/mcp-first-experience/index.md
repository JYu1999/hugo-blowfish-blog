---
title: "MCP 初體驗"
date: 2025-12-20T9:00:00+08:00
draft: false
tags: ["技術", "AI"]
---

最近剛好有個需求，是想要整理一下履歷。

但尷尬的是，我進來這件公司的前兩年，沒有很認真紀錄我的工作。

所以如果有人問我說：「你之前在公司解過哪些議題？」

我只能說：「呃...」

剛好之前一直想試 MCP，但一直沒需求，所以來嘗試看看 MCP 能不能達到這個效果。

我的構想很簡單：透過本地 MCP Client，去存取 Jira 和 Gitlab 的 MCP Server，然後再請 AI 幫我分析我之前在公司解過哪些議題，並整理成履歷。

---

## Jira

### Antigravity

首先嘗試的是 Antigravity，沒有特別的原因，單純是因為最近很常用。

Antigravity 連結 Jira 很簡單，只需要在 Agent 畫面，選擇 MCP Servers，並選擇 Atlassian，然後進行 OAuth 驗證即可。

### Cursor

再來嘗試 Cursor，有了前面 Antigraviry 的經驗，直接去複製 Antigravity 的設定即可。

可以在 MCP Store 找到 **Manage MCP Servers**，然後按 **View Raw Config**，就可以找到 `mcp_config.json`。

進到 Cursor 設定，找到 New MCP Server，並填入設定即可：
```json
{
  "mcpServers": {
    "atlassian-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.atlassian.com/v1/sse"
      ],
      "env": {}
    }
}
```

---

## Gitlab

Gitlab 官方似乎還在測試 MCP，所以設定比較複雜，需要先使用民間的 `@zereight/mcp-gitlab`。

具體安裝流程請參考：[zereight/gitlab-mcp](https://github.com/zereight/gitlab-mcp/blob/main/docs/oauth-setup.md)

不過這邊要特別提醒，這個 MCP Tools 有點多，如果是比較重要的專案，建議把 Create、Update、Delete 等危險權限都關掉，以免誤觸。

Antigraviry 和 Cursor 安裝方式雷同，不贅述

---

## 測試

因為是測試，所以我亂寫了提示詞：

```
我是結語JYu

我在 xxx 這間公司工作滿 n 年了，正在準備履歷。

需要你根據 Jira MCP、Gitlab MCP，幫我整理並分析過去這段時間，我在公司裡面做過的所有專案。讓我可以準備履歷。
```

先嘗試用 Cursor，結果 context 直接不夠用 XD

改用 Antigravity，使用 Planning + Gemini 3 Flash，成果如下：

### 最終成果

#### Career Summary: JYu (Software Engineer @ xxx)

Analytical and impact-driven Software Engineer with n years of experience at xxx. Expertise in backend development (PHP/Laravel), DevOps automation, and technical security. Lead contributor to critical infrastructure and financial modules.

##### 🚀 Key Impact Areas

###### 1. DevOps & Infrastructure Optimization

- CI/CD Pipeline Acceleration: Directed initiatives to optimize CI/CD workflows, significantly reducing build and deployment times.
- Deployment Automation: Developed and integrated robust deployment scripts (deploy.sh, reload-app.sh) and automated database migration triggers to enhance system stability during releases.
- Server Lifecycle Management: Orchestrated server transitions and handled infrastructure updates (SRE tasks) before transitioning to backend lead roles.
###### 2. Financial & Payment Systems
- Complex Withdrawal Logic: Designed and implemented the "Creator Withdrawal System," including automated withdrawal processing and tax-compliant exports (Withholding Tax/扣繳匯出單).
- Payment Stability: Monitored and fixed critical payment/refund failures, ensuring high reliability for financial transactions.
- Architecture Refactoring: Decoupled business logic from report export modules, centralizing domain logic in Services to improve maintainability and scalability.
###### 3. Security & Compliance
- CVE Mitigation: Identified and patched security vulnerabilities, including CVE-2025-14761 (Key Commitment Issue in AWS SDK for PHP), protecting S3-based encrypted assets.
- Invoice & Taxation: Built systems for order invoice processing and taxation module verification, ensuring financial compliance for the platform.
###### 4. Product & Feature Engineering
- Domain Modeling: Refined product taxonomy and tagging systems to support complex content discovery.
V3 Platform Transition: Contributed to the backend architecture for the next-generation creator application flow.
##### 🛠 Technical Stack
- Languages & Frameworks: PHP, Laravel, Bash.
- Integrations: AWS SDK (S3, Encryption), Payment Providers (Ecpay, etc.), Spout (Exporters).
- Tools: Jira, GitLab CI/CD, Confluence (Technical documentation/Whiteboarding).
##### 🏆 Notable Jira/GitLab Projects
- xxx project (Main Platform): Heavy focus on financial reliability and security.
- xxx Deploy Script: Standalone toolset for platform maintenance.
- CatalystV3: Next-generation platform development.

---

## 結語

不知道讀者覺得成果如何XD

我是覺得蠻鳥的，不過我也沒有很認真去下提示詞就是了，感覺認真調教一下應該是大有可為。

我之前一直沒有想要試 MCP 的原因是因為，我覺得它只是省下了一些 Copy & Paste 的時間，但沒有太多實質的幫助。

反而我用「傳統」ChatGPT 這種方式，直接把相關資訊複製給模型，避免模型去看太多不必要的檔案，或進行無意義的思考，這樣會比較有效率。

不過像整理履歷這種「上下文很多」，而且我自己都不知道「相關資訊」有多少的情境，好像就很適合用 MCP 來處理。

整體來說是個有趣的小實驗，不過短期內我應該還是不會很常用 MCP 就是了，可能會再想一下適合的使用情境。