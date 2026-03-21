---
title: "It Took Us a Month to Realize the System Was Broken: Opportunities and Practices for Introducing Monitoring in the Company"
date: 2026-03-22T00:04:52+08:00
draft: false
tags: ["Career", "Technical"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

Over a year ago, I wanted to introduce a monitoring system to the company.
 
When I asked my supervisor for permissions, I was turned down with the remark, "There is no demand for it right now." To be honest, I couldn't refute it—the system seemed to be running perfectly fine, and no one thought there was any issue.
 
But "seems fine" and "actually fine" are two entirely different things.
 
## Two Incidents, One Problem
 
Recently, two incidents happened back-to-back, which finally gave me the opportunity I was waiting for.
 
**Incident 1: A third-party service was down for a month, and we had no idea.**
 
A third-party service we integrated with malfunctioned, causing the application process in specific scenarios to fail completely. Once discovered, the root cause was quickly identified and fixed—but the problem had silently persisted for at least a month. We only found out because a user reported it.
 
**Incident 2: Three days after replacing the servers, they crashed on a holiday.**
 
The company had just replaced a batch of servers. Everything observed over the first three days seemed normal. But the fourth day was a holiday, and users suddenly couldn't upload videos. It wasn't until someone reported the issue that we realized a configuration had been written incorrectly.
 
This error lasted for 12 hours. It affected at least two users who are very important to the company—I say "at least" because only two people actively reported it. One of them even complained directly on a public platform, which took a real toll on the company's reputation.
 
The common denominator in these two incidents is obvious: **When things went wrong, we didn't know; by the time we found out, it was already too late.**
 
There were actually two structural problems behind this: First, due to historical reasons, no one had a sufficient grasp of the entire system, leaving the status of many third-party services as black boxes. Second, the lack of monitoring mechanisms meant we could only wait passively for user reports. And for most users, their reaction to encountering a problem isn't to report it, but to simply think, "Whatever, forget it."
 
The second point is the most fatal one. I discussed a similar idea in [this article](/posts/unexpected-risks/): you think risks appear suddenly, but often they've been there all along, you just haven't seen them.
 
This time, the incidents finally made management face this gap. I took the opportunity to volunteer, stealing a bit of time between work tasks to start pushing for the implementation of monitoring.

---

## Inside the App: Making Every Exception Visible
 
Our application actually already had a mechanism to send errors to Slack, but in actual practice, there were two problems.
 
### "Uncaught Errors" Might As Well Not Exist
 
The original design was: Slack notifications were only sent for explicit `catch` blocks in the code. In other words, errors that weren't caught just quietly made their way to the user, with engineers completely oblivious.
 
If the error handling was designed comprehensively enough, this strategy would actually be fine. But the reality is, there are quite a few places in the legacy codebase where `catch` was poorly written or completely missing.
 
So the first thing I did was very brute-force: **Send notifications for ALL Exceptions, no matter what.**
 
This sounds like asking for trouble—wouldn't Slack get blown up with notifications? At first, yes, it did. But think about it carefully: those situations we already anticipated and that had no real impact on the system shouldn't have been thrown as Exceptions in the first place. They should be handled as normal application flow.
 
So the essence of this strategy is: trading a short-term notification bombardment for a long-term improvement in codebase health. As we gradually clear out those "fake Exceptions" from the code, what remains will be the actual problems that need attention.
 
### Error Messages Only Tell You "It's Broken," Not "How It Broke"
 
Another problem was: The error notification on Slack only said "Error in such-and-such situation," without any specific error message attached. Every time, an engineer had to SSH into the server and dig through the logs just to figure out what happened.
 
But many errors are obvious just by looking at the message—network jitters, payment gateway abnormalities—all of these could be directly identified from the error message without needing to access the server.
 
So the second optimization was: **Send the complete error message to Slack.** This allows engineers to quickly categorize issues right on Slack: which ones require deeper investigation, and which are just temporary problems caused by external factors, saving unnecessary debug time.
 
## Outside the App: Patching Infrastructure Monitoring Gaps with New Relic
 
Alerts within the application layer were done, but some problems don't reside in the application layer at all—network disconnections, CPU spikes, container abnormalities. In these scenarios, requests might not even reach the application, or the app itself might be completely stuck. Naturally, the application-layer error reporting wouldn't log anything.
 
For this part, I chose New Relic, and the reason is simple: the company had actually been using it all along, just not utilizing it properly.
 
Given the limited time, I narrowed the scope to the "newly replaced servers," focusing only on basic metrics like CPU, GPU, Memory, Container, and Network.

Because the old servers will be phased out soon, the return on investment isn't worth it, so they have been left out for now.

As for application-layer metrics like API error rates, response times, and scheduled task execution statuses, I'll add them in later when there's more time.
 
When designing thresholds, a colleague shared an insightful perspective I deeply agree with: **It's better to over-report than to report too late.**
 
Take CPU Usage as an example: rather than initially setting the alert at 80%—by which time users might already feel significant lag—it's better to start at 40%. If it triggers too often, just adjust it upward later. Strive for "visibility" first, then tune for "accuracy."

---

## Putting It to Use Immediately The Next Day
 
On the first day after setting up New Relic, I noticed a bizarre blank spot: for a full half-hour, absolutely no signals came in.
 
After investigating, I learned that the server room network was undergoing maintenance during that time. But the key point is—**we received absolutely no maintenance notification.**
 
This made me wonder: was everything really fine before, or did we just have no idea when things went wrong?
 
Even more coincidentally, the very next day a user reported: she kept trying to send messages on our platform, but they wouldn't go through. Engineers spent a long time troubleshooting—reading code, debugging, flipping through logs—and found no abnormalities whatsoever.

Logically, if a message fails to send, there should definitely be logs at the application layer.
 
Later, I checked the DB and found that this user routinely sent messages at a specific time. Comparing the times—the moment she reported the issue coincided exactly with the data center's network maintenance window.
 
The requests never even reached the application, which is why there were no logs. And because the user didn't refresh the page, she just stayed there repeatedly trying to send, without seeing any clear error prompts.
 
If it weren't for that record of "vanishing signals" in New Relic, we might never have figured out this problem.
 
## Final Thoughts
 
I used to always think that as an engineer, as long as testing was thorough and Code Review was rigorous, I could guarantee that the things I built were problem-free.
 
But the reality is: we can't predict every situation, and mistakes are inevitable.
 
So what we really should be thinking about isn't just "how to avoid making mistakes," but rather "when mistakes happen, how do we minimize the damage"—how to discover them as quickly as possible, and how to stop the bleeding immediately.
 
This means that when developing any feature, error reporting mechanisms and monitoring metrics shouldn't be an afterthought patched on later, but designed and delivered together with the feature itself.
 
Pushing this initiative forward has also given me quite a sense of accomplishment. After all, it's something that went from being rejected over a year ago to finally being implemented today. Sometimes it's not that the timing is wrong, but rather the pain just isn't deep enough yet. When the pain becomes real, the opportunity naturally presents itself.
