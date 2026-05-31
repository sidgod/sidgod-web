---
title: "Three Escape Hatches Every AI-Authored Workflow Needs"
description: "Agent workflows ship bad code by default because abandonment feels like failure. Three explicit exits — re-spec, takeover, close-and-replace — turn it into routine."
tags:
    - "ai-dlc"
    - "methodology"
    - "code-review"
date: "2026-05-31"
categories:
    - "blog"
---

The first time it happens on your team, you'll watch it in slow motion. An engineer kicks off an agent task on a Tuesday. By Thursday they've spent eight hours iterating with the agent, the PR is open, the diff is 1,400 lines, and three of the five test files were never actually run end-to-end. They know it's wrong. They know it. But it's *Thursday*, and they've been talking about this PR all week in standup, and abandoning it now means starting over and explaining to the team that the day-and-a-half they just watched go by produced nothing.

So they merge it. With a TODO. Or they push one more round of "fix the failing tests" at the agent and hope it converges.

This is the failure mode every AI-authored workflow inherits by default. Not from the tooling — from the absence of any cultural permission to abandon. Agent workflows generate more in-progress artifacts than human-authored ones, faster, with higher visible momentum. Without explicit exits that feel like normal operating procedure, that momentum carries every bad approach across the finish line.

The fix isn't another review gate. It's three escape hatches, designed in.

## Hatch One: The Spec Gap Mid-Execution

The first hatch fires before the agent starts coding, or in the first round of review. Symptom: the engineer realises mid-implementation that the spec they handed the agent had a hole. The agent is faithfully implementing what was asked. What was asked is wrong, or under-specified in a way that's only obvious now that real code exists.

The correct move is to abandon the in-flight work and re-spec. Not iterate on the implementation. Not "fix it forward." Close the branch, open the spec doc, do the thinking that should have happened before the agent ran, then start the implementation fresh.

The reason people don't do this is purely psychological. Closing a 600-line diff feels like waste. Re-running the agent feels like admission. So instead the engineer tries to bend the implementation around the new understanding of the spec, and what comes out is a Frankenstein of two different mental models — the one the agent was given and the one the engineer now holds.

Codify the hatch by giving it a name and a default action. The vocabulary I use is "re-spec." In standups, in PR descriptions, in retros: "I hit a spec gap, re-spec'd, here's the new branch." Same energy as "I rebased." Boring. Procedural. Not a moral event.

## Hatch Two: Review Loop Non-Convergence

The second hatch fires after round two of code review. Symptom: you've left agent-targeted review comments, the agent has pushed a new round, you've reviewed again, left more comments, the agent pushed again — and you're now in round three with the same class of issue still reappearing, or with new ones introduced as the old ones get fixed.

Non-convergence after round two is the signal. The agent isn't going to converge. Rounds four, five, six will burn your time and produce a PR that compiles but contains subtle wrongness across a dozen surface areas. By the time you've reviewed seven rounds of changes, you've stared at the same lines so many times you've gone code-blind on them.

The hatch: human takeover. The engineer pulls the branch, opens it in their own editor, and finishes it. Not as punishment. Not as "the agent failed." As the routine handoff that's appropriate when the cost of one more round exceeds the cost of finishing it yourself.

The trap teams fall into is treating the takeover as a defect — either of the agent or of the engineer who "couldn't get the agent to do it." Both readings are wrong. The agent has a convergence horizon. Past that horizon, human edits are the right tool. The team that internalises this stops burning rounds and starts shipping.

Two operational details. First, make round two the explicit gate, not round four. Engineers will defer the takeover decision indefinitely if you let them — there's always one more comment that *might* fix it. Second, when an engineer takes over, the takeover commit should be its own commit on the branch, not amended into the agent's history. You want the audit trail intact.

## Hatch Three: The Approach Was Wrong All Along

The third hatch is the hardest. It can fire at any round, including very late ones. Symptom: the engineer reviews the latest push and realises the *approach* — not the implementation, the approach — is wrong. The agent has built a beautiful staircase to the wrong floor. The right next step isn't another review comment. It's closing the PR.

This is the hatch that costs the most ego and saves the most time. Every engineer who's been in software for more than a few years has shipped at least one PR they knew was the wrong shape, because by the time they understood it was the wrong shape they'd already spent two weeks on it. AI workflows compress that timeline from two weeks to two days, which makes the realisation come faster but also makes the diff bigger when it arrives.

Close the PR. Comment on it: "Closing — approach was wrong, opening replacement at #1247." Open the replacement. Take what you learned from the wrong approach into the new spec. Re-run the agent.

This hatch is the one that most needs cultural permission, because closing a PR with 1,200 lines of changes looks bad to anyone scanning the GitHub activity feed who doesn't read the comment. Make the comment standard. Make the manager who looks at the activity feed read the comment. The work the closed PR did was real — it was the work of figuring out the approach was wrong, which is the cheapest version of that learning you were going to get.

## The Cultural Framing Decides Whether They Get Used

The mechanics are easy. Three exits, three names, three default actions. The hard part is making engineers actually use them.

The default cultural reading of any abandonment is failure. Failure of the engineer to "get the agent to work." Failure of the agent to be "good enough." Failure of the team's adoption story. None of these readings are accurate. All of them produce the same downstream behaviour: engineers stop pulling the hatches and start force-shipping work past the point where it should have been abandoned.

The reframe that works, in my experience, is to make the hatches operationally indistinguishable from other engineering operations. Re-specing isn't different from rebasing. Human takeover isn't different from pair programming. Closing-and-replacing isn't different from reverting a bad commit. The vocabulary is procedural, not evaluative.

Two things help. First, leadership has to pull the hatches first, visibly. The first three times a senior engineer or a staff engineer abandons their own work and re-specs in public, that's worth ten retro discussions about psychological safety. Second, the team's metrics shouldn't reward un-abandoned work. PRs merged per week is the wrong measurement. PRs merged that survive their first month is closer. Reverts per merge is closer still. The metric that punishes force-shipping is the metric that protects the hatches.

## Every Pulled Hatch Is the Signal You Wanted

Here's the part that turns the hatches from a cultural posture into an organisational asset.

Every time someone pulls hatch one and re-specs, you've just discovered a spec review failure. The spec passed review and still had a hole big enough to surface mid-implementation. That's worth knowing. Track it.

Every time someone pulls hatch two and takes over, you've discovered the convergence horizon of your current agent setup on a particular class of task. Track *what* class of task. After a quarter, you'll have a heatmap of where the agent reliably converges and where it doesn't. That heatmap is the strongest input to your next round of harness or methodology investment.

Every time someone pulls hatch three and closes a PR, you've discovered a methodology gap upstream of the spec — the brainstorm phase let a wrong-shaped problem through. That's the highest-leverage thing you can know. Patch the brainstorm process, not the agent.

Teams that don't pull the hatches don't generate this signal. They generate merged code, some of which is wrong, and a team backlog of half-acknowledged technical debt that nobody can quite trace back to a root cause. The team that pulls hatches generates fewer merges and more learning, and the learning compounds.

## What I'd Change

Two things I'd do differently next time.

First, I'd write the hatches into the PR template explicitly. Three checkboxes near the top: "Re-spec considered? Y/N." "Takeover considered (if past round two)? Y/N." "Close-and-replace considered (if approach uncertain)? Y/N." Not as gates. As prompts. The act of having to tick "no" against each of those forces a small moment of reflection that I think would catch a meaningful fraction of force-merges before they happen.

Second, I'd build a lightweight tracker for hatch pulls — a private channel or a tiny doc — where engineers self-report when they used a hatch and what they learned. Not a public scoreboard. A team-private capture, because the value is in the patterns across pulls, not in the individual events.

The escape hatches are the part of an AI-authored workflow that takes the most effort to install and produces the most value when they're actually used. Build them in early, make them feel normal, and watch the signal start to come back.
