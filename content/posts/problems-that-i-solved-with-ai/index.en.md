---
title: "Side Projects Built with AI Collaboration"
date: 2026-01-17T00:50:40+08:00
draft: false
tags: ["AI", "Tools"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

Recently, I was looking for a job and the company asked me to demonstrate some AI-related experience, so I organized a few Side Projects I did with AI to share with everyone XD.

---

## **Jira Copy Tool (Chrome Extension) — Turning "Routine Paperwork" into One-Click Tasks**

### Problem

When our developers open a Merge Request, they need a fixed format for the description. However, manually copying and adjusting it every time is time-consuming and prone to omissions.

### What I Did

I used AI collaboration to quickly develop a Chrome Extension:

- Automatically grab information from the Jira screen

- Generate MR text templates that match the team's habits

- Copy directly to the clipboard, so engineers don't have to organize it manually

![image.png](image.png)

### Results

- Reduced repetitive work and formatting errors for every MR

- Turned a "low-value but necessary" process into a reusable tool

- Allowed the team to focus their time on more important development and decision-making

---

## **YouTube Downloader (Web App) — Quickly Build a Ship-able Product Prototype using AI**

### Problem

Common pain points of YouTube Downloaders on the market are:

- Unstable download quality (unable to get the highest quality)

- Many tools cannot fetch subtitle files at the same time

### What I Did

I used AI collaboration to complete a Web App:

- Users paste the video URL

- Directly download the "highest quality" version of the video

- Support downloading subtitle files simultaneously

![image-1.png](image-1.png)

---

## AI Translation Shortcut (Apple Shortcut + API Integration) — Turning AI into a Portable Exoskeleton

### Problem

When I was traveling in Vietnam, I hoped to communicate more naturally with locals, but Google Translate often produced unnatural tone or failed to convey the meaning effectively; and typing while moving was very inconvenient.

### What I Did

I used AI integration to build an Apple Shortcut with the following flow:

1. Select translation direction (Chinese → Vietnamese / Vietnamese → Chinese)

   ![image-2.png](image-2.png)

2. Voice input

   ![image-3.png](image-3.png)

3. Speech-to-Text: Convert speech to text (Scribe API)

   ![image-4.png](image-4.png)

4. Send to LLM (ChatGPT API) for a translation that sounds more like "human speech"

5. Display the translation result, or read it out using the system voice

   ![image-5.png](image-5.png)

### Extension

After completing the translation tool, I extended the same voice input flow into:

- **Keyboard Tool**: Convert directly to text after speaking → Put into clipboard

- **Flash Note**: Organize into notes directly after speaking → Write to Apple Notes

---

## Telegram Post Hotspot Analysis Tool (Python) — Stop Browsing by Intuition Until You Drop

### Problem

Sometimes I want to quickly find out which posts in a certain Telegram Channel/Group have the "highest interaction / most emojis" to understand community hotspots and discussion trends, but searching manually is very inefficient.

### What I Did

I used AI collaboration to write a Python tool:

- Execute directly after exporting Channel data

- Automatically count Emojis / Interaction volume

- Output ranking results to quickly locate hotspot posts

![image-6.png](image-6.png)

### Results

Turned a process that used to take a lot of time to search into getting answers with just one analysis.

---

## Using AI to Enable "Voice Posting" for My Blog (Content Production Workflow Automation)

### Problem

I want to be able to quickly record thoughts and post them to the blog at any time, but the traditional process requires:
Sitting in front of a computer → Typing → Formatting → commit → Open MR → Publish\
This led to many of my ideas not being produced in the end.

### What I Did

I added AI to my content workflow:

- I just speak my thoughts using voice input

- AI helps organize them into publishable articles (bilingual support)

- Generate Merge Request

- I only need to quickly review and Approve before publishing

See article:
{{< article link="/en/tweets/writing-with-ai/" >}}

### Results

I successfully turned "writing" from a high-cost task into a low-friction, sustainable daily output process.
