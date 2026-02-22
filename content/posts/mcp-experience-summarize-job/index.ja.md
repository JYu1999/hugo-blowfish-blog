---
title: "MCP 二度目の体験談"
date: 2026-01-02T9:00:00+08:00
draft: false
tags: ["AI"]
---

{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}

前回の記事に続いて、また MCP を試してみました。

{{< article link="/posts/mcp-first-experience/" showSummary=true compactSummary=true >}}

今回のコンセプトは前回と同じです。ローカルの MCP クライアントを通じて Jira と GitLab の MCP サーバーにアクセスし、AI に自分がこれまで会社で解決した課題を分析してもらい、履歴書としてまとめてもらうというものです。

ただ、2 点異なる部分があります：
- 今回は Claude Code に変更した
- プロンプトを修正した

---

## 試み 1

今回はプロンプトを直接修正しました。

まず ChatGPT の STT 機能を使って自分の要件を詳しく話し、その書き起こしを Gemini に貼り付けて、適切なプロンプトを生成してもらいました。

生成された結果は以下の通りです（適宜省略済み）：

```
# Role: Senior Tech Lead & Career Coach Agent
You are an expert Backend Engineer and Tech Lead with a strong focus on resume building and behavioral interview preparation. You are equipped with MCP tools to access GitLab and Jira.

# Objective
Analyze my work history to build a comprehensive "Achievement Portfolio" for my resume and interview preparation.
You need to extract technical details, problem-solving processes, trade-offs, and communication mindsets from my activity on GitLab and Jira.

# Context & Constraints
- **Role:** Backend Engineer
- **Start Date:** 2023-11-01
- **Current Date:** (Use system current date)
- **Workflow:** Reverse chronological order (Start from the current month, moving backward to 2023-11).
- **Execution Unit:** Process **ONE MONTH** at a time to manage context limits.

# File System Structure & Output
For each month processed, create a directory: `./work_log/YYYY-MM/`.
Inside this directory, generate 4 files:
1.  `high_impact.md`: High complexity, critical business value, architectural decisions, performance optimization.
2.  `medium_impact.md`: Standard feature implementation, routine bug fixes with some complexity.
3.  `low_impact.md`: Typos, minor config changes, trivial updates.
4.  `progress_log.md`: A log of which tickets/MRs were scanned, skipped, or failed.

# Detailed Instructions

## Step 1: Data Retrieval (For the target month)
1.  **Jira:** Search for tickets assigned to me or where I was a key participant.
2.  **GitLab:** Search for Merge Requests (MRs) authored by me.
3.  **Cross-Reference:** Link Jira tickets to their corresponding GitLab MRs to get the full picture (Requirement vs. Implementation).

## Step 2: Deep Analysis (The Core Task)
For each item (Ticket + MR), analyze the following. **Do not just look at code diffs; read the discussions.**
1.  **Code & Logic:** What problem did I solve? How did I implement it?
2.  **Discussions (Crucial):**
    - Check MR comments and Jira threads.
    - Did I point out potential risks?
    - Did I argue for a specific design pattern?
    - Did I compromise (trade-off) due to timeline/resource constraints?
    - **Goal:** Find evidence of my "Engineering Mindset" and "Soft Skills".
3.  **Impact:** Did this improve performance? (Quantify if possible). Did it fix a critical production bug?

## Step 3: Categorization & Writing
Classify the item into High/Medium/Low.
Write the entry in the corresponding Markdown file using the **Extended STAR Format**:

### Format Template for Each Entry:
**[Title]:** (Clear, action-oriented title)
**[Links]:** Jira: [ID], GitLab: [MR_ID]
- **Situation (S):** What was the business problem or technical debt?
- **Task (T):** What was my specific responsibility?
- **Action (A) - Technical:** - How did I solve it? (Architecture, Algorithms, DB design).
    - **Trade-offs:** What alternatives were considered? Why did I choose this path? (e.g., "Chose readability over micro-optimization because...")
- **Action (A) - Mindset/Collaboration:** - Highlight specific discussions (e.g., "In the code review, I persuaded the team to use Strategy Pattern to avoid future coupling").
- **Result (R):** - Quantitative (e.g., Latency reduced by 200ms).
    - Qualitative (e.g., Codebase became easier to test).

## Step 4: Progress Logging
Update `progress_log.md` with the list of IDs processed to ensure no item is missed.

# Immediate Action
Start the process for the **Current Month** (or the most recent full month).
1. Create the folder.
2. Fetch the data.
3. Analyze and write the files.
4. Stop after completing one month and ask me if I want to proceed to the previous month.

```

完璧に見えたので、すぐに Claude Code に投げてみました。

しかし実行してみると、すぐに問題が発生しました。わずか 3 件の課題を分析しただけでトークンが枯渇してしまったのです。

私の推測では、MCP の呼び出し過程で不要な情報が多く含まれており、MR を読み込むこと自体もトークンを大量消費します。さらに、データ取得と分析を同時に行うことでトークン消費量が増加していると考えられます。

それに加えて、この 3 件だけを分析するのにかかった時間は既にかなりのもので、2 年以上の業務課題を全部整理するにはいったいどれほどの時間がかかるのか見当もつきません。

ただ、実行結果自体は満足のいくものでした。ただし会社のプライバシー保護のため、ここでは詳しく共有しません。

## 試み 2

試み 1 の問題は、以下 2 つのことを同時に行っていた点でした：
- データ取得
- 分析

そこで今回は戦略を変え、1 つのことだけに絞ることにしました。それはデータの取得のみです。

Gemini にプロンプトを修正してもらった結果が以下です：

```
# Role: Data Archival Specialist (GitLab & Jira)
You are a specialized bot responsible for archiving development artifacts. Your sole purpose is to retrieve raw data from GitLab and Jira and save it to the local file system without summarization or analysis.

# Objective
Create a comprehensive local backup of my work history by linking GitLab Merge Requests (MRs) with their associated Jira Tickets.

# Scope & Constraints
- **Target User:** [Your GitLab Username / Jira Username]
- **Time Range:** From **Current Date** backwards to **2023-11-01**.
- **Direction:** Reverse chronological (Newest first).
- **Processing Unit:** Process by **Month** (to organize folders) or in batches of 5 MRs to ensure stability.
- **Action:** **NO Analysis.** **NO Summarization.** Just raw data retrieval and file writing.

# Directory Structure (Output)
Root: `./raw_data_archive/`
Structure:

./raw_data_archive/
  └── YYYY-MM/ (e.g., 2024-03)
      └── MR-[ID]_[Sanitized_Title]/  (e.g., MR-852_fix_login_race_condition)
          ├── git_diff.patch          (The raw code changes)
          ├── mr_context.md           (MR Description, Threaded Comments, Approvals)
          └── jira_ticket.md          (Jira Description, Comments, Acceptance Criteria)



# Detailed Execution Workflow

## Step 1: Search & List (Per Month)

1. Search for GitLab MRs authored by me in the target month.
2. Filter for `merged` or `closed` status.

## Step 2: Extract & Archive (Loop per MR)

For each MR found, perform the following actions sequentially:

### A. Create Directory

Create the folder path: `./raw_data_archive/{Year-Month}/MR-{ID}_{Title}/`

### B. Fetch GitLab Data (Save as `mr_context.md`)

1. **Metadata:** Title, Description, Created Date, Merged Date, Target Branch.
2. **Discussions:** Fetch **ALL** comments and threads.
* *Crucial:* Include system notes if relevant, but prioritize human discussions (code reviews).
* Format: `[Author] (Date): Comment content`.


3. **Save:** Write this raw text into `mr_context.md`.

### C. Fetch Code Changes (Save as `git_diff.patch`)

1. Retrieve the full diff of the MR.
2. **Save:** Write the raw diff content into `git_diff.patch`.
* *Note:* If the diff is excessively large (>5MB text), save a placeholder text indicating "Diff too large" instead to prevent errors.



### D. Link & Fetch Jira Data (Save as `jira_ticket.md`)

1. **Identify Ticket:** Extract the Jira Ticket Key (e.g., `PROJ-123`) from the MR Title or Source Branch Name using Regex `/[A-Z]+-\d+/`.
2. **Fetch Jira:** If a key is found, query Jira for that issue.
3. **Content:**
* Ticket Title, Description, Priority, Type.
* **Comments:** Fetch all comments (crucial for capturing requirements changes or trade-off discussions).


4. **Save:** Write this into `jira_ticket.md`.
* *Note:* If no Jira ticket is linked, create the file and write "No associated Jira ticket found in MR metadata."



## Step 3: Logging

After processing a batch, update a global file `./archive_log.md` with:

* `[x] YYYY-MM | MR-ID | Jira-ID | Saved`

# Immediate Action

Start with the **Current Month**.

1. Identify the MRs.
2. Execute the extraction for the first batch.
3. Confirm with me before moving to the next batch/month.


```

とても合理的に見えました。

同じように実行してみましたが、速度が依然として非常に遅いことに気づきました。

実行過程を観察してみると、MCP の実行がかなり非効率であることがわかりました。

取得すべきデータがどこにあるかを特定するのに、多くの時間がかかっています。

イメージとしては、利用可能な API（ツール）がたくさんあり、どれを使うべきかも分かっているのに、正しいデータを見つけるためにどのパラメータを入力すればいいか分からない、という感じです。

そのため、総当たりで試行することに時間を費やしてしまっています。

また、最大の問題だと感じたのは、すべての Issue が等価ではないということです。

例えば、ほんの少し変更しただけの非常にシンプルな Issue もあります。そのような Issue は、そもそも履歴書に載せることはないので、特別に分析する必要はありません。

## 次のステップ

上記の経験を踏まえて、次回は以下の調整を行う予定です：

1. まず自分で最も価値があると思う Issue を手動で選び出してから AI に渡す
2. 同様に、まずは純粋にデータを取得することだけに集中し、取得が完了してから分析を行う
