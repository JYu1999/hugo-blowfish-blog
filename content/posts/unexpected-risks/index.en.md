---
title: "The Biggest Risk is Always What No One Expected"
date: 2025-12-23T00:04:52+08:00
draft: false
tags: ["Reading", "Career"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

I was recently discussing an issue with a colleague about the priority of our monitoring system.

We've always had monitoring in place, but we haven't been using this tool effectively, which led to this discussion.

During the discussion, we came up with two reasons for "why we shouldn't optimize monitoring right now," which I found interesting and reminded me of some memories, so I wanted to write an article to record them.

However, we were just evaluating, so we naturally analyzed from both positive and negative perspectives.

But for the sake of convenience in the following narrative, I'll position my colleague as the opposing side and myself as the agreeing side.

## Discussion One

### Isn't Monitoring Itself the Most Important?

My colleague believes: What's important about monitoring is **what to do after detecting something**? Can we handle it?

For example, the previous Cloudflare incident—what good is monitoring if we can only wait for it to recover?

Or if a payment service provider goes down, monitoring it won't help at all.

### My Thoughts

It's true that there can be situations where we detect something but are powerless to act.

I think to determine whether something can be handled, we first need to **know** about it.

If we don't even know something has happened, how can we determine whether we can handle it?

Furthermore, while we may be technically unable to handle something, there may be administrative actions we need to take.

For example, if Cloudflare crashes, shouldn't we notify users? How should we notify them?

If a payment service provider crashes, shouldn't we quickly confirm the situation with them?

Without monitoring, we can only wait for users to discover the anomaly and notify us.

We'll always be one step behind.

## Discussion Two

### Monitoring Isn't the Biggest Risk Right Now

My colleague believes that the company currently has other more serious technical issues that need to be addressed.

I can't disclose what this issue is, but it's related to server stability and security.

So we should focus on solving that problem first.

### My Thoughts

In the book "The Same as Ever," there's a passage I really like:

> We are very good at predicting the future, just not good at predicting surprises, and the latter is often the most important key.
>
> What no one expects is always the biggest risk, because no one expects it, so no one prepares for it; because no one prepares for it, when it appears, the damage will be magnified.

Human abilities are ultimately limited. No matter how hard we try, we cannot predict all situations.

I agree that the issue my colleague raised is very important, but since we already know about it, I don't think it's the real risk.

As another quote from the book mentions:

> If you only prepare for foreseeable risks, then you'll be completely unprepared for everything you don't see

Regardless of the actual preparations we've made for this issue, even if we haven't done anything yet, at least we've made **mental preparations**.

But those **unimaginable things** are what prevent us from even making mental preparations. And if we can detect them early, we can gain valuable preparation and response time. I believe that for these **real risks**, even a small time difference is precious.

Technically, how do we detect those **unimaginable things** as early as possible? I think it's through monitoring.

Although we can't monitor all data, monitoring at least ensures that no matter what happens, we can find out as quickly as possible.

