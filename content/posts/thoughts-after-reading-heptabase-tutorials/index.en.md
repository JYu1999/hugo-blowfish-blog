---
title: "Reflections on the Official Heptabase Tutorials"
date: 2024-10-02T19:04:52+08:00
draft: false
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

A few days into executing my learning plan, I realized a problem: my learning methodology hasn't evolved in a long time.

It's not that there was anything inherently wrong with my original approach. However, with AI becoming increasingly advanced and more high-quality software products emerging, theoretically, I should have a better way to learn.

For high-intensity learning, the methodology significantly impacts efficiency and is highly correlated with learning outcomes.

So, I decided to pause all current Tasks and focus exclusively on improving this area.

The goal is to make the process of **absorbing, organizing, and utilizing knowledge smoother and more efficient**.

First, I started investigating various learning methods and found videos made by the founder of Heptabase.

After watching three episodes, I not only understood how to use Heptabase but also reflected on the problems I've encountered in my past learning.

## Reusable

The first point is "reusable." His videos strongly emphasize this concept—that is, all our notes should be written with the expectation that they will be heavily reused in the future.

> Heptabase Fundamentals 101: Se... → The reason that we designed card library this way is because we believe that knowledge should be reusable across topics.

This should also be the core concept of the Zettelkasten method (Slip Box).

In the past, in pursuit of structural completeness, my notes were often very lengthy, with excessive text and descriptions. The consequences were:

First, I didn't like taking notes because it took too long every time.

Second, if I needed to review what I recorded, it was difficult to quickly find what I wanted. So, I would rather just Google it, or now with Perplexity or Felo available, I can get answers even faster.

The Zettelkasten method avoids these two issues effectively.

The core concept of Zettelkasten is to allow us to quickly retrieve the knowledge we recorded in the past when needed. We need to be able to quickly understand and recall the thought process from that time.

> Heptabase Fundamentals 101: Se... → When you revisit them, you can immediately remember how you think even after a long time.

To achieve this, we need to break knowledge points down as much as possible. Each card should try to record just a single piece of knowledge or idea.

The benefit is that in the future, we can not only find this card quickly but also understand its content in a very short time.

And because the recorded content is singular enough—unlike articles containing a lot of irrelevant content—we can easily reuse this specific knowledge point.

This actually reminds me of a concept in software development: **SRP (Single Responsibility Principle)**. The most important concept of SRP is that "a module should be responsible to one, and only one, actor."

If a Function does too many things, binding too much logic together—perhaps including receiving frontend requests, validating requests, processing business logic, saving to the database, error handling, and sending responses...

In this case, if we want to reuse a specific feature within this Function—let's say the error handling part—we simply cannot extract it separately for reuse.

Moreover, when testing this Function, the complexity arising from the combination of all variables makes testing difficult.

This is the phenomenon known as **High Coupling**.

Extending this further, it is similar to software project management concepts: we should break an Issue down into sufficiently small subtasks. But I won't expand on that here.

## Re-structure

The second point is the design of the **Whiteboard** mentioned in the video.

> Heptabase Fundamentals 103: Ma... → Whiteboard is particularly good at breaking down complex knowledge into atomic pieces and connect and visualize them to better see the relationship between ideas.

You can see two concepts emphasized here. First, we need to break down complex knowledge. Second, we need to clearly know the connections and structure between pieces of knowledge.

The first concept is essentially the "card" mentioned above.

However, as mentioned earlier, while "cards" solve the problem of reusability, learning isn't just about decomposing knowledge.

> Heptabase Fundamentals 101: Se... → The essence of learning is you have consumed all this information, but then you restructure it in your own way

Just like when writing code, we might have many Functions or Classes. They are already decomposed, but we still need to know the relationships between them to compose a new Function.

## When to create a Whiteboard?

Seeing this, I started thinking: in what scenarios is it suitable to create a Whiteboard? Or specifically, how should it be used?

> Heptabase Fundamentals 101: Se... → think about a topic that you care about and then create a whiteboard

The answer he gave was surprisingly simple. Basically, anything you care about right now can be a Whiteboard?

I think the reason is: what we care about now represents a problem we need to solve. And to solve this problem, we need to reorganize our knowledge.

He also mentioned an important concept:

> Heptabase Fundamentals 102: Or... → you don't really need to figure out your organization from the very beginning. Once a whiteboard grow big, that's the best time you think about creating the sub-whiteboard

Previously, I spent a lot of time conceptualizing the structure of my notes, hoping to come up with a perfect solution so I wouldn't have to adjust it later.

But note structures need to be adjusted as scale changes, because scaling brings problems you never thought of before.

So actually, just start doing it. XD

## Next-up

Next, I plan to study the official Readwise videos, Alan Chan's Blog (Heptabase founder), and see how others integrate Readwise and Heptabase.

Additionally, I need to research how to use Heptabase for language learning.

Going a step further, I want to explore how to integrate notes with AI to build a Knowledge Agent, further enhancing data reusability. However, this is not the most urgent thing to solve in the short term.

## Reference

- [Heptabase Fundamentals 101: Sense-making with whiteboards](https://www.youtube.com/watch?v=HgvR2QkfwG0&t=38s)

- [Heptabase Fundamentals 102: Organizing topics with nested whiteboards and tab groups](https://www.youtube.com/watch?v=zlGRxZHlDgM)

- [Heptabase Fundamentals 103: Managing card databases with tags and properties](https://www.youtube.com/watch?v=4kwIfzIJ0o0)

- [A Deep Dive into the Single Responsibility Principle (SRP)](https://www.jyt0532.com/2020/03/18/srp/)