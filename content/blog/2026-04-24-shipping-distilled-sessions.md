---
title: "Distilled Sessions Were a Personal Practice. Then I Had to Ship Them."
description: "What changed when I took the distilled-AI-sessions idea from a personal habit to team infrastructure — four architectural shifts between the blog post and the production build."
tags:
    - "architecture"
    - "ai"
    - "sdlc"
    - "knowledge-management"
    - "adoption"
    - "claude-code"
    - "copilot-cli"
date: "2026-04-24"
categories:
    - "blog"
---

A few weeks ago I wrote that ADRs decay because they ask you to write a new artifact after the decision is already made, while an AI session already holds the reasoning. The fix was a one-prompt distillation at session end. Personal practice. I've been doing it for months and it works.

Then I had to ship the same idea to two engineering teams at work.

This post is what changed between the essay and the infrastructure. Four things shifted materially once I stopped writing for myself and started designing for a team of other people's engineers who haven't read the post.

## Shift 1: one script became two, with different trust models

In the blog post's framing there's "a script" that turns distilled sessions into a wiki. In my head it was one thing. The first concrete design I sketched was also one thing: read the `sessions/` folder, regenerate the index, update cross-links, build entity pages for recurring topics by asking an LLM to synthesize across sessions. Ship it, run it nightly, done.

I stopped when I noticed I had collapsed two operations with completely different trust models onto the same codepath.

The maintenance operations are deterministic. Regenerating `index.md` is alphabetical ordering plus front-matter parsing. Updating a chronological `log.md` is appending a row. Finding orphan wikilinks is a directed graph walk. Resolving supersedes chains is pointer-chasing. None of these need an LLM, none of them can get an answer "mostly right," and the correct failure mode for all of them is fail loudly and let a human fix it.

The synthesis operation is the opposite. Asking an LLM to aggregate five sessions about retry policy into a single entity page is probabilistic, context-window-bound, and needs review every single time. The best outcome is "reviewed and accepted 80% of the time." The worst outcome is a confidently wrong entity page that nobody catches because it looks authoritative.

These should never share a codepath. They shouldn't share a CI trigger. They probably shouldn't share a reviewer.

So the actual design is two scripts. A deterministic maintenance job that runs daily and is a reasonable auto-merge candidate. An on-demand entity generator that is explicitly human-in-the-loop, written but not wired up, and won't run until session volume makes review worth the time.

Karpathy's original LLM Wiki gist is worth reading if you haven't — it leans on the synthesis path as the primary one. Curated sources in, LLM-compiled pages out. The strongest critique in that comment thread goes something like: if every page is a synthesis, the wiki has no authority independent of the model. Claims have no traceable provenance. Errors compound silently. I think that critique is right for a shared organizational wiki, which is exactly what I'm building.

So I inverted the default. Scribe by default — humans judge, LLM wordsmiths, every session is a receipt of the judgment trail. Synthesize as a separate, explicitly reviewed layer where every entity page cites the sessions it was built from. The split is load-bearing. The moment I collapsed it, half the architectural guarantees disappeared.

## Shift 2: "raw" became "distilled" — and that is a load-bearing rename

In early drafts I had a folder called `raw/` where engineers dropped their distilled sessions. The entity pages were the "cooked" synthesis. It felt clean.

It was exactly wrong.

Karpathy's framing — and most RAG framings — use "raw" to mean immutable source documents that the LLM compiles over. Research papers, transcripts, documentation. By calling distilled sessions "raw," I was flattening the distinction between the two most important categories in the whole design: source material (which isn't the session, it's the hour-long chat transcript behind it) and distilled artifacts (which is what the session file actually contains — already a judgment-filtered record).

The rename sounds pedantic. It isn't. The whole provenance claim of the scribe-over-synthesizer approach depends on sessions being clearly distilled artifacts with human judgment baked in. If you call them "raw," you've implicitly downgraded them to inputs, and the next reader — human or LLM — treats them that way: something to be reprocessed, rather than cited.

So the folder is `sessions/`. The raw source is the ephemeral chat transcript that produced the distillation, and it lives nowhere in the repo. Distilled sessions are first-class outputs, not inputs to further synthesis.

One of the more humbling patterns I keep running into with AI-adjacent architecture is that terminology is architecture. The name isn't a label on the thing; it's an instruction to every future reader about what to do with it. Get the name wrong and the shape of the thing erodes inside six months.

## Shift 3: repo-level instructions became user-level, conditional on an env var

The distillation post showed the practice inside a single repo. Engineer works in `project-x/`, runs a session, distills at the end, commits the session file to `project-x/decisions/`. Clean. Contained.

Team infrastructure doesn't look like that.

The wiki — where distilled sessions actually go — is its own repo. Engineers work in their product repos all day. They don't `cd` into the wiki repo to work. They distill a session about their product code and need the session file to end up in the wiki, as a PR, from wherever they happened to be working.

That broke every instinct I had about where to put agent instructions.

Repo-level `CLAUDE.md` (Claude Code) and `AGENTS.md` (Copilot CLI) are the obvious answer to "where do I tell the agent how to distill." But they live in the repo the engineer is *in*, not the wiki repo. So every product repo would need to know about the wiki. Every PR in every product repo could accidentally carry wiki-config drift. And engineers using the same tools for personal projects on their laptop would have company distillation behavior leaking into their side work.

The design I landed on is user-level, conditional on an environment variable. `~/.claude/CLAUDE.md` holds a managed block that only activates when `$WIKI_REPO_PATH` points at a valid wiki checkout. `~/.copilot/agents/distiller.agent.md`, loaded via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`, does the equivalent for Copilot CLI. Both files are symlinks back into the wiki repo. When the template changes, it's one PR to the wiki repo and every engineer picks it up on their next `git pull`. A small bootstrap script sets the symlinks and the env var in their shell RC.

Two things I like about this shape.

The conditional activation is what keeps it safe. An engineer on vacation building a Raspberry Pi project has no `$WIKI_REPO_PATH`, so the distillation block is a silent no-op. Nothing fires. Personal context stays personal. Silent no-op turns out to be much better than a broken error path; I had the latter in the first bootstrap and it sent everyone straight to "this tool is janky."

The symlink-not-copy decision is what keeps it maintainable. The first design copied the template into `~/.claude/` at bootstrap time. Every template change required a re-run on every engineer's laptop. That's the road to stale installs, divergent behavior, and the ops person nobody hired. Symlinks turn the wiki repo into the canonical source: `git pull` is the update mechanism.

This pattern — user-level tooling, conditional on a repo-pointing env var, symlinked back to a canonical repo — generalizes beyond distillation. Any cross-repo agent behavior that shouldn't pollute unrelated work can use it. It's the thing from this build I most wish someone had told me six months ago.

## Shift 4: manual discipline became three-layer compliance

The blog post assumed the distilling engineer would remember to distill. Fine for me. Sketchy for a team.

The ADR critique applies recursively. If "write an ADR" decays because it's friction added after the fact, "distill the session" decays the same way the moment it stops being a new toy. You have to design for decay, not against it.

So the infrastructure has three compliance layers, and no single layer carries the load.

Layer one is defaults that nudge. The user-level instructions tell the agent to offer distillation when it detects a wrap signal — "let's ship it," "okay I think we're done," a clean git commit at the end of a session. The offer is advisory. The agent doesn't block. This is the cheapest layer and does most of the work on a good day.

Layer two is explicit invocation. A `/distill` slash command in Claude Code and a `/agent distiller` entry point in Copilot CLI. For the cases where the engineer knows this session is worth distilling and doesn't want to wait for the agent to pattern-match their wrap signal. Also the fallback when layer one misfires — and it will misfire, because skill auto-invocation is description-pattern-matching, not deterministic.

Layer three is verification, not enforcement. A `SessionEnd` hook flags sessions that ended without a distillation for review. A pre-push hook on the wiki repo validates session front-matter. A PR trailer check looks for `Session: <slug>` on product-repo PRs that touch architecturally significant code, and nudges (not blocks) if missing.

Each layer alone is insufficient. Defaults decay. Explicit invocation misses cases where the engineer didn't realize the session was worth keeping. Verification alone is punitive — "you forgot to distill, bad engineer" is the kind of thing that ensures nobody ever distills again. Layered, each one covers the others' gaps.

My honest estimate at steady state is 70–85% compliance. Not 100%. The remaining gap is a coaching problem, not a tooling problem, and the worst thing I could do is try to close it with a blocking gate. The cost of blocking is that engineers route around the tool. The cost of nudging is that some sessions don't get captured. The second cost is lower.

If I had put this layer into the original blog post, it would have been half the post. That was the signal that the first post was about personal practice, and this one is about team infrastructure. Two different audiences. Two different problem shapes.

## What I'd revisit

A handful of triggers I'm watching, in rough order of likelihood.

If compliance falls below ~50% after two sprints of rollout, the nudging model isn't strong enough and layer three probably needs to move from advisory to blocking on a narrow set of PR types. I'd rather not. I'll know in a month.

If the session template gets edited more than twice in a sprint, it's capturing the wrong shape and I should redesign rather than keep patching. Every template change is a soft signal that the original taxonomy was wrong.

If engineers on the second team can't find prior sessions via Obsidian or grep, I move forward on using a persistent agent Project as the query layer. Right now I'm betting Obsidian graph view plus filename conventions are enough. We'll see.

If the volume of distilled sessions crosses ~150–200, I need the entity generator wired up before the index becomes unreadable. Karpathy's comment thread surfaces this exact scaling problem. We have time, not forever.

## What's next

Two follow-up pieces I've queued, both of which are patterns that generalize beyond this specific build.

Three-layer compliance as an adoption model — defaults plus invocation plus verification — for any tool where "the engineer is supposed to remember." It's the most broadly applicable thing in this writeup and I think it's worth its own post.

User-level tooling with env-var-conditional activation, for cross-repo agent work. The `$WIKI_REPO_PATH` pattern is small, but I couldn't find it written up anywhere when I needed it, and cross-repo is going to be a common shape for any team that uses more than one repo and more than one agent.

Both later. For now, the infrastructure is built, the first team is onboarding, and the next post I write about this will be a retrospective on whether the 70–85% number held.

---

**Previous:** [ADRs Didn't Stick. Distilled AI Sessions Might.](/2026/04/16/distilled-sessions-searchable-legacy/)
**Stack:** Claude Code skills, Copilot CLI agents, bash + git, and a lot of rewrites.
