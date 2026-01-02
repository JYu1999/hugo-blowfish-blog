---
title: "MCP Second Flop Experience"
date: 2026-01-02T09:00:00+08:00
draft: false
tags: ["AI"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

Following the previous article, I am here to try MCP again.

{{< article link="/en/posts/mcp-first-experience/" showSummary=true compactSummary=true >}}

The idea this time is the same as the last one: use a local MCP Client to access Jira and Gitlab MCP Servers, and then ask AI to help me analyze which issues I have resolved in the company before, and organize them into a resume.

However, there are two differences:
- Used Claude Code this time
- Changed the prompt

---

## Attempt 1

This time I directly modified the prompt.

First, I used ChatGPT STT to explain my requirements in detail, and then pasted the transcript to Gemini, asking it to help me generate an appropriate prompt.

The generated result is as follows (with appropriate deletion):

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

Looks perfect, throwing it to Claude Code immediately.

However, a problem occurred immediately upon execution: after analyzing only three issues, the Tokens were used up.

I speculate that during the MCP calling process, there might be a lot of unnecessary information, and reading MR is also a token-consuming thing. Furthermore, doing two things at the same time (fetching data and analyzing) will also increase Token usage.

Besides, purely the time consumed to analyze these three issues was already very long. Heaven knows when I can finish organizing all the issues from over two years of work.

But I have to say, I am actually quite satisfied with the execution results, but due to company privacy protection, I won't share them here specifically.

## Attempt 2

The problem with Attempt 1 was mainly doing two things at the same time:
- Fetching data
- Analyzing

So this time I changed my strategy to only do one thing: fetching data.

So I asked Gemini to modify the prompt, and the result is as follows:

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

Looks very reasonable.

Executed it the same way, and I found the speed was still very slow.

I observed the execution process and found that MCP execution is quite inefficient.

It takes a lot of time to locate where the data to be fetched is.

It's a bit like: it knows there are many APIs (Tools) available, and knows which one to use, but it doesn't know what parameters to fill in to find the correct data.

So it spends some time brute-forcing.

In addition, I think the biggest problem is: not every Issue is equivalent.

For example: some Issues are actually very simple, just changing a tiny bit. This kind of Issue basically won't be put into the resume from the root, so there is no need to analyze it specifically.

## Next Step

Based on the experience above, I will make the following adjustments next time:

1. I might first manually find the Issues that I think are most valuable, and then throw them to AI
2. Similarly, next time I will just purely fetch data down, and analyze after fetching
