---
title: "公司終於導入 AI Agent！！我這禮拜做的一些調整"
date: 2026-03-10T00:50:40+08:00
draft: false
tags: ["人工智慧", "生產力工具"]
---

{{< alert "circle-info">}}
這篇文章是 AI 自己透過 MCP 去分析 Jira Ticket 和 Gitlab Merge Request 之後產生的。
{{< /alert >}}

最近公司終於開始正式導入 AI Agent 來寫程式碼。

有趣的是，推動這件事的是一位 PM，而不是工程師。雖然他對產品方向有清晰的判斷，但對工程開發的細節相對陌生。這讓我意識到：如果要讓 AI Agent 真的能在工程環境裡正常工作，**光是「把 AI 接上來」是不夠的**，你得把整個上下文環境也一起建好。    
                                                                                                        
這篇文章想分享我這週做了哪些調整，以及背後的思維。

---

## 問題的起點：AI 不懂我們的開發環境

一開始讓 AI 跑起來後，第一個踩到的坑非常直觀：

**AI 會直接執行 `php artisan migrate`，但本機根本沒有安裝 PHP。**

我們專案使用 Laravel Sail 管理 Docker 開發環境，所有指令都必須透過 `./vendor/bin/sail` 執行。這個規則對工程師來說再熟悉不過，但對 AI 來說它完全不知道。

解法其實很簡單：在 `CLAUDE.md` 加一條規則，**要求 AI 在開始任何開發工作前，先讀取開發環境建置文件**，了解這個專案使用 Laravel Sail 的事實。

```md
<!-- CLAUDE.md -->
開始任何開發工作前，請先讀取 `docs/doc/fruktte/開發相關/開發環境建置.md`，了解本專案使用 Laravel Sail 管理 Docker 開發環境。

所有 CLI 指令都必須透過 `./vendor/bin/sail` 執行，切勿直接在本機執行。

```

這讓我體會到一個重要觀念：CLAUDE.md 不只是規則清單，它是 AI 的「入職文件」。你得把任何一個新工程師第一天需要知道的事，都寫進去。

---

## 第一個大工程：把繁瑣的 Release 流程自動化

在這之前，我們的 release 流程長這樣：

1. 完成的任務 Merge 到 Stage
2. 自己手動開一個 Stage → Master 的 MR
3. 手動整理 commit log，寫 release notes
4. 手動把 release 資訊貼到 Slack #release 頻道

每次 release 光是整理 commit、寫說明、發 Slack，就要花不少時間。最煩的部分是 MR 標題有格式規定、Slack 訊息也有固定格式，每次都要手動對照，很容易出錯。

解法：寫一個 Release Skill

我決定把這個流程包成一個 Claude Code Skill，叫做 `fruktte-release-helper`。

整個流程設計如下：

1. 取得 stage 和 master 的 commit 差異
    ↓
2. 自動分析每個 commit 的類別（Feature / Fix / Change...）
    ↓
3. 展示分析結果，等使用者確認
    ↓
4. 在 GitLab 建立草稿 PR（Stage → Master）
    ↓
5. 產生 Slack 訊息草稿
    ↓
6. 等使用者確認，發送到 #release 頻道

有幾個設計決策值得說明：

- **永遠先展示，再執行。** 每個關鍵步驟前，AI 都會先把分析結果展示給你看，等你確認後才繼續。因為 commit 訊息很可能有歧義，AI 的分類未必 100% 準確，讓人類做最後確認是保險的做法。
- **草稿 PR，不是 Ready to Merge。** Release PR 一律建立為 Draft 狀態，避免有人不小心直接按下 merge。Reviewer assign 和最終 merge 還是由人來做。
- **偵測部署步驟要看 MR 說明，不要靠關鍵字猜。** 要知道這次 release 有沒有需要跑 migration 或 composer install，最可靠的方式是去看每個 FUR ticket 對應的 MR 描述，而不是靠掃 commit message 的關鍵字。AI 會主動去查每個 MR 的 description。

現在 release 流程變成：

跟 AI 說「我要 release」→ AI 自動完成所有整理和 PR 建立 → 確認 → Slack 訊息建立完成

工程師只需要在兩個確認點點頭，剩下的全部自動化。

---

## 第二個改善：把開 MR 也自動化

類似的問題也出現在日常的 MR 上。我們的 MR 標題有格式規定：

`FUR-{編號} {Jira Ticket 名稱}`

以前要開 MR，得：
1. 去 Jira 查 Ticket 的完整標題
2. 複製下來
3. 在 GitLab 貼上，組合成正確格式
4. 在 MR 上貼上 Jira Ticket 的連結

聽起來很小，但重複幾十次之後就很煩。

我把這個包成了 `fruktte-create-mr` skill。AI 會：
1. 從當前 git branch 名稱抓出 FUR 編號
2. 用 Jira MCP 自動查詢 Ticket 標題
3. 組合成正確格式，建立 MR
4. 在 MR 上附上 Jira Ticket 的連結

同時它也會根據分支格式判斷目標分支：
- feature/FUR-{編號} → merge 到 stage
- task/FUR-{子編號}/feature/FUR-{父編號} → merge 到對應的 feature/ 分支

現在開 MR 只要說一句「幫我開 MR」，剩下的 AI 全包。

---

## 第三個改善：把 MCP 從個人設定移到專案層級

在導入初期，MCP（Model Context Protocol，讓 AI 連接外部工具的協定）的設定是放在每個開發者的本機（user scope）。

這帶來了幾個問題：

1. 工具無法統一控管。例如我們的 GitLab MCP 有一個 merge 工具——我們不希望 AI 直接幫忙 merge，但在 user scope 下很難統一把它 disable 掉。
2. SubAgent 的權限無法隔離。如果之後有不同角色的 SubAgent，理論上每個角色應該只能用到它需要的工具。例如「後端工程師」SubAgent 應該有 Jira 讀取，但不應該有 Figma 編輯。
3. 與開發者個人設定混在一起。公司設定和個人設定容易互相干擾，很難維護。

解法是把 MCP 設定移到 project scope，也就是讓設定跟著 codebase 走：

```text
.mcp.json             ← 本機實際設定（gitignore，不 commit）
.mcp.json.example     ← 設定範本（commit 進去，供所有人參考）
.claude/settings.json ← Claude Code project scope 設定
```

用 example 檔案的模式，讓每個開發者知道需要哪些設定，但實際的 credentials 不進版本控制。這個做法跟 `.env.example` 的概念完全一樣，工程師應該很熟悉。

---

## 整體回顧：我從這個過程學到什麼

做完這些之後，我覺得導入 AI Agent 到工程流程的挑戰，不在於 AI 本身夠不夠強，而在於你有沒有把環境和規則建好。

幾個心得：

- **把重複的決策包成 Skill，而不是每次重新解釋。** MR 標題格式、release 流程步驟——這些規則每次都靠自然語言描述是很脆弱的。把它們包成 Skill，AI 每次都會走一樣的流程，結果穩定可預期。
- **CLAUDE.md 是 AI 的入職文件。** 要讓 AI 真的能在你的專案裡工作，就要把任何新工程師需要知道的事都寫進去：用什麼工具、怎麼執行指令、有哪些規範。
- **在 AI 執行關鍵操作前，一定要有確認點。** AI 分析結果不一定 100% 準確，讓人類在關鍵節點做確認，是保持品質的最後防線。全自動很誘人，但在還不夠信任的地方保留人工確認是對的。
- **MCP 要放 project scope，不要放 user scope。** 工具控管、權限隔離、避免設定混淆——這些都是工程上的基本衛生習慣，MCP 管理也不例外。

---

目前這些工具已經在團隊裡跑了一段時間，release 流程的效率明顯提升，也減少了很多「忘記 MR 標題格式」或「漏發 Slack 通知」的人為失誤。

AI 不是銀彈，但如果你願意花時間把它需要的上下文建好，它確實可以幫你省掉很多重複又耗神的工作。