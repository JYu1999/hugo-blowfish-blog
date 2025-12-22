---
title: "從 12 分鐘到 7 分鐘：我在兩天內將公司 CI 速度提升 43% 的實戰紀錄"
date: 2025-12-22T10:47:46+08:00
draft: false
tags: ["技術"]
---

## 結果

省流，先直接放上執行成果：

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image1.png" alt="執行成果" />

- CI 流程原平均時間（統計最近 5 次）：12 minutes 20 seconds
- CI 流程改善後平均時間（統計最近 3 次）：7 minutes 3 seconds

改善幅度：**42.84%**

## 緣起

我們公司一直以來都有 CI 流程，主要是在 Merge 之前，執行一些單元測試，和檢查套件是否過期之類的。

最近因為公司進行了一些人員異動，讓我明確感受到：「我們好像花很多時間在等 CI 流程結束。」

例如前後端共同開發時，前端要接 API，那就要後端的 Branch 先 Merge 進去才行。而就算後端已經做完，也需要等 CI 流程執行完。

或是後端一起開發，但有一個兩邊都需要的功能，且這個功能又不太好 Cherry Pick 出來，這時候也只好等另外一個人 Merge，然後又要等 CI 流程。

如果每次 CI 都能成功倒還好，有些時候是失敗，結果又要花時間 Debug，然後等待它重跑一次。

整體來看，CI 流程雖然有其好處，但目前來說會帶來很多的等待時間，而且影響的幅度可能會隨著團隊規模增加而愈來愈大。

最近我們剛好有一段「農閒時間」，於是我就主動跟主管提出，我想來優化 CI 流程試試看。

---

## 資源分析

在開始實作之前，先來對整個狀況進行盤點：

- 目前 CI 流程執行時間落在 11 \~ 13 min 左右

- 我只有 3 天的時間可以執行這個任務，而且愈快完成愈好

- 在此之前，我對 gitlab CI 完全 0 經驗



盤點完上述資源之後，我大概整理出了幾個方向：

- 因為時間和（我的）經驗有限，我只能專注於**影響最大**的和**最容易調整**的。有些需要深入研究 Gitlab CI 機制的調整，可能要先跳過。

- 我希望能減少 50 % 的 CI 時間

---

## CI 分析

### Job 流程

要優化 CI 速度，首先要知道的是目前究竟慢在哪裡。

因此我去看了最近兩次的 CI 流程，確認各個階段的時間。

因為怕涉及公司機密，這裡就不寫出實際 Log，只大概整理一下：

| Stage | Job 1 | Job 2 | 
|---|---|---|
| **Preparing the "docker" executor** | 14 | 13 | 
| **Preparing environment** | 0 | 0 | 
| **Getting source from Git repository** | 8 | 8 | 
| **Restoring cache** | 10 | 11 | 
| **Executing "step_script" stage of the job script** | 593 | 686 | 
| **Saving cache for successful job** | 48 | 36 | 
| **Cleaning up project directory and file based variables** | 1 | 0 | 
| **總計時長\*** | 11 minutes 17 seconds | 12 minutes 38 seconds | 

\*總計時長是取 Gitlab Pipeline 上面的 Duration，而不是把上面數字加總，所以可能會有些微誤差。

從上表可以明顯看到：瓶頸基本上就是 **Executing "step_script" stage of the job script**，因此這個就是主要要優化的目標。

### 主要瓶頸分析

一樣先來看看 **Executing "step_script" stage of the job script** 到底為什麼慢。首先來看那看哪裡面究竟做了什麼事情（下表由 AI 產生）：

| **階段** | **指令** | **詳細功能說明** | 
|---|---|---|
| **安全性檢查** | `sudo composer self-update --2` | 將 Composer 升級至第 2 版，確保相容性與安全性。 | 
|  | `composer config --global audit.abandoned report` | 設定 Composer 全域設定，遇到已被捨棄的套件時發出報告。 | 
|  | `composer audit` | 掃描 `composer.json` 中的套件是否有已知的安全漏洞。 | 
| **安裝依賴** | `composer install --prefer-dist...` | 安裝 PHP 後端套件，並優化安裝速度（不顯示進度條、不互動）。 | 
|  | `yarn install` | 安裝前端 JavaScript 依賴套件。 | 
| **資料庫基礎建設** | `sudo apt-get install -y mysql-client` | 在環境中安裝 MySQL 客戶端工具，以便執行 SQL 指令。 | 
|  | `mysql ... CREATE DATABASE...` | 建立 `testing` 與 `testing_sub` 兩個測試用資料庫。 | 
|  | `mysql ... CREATE USER...` | 建立一個名為 `user` 的資料庫使用者。 | 
|  | `mysql ... GRANT ALL PRIVILEGES...` | 賦予 `user` 對於兩個測試資料庫的所有操作權限。 | 
|  | `mysql ... < mysql_sub-schema.sql` | 將預先定義好的 SQL Schema 匯入到 `testing_sub` 資料庫。 | 
| **Laravel 環境設定** | `cp .env.testing.example .env` | 複製測試環境變數範本，產生正式的 `.env` 設定檔。 | 
|  | `php artisan key:generate` | 產生 Laravel 應用程式加密金鑰。 | 
|  | `php artisan config:cache` | 將設定檔寫入快取，以確保測試時讀取的是正確的環境變數。 | 
|  | `php artisan migrate --seed` | 執行資料庫遷移（建表）並寫入測試用的初始資料（Seeding）。 | 
| **執行測試** | `./vendor/phpunit/phpunit/phpunit...` | 執行 **PHPUnit** 進行後端功能測試，並將錯誤輸出至標準錯誤流。 | 
|  | `yarn test` | 執行前端測試（通常是 Jest 或 Vitest）。 | 

不過因為這裡面不是每個步驟都有寫時間，所以我這邊直接點出執行最久的，就是 **PHPUnit 測試**。

|  | Job 1 | Job 2 | 
|---|---|---|
| PHPUnit 測試時間 | 09:06.684 | 10:34.911 | 
| Stage 總時間 | 593 sec | 686 sec | 
| CI 流程總時間 | 11 minutes 17 seconds | 12 minutes 38 seconds | 
| 占 Stage 總時長比 | 92\.1% | 92\.6% | 
| 占 Job 總時長比 | 80\.6% | 83\.6% | 

很明顯 PHPUnit 就是這次 CI 優化的最主要目標。

### 為什麼 PHPUnit 慢？

所以為什麼 PHPUnit 會執行這麼久？

我嘗試在本地執行測試，基本上每個測試 Function，大概在 0.1s 以內就能執行完。但我發現有幾個 Test 異常的久：

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image2.png" alt="Test" />

這樣看就很明顯了，Feature Test 3 和 Feature Test 4 的執行時間完全不正常，另外 Feature Test 2 也有一個超過 6 秒的。

可別小看 6 秒，本地 6 秒到 Gitlab Runner 上，可能會被放大好幾倍。

我本地測試大概 130 秒左右就能執行完，相比上面執行 600 秒，差異高達 4 倍以上。

於是這些超過 6 秒的測試就成為我的首要優化目標。

至於 6 秒以內的，由於上面提到的「時間有限」，因此就不作為主要目標來執行。

---

## 實際優化

那我們就來一起看看，這些測試到底做了什麼事情，導致速度如此悲慘吧。

### Feature Test 3

我們先來看一下 Feature Test 3 做了什麼事情：

```php
<?php

class FeatureTest3
{
  use WithFaker, RefreshDatabase;
  
  public function warpUpCache()
  {
    // 建立資料並存入 Cache
  }

  public function setUp()
  {
    parent::setUp();

    // 清空 Cache

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

大概說明一下，這個被測試 Function，資料是去拿 Cache DB 裡面的。

所以我們在測試的時候，會用 Factory 建立資料並存入 DB，再存入 Cache，也就是 `warmUpCache()` 在做的事情。

而關鍵就在於，因為商業邏輯很複雜，所以 `warmUpCache()` 要建立的資料很多，導致每次執行都要很久。

那有沒有可能優化 `warmUpCache()` 呢？有可能，但裡面商業邏輯很複雜，時間限制下很難做到。

此時我的思考方向變成：既然無法優化 `warmUpCache()` 本身的速度，那是否可以減少其執行的次數呢？經過一番研究之後我發現：

1. 因為資料是直接從 Cache 拿，和 DB 無關

2. 每個 Test Function 要測試的東西是獨立的

所以每個 Test 都去 Refresh Database、執行 Seeder、清空 Cache、重新產生 Cache 根本就是多餘的步驟。

於是我寫了一個邏輯：

```php
<?php

class FeatureTest3
{
  use WithFaker, RefreshDatabase;

  protected static array $warmedUpCaches = [];
  
  public function warpUpCache()
  {
    // 若已經暖機過且 Redis 仍然有對應快取，就直接取得目前 Redis 內的版本，
    // 並搭配先前計算好的標籤集合，避免重複建資料與跑 Command
    if (isset(self::$warmedUpCaches[$group]) && $redis->exists($cacheVersionKey)) {
        $cacheVersion = $redis->get($cacheVersionKey);

        return [
            $cacheVersion,
            self::$warmedUpCaches[$group],
        ];
    }
    
    // 建立資料並存入 Cache
  }

  public function setUp()
  {
    parent::setUp();

    // 清空 Cache -> 改成不清空 Cache，所有 Function 共用

    // withoutMiddleware
    
    // Seeder
  }
}
```

ok，來看看結果差多少吧～！

```xml
  
 PASS  Tests\Feature\FeatureTest3
✓ ...                                                                                                               3.05s  
✓ ...                                                                                                               0.18s  
✓ TestFunction3                                                                                                    7.13s  
✓ TestFunction4                                                                                                    6.87s  
✓ TestFunction5                                                                                                    0.14s  
✓ TestFunction6                                                                                                    0.13s  
✓ TestFunction7                                                                                                    0.13s  
```

基本上從 34s 縮短到 17.5 秒，縮短幅度接近一半！

那實際 CI 流程呢？看了一下 Pipeline，時間縮短為 9 minutes 13 seconds，和原本平均 12 minutes 20 seconds 差異超過 3 分鐘。

{{< alert >}}
注意：這種做法雖然能大幅加速，但若測試案例中有修改到這些快取內容的操作，可能會導致其他測試失敗。在實作時需確保快取資料是 Read-only 或具備良好的隔離性。
{{< /alert >}}

可能有人會問：欸還有兩個 Test 超過 6 秒欸。這邊因為涉及比較多商業邏輯，所以就不特別解釋，只能說這個是預期內的結果。

這個測試的優化就先暫時告一段落，當然眼尖的讀者會發現：那 Refresh DB 和 Seeder 重複執行的問題還沒解決啊？

但如同我一直強調的前提：我時間有限，所以應該先針對那些影響最大的議題。

在這個測試，看起來 Refresh DB 和 Seeder 造成的影響沒有到很大，所以就暫時先忽略。

### Feature Test 4

ok，接下來看 Feature Test 4，一樣先了解一下大致的架構：

```php
<?php

class FeatureTest4
{
  use WithFaker, RefreshDatabase;

  public function setUp()
  {
    parent::setUp();

    // 清空 Cache

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
    // 清空 Search Engine

    // 建立資料
    
    // 存入 Search Engine

    // Sleep 5 seconds
  }
}
```

看起來和 Feature Test 3 很像，應該可以直接套用 Feature Test 3 的解法？

很遺憾，答案是不行。因為這個待測 Function 有涉及實際資料庫處理，如果改成單純從 Search Engine 拿資料，那測試會錯。

不過有了上面的經驗，我們應該可以直接發現，每個 Function 都要執行 `warmUpSearchEngine()`，那問題一定就是出在這個 Function！

果不其然在裡面看到了 `sleep(5)` 這個奇怪的邏輯，每個測試都要強制睡 5 秒，這個不慢才奇怪。除了睡 5 秒以外，建立資料也是花了不少時間。

那可以把 `sleep(5)` 拿掉嗎？很可惜不行，是因為 import 到搜尋引擎的操作是異步的，所以上面 `存入 Search Engine` 執行完，不代表資料已成功同步到搜尋引擎內，會需要等待一小段時間讓搜尋引擎完成 import job。

拿掉不行，那可以縮短嗎？很可惜也不行，如果再繼續縮短的話，那有機率來不及 import。

那建立資料可以重構嗎？跟 Feature Test 3 一樣，這裡建立資料的邏輯很複雜，很難優化。

ok，那要走老路了，有可能盡可能減少 `warmUpSearchEngine()` 的執行次數嗎？

答案是可以的！原因是因為雖然每個測試都會依賴資料庫，但每個測試是獨立的，所以用一模一樣的資料沒關係！

所以我進行了簡單的重構：

```php
<?php

class FeatureTest4
{
  use WithFaker, RefreshDatabase;

  public function setUp()
  {
    parent::setUp();

    // 清空 Cache

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
    // 清空 Search Engine

    // 建立資料
    
    // 存入 Search Engine

    // Sleep 5 seconds
  }
}
```

把所有的 Test Function 寫進同一個 Function，就可以最簡單暴力的解決了～！

來看一下實際優化多少吧：

```php
 PASS  Tests\Feature\FeatureTest4
✓ all                                                                                                                                           11.75s  

Tests:    1 passed (1819 assertions)
Duration: 12.02s
```

直接從 42 秒優化成 12 秒，差距接近 30 秒。

線上的話從 Feature Test 3 優化完的結果（9 minutes 13 seconds），變成 7 minutes 51 seconds，又減少了接近 1.5 分鐘！

可能有厲害的工程師會說：這什麼鬼，到時候錯誤不是很難看出來嗎？

這個我也有想到，但還是選擇這個做法的原因是：

- 這個待測試 Function 很少動，我進公司兩年多從來沒改過

- 這個測試會錯，通常是 Search Engine 本身的問題，不是邏輯的問題

- 公司目前正在進行一系列的重構，這個待測試 Function 極有可能被淘汰

基於上述兩個原因，再綜合評估我可以執行這個任務的時間、後續效益，我覺得後續 Debug 的風險遠小於其效益，且這個風險也不值得我花時間去處理。

### Feature Test 2

其實很單純，主要是 `TestFunction2` 裡面執行了：

```php
<?php
public function testFunction2()
{
    // ...略
    $creators = Creator::factory()->count(301)->create();

    // ...略
}
```

為什麼這行會這麼久？主要是因為 Creator 會有很多其他的關聯資料，會由 Factory 一併建立出，這部分涉及公司的核心商業邏輯，暫時無法變動。

那再來就是為什麼需要建立這麼多創作者？是因為待測試 Command 裡面有個邏輯是要測試只取得資料庫的前 300 筆資料。

```php
<?php
Creator::where(xxx)
->limit(300)
->get()
```

對這個測試，其實我想了蠻多方式重構，但都因為一些原因無法執行：

- 不實際建立資料：這個不行，因為這樣就測不到待測試 Command 

- 跟其他 Function 建立 Creator 的部分整合：因為這個 Test 的其他 Function 也有建立一些 Creator，那是不是可以大家共用？這個後來也被我自己否決了，原因是這樣重構蠻複雜的，而且各個 Function 可能會耦合在一起。

那怎麼辦呢？

……

此時我突然靈光一現：是不是可以考慮移除這個測試？

為什麼這樣說呢？因為其實這個測試的邏輯是大幅和其他測試重複的，唯一的差異就是這個 300 的 Limit。

所以看起來的好處就只有：避免別人改到這個 300 的 Limit？

但這裡改到看起來也不會有任何影響，因為我去看前端的程式碼，也沒有對 300 這個 Limit 進行任何的依賴。我們公司也沒有任何的文件說明這個 300 是商業邏輯。

所以這個數字看起來只是當時的開發者隨手所訂而已。

為求安全起見，我也找了公司的 Senior 工程師 Double Check，確認移除這個 Test 的影響。

於是經過評估之後，最後將這個測試刪除了。

優化的結果是：

- 本地從 6.21 秒變成 0 秒

- 線上的話從 Feature Test 4 優化完的結果（7 minutes 51 seconds），變成 7 minutes 07 seconds，又減少了 45 秒左右！

---

## 結語

至此優化暫時結束，從原本的 12.5 分鐘左右，大幅減低至 7 分鐘出頭。

不知道讀者覺得如何，歡迎跟我分享XD

這是我第一次執行 CI 優化的任務，老實說蠻好玩的。

而身為開發者，不只是好玩而已，我知道 CI 速度優化可以提高整個開發團隊的效能。

在過程中讀者應該也能發現，「資源分析」對我來說是一個很重要的環節：**先認清自己有多少時間、自己的能力，然後挑選那些最核心的問題去解決**。

我認為在盡可能短的時間裡面交付價值，是工程師很重要的一個能力，也是面對這個高度變化的世界的一種好方法。


<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image3.png" alt="Mindset" />

---

## 未來展望

有一些在過程中我有 Survey 到的做法，但我自己評估後覺得效益相對還好，而且比較複雜。這邊紀錄一下：

- 改善 Job：似乎是可以把前後端測試拆開來，進行平行處理。但其實前端測試才 3 秒左右，我覺得拆分效益極低。

- 測試平行處理：讓 PHP 所有測試用不同的 Process 去處理，但因為舊有技術債，我們不少測試都有操作資料庫，這個方式可能會出問題（但我沒實際測試）

- Migration Dump：應該可以發現我們使用了一些 Refresh Database，每次都會重新執行 Migration，而我們 Migration 有 100 多個，所以執行會花一些時間。但這個因為一些技術問題，而且實際測試收益沒有預想中的大，所以最終沒有採用。
