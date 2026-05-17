---
title: "Stop Comparing Models. Compare Harnesses."
description: "The model is no longer where most of the AI engineering work happens. The harness around it is — tool definitions, prompts, control flow, memory, policy. Most teams are building one without realising it."
tags:
    - "ai-dlc"
    - "harness-engineering"
    - "governance"
    - "methodology"
    - "ai"
date: "2026-05-17"
categories:
    - "blog"
---

A senior engineer pinged me last week with a one-liner: "There's a new model out, we should re-run our agent eval against it." Reasonable request. We have a small benchmark — twenty real tickets from our backlog, scored by reviewers on a four-axis rubric. Swapping the model behind our agent and re-running the benchmark is a half-day of work. We've done it three times in the last six months.

I told him to hold off. Not because I didn't trust the new model — I hadn't even read the release notes. I told him to hold off because the last three swaps had moved the rubric scores by less than the variance between two runs of the *same* model on the *same* benchmark. The model was not where the score was being decided. The harness was. We just hadn't built the muscle to evaluate that.

This post is about why that's the default situation now, what a harness actually is, and why "we should evaluate the new agent" is almost always the wrong question.

## Agent = Model + Harness

The framing I keep coming back to is one I first saw in a Stanford research note circulating earlier this year: an agent is a model plus a harness. The model is the LLM weights and the API. The harness is everything else. Tool definitions. System prompts and skill files. Control flow — when to call which tool, when to spawn a subagent, when to stop. Memory — what gets written down, where, in what format, and what gets re-read into context next time. Policy — what's allowed without confirmation, what requires a human-in-the-loop, what's flatly blocked.

For most of 2023 and 2024, the model dominated. Capability gaps between releases were so wide that a model upgrade reset the ceiling for the entire stack. You could build a thin harness, swap to the next model, and get a step-change in agent behaviour without doing any harness work at all. Evaluating models in isolation made sense because the model was almost everything.

That world is gone. The frontier models are tightly clustered on most tasks an engineering team cares about. The next agent isn't going to be a meaningfully better coder on your codebase because the model went from a 71 to a 73 on some public benchmark. It's going to be a meaningfully better coder on your codebase because the harness wrapped around it learned how *your team* writes specs, where *your* tests live, what your review loop looks like, and what to do when it gets stuck. That work doesn't ship in a model release. It accumulates in your repo.

## Most teams are already building a harness — they just don't have the vocabulary

The funniest part of running adoption sessions for engineers is watching them realise they've been building a harness for months without naming it.

A team I worked with had a CLI agent wrapped in a small repo of methodology files — a brainstorming skill, a planning skill, a "before you ship" checklist. They had a tool-approval hook that blocked any shell command outside an allow-list. They had a registry of MCP servers checked into a GitHub Pages site, with a vetting checklist for every entry. They had a decisions folder where engineers committed distilled session summaries.

That's a sophisticated harness. Tool definitions, prompts, control flow, memory, and policy — five for five. But because they'd built it piecewise, each addition framed as "a small thing to fix one problem," they didn't think of the whole as an engineering surface. They thought of it as scaffolding. So when someone asked "are we doing AI engineering?" the honest answer was "we're using Claude," not "we've built a harness."

The cost of that vocabulary gap is real. You can't budget for a thing you don't name. You can't staff for it. You can't compare it against an alternative. And — the part that hurt — you can't evaluate it, because every conversation about evaluation drifts back to the model.

## What changes when you call it a harness

Once a team names the harness, three things move.

The first is investment. A harness is a system. Systems get owners, roadmaps, refactor cycles, and tests. Every team I've seen adopt this framing within a quarter ends up with at least one engineer whose job is partly to maintain the harness — tightening up skill files when they produce noisy plans, tuning the tool-approval policy when it blocks too often or not often enough, pruning memory artifacts that are stale or wrong. None of that work makes sense as a line item until you name the thing it serves.

The second is comparison. "Should we switch to agent X?" stops being a meaningful question once you accept that the agent is mostly the harness. The right question becomes: "Can we keep our harness and swap the model underneath, or does the new agent's harness do something ours can't?" That second question is tractable. You can list what your harness does — your skills, your hooks, your registry, your memory model — and check item by item whether the new candidate has a near-equivalent or whether you'd be giving something up. The first question is just vibes.

The third is portability. A harness that's checked into a repo is portable. The model behind it is a swap. Teams that internalise this start designing their harness to be model-agnostic on purpose — abstracting the tool-call interface, keeping skill files free of model-specific tics, building their own evals that score the *combined* system on tasks that matter to them. That's how you future-proof against the next model release without holding your breath for it.

## The components of a real harness

I've been keeping a working list of what counts as harness surface in the teams I work with. It's not exhaustive but it's a useful audit.

**Tool definitions.** Not just the names. The descriptions, the parameter schemas, the example invocations, the "when to use this" guidance. A well-written tool description is the difference between an agent that picks the right tool first try and one that fumbles through three wrong ones. This is prompt engineering masquerading as schema design.

**System prompts and skill files.** The persistent instructions the agent reads on every session. In a Claude-style harness this is `CLAUDE.md` plus a tree of skill files keyed off of intent. In an OpenAI-style harness it's the system message plus retrieval-injected context. Either way, the surface is yours, and it compounds. Every team that takes this seriously ends up with a small in-house library of skills they reuse across projects.

**Control flow.** When does the agent plan before acting? When does it spawn subagents? When does it stop and ask? When does it write to memory? Most of this isn't in the model — it's in the orchestration layer you've built around it. Even if you're using an off-the-shelf agent framework, the configuration you've chosen *is* control flow.

**Memory.** This is the one that's evolved fastest. A year ago, memory was retrieval over a vector store and you tuned it like a search problem. Today, the patterns that work look more like a checked-in markdown wiki — decisions folder, conventions file, glossary, known-pitfalls list — that the agent reads as primary context. The harness decides what gets written, where, when, and what gets read back in. None of that is the model's job.

**Policy.** Tool-approval hooks, allow-lists, deny-lists, secrets scanning on outbound calls, mandatory human-in-the-loop on destructive operations, MCP registry vetting. This is the part that determines whether your security team will let the harness near a production codebase. It's also the part most teams keep outside of version control by accident, which is its own problem.

You can do this audit on any team's setup in a one-hour session. The output is always more harness than they realised they had — and usually a clear list of three or four components that are weak, untested, or completely missing.

## "Compare harnesses, swap models" as a planning principle

Once you accept the framing, it changes how you plan tooling decisions.

A team I talked to was halfway through a months-long evaluation of three coding agents — call them A, B, and C. They had a benchmark, they had reviewers, they had a scoring rubric. The problem was that every time a new model release dropped, one of the three vendors had a new version available and the rest didn't. The rankings shuffled every two weeks. The team kept extending the evaluation window. Six months in they still didn't have a recommendation.

The reframe was: stop trying to pick the agent. Pick the harness. Which of A, B, or C has the harness components your team actually needs — the skill system, the tool policy, the memory model, the orchestration features? Whose harness is most aligned with how your engineers already work? Whose is most extensible? Once you've picked the harness, the model underneath is a config knob. You can re-run the eval every time a new model drops, and the answer is "use the best model the harness supports" — a question that takes an hour, not a quarter.

They picked a harness in two weeks. The "which model" question became operational instead of strategic. The model-evaluation cycle went from quarterly to weekly. And the strategic conversation moved up a layer — to which skills to invest in, which policies to harden, what to add to the registry next.

## Why this is underrated

Harness engineering is underrated for two reasons, and they're related.

The first is that it doesn't *look* like engineering when you're doing it. You're writing markdown files. You're tuning a prompt that already mostly works. You're adding a hook that blocks one specific command. None of these feel load-bearing in the moment. They all feel like small adjustments. But the compounding is real — six months of small adjustments produces a harness that does things off-the-shelf can't, and you have no good way to externalise the value of that work.

The second is that the industry's vocabulary lags the reality. "We're evaluating AI tools" gets head-nods and budget. "We're building a harness" gets a blank stare and a "what's that?" The teams doing the most sophisticated work are often the ones with the worst story to tell about it, because they're inside the work and the field hasn't given them the words yet.

Naming it helps. So does writing it down, talking about it, and treating it like the discipline it is. The teams that get there first will spend the next two years compounding their advantage while everyone else re-runs the model benchmark for the eighth time.

## What I'd Change

If I were starting a team's AI engineering practice today, I'd do three things differently than I see most teams doing.

First, I'd write the harness audit checklist on day one and put it next to the methodology docs. Tool definitions, skill files, control flow, memory, policy — five components, scored honestly. Every quarter, score it again. Watch the components move.

Second, I'd separate the model-evaluation rig from the harness-evaluation rig. Model evals are short, narrow, and frequent — a benchmark you can run in an afternoon when a new release drops. Harness evals are longer, broader, and run on real tickets — quarterly at most, ideally tied to a real sprint where the team is using the harness in anger. Conflating the two is what produces the noise that makes the whole exercise feel pointless.

Third, I'd make the harness ownership explicit. One engineer, named, with a portion of their time allocated to harness work. Not a committee. Not "everyone." A named person whose job is partly to keep the harness sharp. The teams I've seen do this end up six months ahead of the teams that don't, and it's not close.

The model is going to keep getting better. That's table stakes. The harness is the part that's yours.
