---
title: "JetBrains系列IDEのショートカットキー（PHPStorm & RubyMine）"
date: 2023-05-22T10:47:46+08:00
draft: false
tags: ["技術", "生産性ツール"]
---

{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}

以下は、PHPStorm / RubyMine でよく使うショートカットキーです。
コマンドはMac基準で、Windowsの場合は <kbd>Ctrl</kbd> に読み替えてください。

## Search
- <kbd>&#8679;</kbd><kbd>&#8679;</kbd> : Search EveryWhere

    すべてのファイルを検索できます。
- <kbd>&#8679;</kbd> + <kbd>Cmd</kbd> + <kbd>F</kbd> : Find in path（全文検索）

    プロジェクト全体の全文検索。
---

## View
- <kbd>Cmd</kbd> + <kbd>&#8679;</kbd> + <kbd>F12</kbd> : Toggle Maximize Editor

    Editor以外のウィンドウをすべて閉じる／開く
- <kbd>option</kbd> + <kbd>F12</kbd> : Toggle Terminal

    ターミナルを開く／閉じる
- <kbd>Cmd</kbd> + <kbd>1</kbd> : Project View

    Projectファイル一覧を開く／閉じる
- <kbd>Cmd</kbd> + <kbd>2</kbd> : Database View（これはデフォルトではなく、別途設定したものです）

    Database Viewを開く／閉じる
---

## Navigation
- <kbd>Cmd</kbd> + <kbd>E</kbd> : Recent File

  最近アクセスまたは編集したファイル
- <kbd>Cmd</kbd> + <kbd>B</kbd> / <kbd>Cmd</kbd> + Click : Go to declaration

  そのメソッドが宣言されている場所へ移動
- <kbd>option</kbd> + <kbd>Cmd</kbd> + <kbd>&#8592;</kbd> / <kbd>&#8594;</kbd> : Navigate back/forward

  前のナビゲーションに戻る／次のナビゲーションへ進む（存在する場合）
---

## Files
- <kbd>Cmd</kbd> + <kbd>&#8593;</kbd> : ファイルを選択
- <kbd>Cmd</kbd> + <kbd>N</kbd> : ファイルを新規作成

---

## Clean Code
- <kbd>Cmd</kbd> + <kbd>&#8679;</kbd> + <kbd>option</kbd> + <kbd>L</kbd> : コードを整形

  実行後にメニューが表示され、選択した部分だけをリフォーマットするか、ファイル全体をリフォーマットするかを選べます。


実際のコードトレースについては、以下の動画を参考にしてください：
{{< youtube nvAlBpbFNNs >}}
