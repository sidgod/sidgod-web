---
title: "ADRs Didn't Stick. Distilled AI Sessions Might."
description: "Why ADRs keep failing, why decision reasoning now evaporates into closed chat tabs, and how distillation turns those sessions into both a searchable legacy for the next engineer and the LLM-wiki memory layer (Karpathy's pattern) your future agent sessions will read from."
tags:
    - "architecture"
    - "ai"
    - "sdlc"
    - "knowledge-management"
    - "context-engineering"
    - "workshops"
date: "2026-04-16"
categories:
    - "blog"
---

About a year and a half ago I introduced Architecture Decision Records to my team. Classic Michael Nygard format, one Confluence page per decision, parked in our team space alongside everything else. Everyone nodded. We wrote a bunch in the first six months. By month nine we'd added a few more. By the end of the year I stopped asking.

This isn't a story unique to my org. Every engineering team I've talked to has the same arc with ADRs: real enthusiasm, genuine early output, slow fade. The diagnosis usually gets blamed on culture or discipline. I think that's wrong. The diagnosis is friction.

## What ADRs were actually for

Strip the template away and an ADR exists to preserve one thing: the *why* behind a decision. Not the what — the what is in the code. The *why* — the tradeoffs we weighed, the options we rejected, the constraints that were true the day we chose — is the thing that evaporates, and the thing that future-you (or the next architect) would pay money to have.

The ADR template tries to capture that *why* by making you stop, open a blank template, and write it out in a structured way after the decision is already made. And that's the friction problem. By the time you sit down to write the ADR, the conversation is over, the decision feels obvious in hindsight, and the tradeoffs you spent two days wrestling with have already collapsed into "we picked Kafka." The doc that comes out is flat. You know it's flat as you write it. So next time, you skip it.

Our choice of Confluence didn't help either. The ADR pages lived one system removed from the code they documented — un-greppable, un-diffable, one context-switch away from any editor an engineer actually worked in. A markdown ADR in a repo at least sits next to the thing it describes. Confluence piled an infrastructure tax on top of the cognitive one.

## Where the "why" actually lives in 2026

In the AI-in-SDLC world, something interesting has happened: we're generating *more* reasoning than ever, not less. A real architectural decision today looks like a 90-minute chat session with Copilot or Claude, where the engineer pastes in constraints, explores three options, asks for counterarguments, stress-tests the winner against failure modes, drafts the implementation, revises it twice. The *why* is all there. Every branch we considered and rejected. Every assumption we tested. The moment the decision crystallized.

And then the tab closes and it's gone.

Multiply that by every engineer on your team. Right now, the richest record of decision-making your org has ever produced is being generated daily and thrown away daily. Compare that to the ADR era, where the record was thin but at least durable. We've inverted the problem: from poor-quality-but-preserved to rich-but-ephemeral.

## The distillation technique

In the Copilot + Superpowers onboarding session I've been running for our engineers, the single practice I push hardest is this: at the end of any meaningful session, distill it.

The mechanics are mundane on purpose. When the session is winding down and you've landed on a direction:

> Summarise this session as a decision record. Include: the problem I was solving, the options I considered, why I rejected the ones I rejected, the option I picked, the assumptions I'm making, and the things I'd want to revisit if those assumptions break.

The AI already holds the full context. It's the cheapest possible prompt to run. What comes back is usually 80% right — tighten it, paste it into a markdown file, commit.

Where that file goes matters. Two patterns I've seen work:

- A `decisions/` folder in the relevant repo, same idea as ADRs but with the per-decision friction measured in seconds instead of an hour.
- A personal `brain/` or `second-brain/` repo that each engineer keeps, org-visible but personally owned. This is the one I push for non-architectural decisions — debugging sessions, spike outcomes, "why this config value is 30 and not 60."

The naming convention is loose. Dates work. Short slugs work. The point isn't taxonomy, it's that the file exists and is grep-able six months from now.

## Why this sticks where ADRs didn't

The ADR playbook asked engineers to produce a new artifact *after* the decision was made. Distillation asks them to produce the artifact *from* the decision they already talked through. The marginal cost is one prompt and one commit.

There's a second-order effect worth naming. Once you've got a couple of months of distilled sessions in a repo, they become queryable. You can point an AI at your own folder and ask "did I decide anything about retry semantics for the payments service in the last quarter?" — and get a real answer, with the reasoning intact. Your past decisions become a resource you can interrogate, not a museum you occasionally visit.

## From personal archive to agent memory

There's a second reader for this corpus, and it's not a human.

Andrej Karpathy [recently sketched](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) what he's calling the *LLM Wiki* pattern — instead of agents doing RAG-style retrieval from raw sources at query time, you maintain a persistent, structured set of markdown files that an agent reads directly as context. An index file orients the agent; individual topic files cover architecture decisions, module notes, coding conventions, and known pitfalls. Memory as synthesis rather than retrieval.

A checked-in `decisions/` folder is exactly that store — Karpathy explicitly names architecture decisions as one of the canonical topics in the pattern. The same file that lets the next engineer reconstruct why you picked a particular retry policy is, to an agent, priming context for every future session that touches retry logic. *Here's what this team has already decided about timeouts. Here's what we tried and abandoned. Here are the assumptions that are load-bearing.* The agent walks into the session already aligned with the team's accumulated judgment instead of re-deriving it poorly — or worse, confidently re-deriving it differently.

Karpathy's default path to building the wiki is to have an LLM compile it from raw source material. Distillation is the other path: humans growing the wiki organically from live reasoning, one session at a time. Same destination, different economics — distillation front-loads the human thinking (which is where the real judgment lives anyway) and treats the AI as the scribe rather than the synthesiser.

The compounding effect is the interesting part. In an org that's been distilling for a year, the next agent session isn't starting cold — it's starting with a year of the team's reasoning as its working set. New engineers get the same benefit on their first day. That's a different kind of asset from a codebase or a doc site. It's judgment, serialized, and it keeps paying out.

Which makes the capture habit matter more, not less. Every session you don't distill is a paragraph that neither the next engineer nor the next agent gets to read.

## The TOI problem

Here's the part that matters more than the technique.

Think about how knowledge transfer actually works when someone leaves an org. There's a transition meeting, maybe two. They walk through the repos they owned, the on-call playbooks, the stakeholder map. Artifacts transfer cleanly — the code is the code, the runbook is the runbook. But the *why* almost never does. Why did we pick this queue? Why is this timeout 500ms and not 1s? Why did we abandon the migration we started in Q2? That knowledge is in their head, and most of it walks out with them. The new person inherits a system whose shape they can see but whose logic they can't reconstruct.

This has always been true. It's just more acute now, because the density of decisions per engineer per week has gone up with AI in the loop. We're making *more* decisions, faster, with fewer of them written down.

A checked-in distilled-session corpus is the first honest answer I've seen to this. It's not a perfect handoff — nothing is — but it's a searchable, queryable quantum of *every decision this person made and why they made it*. When they leave, that corpus stays. The next person inherits not just the code but the reasoning that produced it.

I've started to think of this as an individual engineer's real legacy. The code you wrote will be refactored; the systems you designed will be replaced. But the reasoning — the accumulated judgment of why you did what you did — can compound if you capture it. It's the closest thing to durable institutional memory we've ever had at the individual level.

## The team habit

The last bit is the part I'm still working through. Distillation is low-friction at the individual level. Making it a team *norm* — where the corpus is visible, cross-searchable, and expected — is a different problem. My current bet is a weekly pass: each engineer commits their distilled decisions from the week into a shared repo with a light PR review that's more "did you include the tradeoffs" than "is this well-written." No templates. No gates. Just the habit of capturing-and-checking-in.

If ADRs died from friction, this is the attempt to run the same play with the friction actually removed.

I'll report back on whether it sticks this time. If you've tried something similar — or something better — I'd genuinely like to hear it.
