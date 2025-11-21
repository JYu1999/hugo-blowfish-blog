---
title: "OWASP Top 10(1) - Broken Access Control"
date: 2025-08-24T10:47:46+08:00
draft: false
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

## Preface

I wrote an article about information security a while back, and it suddenly occurred to me that I had never systematically studied common security issues; I had always learned directly through practical experience.

So, I wanted to dedicate some time to supplementing my knowledge in this area.

I happened to see someone recommend the website [Hacksplaining](https://hacksplaining.com/), so I thought, "Let's start with the OWASP Top 10!"

Therefore, this series of articles will mainly be a compilation of my research into the OWASP Top 10. I will also organize my experience as a Laravel backend engineer to try and draw some connections with Laravel.

## What is Broken Access Control?

Broken Access Control is a regular feature of OWASP, even reaching the number one spot in 2021, which shows its importance.

Simply put, Broken Access Control means "users are able to do things they shouldn't be able to do."

Applications should strictly limit which information users can access or which functions they can execute based on their identity and permissions.

When these restriction measures are flawed or can be easily bypassed, it is called Broken Access Control.

## Example

Let's use a simple example to illustrate.

Imagine a company website manager whose job is to publish the company's financial reports, press releases, and related information.

This information must be made public simultaneously at a specified time to avoid accusations of insider trading.

Because work can be busy, they cannot always manually publish at the exact time, so they built a "Scheduled Publishing" feature. This means the information is uploaded to the company website beforehand, but users can only see the link in the information list after the designated time arrives.

However, the URL for each piece of information follows a fixed pattern. For example, the URL for the quarterly financial report might always be:

```php
https://example-company/reports/2025-Q2.pdf
````

Malicious actors can exploit this vulnerability to try and obtain the information they want.

For instance, a few days before the scheduled release date of the 2025 Q3 financial report—even though the information is not yet visible in the list—I could try accessing:

```php
https://example-company/reports/2025-Q3.pdf
```

I could do this to see if I can obtain the relevant information in advance.

Of course, obtaining information by modifying the URL is just one common way Broken Access Control manifests.

Other possibilities include users being able to modify their own identity to become an Admin, and so on.

## Defense Strategies

Seeing the example above, some might say: "Then why don't I just make the URL unpredictable?"

For example, you could turn the URL into a string of random characters, which indeed increases the difficulty of guessing correctly.

However, experienced individuals might attempt brute force attacks or even try to crack the encoding method. In the end, the information could still leak. Therefore, this is considered a "security by obscurity" approach—treating the symptoms but not the root cause.

A more complete defense strategy includes three components:

### 1\. Authentication

Accurately identifying the user's identity every time they return to the application. This is the starting point for all permission management.

### 2\. Authorization

After the user passes authentication, the system needs to decide which operations that user is allowed or not allowed to perform.

### 3\. Access Control Check

At the moment a user attempts to execute a specific operation, the system must immediately assess their authorization status to confirm whether the operation is permitted.

## Common Implementation Methods for Authorization

So, on what basis should the system decide whether a user can execute certain operations? Here are some common methods:

### 1\. Role-based

This is the most common authorization method. It distinguishes permissions by assigning a specific role to each user (e.g., "Administrator" vs. "General User").

### 2\. Ownership-based Authorization

Certain resources belong to specific users or groups. Without their permission, others cannot access them.

### 3\. Policy-based Authorization

Access control schemes are often defined in the form of "Policies," which explicitly define which entities or groups can (whitelist) or cannot (blacklist) execute specific operations.

In more complex scenarios, we might need to set different permissions for individual files or data. In such cases, a more refined and specific permission management scheme must be implemented.

## Four Guiding Principles for Design and Implementation

As software engineers, what should we think about before implementation? Or what should we pay attention to during implementation?

### 1\. Assess and Focus on the Greatest Risks

We all understand the concept that "too much is as bad as too little," and the same applies to permissions. Handling permissions too early can just complicate business logic and increase maintenance costs unnecessarily.

A better approach is: Identify what data in the product or organization "absolutely must not" be leaked or accessed, and prioritize your efforts on handling those.

As for information that wouldn't have severe consequences even if leaked, you can deal with it a bit later.

### 2\. Design and Document in Advance

After defining what is important, it is best to design and document it in the early stages of development.

When designing permissions, it is best to confirm requirements frequently with the PM. If there isn't a commonly agreed-upon set of rules, it is very difficult to define what a "correct" implementation is.

I find documentation particularly important. Sometimes access control exists only in the Codebase. The company PM, or even the engineers themselves, may not be clear on how permissions are currently defined, leading to a need to re-check the Codebase every time, which actually wastes time.

### 3\. Attempt to Centralize Authorization Decisions

You should attempt to manage access control decision logic centrally within the codebase.

This doesn't mean all requests must pass through a single code path, but rather that a standard method for assessing permissions should be established. Examples include using function decorators, route checks, database stored procedures, or calling specialized authorization components.

For example, in Laravel, "non-centralized management" might look like this:

In `PostController.php`'s `update` method:

```php
<?php
public function update(Request $request, Post $post)
{
    // Check 1: Is the user the author?
    // Check 2: Or, is the user an admin?
    if (Auth::id() !== $post->user_id && Auth::user()->role !== 'admin') {
        abort(403, 'Unauthorized action.');
    }

    // ...logic to update the post...
}
```

In `PostController.php`'s `destroy` method:

```php
<?php
public function destroy(Post $post)
{
    // Repeating almost the exact same logic again
    if (Auth::id() !== $post->user_id && Auth::user()->role !== 'admin') {
        abort(403, 'Unauthorized action.');
    }

    // ...logic to delete the post...
}
```

In the view `show.blade.php`, deciding whether to show the edit button:

```php
@if (Auth::id() === $post->user_id || (Auth::check() && Auth::user()->role === 'admin'))
    <a href="/posts/{{ $post->id }}/edit">Edit Post</a>
@endif
```

What are the potential problems here?

1.  **Duplication**: The same permission check logic is scattered across multiple places like Controllers and Views.
2.  **Hard to Maintain**: If you want to add a "Chief Editor" who can also modify articles, you have to find all these `if` statements and modify them one by one, which makes it very easy to miss something.
3.  **Prone to Error**: If you forget to add a check in just one place, it creates a serious security vulnerability.

Therefore, Laravel provides **Gates** and **Policies** to centrally manage authorization logic. A concrete implementation might look like this:

1.  First, create a centralized "Rule Book." Here we use `PostPolicy.php` as an example.

    ```php
    <?php


    class PostPolicy
    {
        // Define the rule for "update post"
        public function update(User $user, Post $post): bool
        {
            // Rule 1: User is the post author
            // Rule 2: Or, user is an admin
            return $user->id === $post->user_id || $user->role === 'admin';
        }

        // Define the rule for "delete post"
        public function delete(User $user, Post $post): bool
        {
            // The rule can be the same as update, or different
            return $user->id === $post->user_id || $user->role === 'admin';
        }
    }
    ```

2.  Use these centralized rules in different places.

    ```php
    <?php
    public function update(Request $request, Post $post)
    {
        // Laravel will automatically find PostPolicy and call the update method
        // If the rule fails, it automatically throws a 403 error
        $this->authorize('update', $post);

        // ...logic to update the post...
    }

    public function destroy(Post $post)
    {
        // Similarly, call the centralized delete rule
        $this->authorize('delete', $post);

        // ...logic to delete the post...
    }
    ```

    ```html
    {{-- Laravel will automatically use PostPolicy to judge --}}
    @can('update', $post)
        <a href="/posts/{{ $post->id }}/edit">Edit Post</a>
    @endcan
    ```

    ```php
    <?php
    // Only users who pass the PostPolicy update rule can access this route
    Route::put('/posts/{post}', [PostController::class, 'update'])
        ->middleware('can:update,post');
    ```

### 4\. Test Strictly and Critically

The testing process must genuinely attempt to find loopholes in the access control scheme. Thinking and testing like an attacker is the only way to prepare for real attacks. If budget and time allow, consider hiring an external team to perform penetration testing.

## Conclusion

Broken Access Control is a concept that one encounters early on when learning computer science, but I had never really understood it systematically.

While reading about it, I kept thinking of the permission design in SELinux, and also realized that some tools in Laravel were born from these very concepts. It has given me a better understanding of the reasoning behind them.

I hope this is helpful to everyone\!
