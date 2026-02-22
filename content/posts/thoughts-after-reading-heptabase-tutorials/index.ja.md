---
title: "Heptabase 公式チュートリアルを読んで"
date: 2024-10-02T19:04:52+08:00
draft: false
tags: ["生産性ツール", "読書"]
---

{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}

学習計画を実行し始めて数日後、一つの問題に気づきました：自分の学習方法が長い間改善されていないのです。

元の学習方法に問題があったわけではありませんが、今やAIがますます高度になり、便利なソフトウェア製品も増えているので、理論上はより良い学習方法があるはずです。

高強度の学習において、学習方法は学習効率を大きく影響し、学習成果とも高い正の相関があります。

そこで手元のすべてのタスクを一時停止し、この部分の改善に集中することにしました。

目標は、**知識を吸収・整理・使用するプロセスをよりスムーズ・より効率的にする**ことです。

まず、いくつかの学習方法について調べ始め、Heptabaseの創設者が撮った動画を見つけました。

3エピソードを見た後、Heptabaseの使い方を理解しただけでなく、過去の学習上の問題も一緒に振り返ることができました。

## Reusable

まず最初のポイントは「reusable（再利用可能）」です。動画の中でこの概念が非常に強調されています。つまり、すべての自分のノートは将来大量に繰り返し使われることを予期すべきです。

> Heptabase Fundamentals 101: Se... → The reason that we designed card library this way is because we believe that knowledge should be reusable across topics.

これはツェッテルカステン（カードボックスメモ法）の核心概念でもあります。

以前の私のノートは、構造的な完全性を追求するために、非常に冗長になることが多く、文字と記述が非常に多かったです。その結果：

第一に、毎回書くのに時間がかかるため、ノートを書くのが好きではなくなりました。

第二に、ノートに記録した内容を後で調べる場合、求めているものを素早く見つけにくいため、むしろGoogleで検索する方がいいと感じました。現在はPerplexityやFeloも使えるため、さらに素早く答えが得られます。

ツェッテルカステン（カードボックスメモ法）はこの二つの問題をうまく回避できます。

カードボックスメモ法の核心概念は、必要な時に過去に記録した知識を素早く見つけられるようにすることです。すぐに理解でき、当時の思考の流れが分かる必要があります。

> Heptabase Fundamentals 101: Se... → When you revisit them, you can immediately remember how you think even after a long time.

上述の目的を達成するために、知識ポイントを可能な限り分割する必要があります。各カードにはできるだけ一つの知識やアイデアだけを記録します。

利点は、将来そのカードをすぐに見つけられるだけでなく、短時間でそのカードの内容を理解できることです。

また、記録するものが十分にシンプルであれば、記事のように多くの無関係な内容がないため、その知識ポイントを便利に再利用できます。

これはソフトウェア開発の概念、いわゆるSRP（単一責任の原則）を思い起こさせます。SRPの最も重要な概念は「モジュールは唯一の役割に対してのみ責任を持つべき」です。

一つのFunctionが多くのことをして、ロジックが過剰に束縛されている場合を想像してください。フロントエンドのRequest受け取り、Requestのバリデーション、ビジネスロジックのデータ処理と確認、データベースへの保存、エラー処理、フロントエンドへのResponseの返却などです。

この場合、そのFunction内の特定の機能を再利用しようとすると（例えばエラー処理の部分）、単独で取り出して再利用することができません。

また、そのFunctionをテストする場合、すべての変数の組み合わせが複雑すぎてテストが困難になります。

これが高結合（Coupling）の現象です。

さらに延伸すると、これはソフトウェアプロジェクト管理の概念にも似ています：一つのIssueをできるだけ細かいsubtasksに分割すべきです。ただし、この部分は今は展開しません。

## Re-structure

次に二点目として、動画でWhiteboardのデザインについて言及されていました。

> Heptabase Fundamentals 103: Ma... → Whiteboard is particularly good at breaking down complex knowledge into atomic pieces and connect and visualize them to better see the relationship between ideas.

ここで二つの概念が強調されています。第一に複雑な知識を分解すること、第二に知識間の関係と構造を明確に知ること。

第一の概念は上述の「カード」です。

ただし、上述の通り「カード」が解決する問題は知識を再利用可能にすることですが、学習とは単に知識を分解するだけではありません。

> Heptabase Fundamentals 101: Se... → The essence of learning is you have consumed all this information, but then you restructure it in your own way

プログラムを書く時、多くのFunctionやClassがあるようなものです。すでに分解されていますが、それでも互いの関係を知って初めて新しいFunctionを組み立てることができます。

## When to create Whiteboard ?

ここまで読んで考え始めました。どんな状況でWhiteboardを作るべきか？具体的にどう使うべきか？

> Heptabase Fundamentals 101: Se... → think about a topic that you care about and then create a whiteboard

答えは意外とシンプルで、今気になっていることなら何でもWhiteboardにできるということです。

理由はおそらく：今気になっていることは何らかの問題を解決する必要があることを意味するからでしょう。その問題を解決するために、知識を再整理する必要があります。

また、重要な概念も提言されていました：

> Heptabase Fundamentals 102: Or... → you don't really need to figure out your organization from the very beginning. Once a whiteboard grow big, that's the best time you think about creating the sub-whiteboard

以前、私はノートの構造設計に非常に多くの時間を費やしていました。完璧な解決策を考え出し、後でもう構造を調整しなくて済むようにしたいと思っていたのです。

しかし、ノートの構造は規模の変化に伴い調整が必要で、規模の変化は今まで考えもしなかった問題を伴います。

だから実際には、まず始めてしまえばいいのです（笑）

## Next-up

次はReadwiseの公式動画、詹雨安のブログ、そして他の人がReadwiseとHeptabaseをどう統合しているかを調べる予定です。

また、Heptabaseを使った言語学習の方法もまだ研究が必要です。

さらに進めると、ノートとAIの統合を通じてKnowledge Agentを構築し、データの再利用性をさらに向上させることです。ただし、これは短期的に最も緊急に解決すべき問題ではありません。

## 参考資料

- [Heptabase Fundamentals 101: Sense-making with whiteboards](https://www.youtube.com/watch?v=HgvR2QkfwG0&t=38s)

- [Heptabase Fundamentals 102: Organizing topics with nested whiteboards and tab groups](https://www.youtube.com/watch?v=zlGRxZHlDgM)

- [Heptabase Fundamentals 103: Managing card databases with tags and properties](https://www.youtube.com/watch?v=4kwIfzIJ0o0)

- [深入淺出單一職責原則 Single Responsibility Principle](https://www.jyt0532.com/2020/03/18/srp/)
