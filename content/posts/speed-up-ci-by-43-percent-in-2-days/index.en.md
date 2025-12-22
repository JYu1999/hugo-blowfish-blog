---
title: "From 12 Minutes to 7 Minutes: A 43% CI Speedup in Two Days"
date: 2025-12-22T10:47:46+08:00
draft: false
tags: ["Technical"]
---

{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}

## Result

Skip the suspense—here are the numbers first:

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image1.png" alt="執行成果" />

- CI average before (last 5 runs): 12 minutes 20 seconds
- CI average after (last 3 runs): 7 minutes 3 seconds

Improvement: 42.84%

## Why I Did This

We’ve always had a CI pipeline that runs unit tests and checks for outdated packages before merges.

Recently, some team changes made the CI wait feel painful. For example, when frontend needs backend APIs, the backend branch has to merge first—and even if the code is ready, we still wait for CI. Sometimes CI fails and we debug and rerun, adding more wait time. The larger the team, the worse the delays.

We hit a short “off-season,” so I pitched my manager on optimizing CI.

---

## Resource Check

Before touching code, I took stock:

- Current CI runtime: ~11–13 minutes
- I had 3 days for this task (the sooner, the better)
- I had zero experience with GitLab CI

With that, I set some principles:

- Focus on the biggest and easiest wins; skip anything requiring deep GitLab CI knowledge for now.
- Aim for a 50% reduction in CI time.

---

## CI Analysis

### Job Timeline

To speed things up, I needed to know where time was spent. I reviewed the last two CI runs and summarized the stages (times are representative):

| Stage | Job 1 | Job 2 | 
|---|---|---|
| **Preparing the "docker" executor** | 14 | 13 | 
| **Preparing environment** | 0 | 0 | 
| **Getting source from Git repository** | 8 | 8 | 
| **Restoring cache** | 10 | 11 | 
| **Executing "step_script" stage of the job script** | 593 | 686 | 
| **Saving cache for successful job** | 48 | 36 | 
| **Cleaning up project directory and file based variables** | 1 | 0 | 
| **Total duration\*** | 11 minutes 17 seconds | 12 minutes 38 seconds | 

\*Total duration uses the GitLab Pipeline “Duration,” so there may be slight differences from summing the numbers.

Clearly, the bottleneck is **Executing "step_script" stage of the job script**. That’s where we should focus.

### Main Bottleneck

I dug into the **Executing "step_script" stage** to see what it actually does (AI-generated outline below):

| **Phase** | **Command** | **What it does** | 
|---|---|---|
| **Security checks** | `sudo composer self-update --2` | Upgrade Composer to v2 for compatibility and security. | 
|  | `composer config --global audit.abandoned report` | Set Composer to report abandoned packages. | 
|  | `composer audit` | Scan `composer.json` dependencies for known vulnerabilities. | 
| **Install deps** | `composer install --prefer-dist...` | Install PHP backend deps with faster flags (no progress bar, non-interactive). | 
|  | `yarn install` | Install frontend JS deps. | 
| **DB setup** | `sudo apt-get install -y mysql-client` | Install MySQL client for running SQL. | 
|  | `mysql ... CREATE DATABASE...` | Create two test DBs: `testing` and `testing_sub`. | 
|  | `mysql ... CREATE USER...` | Create DB user `user`. | 
|  | `mysql ... GRANT ALL PRIVILEGES...` | Grant full privileges on the test DBs. | 
|  | `mysql ... < mysql_sub-schema.sql` | Import schema into `testing_sub`. | 
| **Laravel env setup** | `cp .env.testing.example .env` | Copy env template. | 
|  | `php artisan key:generate` | Generate app key. | 
|  | `php artisan config:cache` | Cache config. | 
|  | `php artisan migrate --seed` | Run migrations and seed test data. | 
| **Run tests** | `./vendor/phpunit/phpunit/phpunit...` | Run PHPUnit; pipe errors to stderr. | 
|  | `yarn test` | Run frontend tests (Jest/Vitest). | 

Not every step had timings, so I singled out the biggest chunk: **PHPUnit tests**.

|  | Job 1 | Job 2 | 
|---|---|---|
| PHPUnit time | 09:06.684 | 10:34.911 | 
| Stage total | 593 sec | 686 sec | 
| CI total | 11 minutes 17 seconds | 12 minutes 38 seconds | 
| Share of stage time | 92.1% | 92.6% | 
| Share of job time | 80.6% | 83.6% | 

PHPUnit is the primary target.

### Why Is PHPUnit Slow?

Locally, most test methods finish under 0.1s, but some are abnormally slow:

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image2.png" alt="Test" />

Feature Test 3 and 4 are wildly slow, and Feature Test 2 has a 6s case. A “mere” 6 seconds locally can balloon on GitLab runners. I finish locally in ~130s vs. ~600s on CI—a >4x difference. The 6s+ tests became my top targets; anything under 6s wasn’t prioritized due to time limits.

---

## Optimization in Practice

Let’s see what made those tests so slow.

### Feature Test 3

Structure overview:

```php
<?php

class FeatureTest3
{
  use WithFaker, RefreshDatabase;
  
  public function warpUpCache()
  {
    // Build data and store in cache
  }

  public function setUp()
  {
    parent::setUp();

    // Clear cache

    // withoutMiddleware
    
    // Seeder
  }

  public function testFunction3()
  {
    $caches = $this->warpUpCache();

    // assert
  }

  public function testFunction4()
  {
    $caches = $this->warpUpCache();

    // assert
  }

  public function testFunction5()
  {
    $caches = $this->warpUpCache();

    // assert
  }

  public function testFunction6()
  {
    $caches = $this->warpUpCache();

    // assert
  }

  public function testFunction7()
  {
    $caches = $this->warpUpCache();

    // assert
  }
}
```

The function under test reads from a cache DB. During tests, we build data via factories, store in DB, then cache—done in `warmUpCache()`. Because of complex business logic, `warmUpCache()` builds a lot of data and is slow. Optimizing it directly is hard within time limits, so I looked at reducing how often it runs:

1. Data comes from cache, not DB.
2. Each test method is independent.

So refreshing DB, seeding, clearing cache, and rebuilding cache for every test is wasteful. I added a cache reuse mechanism:

```php
<?php

class FeatureTest3
{
  use WithFaker, RefreshDatabase;

  protected static array $warmedUpCaches = [];
  
  public function warpUpCache()
  {
    // If already warmed and Redis still has the cache, reuse it
    if (isset(self::$warmedUpCaches[$group]) && $redis->exists($cacheVersionKey)) {
        $cacheVersion = $redis->get($cacheVersionKey);

        return [
            $cacheVersion,
            self::$warmedUpCaches[$group],
        ];
    }
    
    // Build data and store in cache
  }

  public function setUp()
  {
    parent::setUp();

    // Stop clearing cache; share across functions

    // withoutMiddleware
    
    // Seeder
  }
}
```

Results:

```xml
 PASS  Tests\Feature\FeatureTest3
✓ ...                                                                           3.05s  
✓ ...                                                                           0.18s  
✓ TestFunction3                                                                 7.13s  
✓ TestFunction4                                                                 6.87s  
✓ TestFunction5                                                                 0.14s  
✓ TestFunction6                                                                 0.13s  
✓ TestFunction7                                                                 0.13s  
```

Runtime dropped from ~34s to ~17.5s—almost half. CI time fell from ~12m20s to 9m13s (over 3 minutes saved).

{{< alert >}}
Note: This boosts speed but risks cross-test contamination if any test mutates cache contents. Use only when cache data is read-only or well-isolated.
{{< /alert >}}

Two tests still exceed 6s; that’s expected due to business logic. Refresh DB and seeder repeats remain, but they weren’t the biggest pain here, and time was limited.

### Feature Test 4

Structure:

```php
<?php

class FeatureTest4
{
  use WithFaker, RefreshDatabase;

  public function setUp()
  {
    parent::setUp();

    // Clear cache

    // withoutMiddleware
    
    // Seeder

    $this->warmUpSearchEngine();
  }

  public function testFunction8()
  {
    // assert
  }

  public function testFunction9()
  {
    // assert
  }

  public function testFunction10()
  {
    // assert
  }

  public function testFunction11()
  {
    // assert
  }

  public function testFunction12()
  {
    // assert
  }

  public function warmUpSearchEngine()
  {
    // Clear search engine

    // Build data
    
    // Store into search engine

    // Sleep 5 seconds
  }
}
```

Looks similar to Feature Test 3—reuse trick? Unfortunately no, because the function under test depends on real DB operations; using cached-only data would break correctness. But the pain is obvious: every test calls `warmUpSearchEngine()`, which includes a `sleep(5)` to wait for async import. Shortening or removing it isn’t safe. Data setup is complex as well.

Could we reduce how often `warmUpSearchEngine()` runs? Yes, because tests are independent and can share identical fixture data. I collapsed the test methods into one:

```php
<?php

class FeatureTest4
{
  use WithFaker, RefreshDatabase;

  public function setUp()
  {
    parent::setUp();

    // Clear cache

    // withoutMiddleware
    
    // Seeder

    $this->warmUpSearchEngine();
  }

  public function testAll()
  {
    $this->assertFunction8();
    $this->assertFunction9();
    $this->assertFunction10();
    $this->assertFunction11();
    $this->assertFunction12();
  }
  
  public function assertFunction8()
  {
    // assert
  }

  public function assertFunction9()
  {
    // assert
  }

  public function assertFunction10()
  {
    // assert
  }

  public function assertFunction11()
  {
    // assert
  }

  public function assertFunction12()
  {
    // assert
  }

  public function warmUpSearchEngine()
  {
    // Clear search engine

    // Build data
    
    // Store into search engine

    // Sleep 5 seconds
  }
}
```

All checks live in one test, so `warmUpSearchEngine()` runs once.

Results:

```php
 PASS  Tests\Feature\FeatureTest4
✓ all                                                                                                                                           11.75s  

Tests:    1 passed (1819 assertions)
Duration: 12.02s
```

From ~42s to ~12s—about 30s saved. CI dropped from 9m13s (after Feature Test 3) to 7m51s—another ~1.5 minutes.

Is this harder to debug? Possibly, but I accepted it because:

- This function rarely changes; I haven’t touched it in 2+ years.
- Failures usually come from the search engine, not business logic.
- The company is mid-refactor; this function may be sunset soon.

Given time constraints and payoff, the risk felt small.

### Feature Test 2

The slow part:

```php
<?php
public function testFunction2()
{
    // ...snip
    $creators = Creator::factory()->count(301)->create();

    // ...snip
}
```

Why so slow? `Creator` has many related records created by the factory—core business logic we can’t change right now.

Why 301 creators? The command under test fetches the first 300 rows:

```php
<?php
Creator::where(xxx)
->limit(300)
->get()
```

I considered refactors but hit dead ends:

- Skip creating data: wouldn’t test the command properly.
- Share creators with other functions: too complex; risks coupling tests.

Then it clicked: could we drop this test? Its logic largely duplicates other tests; the only unique piece is the “limit 300.” No frontend dependency or documented business rule ties to 300. Likely just an arbitrary number. I double-checked with a senior engineer; we agreed removal was safe.

Results:

- Local: 6.21s → 0s
- CI: 7m51s → 7m07s (about 45s saved)

---

## Wrap-Up

We cut CI from ~12.5 minutes to a little over 7 minutes.

My first CI-optimization task turned out fun and impactful. The key takeaway is “resource analysis”: **know your time and skills, then hit the highest-leverage issues first**. Deliver value fast—that’s critical for engineers in a fast-moving world.

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image3.png" alt="Mindset" />

---

## Future Ideas

Things I surveyed but skipped due to lower ROI or complexity:

- Split jobs: e.g., separate frontend/backend tests to run in parallel. Frontend tests take ~3s, so gains are tiny.
- Parallelize PHP tests: run in multiple processes. But many tests touch the DB; might get flaky (untested).
- Migration dump: avoid rerunning 100+ migrations by using dumps. Technical hurdles and smaller-than-expected gains, so deferred.

