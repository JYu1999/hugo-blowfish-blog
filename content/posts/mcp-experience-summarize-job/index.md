---
title: "MCP 二次烙賽體驗"
date: 2026-01-02T9:00:00+08:00
draft: false
tags: ["人工智慧"]
---

接續上一篇文章，我又來嘗試 MCP。

{{< article link="/posts/mcp-first-experience/" showSummary=true compactSummary=true >}}

這次的構想跟上次一樣：透過本地 MCP Client，去存取 Jira 和 Gitlab 的 MCP Server，然後再請 AI 幫我分析我之前在公司解過哪些議題，並整理成履歷。

不過不同的有兩點：
- 這次改用 Claude Code
- 改一下提示詞

---

## 嘗試一

這次我直接修改了提示詞。

首先我用 ChatGPT STT，詳細講了我的需求，然後把逐字稿貼給 Gemini，請它幫我生成適當的提示詞。

生成後結果如下（經過適當刪減）：

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

看起來很完美，馬上丟給 Claude Code。

然而執行下去馬上就遇到一個問題：才分析三個議題，Token 就用光了。

我自己推測是 MCP 呼叫過程中，可能會有很多不必要的資訊，去讀取 MR 也是一個很耗費 Token 的事情。再來同時做兩件事情（抓資料和分析）也會增加 Token 的使用。

除此之外，光是要分析這三個議題所消耗的時間，就已經很長了，天知道我要什麼時候才能把工作兩年多的議題全部整理完。

但也要說一下，其實它執行的結果我是蠻滿意的，但礙於保護公司隱私，這裡就不特別分享。

## 嘗試二

嘗試一的問題主要是同時做兩件事情：
- 抓資料
- 分析

所以這次我改變策略，改成只做一件事情：抓資料。

於是我請 Gemini 修改提示詞，結果如下：

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

看起來非常合理。

一樣執行下去，我發現速度依舊非常緩慢。

我觀察了一下執行過程，發現 MCP 執行蠻沒效率的。

會需要花很多時間定位到該抓的資料哪裡。

有點像是：他知道有很多 API(Tools) 可以用，也知道該用哪一個，可是他不知道要填入什麼參數才能找到正確資料。

所以會花一些時間在窮舉。

此外，我覺得最大的問題是：不是每個 Issue 都是等價的。

舉例來說：有些 Issue 其實非常單純只是改了一點點，這種 Issue 其實從根本上就不會被放進履歷，其實不用特別去分析。

## Next Step

經過上面的經驗，下次會做以下調整：

1. 我可能會先人工去找我覺得最有價值的那些 Issue，再丟給 AI
2. 一樣，下次就先單純抓資料下來，抓完再來分析