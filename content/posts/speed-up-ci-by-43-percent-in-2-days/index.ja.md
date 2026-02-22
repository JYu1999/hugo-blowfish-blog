---
title: "12分から7分へ：2日間で会社のCI時間を43%削減した実戦記録"
date: 2025-12-22T10:47:46+08:00
draft: false
tags: ["技術"]
---

{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}

## 結果

まず最初に実行結果を直接お見せします：

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image1.png" alt="実行結果" />

- CI フロー改善前の平均時間（直近 5 回の統計）：12 minutes 20 seconds
- CI フロー改善後の平均時間（直近 3 回の統計）：7 minutes 3 seconds

改善幅：**42.84%**

## 経緯

私たちの会社では以前から CI フローを運用しており、主に Merge 前にユニットテストの実行やパッケージの期限切れチェックなどを行っています。

最近、会社で人員の異動があり、「CI フローの完了を待つ時間がやたら多い」と明確に感じるようになりました。

例えばフロントとバックエンドが共同開発する場合、フロントが API を繋ぐにはバックエンドのブランチを先に Merge する必要があります。バックエンドが完成していても、CI フローが終わるまで待たなければなりません。

またバックエンドで共同開発をしていても、両側で必要な機能があって Cherry Pick しにくい場合は、もう一方の人が Merge するのを待ち、また CI フローを待つことになります。

毎回 CI が成功すればまだましですが、失敗することもあり、その都度 Debug に時間を費やして再実行を待つ羽目になります。

全体的に見ると、CI フローにはメリットがある一方で、現状では多くの待機時間を生み出しており、チーム規模が大きくなるにつれてその影響はさらに拡大する可能性があります。

ちょうどいくらか余裕のある「農閑期」があったので、上司に自分から申し出て、CI フローの最適化に取り組むことにしました。

---

## リソース分析

実装を始める前に、まず状況全体を把握します：

- 現在の CI フロー実行時間は約 11〜13 分

- このタスクに使える時間は最大 3 日なので、できるだけ早く完成させる必要がある

- この時点で、私は GitLab CI の経験がゼロ

上記のリソースを把握した上で、方向性をいくつかまとめました：

- 時間と（私の）経験に限りがあるため、**影響が最も大きい**ものと**最も調整しやすい**ものに集中するしかない。GitLab CI の仕組みを深く研究する必要がある調整は、ひとまずスキップする可能性がある。

- CI 時間を 50% 削減したい

---

## CI 分析

### ジョブフロー

CI 速度を最適化するには、まず現在どこが遅いかを知る必要があります。

そこで直近 2 回の CI フローを確認し、各フェーズの時間を調べました。

会社の機密に関わるため実際のログは記載しませんが、大まかにまとめると以下のとおりです：

| Stage | Job 1 | Job 2 |
|---|---|---|
| **Preparing the "docker" executor** | 14 | 13 |
| **Preparing environment** | 0 | 0 |
| **Getting source from Git repository** | 8 | 8 |
| **Restoring cache** | 10 | 11 |
| **Executing "step_script" stage of the job script** | 593 | 686 |
| **Saving cache for successful job** | 48 | 36 |
| **Cleaning up project directory and file based variables** | 1 | 0 |
| **合計時間\*** | 11 minutes 17 seconds | 12 minutes 38 seconds |

\*合計時間は GitLab Pipeline 上の Duration を参照しており、上の数字を単純に合計したものではないため、若干の誤差がある場合があります。

上表から明らかなように、ボトルネックは **Executing "step_script" stage of the job script** にあり、これが主な最適化対象となります。

### 主なボトルネックの分析

次に **Executing "step_script" stage of the job script** がなぜ遅いかを見てみましょう。まずその中で何が行われているかを確認します（下表は AI が生成）：

| **フェーズ** | **コマンド** | **詳細説明** |
|---|---|---|
| **セキュリティチェック** | `sudo composer self-update --2` | Composer をバージョン 2 にアップグレードし、互換性とセキュリティを確保。 |
|  | `composer config --global audit.abandoned report` | 廃止されたパッケージに遭遇した場合にレポートを出力するよう Composer のグローバル設定を変更。 |
|  | `composer audit` | `composer.json` のパッケージに既知のセキュリティ脆弱性がないかスキャン。 |
| **依存関係のインストール** | `composer install --prefer-dist...` | PHP バックエンドパッケージをインストール（プログレスバー非表示・非インタラクティブで高速化）。 |
|  | `yarn install` | フロントエンド JavaScript 依存パッケージをインストール。 |
| **データベース構築** | `sudo apt-get install -y mysql-client` | 環境に MySQL クライアントツールをインストールして SQL コマンドを実行可能にする。 |
|  | `mysql ... CREATE DATABASE...` | `testing` と `testing_sub` の 2 つのテスト用データベースを作成。 |
|  | `mysql ... CREATE USER...` | `user` という名前のデータベースユーザーを作成。 |
|  | `mysql ... GRANT ALL PRIVILEGES...` | `user` に 2 つのテストデータベースへのすべての操作権限を付与。 |
|  | `mysql ... < mysql_sub-schema.sql` | 事前定義された SQL スキーマを `testing_sub` データベースにインポート。 |
| **Laravel 環境設定** | `cp .env.testing.example .env` | テスト環境変数テンプレートをコピーして本番の `.env` 設定ファイルを生成。 |
|  | `php artisan key:generate` | Laravel アプリケーションの暗号化キーを生成。 |
|  | `php artisan config:cache` | 設定ファイルをキャッシュに書き込み、テスト時に正確な環境変数が読まれるよう確保。 |
|  | `php artisan migrate --seed` | データベースマイグレーション（テーブル作成）を実行し、テスト用の初期データを投入（Seeding）。 |
| **テスト実行** | `./vendor/phpunit/phpunit/phpunit...` | **PHPUnit** でバックエンド機能テストを実行し、エラーを標準エラー出力に送る。 |
|  | `yarn test` | フロントエンドテスト（通常 Jest または Vitest）を実行。 |

各ステップの時間がすべて記録されているわけではありませんが、最も時間がかかっているのは **PHPUnit テスト**です。

|  | Job 1 | Job 2 |
|---|---|---|
| PHPUnit テスト時間 | 09:06.684 | 10:34.911 |
| Stage 合計時間 | 593 sec | 686 sec |
| CI フロー合計時間 | 11 minutes 17 seconds | 12 minutes 38 seconds |
| Stage 合計時間に対する割合 | 92.1% | 92.6% |
| Job 合計時間に対する割合 | 80.6% | 83.6% |

明らかに PHPUnit が今回の CI 最適化の最優先ターゲットです。

### なぜ PHPUnit が遅いのか？

では PHPUnit はなぜそれほど時間がかかるのでしょうか？

ローカルでテストを実行してみると、基本的に各テスト関数は 0.1 秒以内で終わります。しかしいくつかのテストが異常に長いことに気づきました：

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image2.png" alt="テスト" />

明らかに Feature Test 3 と Feature Test 4 の実行時間がまったく正常ではなく、Feature Test 2 にも 6 秒を超えるものがありました。

6 秒を侮ってはいけません。ローカルで 6 秒でも、GitLab Runner 上では数倍に膨れ上がる可能性があります。

ローカルでは約 130 秒で完了しますが、上記の 600 秒と比べると差異は 4 倍以上にもなります。

そこでこれらの 6 秒を超えるテストが最優先の最適化対象となります。

6 秒以内のものは、前述の「時間に限りがある」という前提から、主要ターゲットとしては扱いません。

---

## 実際の最適化

では、これらのテストが一体何をしているのかを一緒に見ていきましょう。

### Feature Test 3

まず Feature Test 3 が何をしているかを見てみます：

```php
<?php

class FeatureTest3
{
  use WithFaker, RefreshDatabase;

  public function warmUpCache()
  {
    // データを作成して Cache に保存
  }

  public function setUp()
  {
    parent::setUp();

    // Cache をクリア

    // withoutMiddleware

    // Seeder
  }

  public function testFunction3()
  {
    $caches = $this->warmUpCache();

    // assert
  }

  public function testFunction4()
  {
    $caches = $this->warmUpCache();

    // assert
  }

  public function testFunction5()
  {
    $caches = $this->warmUpCache();

    // assert
  }

  public function testFunction6()
  {
    $caches = $this->warmUpCache();

    // assert
  }

  public function testFunction7()
  {
    $caches = $this->warmUpCache();

    // assert
  }
}
```

簡単に説明すると、テスト対象の関数はキャッシュからデータを取得します。

そのためテスト時には、Factory でデータを作成して DB に保存し、さらに Cache に保存する処理、つまり `warmUpCache()` が行っていることが必要です。

重要な点は、ビジネスロジックが複雑なため `warmUpCache()` で作成するデータが多く、毎回実行するのに非常に時間がかかることです。

`warmUpCache()` 自体を最適化できるか？可能かもしれませんが、内部のビジネスロジックが非常に複雑で、時間的制約の下では難しいです。

そこで考え方を変えました：`warmUpCache()` 自体の速度を最適化できないなら、実行回数を減らすことはできないか？調査の結果わかったことは：

1. データは Cache から直接取得され、DB とは無関係

2. 各テスト関数でテストする内容は独立している

つまり毎テストで DB のリフレッシュ、Seeder 実行、Cache のクリア、Cache の再生成を繰り返すのは完全に無駄なステップです。

そこで次のようなロジックを書きました：

```php
<?php

class FeatureTest3
{
  use WithFaker, RefreshDatabase;

  protected static array $warmedUpCaches = [];

  public function warmUpCache()
  {
    // 既にウォームアップ済みかつ Redis に対応するキャッシュが存在する場合は、
    // 現在の Redis 内のバージョンを直接取得し、
    // 以前に計算済みのタグセットと組み合わせて、データ作成と Command 実行の重複を避ける
    if (isset(self::$warmedUpCaches[$group]) && $redis->exists($cacheVersionKey)) {
        $cacheVersion = $redis->get($cacheVersionKey);

        return [
            $cacheVersion,
            self::$warmedUpCaches[$group],
        ];
    }

    // データを作成して Cache に保存
  }

  public function setUp()
  {
    parent::setUp();

    // Cache をクリア -> すべての Function で共用するためクリアしない

    // withoutMiddleware

    // Seeder
  }
}
```

結果はどうだったでしょうか？

```xml

 PASS  Tests\Feature\FeatureTest3
✓ ...                                                                                                               3.05s
✓ ...                                                                                                               0.18s
✓ TestFunction3                                                                                                    7.13s
✓ TestFunction4                                                                                                    6.87s
✓ TestFunction5                                                                                                    0.14s
✓ TestFunction6                                                                                                    0.13s
✓ TestFunction7                                                                                                    0.13s
```

34 秒から 17.5 秒に短縮され、約半分の削減です！

実際の CI フローはどうなったか？Pipeline を確認すると、時間が 9 minutes 13 seconds に短縮されており、元の平均 12 minutes 20 seconds と比べて 3 分以上の差が出ました。

{{< alert >}}
注意：この手法は大幅な高速化が可能ですが、テストケース内でこれらのキャッシュ内容を変更する操作がある場合、他のテストが失敗する可能性があります。実装時にはキャッシュデータが Read-only であるか、適切な分離性が確保されていることを確認してください。
{{< /alert >}}

2 つのテストがまだ 6 秒を超えているのでは、と思う方もいるでしょう。これはビジネスロジックに関わる複雑な事情があるため詳しく説明しませんが、これは予想内の結果です。

このテストの最適化はひとまず一段落ですが、鋭い読者なら気づくでしょう：DB のリフレッシュと Seeder の繰り返し実行の問題がまだ残っています。

しかし前提として一貫して強調しているように、私には時間の制限があるため、影響が最も大きい問題に先に取り組む必要があります。

このテストでは、DB のリフレッシュと Seeder による影響がそれほど大きくないと判断し、ひとまず後回しにします。

### Feature Test 4

では Feature Test 4 を見ていきましょう。まず大まかな構造を把握します：

```php
<?php

class FeatureTest4
{
  use WithFaker, RefreshDatabase;

  public function setUp()
  {
    parent::setUp();

    // Cache をクリア

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
    // Search Engine をクリア

    // データを作成

    // Search Engine に保存

    // Sleep 5 seconds
  }
}
```

Feature Test 3 に似ているので、同じ解法をそのまま適用できそうでしょうか？

残念ながら、答えはノーです。このテスト対象の関数は実際のデータベース処理を伴うため、Search Engine からのみデータを取得するように変えるとテストが失敗します。

しかし上記の経験から、各 Function が `warmUpSearchEngine()` を実行しているなら、問題はそこにあると直接気づけるはずです！

予想通り、中に `sleep(5)` という奇妙なロジックがありました。各テストで強制的に 5 秒待機しているので、遅くて当然です。5 秒待機以外にも、データ作成にも相当な時間がかかっています。

`sleep(5)` を削除できるか？残念ながらダメです。Search Engine へのインポート操作は非同期であるため、`存入 Search Engine` が完了してもデータが検索エンジン内に同期されているとは限らず、インポートジョブが完了するまで少し待つ必要があるからです。

削除できないなら、短縮できるか？残念ながらそれもダメです。さらに短縮するとインポートが間に合わないリスクがあります。

データ作成を改善できるか？Feature Test 3 と同様に、ここのデータ作成ロジックは複雑で、最適化が難しいです。

では前回と同じ道を歩みましょう。`warmUpSearchEngine()` の実行回数をできるだけ減らすことはできるか？

できます！なぜなら、各テストはデータベースに依存していますが、それぞれは独立したテストなので、まったく同じデータを使っても問題ないからです！

そこでシンプルなリファクタリングを行いました：

```php
<?php

class FeatureTest4
{
  use WithFaker, RefreshDatabase;

  public function setUp()
  {
    parent::setUp();

    // Cache をクリア

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
    // Search Engine をクリア

    // データを作成

    // Search Engine に保存

    // Sleep 5 seconds
  }
}
```

すべてのテスト関数を一つの関数にまとめることで、最もシンプルかつ強引に解決できました！

実際にどれだけ改善されたか見てみましょう：

```php
 PASS  Tests\Feature\FeatureTest4
✓ all                                                                                                                                           11.75s

Tests:    1 passed (1819 assertions)
Duration: 12.02s
```

42 秒から一気に 12 秒に最適化され、約 30 秒の差です。

本番環境では、Feature Test 3 の最適化後の結果（9 minutes 13 seconds）から 7 minutes 51 seconds に短縮され、さらに約 1.5 分の削減です！

優秀なエンジニアからは「これは何だ、エラーが出たとき原因を特定しにくくなるのでは？」と言われるかもしれません。

それは私も考えましたが、それでもこの手法を選んだ理由があります：

- このテスト対象の関数はほとんど変更されず、私が入社して 2 年以上一度も修正したことがない

- このテストが失敗するとき、通常は Search Engine 自体の問題であって、ロジックの問題ではない

- 会社では現在一連のリファクタリングを進めており、このテスト対象の関数は廃止される可能性が高い

上記の理由を踏まえて、このタスクに使える時間と将来の効果を総合的に評価した結果、後から Debug するリスクはその効果より遥かに小さく、そのリスクに時間を割く価値もないと判断しました。

### Feature Test 2

実はとてもシンプルで、主な原因は `TestFunction2` 内で以下を実行していることです：

```php
<?php
public function testFunction2()
{
    // ...省略
    $creators = Creator::factory()->count(301)->create();

    // ...省略
}
```

なぜこの一行がこんなに時間がかかるのか？Creator には多くの関連データがあり、Factory によって一緒に作成されますが、これは会社のコアビジネスロジックに関わるため、現時点では変更できません。

では、なぜこれほど多くのクリエイターを作成する必要があるのか？テスト対象の Command 内に、データベースの最初の 300 件だけ取得するロジックをテストする処理があるからです。

```php
<?php
Creator::where(xxx)
->limit(300)
->get()
```

このテストのリファクタリング方法をいろいろ考えましたが、いずれも何らかの理由で実行できませんでした：

- データを実際に作成しない：これはダメ、テスト対象の Command をテストできなくなる

- 他の Function のクリエイター作成部分と統合する：このテストの他の Function でもいくつかのクリエイターを作成しているが、共通化できないか？これも自分で否決しました。リファクタリングが複雑すぎて、各 Function が結合してしまう可能性があるから。

ではどうするか？

……

突然、ひらめきました：このテストを削除することを検討できないか？

なぜそう思ったかというと、このテストのロジックは他のテストと大幅に重複しており、唯一の違いはこの 300 という Limit だけだからです。

見たところのメリットは：誰かがこの 300 の Limit を変更した場合に気づける、という点だけです。

しかしここを変更しても影響は見当たりません。フロントエンドのコードを確認したところ、この 300 という Limit に依存する処理はありませんでした。また社内のどのドキュメントにも、この 300 がビジネスロジックであるという説明はありませんでした。

この数字は当時の開発者が随意に決めたものに過ぎないようです。

念のため、社内のシニアエンジニアにもダブルチェックをお願いし、このテストを削除した場合の影響を確認しました。

評価の結果、最終的にこのテストを削除しました。

最適化の結果は：

- ローカルで 6.21 秒から 0 秒に

- 本番環境では Feature Test 4 最適化後の結果（7 minutes 51 seconds）から 7 minutes 07 seconds に短縮され、さらに約 45 秒の削減です！

---

## まとめ

今回の最適化はここで一区切りとします。元の約 12.5 分から大幅に削減し、7 分台まで短縮できました。

読者の皆さんはどう感じたでしょうか？ぜひシェアしてください（笑）。

これが私にとって初めての CI 最適化タスクで、正直かなり楽しかったです。

開発者として、楽しいだけでなく、CI 速度の最適化が開発チーム全体の生産性を向上させることもわかっています。

過程を通じて読者の方も気づいたと思いますが、「リソース分析」は私にとって非常に重要なステップです：**自分がどれだけの時間を持ち、自分の能力を把握した上で、最もコアな問題を選んで解決する**。

できるだけ短い時間で価値を届けることは、エンジニアにとって重要な能力であり、この高度に変化する世界に対処するための良い方法でもあると思っています。

<img src="/posts/speed-up-ci-by-43-percent-in-2-days/image3.png" alt="マインドセット" />

---

## 今後の展望

調査の過程でいくつかの手法を見つけましたが、私の評価では効果が比較的限定的で、且つ複雑なものでした。記録として残しておきます：

- ジョブの改善：フロントとバックエンドのテストを分離して並列処理できるようです。ただしフロントエンドテストはわずか 3 秒程度なので、分離の効果は非常に低いと判断しました。

- テストの並列処理：PHP のすべてのテストを異なるプロセスで処理しますが、技術的負債により多くのテストがデータベース操作を含んでいるため、この方法では問題が生じる可能性があります（実際にはテストしていません）。

- Migration Dump：Refresh Database を使用しているため、毎回 Migration を再実行しています。私たちの Migration は 100 以上あるので実行に時間がかかります。ただしいくつかの技術的問題があり、実際にテストした収益も予想ほど大きくなかったため、最終的には採用しませんでした。
