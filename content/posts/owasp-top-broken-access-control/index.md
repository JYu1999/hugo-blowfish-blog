---
title: "OWASP Top 10 - Broken Access Control"
date: 2025-08-24T10:47:46+08:00
draft: false
---

## 前言

前一陣子寫了一篇有關資安的文章，我才突然想到我從來沒有系統性的去了解常見的資安問題，都是直接在實務經驗中學習XD

所以想花一些多少補充一些這方面的知識。

剛好又看到有人推薦了 [Hacksplaining](https://hacksplaining.com/) 這個網站，就想說「那就從 OWASP Top 10」開始吧！

所以這一系列的文章，主要就是我研究 OWASP Top 10 的一些整理，然後也會統整我身為一個 Laravel 後端工程師的經驗，嘗試和 Laravel 做一些關聯～

## 什麼是 Broken Access Control

Broken Access Control 是 OWASP 的常客了，在 2021 年登頂第一名，可見其重要程度。

簡單來說，Broken Access Control 就是「使用者能做到他們不應該做到的事情」。

Application 應該要能根據使用者的身份和權限，嚴格限制他們可以存取哪些資訊或執行哪些功能。

當這些限制措施存在缺陷、可以被輕易繞過時，就稱為 Broken Access Control。

## 範例

舉個簡單的例子來說明。

今天有一個公司的網站管理人員，他的工作是發布公司的財報、新聞稿等相關資訊。

這些資訊必須在指定時間內，同時公開，以避免內線交易的指控。

因為有時候工作繁忙，沒辦法都在指定的時間手動發布，於是他們做了一個「預定發布」的功能。也就是資訊會先放到公司網站上，但只有時間到了之後，使用者才能在資訊列表看到連結。

而每份資訊的 URL，有固定的編排方式，例如每季財報的 URL，都會是：

```php
https://example-company/reports/2025-Q2.pdf
```

有心人士就可以利用這個漏洞，來嘗試獲取自己想要的資訊。

例如我在 2025 Q3 財報預訂公布日期的前幾天，雖然資訊列表上面還不能看到該資訊，但我可以嘗試用：

```php
https://example-company/reports/2025-Q3.pdf
```

來看看能不能提前獲取相關資訊。

當然透過修改網址來獲取資訊，只是 Broken Access Control 的其中一個常見的方式。

其他可能性還有使用者可以修改自己的身分成 Admin 之類的。

## 防護策略

看到上面的例子，也許有人會說：「那我讓 URL 不可預測不就好了？」

例如可以讓 URL 變成一串亂碼，這樣確實可以提高猜中的難度。

但其實有經驗的人，可能會嘗試用窮舉法，甚至去破解 Encode 的方式，到最後這個資訊仍有可能外洩，所以算是治標不治本的方式。

一個較完整的防護策略，會包含三個環節：

### 1\. 身分驗證(Authentication)

在使用者每次返回應用程式時，能夠準確地識別其身份。這是所有權限管理的起點。

### 2\. 授權(Authorization)

在使用者通過身份驗證後，系統需要決定該使用者被允許及不被允許執行哪些操作。

### 3\. 權限檢查

當使用者嘗試執行某個具體操作的當下，系統必須即時評估其授權狀態，以確認該操作是否被允許。

## 授權的常見實現方式

那系統應該根據什麼決定使用者能不能執行某些操作呢？以下是一些常見的方式：

### 1\. Role-based

這是最常見的授權方式，透過賦予每個使用者一個特定的角色（例如「管理員」與「一般使用者」）來區分權限。

### 2\. 給予所有權的授權

某些資源歸屬於特定的使用者或群組，未經其許可，其他人將無法存取。

### 3\. 基於策略的授權

權限控制方案通常會以「策略(Policy)」的形式來定義，明確定義哪些實體或群組可以（白名單）或不可以（黑名單）執行特定的操作。



在比較複雜的場景中，我們可能會需要對單獨的文件或資料，設定不同的權限。此時就必須實施更精細、更具體的權限管理方案。

## 設計與實作的四大指導原則

那身為軟體工程師，我們在實作之前，應該要思考什麼？或是在實作的時候應該要注意什麼事情呢？

### 1\. 評估並聚焦於最大風險

過猶不及的概念大家都知道，權限這件事情也是。過早進行一些權限的處理，反而只會讓商業邏輯變得複雜，徒增維護成本。

比較好的方式是：找出產品或組織有哪些「絕對不能」被洩漏或被取得權限的東西，優先花心力處理那些。

至於那些就算被洩漏也相對沒有嚴重後果的資訊，就可以慢一點再處理。

### 2\. 預先設計並文件化

定義完哪些是重要的之後，最好在開發初期就進行設計和文件化。

而在設計權限的時候，最好跟 PM 多多確認需求。如果沒有一套共同認可的規則，就很難定義何謂「正確」的實作。

其中文件化這件事情我覺得蠻重要的，有時候權限控制只存在 Codebase，公司 PM 乃至於工程師本人，都不一定清楚現在的權限是怎麼定義的，導致每次都需要重新 Check Codebase，其實會有點浪費時間。

### 3\. 嘗試集中化權限決策

應試圖將權限控制的決策邏輯在程式碼庫中集中管理。

這不代表所有請求都必須通過單一程式碼路徑，而是應建立一套評估權限的標準方法，例如使用函式裝飾器 (function decorators)、路徑檢查、資料庫預存程序、或呼叫專門的權限組件等。

舉個例子來說，在 Laravel 中，「非集中管理」可能會像這樣：

在 `PostController.php` 的 `update` 裡：

```php
<?php
public function update(Request $request, Post $post)
{
    // 檢查1：使用者是否是文章作者？
    // 檢查2：或者，使用者是否是管理員？
    if (Auth::id() !== $post->user_id && Auth::user()->role !== 'admin') {
        abort(403, 'Unauthorized action.');
    }

    // ...更新文章的邏輯...
}
```

在 `PostController.php` 的 `destroy` 裡：

```php
<?php
public function destroy(Post $post)
{
    // 又要重複一次幾乎一樣的邏輯
    if (Auth::id() !== $post->user_id && Auth::user()->role !== 'admin') {
        abort(403, 'Unauthorized action.');
    }

    // ...刪除文章的邏輯...
}
```

在 view `show.blade.php` 裡，決定是否顯示編輯按鈕：

```php
@if (Auth::id() === $post->user_id || (Auth::check() && Auth::user()->role === 'admin'))
    <a href="/posts/{{ $post->id }}/edit">編輯文章</a>
@endif
```

這樣可能有什麼問題？

1. **重複**：同樣的權限檢查邏輯散落在 Controller 和 View 等多個地方

2. **難以維護**：如果要增加一個「總編輯 (editor)」也能修改文章，必須找出所有這些 `if` 判斷，然後一個個修改它們，非常容易遺漏

3. **容易出錯**：只要有一個地方忘記加上檢查，就會產生一個嚴重的安全漏洞。



因此在 Laravel 中，提供了 Gates 和 Policies 來集中管理授權邏輯，具體實作方式可能是：

1. 先建立一個集中的「規則手冊」，這裡用 `PostPolicy.php` 作為範例

   ```php
   <?php
   
   
   class PostPolicy
   {
       // 定義「更新文章」的規則
       public function update(User $user, Post $post): bool
       {
           // 規則1：使用者是文章作者
           // 規則2：或者，使用者是管理員
           return $user->id === $post->user_id || $user->role === 'admin';
       }
   
       // 定義「刪除文章」的規則
       public function delete(User $user, Post $post): bool
       {
           // 規則可以和 update 一樣，也可以不同
           return $user->id === $post->user_id || $user->role === 'admin';
       }
   }
   ```

2. 在不同地方使用這個集中的規則

   ```php
   <?php
   public function update(Request $request, Post $post)
   {
       // Laravel 會自動找到 PostPolicy 並呼叫 update 方法
       // 如果規則不通過，會自動拋出 403 錯誤
       $this->authorize('update', $post);
   
       // ...更新文章的邏輯...
   }
   
   public function destroy(Post $post)
   {
       // 同樣地，呼叫集中的 delete 規則
       $this->authorize('delete', $post);
   
       // ...刪除文章的邏輯...
   }
   ```

   ```html
   {{-- Laravel 會自動使用 PostPolicy 來判斷 --}}
   @can('update', $post)
       <a href="/posts/{{ $post->id }}/edit">編輯文章</a>
   @endcan
   ```

   ```php
   <?php
   // 只有通過 PostPolicy 的 update 規則的使用者才能訪問這個 route
   Route::put('/posts/{post}', [PostController::class, 'update'])
        ->middleware('can:update,post');
   ```

### 4\. 嚴格且批判性地測試

測試流程必須真正地嘗試找出權限控制方案中的漏洞。像攻擊者一樣思考和測試，才能為真實的攻擊做好準備。若預算和時間允許，應考慮聘請外部團隊進行滲透測試。

## 結語

Broken Access Control 應該算是學習資訊工程初期就會有的概念，但從來沒有系統性的去了解過。

在看的過程中，不斷想到的是 SELinux 的權限設計，也會想到 Laravel 的一些工具原來是由此而生，算是讓我更理解緣由。

希望多大家有所幫助！
