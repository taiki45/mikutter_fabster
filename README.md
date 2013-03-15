# mikutter fabster
mikutter ふぁぼ☆コレ

## About
mikutter でふぁぼすたに近い機能を実現するプラグインです.
外部 DB にデータを入れるので mikutter が再起動しても消えることはないのです.

## Features
* 自分の Most がわかる☆
* 自分の Recent が起動直後から見れる☆

## Plan
* 自分がふぁぼった履歴のタブ(descovery 相当)
* RT に対応する

## Status
開発初期段階なのでいろいろ変わる可能性があります.
ChangeLog にかくのでそれを参照して追従してください.

## Setup
いまはタイムラインの情報をたくわえるのに
 [twitter-daemon](https://github.com/taiki45/twitter_daemon) というバックグラウンドで
動く(動かす予定)のサービスを使って MongoDB に入れてます.
なので twitter-daemon が後ろで動いている必要があります.

設定ふぁいるは `config.yaml` という名前のファイルを `sample.yaml` を参考にかいてください.

あとは develop ブランチのmikutter を起動すると `M`, `F` というタブができていると思います.
