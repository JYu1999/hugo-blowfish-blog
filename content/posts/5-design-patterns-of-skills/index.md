---
title: "你真的有需要知道 Agent Skill design patterns 嗎？"
date: 2026-03-25T00:00:00+08:00
draft: false
tags: ["人工智慧", "技術"]
---

Google 在 X 上發布了這篇文章

{{< x user="GoogleCloudTech" id="2033953579824758855" >}}

文章內簡單統整了 5 個 Agent Skill Design Pattern，以下由 AI 整理：

## 5個 Agent Skill Design Pattern

### 模式一：Tool Wrapper（工具包裝器）
- **用途：** 讓 Agent 在需要時動態載入某個函式庫或框架的專業知識，而非寫死在系統提示中。
- **運作機制：** SKILL.md 監聽使用者 prompt 中的特定關鍵字，在觸發時才從 references/ 目錄載入內部文件，並將其視為絕對準則。這適合用來分發團隊內部的程式碼規範或框架最佳實踐。

> "Instead of hardcoding API conventions into your system prompt, you package them into a skill. Your agent only loads this context when it actually works with that technology."

- **實例：** FastAPI 專家技能——Agent 在審查或撰寫程式碼時才載入 conventions.md，逐條比對慣例並提出修正建議。
- **關鍵特性：** 這是最簡單的模式，核心價值在於「按需載入」，避免浪費 context window。

### 模式二：Generator（生成器）
- **用途：** 確保 Agent 每次產出的文件結構一致，解決「每次跑出來格式都不一樣」的問題。
- **運作機制：** 利用 assets/ 目錄放置輸出模板、references/ 放置風格指南。SKILL.md 的指令扮演專案經理角色：載入模板 → 讀取風格指南 → 向使用者詢問缺少的變數 → 填充文件。適合產生 API 文件、標準化 commit message 或搭建專案架構。

> "The instructions act as a project manager. They tell the agent to load the template, read the style guide, ask the user for missing variables, and populate the document."

- **實例：** 技術報告生成器——SKILL.md 本身不包含排版規則或語法標準，只負責協調資源取得並強制 Agent 逐步執行。
- **關鍵特性：** 模板與風格規則外部化，SKILL.md 只做「編排」。

### 模式三：Reviewer（審查器）
- **用途：** 將「檢查什麼」與「如何檢查」分離，實現模組化的自動化審查。
- **運作機制：** 審查標準存放在 references/review-checklist.md 中。Agent 載入 checklist 後，逐條對照使用者提交的程式碼，依嚴重程度（error / warning / info）分組輸出結果。只要替換 checklist（例如用 OWASP 安全清單取代 Python 風格清單），就能用同一套技能基礎設施進行完全不同的專業審計。

> "If you swap out a Python style checklist for an OWASP security checklist, you get a completely different, specialized audit using the exact same skill infrastructure."

- **實例：** Python 程式碼審查器——指令固定不變，Agent 動態載入外部 checklist，強制輸出包含摘要、分級發現、評分與前三大建議。
- **關鍵特性：** 高度可替換——更換 checklist 即可切換審查領域，適合自動化 PR review 或安全掃描。

### 模式四：Inversion（反轉）
- **用途：** 阻止 Agent 在資訊不足時就猜測並直接生成結果，改由 Agent 主導提問、蒐集完整需求後再行動。
- **運作機制：** 核心是設定明確且不可妥協的「閘門指令」（例如 "DO NOT start building until all phases are complete"），強迫 Agent 按順序逐一提問、等待回答，直到所有階段完成才進入產出階段。角色從「執行者」翻轉為「訪談者」。

> "Instead of the user driving the prompt and the agent executing, the agent acts as an interviewer."
>
> "The agent refuses to synthesize a final output until it has a complete picture of your requirements and deployment constraints."

- **實例：** 專案規劃器——分為三個階段（問題探索 → 技術限制 → 綜合產出），每階段都有嚴格的閘門控制，未完成前一階段不得進入下一階段。
- **關鍵特性：** 多輪對話互動，透過分階段提問降低需求遺漏風險。

### 模式五：Pipeline（管線）
- **用途：** 處理複雜任務時，強制執行嚴格的順序工作流程，並設置硬性檢查點，防止 Agent 跳步或呈現未驗證的結果。
- **運作機制：** SKILL.md 本身就是工作流程定義。透過「鑽石閘門條件」（diamond gate conditions）——例如要求使用者確認 docstring 後才能進入組裝階段——確保每一步都不可略過。此模式會在各步驟中按需載入不同的 reference 和 template，保持 context window 乾淨。

> "By implementing explicit diamond gate conditions (such as requiring user approval before moving from docstring generation to final assembly), the Pipeline ensures an agent cannot bypass a complex task and present an unvalidated final result."

- **實例：** 文件產生管線（四步驟）：解析與盤點 → 生成 Docstring（需使用者確認）→ 組裝文件 → 品質檢查。每步都有明確的進入條件。
- **關鍵特性：** 充分利用所有可選目錄，在特定步驟才引入所需資源，是五種模式中控制力最強的。

---

## Why？

我覺得概念蠻不錯的，但我看完之後就開始在想：身為一個使用 Agent 的人，我知道這個有什麼用？Google 幹嘛特地整理這些？

後來仔細想了一下，覺得這跟我們寫程式的時候，會學習一些 Design Pattern 或是 Clean Architecture 蠻相似的。

這些模式大概都是前人經過千錘百鍊後得出的精華，所以通常照抄都能有不錯的成效（但也是不要濫用）。

所以按照這個模式依樣畫葫蘆，如果 skill-creator 這個 skill，也能在我們提出需求的時候，先快速確認這個 skill 想要達成的目標，並選擇適合的 Design Pattern 來實現這個 skill，好像就有機會實現更好的結果？