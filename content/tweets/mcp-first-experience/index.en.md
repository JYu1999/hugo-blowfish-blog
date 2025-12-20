---
title: "First Experience with MCP"
date: 2025-12-20T9:00:00+08:00
draft: false
tags:
    - AI
---

Recently, I had a need: I wanted to polish my resume.

However, the awkward part is that during my first two years at this company, I didn't diligently record my work.

So, if someone asked me, "What kind of issues did you resolve at your previous company?"

I could only respond with, "Uh..."

Coincidentally, I've been wanting to try MCP (Model Context Protocol) for a while but never had a practical need for it. So, I decided to see if MCP could help with this.

My idea was simple: use a local MCP Client to access Jira and GitLab MCP Servers, then ask an AI to analyze the issues I've solved and organize them into a resume format.

---

## Jira

### Antigravity

The first one I tried was Antigravity, simply because I've been using it a lot lately.

Connecting Antigravity to Jira is very straightforward. In the Agent screen, select **MCP Servers**, choose **Atlassian**, and complete the OAuth authentication.

### Cursor

Next, I tried Cursor. Based on my experience with Antigravity, I simply copied the configuration.

You can find **Manage MCP Servers** in the MCP Store, then click **View Raw Config** to find `mcp_config.json`.

Go to Cursor settings, find **New MCP Server**, and fill in the configuration:

```json
{
  "mcpServers": {
    "atlassian-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.atlassian.com/v1/sse"
      ],
      "env": {}
    }
  }
}
```

---

## GitLab

GitLab officially seems to still be testing MCP, so the setup is more complex. I had to use a community-developed one called `@zereight/mcp-gitlab`.

For the specific installation process, please refer to: [zereight/gitlab-mcp](https://github.com/zereight/gitlab-mcp/blob/main/docs/oauth-setup.md)

However, I should point out that this MCP has quite a few tools. If you're working on important projects, I recommend turning off dangerous permissions like Create, Update, and Delete to avoid accidental triggers.

The installation for Antigravity and Cursor is similar, so I won't go into detail.

---

## Testing

Since it was just a test, I wrote a rather casual prompt:

```
I am JYu.

I have been working at company xxx for n years and am preparing my resume.

I need you to use Jira MCP and GitLab MCP to help me organize and analyze all the projects I've worked on during this period, so I can prepare my resume.
```

I first tried it with Cursor, but it ran out of context immediately XD.

Then I switched to Antigravity using Planning mode + Gemini 1.5 Flash, and here is the result:

### Final Result

#### Career Summary: JYu (Software Engineer @ xxx)

Analytical and impact-driven Software Engineer with n years of experience at xxx. Expertise in backend development (PHP/Laravel), DevOps automation, and technical security. Lead contributor to critical infrastructure and financial modules.

##### 🚀 Key Impact Areas

###### 1. DevOps & Infrastructure Optimization

- **CI/CD Pipeline Acceleration**: Directed initiatives to optimize CI/CD workflows, significantly reducing build and deployment times.
- **Deployment Automation**: Developed and integrated robust deployment scripts (`deploy.sh`, `reload-app.sh`) and automated database migration triggers to enhance system stability during releases.
- **Server Lifecycle Management**: Orchestrated server transitions and handled infrastructure updates (SRE tasks) before transitioning to backend lead roles.

###### 2. Financial & Payment Systems
- **Complex Withdrawal Logic**: Designed and implemented the "Creator Withdrawal System," including automated withdrawal processing and tax-compliant exports (Withholding Tax).
- **Payment Stability**: Monitored and fixed critical payment/refund failures, ensuring high reliability for financial transactions.
- **Architecture Refactoring**: Decoupled business logic from report export modules, centralizing domain logic in Services to improve maintainability and scalability.

###### 3. Security & Compliance
- **CVE Mitigation**: Identified and patched security vulnerabilities, including CVE-2025-14761 (Key Commitment Issue in AWS SDK for PHP), protecting S3-based encrypted assets.
- **Invoice & Taxation**: Built systems for order invoice processing and taxation module verification, ensuring financial compliance for the platform.

###### 4. Product & Feature Engineering
- **Domain Modeling**: Refined product taxonomy and tagging systems to support complex content discovery.
- **V3 Platform Transition**: Contributed to the backend architecture for the next-generation creator application flow.

##### 🛠 Technical Stack
- **Languages & Frameworks**: PHP, Laravel, Bash.
- **Integrations**: AWS SDK (S3, Encryption), Payment Providers (Ecpay, etc.), Spout (Exporters).
- **Tools**: Jira, GitLab CI/CD, Confluence (Technical documentation/Whiteboarding).

##### 🏆 Notable Jira/GitLab Projects
- **xxx project (Main Platform)**: Heavy focus on financial reliability and security.
- **xxx Deploy Script**: Standalone toolset for platform maintenance.
- **CatalystV3**: Next-generation platform development.

---

## Conclusion

I wonder what you think of the result? XD

Personally, I think it's a bit subpar, but then again, I didn't put much effort into the prompt. With the right "tuning," it definitely feels promising.

The reason I hadn't wanted to try MCP before was that I felt it only saved some Copy & Paste time without providing much substantial help.

In fact, using the "traditional" ChatGPT approach—manually copying relevant information to the model—often feels more efficient because it prevents the model from looking at too many unnecessary files or engaging in meaningless reasoning.

However, for scenarios like "summarizing a resume" where there is a lot of context and I don't even know how much "relevant information" there is, MCP seems perfectly suited for the task.

Overall, it was an interesting little experiment. I probably won't use MCP very often in the short term, but I'll think about more suitable use cases for it.
