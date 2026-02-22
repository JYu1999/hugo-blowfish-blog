---
title: "MCP 初体験"
date: 2025-12-20T9:00:00+08:00
draft: false
tags: ["技術", "AI"]
---

{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}

最近、ちょうど履歴書を整理したいというニーズがありました。

ただ困ったことに、入社前の二年間、仕事の記録をあまり真剣につけていませんでした。

だから誰かに「以前の会社でどんな問題を解決しましたか？」と聞かれると、

「えっと...」としか言えません。

前からMCPを試してみたかったのですが、ずっとニーズがなかったので、MCPがこの効果を実現できるか試してみることにしました。

構想はシンプルです：ローカルMCPクライアントを通じて、JiraとGitlabのMCPサーバーにアクセスし、AIに以前の会社で解決した問題を分析してもらい、履歴書にまとめてもらう。

---

## Jira

### Antigravity

まずAntigravityを試しました。特別な理由はなく、最近よく使っているからです。

AntigravityでJiraを接続するのはとても簡単で、Agentの画面でMCP Serversを選択し、Atlassianを選んでOAuth認証を行うだけです。

### Cursor

次にCursorを試しました。前のAntigravityの経験があったので、Antigravityの設定をコピーするだけでした。

MCPストアで**Manage MCP Servers**を見つけ、**View Raw Config**をクリックすると、`mcp_config.json`が見つかります。

Cursorの設定に入り、New MCP Serverを見つけて設定を入力します：
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

GitlabはまだMCPをテスト中のようで、設定がより複雑です。まずサードパーティの`@zereight/mcp-gitlab`を使用する必要があります。

具体的なインストール手順は：[zereight/gitlab-mcp](https://github.com/zereight/gitlab-mcp/blob/main/docs/oauth-setup.md) をご参照ください。

ただし、このMCPツールには少し多めのツールがあります。重要なプロジェクトの場合、誤操作を防ぐため、Create、Update、Deleteなどの危険な権限はすべてオフにすることをお勧めします。

AntigravityとCursorのインストール方法は同様なので省略します。

---

## テスト

テストなので、プロンプトは適当に書きました：

```
私は結語JYuです

xxx という会社でn年働いており、履歴書を準備しています。

Jira MCP、Gitlab MCPに基づいて、この期間に会社で行ったすべてのプロジェクトを整理・分析して、履歴書の準備ができるようにしてください。
```

まずCursorを試しましたが、コンテキストが足りなくなってしまいました（笑）

AntigravityのPlanning + Gemini 3 Flashに切り替えました。成果は以下の通りです：

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

## まとめ

読者の方々はどう思われましたか（笑）

私はあまり良くないと思いましたが、プロンプトをあまり真剣に書いていないので、しっかり調整すればかなり良くなる可能性があります。

以前MCPを試したくなかった理由は、コピー＆ペーストの時間を少し省くだけで、実質的な助けがあまりないと思っていたからです。

むしろ「従来」のChatGPT方式で関連情報をモデルに直接コピーすれば、モデルが不必要なファイルを見たり無意味な思考をしたりするのを避けられ、より効率的です。

ただ、履歴書のまとめのように「コンテキストが多く」、しかも「関連情報」がどのくらいあるか自分でも分からない状況は、MCPで処理するのに向いているようです。

全体的には興味深い小実験でしたが、短期的にはまだMCPをそこまで頻繁に使わないと思います。適切な使用シナリオをもう少し考えてみます。
