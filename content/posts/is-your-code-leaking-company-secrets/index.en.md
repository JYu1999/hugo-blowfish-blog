---
title: "Is Your Code Leaking Company Secrets?"
date: 2025-07-26T19:07:31+08:00
draft: false
description: "A reflection on common security pitfalls in software development."
tags: ["Technical", "Security"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

In my two years as a software engineer, I’ve encountered some interesting security issues that I’d like to share in this post.

Before we really get started, here is a disclaimer: I don’t have a deep understanding of the strict definition of "Information Security." So, I’m not sure if the topics below technically count as security issues under a rigorous definition. But anyway, I categorize them all under security. 😆

## User Enumeration

Here is the scenario: A user has registered an account on our system using their email.

Later, having not used the system for a long time, they forget they already registered. So, they try to sign up with that email again.

At this point, standard website logic would likely tell the user: "This Email has already been used."

But let’s consider a scenario:

> Is it possible the user doesn't want others to know they have registered here?

Beyond registration, this issue frequently appears in the **"Forgot Password"** flow.

An attacker can enter an email on the "Forgot Password" page. If the system responds with "Account not found," it confirms which emails are **not** registered. Conversely, if it sends an email, it confirms who **is** registered.

Normal websites might not have this issue, but websites that are viewed with a certain social stigma might face this problem.

I won't give specific examples to avoid trouble, but you can imagine the type of sites I mean. XD

So, how do we solve this? Here is a common solution:

Regardless of whether the email entered by the user exists, return a vague message, such as: **"If this email exists in our system, you will receive a password reset email shortly."** This way, an attacker cannot determine the validity of the email.

## Blacklists vs. Whitelists

Sometimes there are services that we need to restrict to specific people. In this case, which approach should we prioritize?

-   **Blacklist:** Explicitly exclude people who cannot access it.
-   **Whitelist:** Define the people who can access it.

Some might say, "Why not use both?" Indeed, they are not mutually exclusive. However, the word "prioritize" is key here.

In my personal experience, Whitelists are suitable for most situations.

What a Whitelist ensures is this: Only the people I have opened access to can enter. This means anyone who gets in is definitely someone I know.

With a Blacklist, I cannot guarantee that *everyone* I want to block is actually blocked. It only ensures that the people within my "scope of awareness" whom I want to block are blocked.

People outside my "scope of awareness" who shouldn't have access might still slip through.

This is actually a significant risk. No matter how experienced you are, it is hard to ensure you have thought of every possible scenario in advance. If you miss just one, it could lead to problems.

## Someone Tried Too Many Times

Speaking of this, I’m reminded of a painful experience.

When I first started using a digital bank account, I set a super complex password to ensure security.

At the time, I didn't have the concept of using password management tools, so I eventually forgot the password.

Forgetting that I had set a complex one, I tried logging in with my commonly used passwords. After five attempts, I was locked out and had to make a special trip to the bank... 🥲

I believe many systems have a "lock account after X failed attempts" mechanism. This is designed to prevent Dictionary Attacks.

But what risks might this mechanism carry?

Obviously, if I know someone else's account name today, I can just keep trying to log in until their account gets locked. Using the digital bank example, this forces the victim to keep running to the bank, which is quite inconvenient.

That is actually a better-case scenario. Some services don't have "rescue" measures. For example, there is a tool called `fail2ban` which locks an account (or IP) after too many failed SSH attempts.

If someone exploits this mechanism to constantly attack a key operations engineer's account, it could result in that engineer being unable to access the server at all...

To clarify, I am not against locking accounts. I am just pointing out the underlying risk.

## How Big is Your Company?

Let’s use a forum website as an example. Generally, the API for posts might be designed like this:

```bash
GET [forum.com/posts/1](https://forum.com/posts/1)
````

At first glance, there doesn't seem to be a problem. But it hides a risk: It reveals the company's scale and development speed.

For instance, if I see `posts/1001`, I know the forum has a total of 1001 posts.

Or, I can take `The ID of the last post this month` and subtract `The ID of the first post this month` to know exactly how many new posts were created this month.

If I track this data every month, wouldn't I know the company's growth rate?

Reading this, some might think: "I know\! I'll just use UUIDs or Slugs for the API, and that solves it, right?"

That is correct. But I believe the point isn't just the solution, but the principle: **Do not leak IDs that have business significance or are enumerable**, otherwise, you risk revealing unnecessary information.

## What is the Current Status?

Many of you likely know the Status Code:

```bash
429 Too Many Requests
```

Here is the question: When someone actually triggers the Rate Limit, should we give the frontend this Status Code, or should we give them something like a `400`?

Generally, companies won't set overly strict Rate Limits. So, we can assume that anyone triggering them is likely writing an automation script (bot).

In this scenario, if a bot is halfway through scraping and suddenly hits a `429`, the attacker can easily calculate the system's Rate Limit rules based on the start time and adjust their crawler strategy accordingly.

However, throwing a `400` is different. When an attacker sees a `400`, they won't necessarily associate it with Rate Limiting immediately. They might need to conduct extra experiments to actually calculate the Rate Limit threshold.

While you can't completely prevent someone from guessing the threshold, this at least increases the difficulty for the attacker.

-----

Another similar example is form validation. If a user fills something out incorrectly, should we tell them exactly which field is wrong and what rule was violated?

Some might think: "Just tell them. Isn't that more convenient?"

It is convenient, yes. But consider two situations:

1.  Similar to the Rate Limit issue above, malicious actors can use simple trial-and-error to figure out exactly what data the system accepts. They can then use this to flood the system with garbage data.

2.  Actually, many users have poor habits and fill in data carelessly, often with typos or extra characters. If you don't tell the user exactly where the error is, they are forced to double-check *all* fields carefully, which increases the chance of them discovering other mistakes they made.

## Conclusion

I wonder if, after reading this, you feel: "Whoa, there are way too many things to watch out for\!"

I never thought about these things before either. 😂

However, I want to remind readers of two points:

  * Security and convenience are always a trade-off. Whether to adopt these measures depends on the design philosophy of your product.
  * Most of the issues above likely have other solutions. If you are interested, feel free to think about them further.

Have you encountered any other interesting security issues? Feel free to share them with me\! XD
