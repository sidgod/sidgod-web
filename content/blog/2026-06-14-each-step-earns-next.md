---
title: "Each Stage Earns The Next: An Earned-Adoption Playbook For AI-First SDLC"
description: "AI-First SDLC isn't a banner you raise; it's four stages where each one must earn the next through real friction, real measurement, and real team confidence."
tags:
    - "ai-dlc"
    - "adoption"
    - "methodology"
date: "2026-06-14"
categories:
    - "blog"
---

I'm trying to build AI-First engineering teams, and the single most useful thing I've learned so far is that AI-First isn't a state you switch into. It's a sequence of stages, and each stage has to earn the right to the next one. You can compress the calendar. You can't skip a gate. Skipping a gate doesn't shorten the program; it cosmetically shortens it while the foundations rot underneath, and the team reverts the moment delivery pressure comes back.

That's the reason I wrote this down. Most "AI transformation" plans I see are really procurement plans wearing a methodology costume. Buy the licenses, run a lunch-and-learn, declare victory, move on. Six weeks later the usage graph is a sad asymptote and nobody can explain why. The why is almost always the same: a stage got skipped because skipping it looked faster.

Here is the four-stage ladder I actually use, what each rung earns, and how to tell whether you've earned the next one or are just standing on a painted step.

## The Ladder, Top To Bottom

The four stages are train, surface, formalize, integrate. Train the team on both the tools and the methodology. Let friction surface organically before you mandate anything. Formalize what survived into a structured AI-First Sprint. Then build toward an AI-integrated SDLC where the practices are the default, not the experiment.

The ordering encodes three principles, and the principles matter more than the labels. Methodology before tooling. Organic adoption before measurement. Team confidence before formalization. Every failure I've watched comes from inverting one of those three. So the rest of this is really a tour of what each inversion costs you.

## Stage One: Train Methodology, Not Just Tools

The first instinct of every rollout is to teach the tool. Here's the CLI, here's the IDE plugin, here's how to accept a suggestion. That training takes an afternoon and produces nothing durable, because the tool was never the hard part.

The hard part is the methodology around the tool: how to write a spec the agent can actually execute, how to brainstorm and plan before you let it touch code, how to read a plan critically instead of mashing "continue," how to recognize when the agent has drifted from intent. None of that is in the tool's documentation. It's a way of working, and it has to be taught as one.

So stage one is two trainings wearing one name. The tool training is the cheap half. The methodology training — the part where an engineer learns to drive the agent rather than be driven by it — is the half that earns the next stage. The test for whether stage one is done is not "can everyone log in." It's "can a median engineer take a real ticket, write a spec, produce a plan, and explain why the plan is sequenced the way it is." If they can't articulate the why, they've learned keystrokes, not a method, and you have not earned stage two.

The failure mode here is seductive because tool training demos so well. People nod, they generate a function, the room feels productive. Then they go back to their real codebase, hit the first non-trivial task, and quietly stop. You taught them to use the thing in a sandbox and called it adoption.

## Stage Two: Let Friction Surface Before You Mandate

Stage two is the one everyone wants to skip, because it looks like doing nothing. You've trained the team. Now you deliberately do not mandate usage, do not set targets, and do not put a dashboard on the wall. You let people use the tools on real work, in their own way, and you watch where they get stuck.

This is organic adoption before measurement, and the sequencing is not optional. If you measure first, you measure people performing adoption for the dashboard. They'll run the agent on tasks where it doesn't help just to move the number, and you'll learn nothing about where it actually fits. Worse, you'll harden the wrong practices into your eventual standard because they looked good on the chart.

What you're harvesting in stage two is friction — the honest, specific complaints that only show up when someone is trying to ship real code. "The agent keeps regenerating files I told it not to touch." "Planning takes longer than just writing it for tasks under twenty minutes." "Code review on agent-authored PRs takes me longer than authoring would have." Each of those is a gift. It tells you where your eventual methodology needs an answer.

I run a recurring forum for exactly this — a standing slot where engineers bring the friction, no agenda, no judgment. The point is to make complaining safe and specific. The thing you're listening for is the difference between "I don't like it" and "here is the exact seam where it breaks." The second kind is what you formalize against.

You've earned stage three when the friction stops being novel. When the same five problems keep coming back and the team has, informally, started solving them the same way, the practice has discovered its own shape. That convergence is the signal. Forcing a structure before it appears means inventing a process for problems you don't understand yet.

## Stage Three: Formalize Only What Survived

Now you formalize — but only what survived stage two. This is the AI-First Sprint: a sprint run deliberately with the methodology as the default, with the practices that emerged from real friction baked in as the standard way of working rather than an experiment a few enthusiasts run.

The reason this comes third and not first is team confidence before formalization. A structured sprint is a commitment. You're telling people "this is how we work now," and that statement only holds if the team already believes the method works, because they've watched it work on their own tickets. Formalize too early and you're asking people to commit to a process they have no evidence for. They comply on the surface and revert the instant a deadline gets tight, because the process was never theirs — it was imposed.

Formalizing what survived looks concrete. The spec format that the team converged on becomes the ticket template. The brainstorm-plan-execute rhythm becomes the expected flow, with the plan reviewed before execution rather than after. The code-review adjustments people figured out for agent-authored changes become the review checklist. None of this is invented in a planning meeting. All of it is promoted from practice that already earned its place.

The failure mode at this gate is formalizing the aspiration instead of the reality. Someone writes the process they wish the team followed, not the one that survived contact with real work. You can spot it because the document is cleaner than anything anyone actually does. A formalization that's prettier than your observed practice is a formalization that won't hold.

## Stage Four: Integrate Until It's Just How We Work

Stage four is the AI-integrated SDLC — the point where the practices stop being a "program" with a name and a sponsor and become the unremarkable default. New engineers learn it as the way the team works, not as a special initiative. The methodology is in the templates, the review process, the definition of done. There's no dashboard tracking adoption because adoption isn't a question anymore.

This is the stage you can't rush precisely because it's defined by absence — the absence of the scaffolding you needed in the earlier stages. You know you're here when you can remove the training, the friction forum, and the usage tracking, and nothing collapses. If pulling the scaffolding makes the practice fall over, you're not integrated. You're propped up.

Most organizations never reach stage four, and many that claim to are actually living in a permanent, anxious version of stage three, where the process holds only because someone keeps pushing it. That's fine, honestly. Stage three with an engaged sponsor delivers most of the value. The mistake is believing you've reached four when you've only built a stage-three habit that requires constant energy to maintain.

## Why Skipping A Stage Costs More Than It Saves

The whole model rests on one claim: skipping a stage doesn't accelerate the program, it cosmetically shortens it. Let me make that concrete with the most common skip I see, which is jumping straight from stage one to stage three. Train the team on Monday, mandate the structured sprint on the following Monday, skip the messy organic middle entirely.

It works for about three weeks. The early adopters carry it. The dashboard looks great. Then the first hard sprint arrives — a real deadline, an incident, a quarter-end crunch — and the team reaches for what they trust. What they trust is the old way, because they never accumulated the evidence that the new way survives pressure. That evidence is exactly what stage two produces. You skipped the stage that builds the confidence that the formalization in stage three depends on. So the formalization had nothing under it, and it folded the first time it was tested.

The cruel part is that the skip is invisible while it's happening. The cosmetic version of the program is indistinguishable from the real one for about a month. You only find out you skipped a gate when pressure arrives and the foundation isn't there. By then you've spent the political capital and the team is quietly cynical about the next initiative.

## What I'd Change

If I were starting over, I'd change two things about how I run this.

First, I'd make stage two louder. My instinct has been to keep it quiet — no mandates, no metrics, let it breathe. But "quiet" reads as "abandoned" to a team that's used to initiatives having momentum. People assumed the program had died because nothing was being tracked. I'd keep the no-metrics rule but pair it with visible, frequent engagement — show up to the friction forum, repeat back what you're hearing, make it obvious the silence is deliberate and not neglect.

Second, I'd define the gates more explicitly up front, including for whoever is sponsoring the program. Leadership always wants a date, and they're not wrong to want one — they're usually reacting to a model that's been left implicit. If you hand them the four gates and the specific exit criteria for each — "we move to the structured sprint when the same friction stops being novel, and here's how we'll know" — they have something concrete to plan against, even without a calendar date. Earned adoption and executive planning aren't actually in tension. I used to make them feel that way by keeping the ladder in my head instead of on the wall.

The principle I wouldn't change: methodology before tooling, adoption before measurement, confidence before formalization. Every time I've seen a program fail, it inverted one of those three. The ordering is the whole method. The stages are just where the ordering becomes visible.
