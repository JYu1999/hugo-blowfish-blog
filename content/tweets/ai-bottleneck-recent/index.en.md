---
title: "Short to Mid-term Bottlenecks for AI?"
date: 2026-03-06T10:30:00+08:00
draft: false
tags: ["Technology", "Career", "Reading"]
---

[Software Engineering Accounts for Nearly 50% of AI Agentic API Calls — The Reality and Future of Agent Autonomy from Data](https://blog.aihao.tw/2026/02/23/agent-autonomy-domains/)

I saw this article and my thoughts are quite similar, so I'm writing them down.

Mainly this part:

> The research used a great concept: "deployment overhang" — the models' capabilities have arrived, but the actual degree of autonomy in deployment is lagging far behind.
>
> METR's evaluation shows that Claude Opus 4.5 can handle tasks that would take humans nearly 5 hours to complete, but Claude Code's 99.9th percentile autonomous work time is only 45 minutes, with the median being a mere 45 seconds.
>
> This gap is an opportunity for product builders: it's not that the models aren't capable, but that product-level trust mechanisms, monitoring tools, and access controls aren't ready yet. Whoever can do these well in vertical domains will be able to unlock the potential of agents.

I think AI is completely fine for development right now; probably many engineers are already using AI for development, tracing code, and debugging.

However, observing most production products currently, human review is still required in the end. This means one thing: no matter how fast AI generates code, it will ultimately be bottlenecked by the speed of human review.

I believe the underlying reason stems from the nature of LLMs: they are probabilistic prediction models.

Therefore, even a 0.01% chance of causing issues in the production environment is unacceptable.

So what should we do about this problem? Will it forever be bottlenecked by review speed?

Of course, no one knows exactly what the future holds, but I'd boldly guess what infrastructure might be needed to further liberate AI's productivity:

1. Documentation: Sometimes AI makes incorrect judgments due to a lack of context. If the documentation is comprehensive, AI can make more accurate judgments, reducing the probability of errors. Furthermore, we also want to ensure AI doesn't repeat the same mistakes.
2. SRE: Since AI cannot be 100% correct, there must be solid monitoring and rollback mechanisms. If the mechanisms are well-established, we can accept AI making mistakes because we know "even if there is an error, we can quickly receive notifications and fix it rapidly."
