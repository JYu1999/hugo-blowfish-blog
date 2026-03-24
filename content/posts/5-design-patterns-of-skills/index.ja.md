---
title: "Agent Skillの設計パターンを本当に知る必要がありますか？"
date: 2026-03-25T00:00:00+08:00
draft: false
tags: ["AI", "技術"]
---

{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}

GoogleがXでこの記事を投稿しました：

{{< x user="GoogleCloudTech" id="2033953579824758855" >}}

記事では5つのAgent Skill Design Patternが簡単にまとめられており、以下はAIによる要約です：

## 5つのAgent Skill Design Pattern

### パターン1：Tool Wrapper（ツールラッパー）
- **用途：** システムプロンプトにハードコーディングするのではなく、必要に応じて特定のライブラリやフレームワークの専門知識をAgentに動的にロードさせます。
- **メカニズム：** SKILL.mdはユーザーのプロンプト内の特定のキーワードを監視し、トリガーされたときにのみ`references/`ディレクトリから内部ドキュメントをロードして、絶対的なガイドラインとして扱います。これは、チーム内部のコーディング規約やフレームワークのベストプラクティスを配布するのに適しています。

> "Instead of hardcoding API conventions into your system prompt, you package them into a skill. Your agent only loads this context when it actually works with that technology."

- **例：** FastAPI専門家スキル——Agentは、コードのレビューや記述を行う際にのみ`conventions.md`をロードし、規約を逐一つ突き合わせて修正を提案します。
- **重要な特徴：** これは最もシンプルなパターンであり、その中核となる価値はコンテキストウィンドウの無駄を防ぐ「オンデマンドなロード」にあります。

### パターン2：Generator（ジェネレーター）
- **用途：** Agentが毎回一貫した構造のドキュメントを生成するようにし、「実行するたびにフォーマットが異なる」という問題を解決します。
- **メカニズム：** 出力テンプレートを`assets/`ディレクトリに、スタイルガイドを`references/`に配置します。SKILL.mdの指示はプロジェクトマネージャーとして機能します：テンプレートをロード → スタイルガイドを読み込む → 不足している変数をユーザーに尋ねる → ドキュメントに入力する。APIドキュメントの生成、標準化されたコミットメッセージ、またはプロジェクトアーキテクチャの構築に適しています。

> "The instructions act as a project manager. They tell the agent to load the template, read the style guide, ask the user for missing variables, and populate the document."

- **例：** 技術レポートジェネレーター——SKILL.md自体にはフォーマットのルールや構文の標準は含まれておらず、リソースの取得を調整し、Agentに段階的に実行させることのみを担当します。
- **重要な特徴：** テンプレートとスタイルルールを外部化し、SKILL.mdは「オーケストレーション」のみを行います。

### パターン3：Reviewer（レビュアー）
- **用途：** 「何をチェックするか」と「どのようにチェックするか」を分離し、モジュール化された自動レビューを実現します。
- **メカニズム：** レビュースタンダードは`references/review-checklist.md`に保存されます。Agentはチェックリストをロードした後、ユーザーが提出したコードと1行ずつ比較し、重要度（error / warning / info）によって出力結果をグループ化します。チェックリストを入れ替えるだけで（例えば、PythonのスタイルチェックリストをOWASPセキュリティチェックリストに置き換える）、同じスキルインフラストラクチャを使用して全く異なる専門的な監査を実行できます。

> "If you swap out a Python style checklist for an OWASP security checklist, you get a completely different, specialized audit using the exact same skill infrastructure."

- **例：** Pythonコードレビュアー——指示は固定されたままで、Agentは外部のチェックリストを動的にロードし、要約、段階分けされた課題、スコア、上位3つの提案を含む出力を強制します。
- **重要な特徴：** 高い代替性——チェックリストを変更するだけでレビュー分野を切り替えることができ、自動PRレビューやセキュリティスキャンに最適です。

### パターン4：Inversion（反転）
- **用途：** 情報が不足しているときにAgentが推測して直接結果を生成するのを防ぎ、代わりにAgentが主導して質問し、要件を完全に収集してから行動するようにします。
- **メカニズム：** コアとなるのは、明確で妥協のない「ゲート条件」（例："DO NOT start building until all phases are complete"）を設定することです。Agentに順番に質問させ、回答を待ち、すべての段階が完了するまで出力段階に入らないよう強制します。役割は「実行者」から「面接官」へと反転します。

> "Instead of the user driving the prompt and the agent executing, the agent acts as an interviewer."
>
> "The agent refuses to synthesize a final output until it has a complete picture of your requirements and deployment constraints."

- **例：** プロジェクトプランナー——3つの段階（問題の探索 → 技術的な制約 → 総合的な出力）に分かれ、各段階に厳格なゲートコントロールがあり、前の段階が完了するまで次の段階に進むことはできません。
- **重要な特徴：** 複数回の対話インタラクション。段階的な質問を通じて要件の抜けもれリスクを低減します。

### パターン5：Pipeline（パイプライン）
- **用途：** 複雑なタスクを処理する際、厳格なシーケンシャルワークフローを強制し、Agentがステップをスキップしたり未検証の結果を提示したりするのを防ぐために、ハードチェックポイントを設定します。
- **メカニズム：** SKILL.mdそのものがワークフローの定義です。「ダイアモンドゲート条件」（diamond gate conditions）——例えば、Docstringの生成からアセンブリフェーズに移行する前にユーザーの承認を要求するなど——を実装することで、どのステップもスキップできないようにします。このパターンは各ステップで必要なリファレンスとテンプレートを動的にロードし、コンテキストウィンドウをクリーンに保ちます。

> "By implementing explicit diamond gate conditions (such as requiring user approval before moving from docstring generation to final assembly), the Pipeline ensures an agent cannot bypass a complex task and present an unvalidated final result."

- **例：** ドキュメント生成パイプライン（4ステップ）：解析と棚卸し → Docstringの生成（ユーザー確認が必要） → ドキュメントの組み立て → 品質チェック。各ステップに明確な進入条件があります。
- **重要な特徴：** すべてのオプションディレクトリを最大限に活用し、特定のステップでのみ必要なリソースを導入します。5つのパターンのうち最も制御力が強いです。

---

## 理由（Why?）

コンセプトはかなり良いと思いますが、読んだ後、私は考え始めました：Agentを使う側として、これが私に何の役に立つのか？なぜGoogleはわざわざこれをまとめたのか？

よく考えてみると、これは私たちがコードを書くときにDesign Pattern（設計パターン）やClean Architecture（クリーンアーキテクチャ）を学ぶのと非常に似ていることに気づきました。

これらのパターンは一般的に、先人たちが厳しい試練を経て鍛え上げたエッセンスなので、それらを模倣すれば通常は良い結果が得られます（ただし、乱用すべきではありません）。

したがって、このモデルに従えば、`skill-creator`というスキルも、私たちが要求を出したときに、このスキルが達成しようとしている目標を迅速に確認し、それを実現するための適切な設計パターンを選択できれば、はるかに良い結果を達成できる可能性があるのではないでしょうか。
