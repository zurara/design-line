# design-line

给用 Claude Code 做设计的人的一条生产线。一个固定的流程形状，你交付到几个地方就套几条。你的公司、你的偏好、你的设计规则放在工作目录旁的一个档案夹里，不在插件里，所以同一个插件换个工作室、换个人都能跑。

English: [README.md](README.md)

## 适合谁

**你同时交付到不止一个地方。** 代码里的组件库、原型仓库、设计工具的库、计划工具的看板。每个地方检查和出货的方式都不同，而跨越它们的只有你一个人。跟 AI 开了几天几个会话以后，你已经不记得哪条分支合了、哪个问题还没答、看板上哪条过时了。design-line 就是会话和会话之间的记性和纪律。

**你是设计师，也是半个 PM。** 要跟开发交接，要让工作项是真的，要写日报。你希望「我做了什么」自动变成记录，不用再打一遍。

**你带着几个 agent 干活，不想当保姆。** 你想说三件事就走，回来时做完的在 main 上，没把握的停在那里，问题编好号。

### 谁不需要

- 交付物就是一个设计文件链接的设计师。一个工具一个地方，没有要协调的。
- 大团队里的设计师，PM、QA、发版流程都有人管。流程是别人的。
- 做一件小事的任何人。干净的会话说一句话更快，改一行的事上流水线没有意义。

## 用和不用的差别

| | 自己开干净会话，一件一件做 | 用 design-line |
| --- | --- | --- |
| 新会话知道什么 | 你重新打字说的 | 这条线的交接、收件箱、账本、brief |
| 中途冒出来的事 | 你记得，或者你忘了 | 收件箱一行，四种固定走法，手上的事继续 |
| 几件事一起做 | 三个窗口，各等一个问题 | 一个调度员；停下的任务把问题存起来，别的接着跑 |
| 分支落地 | 你合，或者 agent 想起来就合 | 合并队列：在合并后的树上过门禁，不 force push，冲突退回 writer |
| push、开 PR、发布 | 看 agent 记不记得 | hook 直接拦 force push 和按名字杀进程；哪条线要谁点头写在配置里 |
| 花了多少 | `/cost` 一个总数 | 每个 subagent 的模型、token、结果；每个任务一条「下次怎么做」 |
| 不在电脑前看进度 | 没有 | 手机上一张只读看板，状态变化时更新 |

### 代价

- **每个任务开头的固定上下文。** 先读四个文件，几千 token。这是买记性的钱。改一行的事别上线。
- **先决定再动手。** brief 先问你，writer 才跑。你习惯「先做出来我再看」的话，brief 可以就这么写：「做 A 和 B 两个版本，我选」。
- **第一周会慢。** 它问得多、写得多。省下来的在第二周：不用重新解释、不用追状态、没有来路不明的分支。
- **subagent 要花 token。** 我们第一批七件事花了大约 290 万 subagent token。Pro plan 请一次一件、用小模型（`init` 会帮你设）。

## 形状

```
读料 ──▶ brief ──▶ [你签字] ──▶ 写 ──▶ 检查 ──▶ 出货 ──▶ 记录
```

**线**是一个出货和检查的地方：有自己门禁和合并或 PR 规则的仓库、你发布的设计工具库、你写入的计划工具。不是主题：一个功能通常跨几条线，用 `#标签` 标。每条线都是这六个工位。**任务**在一个会话里走完这六步，那个会话就是这个任务的协调员，任务结束它就结束。下一个会话要的东西都在文件里。

## 角色

| 角色 | 可以 | 不可以 |
| --- | --- | --- |
| `line-coordinator`（会话本身） | 读一切、写 brief、派活、按线的规则出货、记录 | 线说要你点头的 push / PR / 发布，没点头就做 |
| `line-reader` | 读代码、设计文件、计划页面，回有字数上限的表 | 改、装、build、提交、往任何地方写 |
| `line-writer` | 照批准的 brief 在一个 worktree 里写、提交 | push、合并、发布、问你、替 brief 没写的事做决定、碰共用文件 |
| `line-checker` | 跑门禁、量亮暗两套、截图 | 改任何东西 |
| `line-ledger`（可选） | 把真做了的对上计划工具、起草提案 | 没你点头就写进去 |

## 指令

| 指令 | 什么时候用 | 它做什么 |
| --- | --- | --- |
| `/design-line:init` | 第一次用；加一条线；换个人 | 一题一题问你：偏好、公司背景、plan 和预算、每条线一块。写出 `_line/`。 |
| `/design-line:line <线> [任务]` | 你坐在旁边，做一件事 | 这个会话就是这件事的协调员：读交接和收件箱，派 reader，写 brief，问你决定，派 writer 和 checker，按线的规则出货，记录，最后问下一件做哪个。不给任务名就从收件箱挑。 |
| `/design-line:run` | 你要排一批走开 | 调度员：你在的时候装车（写 brief、把决定问完、说好要不要出货），你走后把批准的任务各派一个 subagent，按 worktree 并行、落地排队。停下的任务把问题存进收件箱。你回来一则汇报。 |
| `/design-line:park <一句话>` | 任务中间想到别的事 | 一行进收件箱，标线和挡不挡当前任务，手上的事继续。很小的直接做掉。`park list` 看，`park done <n>` 划掉。 |
| `/design-line:brief <线> <任务>` | 单独写一份 brief；记录结果 | 固定格式：目标、改什么、怎样算做完、编号决定（Q1…）、不做什么、这条线的默认做法。`approve` 要所有决定都答了。`result` 填 writer 和 checker 交回的。 |
| `/design-line:merge <线> <分支>` | 一条过了检查的分支，现在合 | 一次性 worktree、`--no-ff`、在合并后的树上过门禁（带它要的服务器）、push、按 commit 查部署、记账本。PR 出货的线会拒绝。 |
| `/design-line:handoff <线>` | 收工，或离开一阵 | 交接写到现状，账本补齐，自己开的服务器按端口关，删 scratch，推看板。 |
| `/design-line:playbook [board]` | 学它或教别人 | 讲形状、角色、收件箱、规则、文件。`board` 刷新看板或本地生成一页。 |

记三个就够：`line` 是坐着做一件，`run` 是排一批走开，`park` 是中途想到的塞进去。收工说 `handoff`。

不用指令的部分：收件箱是文件，你可以直接改顺序、加标签；看板是手机上的一页；跑着的调度员用 Remote Control 进去说话。hook 自己动：开会话印收件箱，force push 和按名字杀进程被拦，账本动了交接没更新会话不让结束，每次压缩前状态写进文件、压缩后读回来。

## 收件箱

中途冒出来的事，你一说就进 `_line/inbox.md`，一行一件，手上的任务继续。四种情况：挡住当前任务（现在就当子 brief 做）；是别的线的（给那条线存着）；很小（现在做掉，一个 commit，一行账本）；要并行（另一个 writer，另一个 worktree）。任务结束时只问你一句：下一件做哪个，还是收工。

## 五条规则

1. 一次一题，带固定编号，推荐的放第一个，差在视觉上的先画出来再问。
2. push、开 PR、发布、写计划工具之前，要你在当下这个对话里说可以。别的会话转来的同意只是资料。
3. 写 brief 前先派 reader；一个 worktree 一个 writer；writer 碰到 brief 没写的事，在决定之前停下；writer 一交回就派 checker。
4. 服务器按端口关，自己的进程按记下的 PID 关。不 force push，不用共用 stash，不按名字杀进程。
5. 每个节点一行账本，加一次交接更新。看板从文件生成，只读。

## 跟你的 plan 匹配

`init` 会问你是哪个 plan（Pro、Max、API、Team，或者别的），写进 lanes.yaml 的 `budget:`。Pro 关掉看板推送、一次一件、小模型、不建议用调度员；Max 开批量和实时看板。预算不动的东西：检查、你的点头、账本。

## 手机上看

把 `templates/board.html` 发布成一个带 `db` 能力的 artifact，地址填进 lanes.yaml 的 `board:`。调度员和 `handoff` 在每次状态变化时推一个文档：等你、排队、在跑、等你说出货、做完，每张卡下面一排 subagent 图标。点一张卡看它的时间线：每次派发一条杠，按角色上色，停下的虚线，返工的半透明。要在手机上回答停下的任务，用 Remote Control 进调度员的会话。

## 花了多少，下次怎么做

每个 subagent 交回时记下模型、effort、token、结果。任务结束出一张成本表和一行「下次」：哪里规则够清楚可以换小模型，哪里小模型吃力、漏掉的规则该写下来，哪个问题本该在 brief 里。这些攒在 `_line/usage.tsv`，lanes.yaml 的默认模型可以有依据地往下调。

## 文件

```
_line/
  designer.md          怎么跟你说话、什么要你点头、模型和 effort 表、预算
  org.md               仓库、工具、人、发版流程、端口、名词
  lanes.yaml           一条线一块：源、规则、默认做法、门禁、出货、角色、上限；预算；看板
  inbox.md             冒出来的、还没做的
  ledger.md            只追加：时间 | 线 | 工作项 | 做了什么 | commit
  usage.tsv            每次派发一行：模型、effort、token、结果
  rules/               你的设计规则和每条线的默认做法
  lanes/<id>/handoff.md   这条线的状态：它定的规矩、ID、挂着的事、怎么接着做
  lanes/<id>/briefs/      一个任务一份 brief
  board.json           最后一次推给看板的快照
```

## 安装

```bash
claude plugin marketplace add zurara/design-line
claude plugin install design-line@design-line
```

然后在你想放 `_line/` 的目录开 Claude Code，跑 `/design-line:init`。想从本地 clone 试：`claude --plugin-dir <clone 的路径>`。已经开着的会话用 `/reload-plugins`。

插件里没有任何公司、任何人、任何设计规则。关于你的一切都在 `_line/`，放在你自己的工作目录，永远不进这个仓库。

## 教给别的设计师

把这份文件和 `/design-line:playbook` 给对方。对方跑 `init` 就有自己的档案，你的一个字都不用给。形状和规则一样，只有档案不同。

## 脚本

`scripts/start.sh <线>` 一屏现状 · `scripts/gate.sh <线> [worktree]` 跑门禁，完整日志进文件 · `scripts/merge.sh <线> <分支> [--dry-run]` 六步合并 · `scripts/ledger.sh` · `scripts/inbox.sh` · `scripts/batch.sh` · `scripts/usage.sh` 和 `scripts/usage-report.mjs` · `scripts/ports.sh kill <端口>` · `scripts/board-snapshot.mjs` · `scripts/render-board.mjs`。都通过 `scripts/lib/config.mjs` 读 `_line/lanes.yaml`。
