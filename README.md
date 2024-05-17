# Juliaへようこそ！
これはJuliaのチュートリアルです．
<details>
<summary>Language</summary>

[English](https://github.com/hibiki-kato/Lecture_Julia)  
[日本語](https://github.com/hibiki-kato/Lecture_Julia_ja)
</details>

<a name="logo"/>
<div align="center">
<a href="https://julialang.org/" target="_blank">
<img src="src/assets/logo.svg" alt="Juliaのロゴ" width="210" height="142"></img>
</a>
</div>

# レッスンリスト

### Google Colaboratoryでコードを実行したい場合は、以下の手順に従ってください
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ageron/julia_notebooks/blob/master/Julia_Colab_Notebook_Template.ipynb)
|回 | 概要 | ファイル |
|:--------:|---|:----:|
| レッスン1 | 入門 | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](./src/lesson1.ipynb) |　
| レッスン2 | 変数・データ型 |  |  |
| レッスン3 | 制御フロー | |  |
| レッスン4 | 関数 ||  |
| レッスン5 | データ構造 ||  |


# レポジトリレイアウト
```sh
.
├── auto_pull
├── data
└── src
    └── assets
```

<dl>
    <dt>auto_pull</dt>
    <dd>ここに格納されているファイルを以下のように実行することでこのレポジトリの更新をローカルに反映させます．
    <li>Windows</li>
      <pre><code class="language-sh">> .\auto_pull\pull.ps1</code></pre>
      <li>macOS or Linux</li>
      <pre><code class="language-sh">$ zsh ./auto_pull/pull.sh</code></pre>
    </dd>
    <dt>data</dt>
    <dd>データファイルを保存するフォルダです．</dd>
    <dt>src</dt>
    <dd>ソースコードや画像ファイルを格納するフォルダです。</dd>
</dl>


# Juliaのインストール方法
ここでも説明しますが，詳しくは[公式ウェブサイト](https://julialang.org/downloads/)を参照してください。

公式のバージョン管理ソフト[Juliaup](https://github.com/JuliaLang/juliaup)を使用してインストールしてください。
まず，以下のコマンドを，ターミナル(PowerShell)で実行してください．

```sh
# Windows
> winget install julia -s msstore

# macOS or Linux
$ curl curl -fsSL https://install.julialang.org | sh

# homebrew
$ brew install juliaup
```

特定のバージョンのJuliaをインストールするために，以下を実行してください．
```sh
juliaup add <version>
```
`<version>`は入れたいバージョンに置き換えてください．

*e.g.* `juliaup add 1.10`



# パッケージのインストール方法
ターミナル(PowerShell)を開いて，`julia`を実行してください．対話型のコマンドライン**REPL**が起動します．

```sh
$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.10.3 (2024-04-30)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia>
```
そこで，`]`を押してください．その後，
```sh
$ (@v1.10) pkg> add <packagename>
```
を実行すれば，パッケージがインストールされます．`<packagename>`はパッケージの名前に置き換えてください．*e.g.* `add PyPlot`

このレッスンでは以下のパッケージを使用します．

<dl>
  <li> PyPlot </li>
  <dd>データを視覚化するためのグラフソフト．</dd>
  <li> IJulia </li>
  <dd>Juliaをjupyter labで使用するためのパッケージ．</dd>
  <li> <a href="https://juliadynamics.github.io/DynamicalSystems.jl"> DynamicalSystems </a> </li>
  <dd>非線形力学系と非線形時系列解析のための強力なライブラリ．
</dl>