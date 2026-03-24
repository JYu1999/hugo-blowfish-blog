---
title: "Do you really need to know Agent Skill design patterns?"
date: 2026-03-25T00:00:00+08:00
draft: false
tags: ["AI", "Technical"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

Google posted this article on X:

{{< x user="GoogleCloudTech" id="2033953579824758855" >}}

The article briefly summarizes 5 Agent Skill Design Patterns, organized here by AI:

## 5 Agent Skill Design Patterns

### Pattern 1: Tool Wrapper
- **Purpose:** Allows the Agent to dynamically load the expertise of a specific library or framework when needed, rather than hardcoding it into the system prompt.
- **Mechanism:** SKILL.md listens for specific keywords in the user's prompt and only loads internal documents from the `references/` directory when triggered, treating them as absolute guidelines. This is suitable for distributing internal team coding conventions or framework best practices.

> "Instead of hardcoding API conventions into your system prompt, you package them into a skill. Your agent only loads this context when it actually works with that technology."

- **Example:** FastAPI expert skill — The Agent only loads `conventions.md` when reviewing or writing code, checking conventions line by line and providing correction suggestions.
- **Key Feature:** This is the simplest pattern; its core value lies in "on-demand loading" to avoid wasting the context window.

### Pattern 2: Generator
- **Purpose:** Ensures the Agent produces documents with a consistent structure every time, solving the "different format every time" problem.
- **Mechanism:** Uses the `assets/` directory for output templates and `references/` for style guides. The instructions in SKILL.md act as a project manager: load template → read style guide → ask the user for missing variables → populate the document. Suitable for generating API documentation, standardized commit messages, or scaffolding project architectures.

> "The instructions act as a project manager. They tell the agent to load the template, read the style guide, ask the user for missing variables, and populate the document."

- **Example:** Technical report generator — SKILL.md itself doesn't contain formatting rules or syntax standards; it only coordinates resource retrieval and forces the Agent to execute step by step.
- **Key Feature:** Externalizes templates and style rules, leaving SKILL.md to only handle "orchestration".

### Pattern 3: Reviewer
- **Purpose:** Separates "what to check" from "how to check," enabling modular automated reviews.
- **Mechanism:** Review standards are stored in `references/review-checklist.md`. After loading the checklist, the Agent compares the code submitted by the user against it line by line, grouping the output by severity (error / warning / info). By simply swapping the checklist (e.g., replacing a Python style checklist with an OWASP security checklist), you can conduct completely different professional audits using the same skill infrastructure.

> "If you swap out a Python style checklist for an OWASP security checklist, you get a completely different, specialized audit using the exact same skill infrastructure."

- **Example:** Python code reviewer — The instructions remain fixed while the Agent dynamically loads an external checklist, enforcing an output that includes a summary, graded findings, a score, and the top three recommendations.
- **Key Feature:** Highly interchangeable — switch the checklist to change the review domain; ideal for automated PR reviews or security scans.

### Pattern 4: Inversion
- **Purpose:** Prevents the Agent from guessing and directly generating results when information is insufficient; instead, the Agent takes the lead in asking questions and gathering complete requirements before acting.
- **Mechanism:** The core is setting clear and uncompromising "gate conditions" (e.g., "DO NOT start building until all phases are complete"), forcing the Agent to ask questions sequentially, wait for answers, and only proceed to the output phase once all stages are complete. The role is flipped from "executor" to "interviewer."

> "Instead of the user driving the prompt and the agent executing, the agent acts as an interviewer."
>
> "The agent refuses to synthesize a final output until it has a complete picture of your requirements and deployment constraints."

- **Example:** Project planner — Divided into three stages (problem exploration → technical constraints → comprehensive output), with strict gate controls for each stage; the Agent cannot proceed to the next stage until the current one is completed.
- **Key Feature:** Multi-turn conversational interaction, reducing the risk of missing requirements through phased questioning.

### Pattern 5: Pipeline
- **Purpose:** When handling complex tasks, enforces a strict sequential workflow with hard checkpoints to prevent the Agent from skipping steps or presenting unvalidated results.
- **Mechanism:** SKILL.md itself is the workflow definition. Through "diamond gate conditions" — such as requiring user confirmation of a docstring before entering the assembly phase — it ensures that no step can be skipped. This pattern dynamically loads different references and templates at each step, keeping the context window clean.

> "By implementing explicit diamond gate conditions (such as requiring user approval before moving from docstring generation to final assembly), the Pipeline ensures an agent cannot bypass a complex task and present an unvalidated final result."

- **Example:** Document generation pipeline (four steps): Parsing and inventory → Generating Docstring (requires user confirmation) → Assembling document → Quality check. Each step has clear entry conditions.
- **Key Feature:** Fully utilizes all optional directories and only introduces necessary resources at specific steps; it offers the strongest control among the five patterns.

---

## Why?

I think the concept is quite good, but after reading it, I started wondering: as someone who uses Agents, what's the use of this for me? Why did Google go out of its way to compile these?

Thinking about it more carefully, I realized this is quite similar to learning Design Patterns or Clean Architecture when we write code.

These patterns are generally the distilled essence of what predecessors have forged through intense trials, so copying them usually yields good results (though they shouldn't be abused).

So, following this model, if the `skill-creator` skill could also quickly confirm the goal a skill intends to achieve when we make a request, and select an appropriate Design Pattern to implement it, we might have a chance of achieving much better results, right?
