---
title: "Why I Quit After Building a YouTube Downloader in 3 Days — The 'Stop-Loss' Philosophy of Side Projects"
date: 2026-01-15T09:00:00+08:00
draft: false
tags: ["Career"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

Recently, I spent some time building a Side Project: a YouTube video downloader.

It didn't end up going down the path I initially fantasized about—"turning it into a product, offering memberships, taking ads"—but it did solve my immediate problem, and it gave me a clearer understanding of the **"Core Philosophy of Building Side Projects."**

If you've ever wanted to start a Side Project but hesitated, or started one only to give up halfway, perhaps this article can offer some inspiration.

---

## I Used to Think Side Projects Were "Heavy," Until I Saw a New Possibility

In the past, when people asked me, "Are you working on any Side Projects?" I would often reply:

> No, because I don't have any problems that need solving with a Side Project.

But later, I slowly realized that this statement was only half true.

The more honest reason was—I felt the cost of doing a Side Project was too high.

*   Designing features
*   Coding
*   Deploying
*   Maintaining
*   Maybe even marketing

If the problem I'm facing right now isn't big enough to justify these costs, I naturally feel that a "Side Project is too heavy," and I might even start avoiding it.

---

## Strategy: Write Your "Will" Before You Write Code

Last week, I was chatting with a Mentor, and I mentioned that I wanted to start a Side Project but was worried about the high costs.

He shared an approach that I strongly agree with:

### ✅ For a Side Project, clearly define your "Failure Goals" from the start.

For example:
*   Use "Revenue < $1,000 NTD/month within a week" as a failure condition.
*   "Maintenance takes > 5 hours/week" as a failure condition.

As long as this Side Project hits a "Failure Goal," you can drop it immediately.

This sounds a bit counter-intuitive because we are used to setting goals based on "Success Conditions." But for Side Projects, it's actually better to define the **Stop Conditions** first.

It's like investing: you can hope for profit, but risk control requires a "Stop-Loss Point."

A "Stop-Loss Point" is a worst-case scenario. When you already know what the worst-case scenario is, "starting to act" doesn't feel so terrifying anymore.

So, for this YouTube downloader, I set 3 stop-loss points:

1.  I'm only willing to pay for one VPS (approx. $5/month).
2.  I don't want to spend more than 20 hours on development & launch.
3.  I don't want follow-up maintenance to exceed 3 hours/week.

If it doesn't meet expectations (e.g., maintenance costs are too high), stop immediately—no dragging it out.

---

## Execution: A 3-Day Sprint to Build the "Simplest" Downloader

The topic this time was simple: My girlfriend wanted to download YouTube videos, but she didn't know how to use CLI tools. I thought, since I know how to code, why not build a web version for her?

I spent about two or three days finishing the entire feature set, including:

*   Pasting a YouTube video URL
*   Downloading the video (mp4, highest quality)
*   Downloading subtitles
*   Infrastructure (Docker/DB/Queue)

### The Temptation of "Perfectionism"

During the development process, I actually struggled with the scope of the MVP.

At the time, AI suggested: "Since this is an online service, it might be abused. You should implement Rate Limiting, for example, limiting a single IP to downloading 1 video at a time, or maximum 10 videos concurrently system-wide."

This sounded very reasonable. I hesitated for a moment:

*   Should I add a membership system?
*   Should I integrate ads?
*   Should I build a robust rate-limiting system?

But I calculated the timeline: The core features took 3 days. Implementing rate limiting might take another 1-2 days, and it would restrict my own usage, meaning I'd have to build a backdoor for myself.

This would drag down the entire validation speed.

Finally, a voice in my head convinced me: **"You haven't even confirmed if this thing works in Production yet. Why build so many protection mechanisms?"**

Besides, if no one uses it after launch, or if the core features have issues in the live environment, then the time I spent carving out rate-limiting features would be totally wasted.

Instead of agonizing over this 1% risk, it's better to launch quickly and see if it runs.

So, I finally chose to follow the principle of "Rapid Launch"—**Deploy first, ask questions later.**

---

## Hitting the Wall: Initial Launch Reality Check

After the service went online, I ran straight into the biggest problem:

> **I couldn't download anything, no matter what.**

I did some research and found out that YouTube has anti-download mechanisms. It detects if an IP belongs to a Data Center. If you run downloads on a cloud server (like AWS EC2), it might block you directly.

This issue was critical because it was completely outside my expectations.

If I wanted to continue, I would probably need to go down these paths:

*   Proxy / Proxy Pools
*   Cookie Login
*   Other bypass strategies

But my immediate gut reaction was: **"This is way too much trouble."**

I just wanted to make a tool to "download YouTube videos," and now I have to fight a bunch of anti-crawling measures in Production. Plus, using Proxies would increase costs.

### Triggering the Stop-Loss Point

At this moment, I looked back at the "Failure Goals" I set at the beginning:

1.  **Uncontrollable Costs**: If I have to buy Proxies, the cost will definitely exceed $5/month.
2.  **Excessive Maintenance Costs**: This would turn into an eternal cat-and-mouse game. If YouTube changes its algorithm, I have to change with it.

This directly triggered my "Stop-Loss Point."

If I had spent three weeks building the membership system and rate-limiting mechanisms only to discover this, I would probably have broken down. But because I only spent three days, I could accept this fact very calmly.

---

## Conclusion: A Dignified Quit & A Compromise

After evaluation, I decided to halt the Production launch plan for this Side Project.

But I didn't feel it was a pity. This is what I felt was the most satisfying part: **Rapid launch allowed me to quickly obtain evidence that it was "not worth investing in."** This saved so much time compared to spending three weeks building a complete MVP only to find out it wouldn't work.

### Pivoting: Cloudflare Tunnel

Although I gave up on the public launch, it didn't mean the project was completely useless.

Later, I found a compromise:

*   I run the service on my own computer (spun up with Docker).
*   Use Cloudflare Tunnel to open a public entry point.
*   When my girlfriend needs to use it, she tells me, and I turn on the Tunnel.

She can use her phone or computer to connect directly to the service on my machine and download videos as usual.

The benefits of this are:

*   Local IPs are usually not blocked by YouTube.
*   No need for Proxies.
*   No need to maintain a service that is online forever.
*   I can use it myself too.

The core purpose was still achieved, but I successfully avoided the bottomless pit of maintenance costs.

---

## Summary: Dual Growth in Tech and Mindset

Although this Side Project "failed" (it didn't become a public service), I feel like I gained a lot.

### 1) The "Stop-Loss Philosophy" of Side Projects

My Mentor was right: "Not knowing why you gave up" is the problem. But this time, I gave up very clearly and with reason. You could even say, **"Giving up with a reason" is a success in itself.**

### 2) The Value of Rapid Launch

In a Side Project, **whether the core feature works is far more important than "how complete the additional features are."** Especially when you need to verify unknown risks like "Will I step on a landmine in the Production environment?", speed is your lifeline.

### 3) Unexpected Technical Gains: Docker / IaC

Although the features didn't get big, my deliberate use of Docker for one-click deployment turned out to be my biggest takeaway.

Previously, I usually deployed projects by manually SSH-ing and typing commands. This time, I experienced the beauty of "Repeatable, Fast, Recoverable."

*   Need to rebuild the environment? Just delete and restart.
*   Debugging live? Change it and redeploy directly.

Even in the AI era, AI writes the Dockerfile for me, and I just run it. This made my iteration speed more than double. It also made me realize: **Infrastructure as Code might be more important than the feature itself, because it is the foundation that gives you the courage to try things quickly.**

---

If you are also hesitating about whether to do a Side Project, I want to give you a sentence that I believe in the most right now:

> **Launch fast, fail fast—that is the most efficient route to success.**
