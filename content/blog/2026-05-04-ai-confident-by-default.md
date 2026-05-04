---
title: "Confidently Wrong: Where Code Review Has to Move When Agents Write the Code"
description: "Agent-authored code is usually clean. Cleanly wrong is a different failure mode than messily wrong, and the review has to migrate upstream to catch it."
tags:
    - "code-review"
    - "ai-dlc"
    - "spec-driven"
    - "governance"
    - "ai"
date: "2026-05-04"
categories:
    - "blog"
---

A PR landed last month that I almost merged on the first read. The diff was tight — 200 lines, no formatting noise, idiomatic Java, decent tests. The agent had written it from a one-paragraph spec the developer pasted into the planning prompt. I ran the tests, they passed. Static analysis was clean. The PR description matched the spec. I left a "looks good" comment and went back to my queue.

Then a teammate flagged it. The spec had said "deduplicate by user id within the request batch." The implementation deduplicated by user id across the whole inbound stream, using an in-memory set that grew unbounded. The agent had picked the more aggressive interpretation, written an excellent implementation of it, and produced tests that confirmed the more aggressive behavior worked. Nothing in the diff was sloppy. The diff was the wrong feature, executed beautifully.

That PR is what I keep coming back to when people ask why our team is spending more time on reviews now, not less, even though the code itself is cleaner than it has ever been.

## The shape of confidently-wrong code

When humans write code, the doubt leaves fingerprints. There's a `TODO` where they ran out of patience. A defensive null check that doesn't quite belong. A comment that says "not sure why this works but the test goes green." A function name that hedges — `maybeGetUser`, `tryParse`. The reviewer is reading those signals as much as the code itself. The doubt is signal — it tells you where the author wasn't sure, where the spec was ambiguous, where the next bug is likely to come from.

Agent-authored code does not carry that doubt. The agent doesn't write `TODO: revisit this` because at the moment of generation, it has no inner experience of being unsure. It writes one of two things: an idiomatic implementation of what it thinks the spec said, or, if the harness is set up well, a clarifying question back to the human. The middle layer — "I'll write this and we'll see if it sticks" — is gone. By the time the diff hits review, every line has the same confidence level.

This sounds like a feature, and at the execution layer it is. The code reads cleanly. Tests align with implementation because the agent generated both from the same internal model. The PR description summarizes the diff faithfully. A reviewer scanning for the usual smells finds none of them. That is exactly the problem.

## Where review used to live

The traditional code review checklist was load-bearing in three different places. It caught style and consistency drift. It caught implementation-level bugs — off-by-ones, race conditions, N+1 queries, missing error handling. And, almost as a side effect, it caught spec ambiguity — the moments when a human author, mid-implementation, encountered a question the spec hadn't answered and made a judgment call worth questioning.

Agents have hollowed out two of those three. Style and consistency are now mostly settled by the harness — the prompt has the team's conventions baked in, the formatters run automatically, the linter flags drift. Implementation bugs still occur, but the agent's hit rate on the standard catalog of mistakes is higher than most engineers want to admit. The diff is almost always at least as careful as a senior engineer's first draft, and frequently more so.

The third one — the side-effect catch on spec ambiguity — has not just gotten weaker. It has inverted. The agent's confidence eats the ambiguity rather than surfacing it. A spec that says "deduplicate by user id" doesn't produce an implementation that asks "deduplicate within what window?" It produces an implementation that picks a window and commits to it with full conviction. Whatever was ambiguous in the spec is now unambiguous in the diff, but the disambiguation happened in a context the reviewer never sees.

## The new load-bearing question

The job that used to be "is this code clean" has migrated to "is this spec right." That sounds like a small shift in framing. In practice it changes what the reviewer reads, in what order, and what they're willing to escalate.

The first artifact a reviewer should open is not the diff. It is the spec the agent worked from. If the spec lives in the PR description, in a sibling markdown file, or in a planning document linked in the PR, that is the thing to read first and read closely. Reviewers in our team have started writing inline comments on the spec text before they look at any code. *What does "deduplicate" mean here?* *Does this account for the case where the same user id has different display names in the same batch?* *What's the expected behavior on partial failure of the upstream call?* These are questions the agent answered without ever surfacing the choice. They are also exactly the questions a careful human author would have written into a TODO and surfaced in the PR description.

Once those questions are answered, the diff reads in a different posture. You're not auditing the code — you're auditing whether the code matches the spec you just stress-tested. That is a much faster read. You can skim a 500-line agent-authored diff in 10 minutes if you've spent 30 minutes on the spec. The reverse — 30 minutes on the diff and 10 on the spec — is how a wrong feature ships.

## What to actually watch for

Five concrete patterns have shown up enough that I've started flagging them on PRs explicitly.

The first is *over-interpretation of vague verbs*. "Cache," "retry," "deduplicate," "validate" — these are all words that hide enormous decisions. A spec that says "cache the response" produces an implementation with a chosen TTL, a chosen invalidation strategy, a chosen storage tier, and a chosen serialization format. None of those choices are in the spec. All of them are in the diff. If the reviewer doesn't surface them, they ship.

The second is *missing edge cases that the agent didn't think to ask about*. The spec says "process the batch." The batch is empty. The batch has one element. The batch has 10 million elements. The agent picks reasonable defaults for all three, but "reasonable" depends on context the spec didn't carry. An empty-batch behavior of "no-op silently" is reasonable for a metrics pipeline and disastrous for a payments pipeline. The diff looks identical either way.

The third is *clean implementations of the wrong abstraction*. The agent picks an interface — say, a `RetryPolicy` — and implements it well. The interface itself is the bet. If the team's existing code uses a different abstraction for the same concept, the new one will look right in isolation and feel wrong in the context of the codebase. This used to surface during human implementation as "wait, don't we already have a thing for this?" The agent rarely asks that question unless the prompt explicitly tells it to look.

The fourth is *non-functional requirements absent from the spec*. Latency budgets, memory ceilings, audit-log requirements, error message conventions. None of these are in the one-paragraph prompt the developer pasted in. The agent doesn't violate them maliciously — it just doesn't know they exist. The reviewer is the only one who does.

The fifth is *tests that confirm the wrong behavior*. This is the trap that almost caught me. The agent generates the implementation and the tests from the same internal model. If the model is wrong, the tests are wrong in the same direction. Coverage is high. Assertions are specific. The CI is green. The behavior is the wrong behavior, perfectly tested.

## Why this pushes review up the seniority curve

I've seen organizations respond to AI-authored code by shifting review to junior engineers, on the theory that the agent has done the hard part and now you just need someone to eyeball the diff. This is exactly backwards.

A junior reviewer is well-equipped to catch style issues and surface-level bugs. The agent has already eliminated most of those. The questions that remain — *is this the right abstraction*, *does this match how the team handles errors*, *is the spec capturing the actual requirement* — require knowing the codebase deeply, knowing the product context, and having the standing to push back when the answer is "this whole feature shouldn't be built this way." That's senior work. It always was. It just used to be diluted by all the lower-level catches that surrounded it.

The other implication: review now takes longer per line on the senior end, not shorter, even though the code itself is faster to read. The senior reviewer is doing the design review and the spec review and the abstraction review in addition to scanning the diff. Throughput per reviewer goes down. The savings come from upstream — the agent absorbed the implementation effort — but they don't show up in review queue length.

## The spec as a first-class review artifact

The most concrete change my team has made is treating the spec as an artifact that gets reviewed and merged with the code, not as throwaway scaffolding. Every PR has a `spec.md` (or a section in the PR description that is structurally identical) that captures: what the agent was asked to build, what the agent assumed, what the reviewer signed off on. The merge stamps that spec with the commit SHA. Six months later, when someone is debugging a behavior that doesn't match what they expected, the spec is the first place to look — and crucially, the diff between the spec and the actual behavior is now a tractable artifact. Without that, the only record of what the team intended to build is the prompt the developer typed at 3pm on a Thursday and never saved.

This also forces the spec review to happen explicitly. A reviewer signing off on the spec is a different action than signing off on the diff. We've started treating them as separate review rounds — spec sign-off first, then implementation sign-off. The friction is real. It also catches the wrong-feature case before any code gets written, which is by far the cheapest place to catch it.

## What I'd change

Two things, neither of which I've fully solved.

First, I want a tool that surfaces the agent's ambiguity-resolution choices automatically. Right now the agent makes those choices silently — it picks a TTL, picks a deduplication window, picks an error-message tone — and the reviewer has to reverse-engineer them from the diff. I'd like the harness to emit a list of "decisions I made that weren't in the spec" alongside the diff, so the reviewer can scan that list first and challenge any of them without having to spot the choice in the code. Some harnesses are starting to do this. None do it well yet.

Second, I want an explicit "spec review" gate in our CI, separate from code review. Today both reviews happen in the same PR thread, which means the spec review gets compressed into a sentence or two and the diff review absorbs the attention. A two-stage gate — *did the spec get signed off before the agent ran*, *did the diff match the signed-off spec* — would force the spec discussion to happen in a forum where it can actually take 30 minutes without anyone feeling like the PR is stuck. I haven't shipped this yet. I suspect it's the highest-leverage change available.

The summary I keep coming back to: the agent's confidence is a feature for execution and a vulnerability at the design boundary. Different muscle. Different review rhythm. The teams that get this right will build a code-review practice that looks less like editing a manuscript and more like commissioning one.
