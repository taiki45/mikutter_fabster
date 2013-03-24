# mikutter fabster
mikutter ふぁぼ☆コレ

## About
mikutter でふぁぼすたに近い機能を実現するプラグインです.

## Features
* mikutter fabster を始めてからの Most がわかる
* 自分の Recent が起動直後から見れる
* 自分のふぁぼりを起動時に再現
* mikutter 起動時に過去のツイートを読むこむ

## Plan
* RT に対応する
* ふぁぼすたインポートスクリプト用意する

## Setup
いまはタイムラインの情報をたくわえるのに
 [twitter-daemon](https://github.com/taiki45/twitter_daemon) というバックグラウンドで
動く(動かす予定)のサービスを使って MongoDB に入れてます.
なので twitter-daemon が後ろで動いている必要があります.

設定ふぁいるは `config.yaml` という名前のファイルを `sample.yaml` を参考にかいてください.

あとは develop ブランチの mikutter を起動すると `M`, `R`, `D` というタブができていると思います.

mikutter の設定に `mikutter fabster` が追加されているのでいい感じの数値にしてみてください.
