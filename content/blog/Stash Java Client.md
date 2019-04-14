+++
title = "Stash Java Client"
description = "How to use Stash APIs in Java"
tags = [
    "java",
    "stash",
    "bit-bucket"
]
date = "2019-04-14"
categories = [
    "Howto"
]
highlight = "true"
+++
# Cool Off Period
Every now and then I need a "developer cool-off period" out of usually tight deliveries. Personally I take these "downtimes" to work on a small coding project to cool off of sorts!

Organisation that I works for has great manual gates on how AWS IAM policies are created and approved. Me, being one of those who review these policies always thought whether it's really needed to be done by a human. Thus came "cool off" mini project to automate IAM policy reviews. This review essentially consists of two thing:

* AWS Standards - These are structure and content of policy as specified by AWS. Typically policy has to adhere to the policy grammar as described [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_grammar.html) 
* Org Standards - On top of what AWS recommends, there are organisation specific policies like naming conventions, certain policy standards to be uphelp.

My IAM Policy review Bot was supposed to work on both these aspect and provide review comments to policy authors. While this task was simple, I was looking for a JAVA library for the final stage - Posting Review Comments on Pull Request in Stash / Bitbucket.

# Stash Java Client
When I tried to search for java client for stash I came up with multiple inplementations all over GitHub. However I was wondering if I can get a library that's supported by Atlassian so that I can trust that library without too much trouble. Luckily there is one available [here](https://bitbucket.org/atlassianlabs/stash-java-client/)

Problem however was that it lacks documentation on how to use it, specifically where to start ;) I do have habit of using TDD in my normal work so in such situations, that's where I typically start. While going through test cases I did find how to use this library and finally put it to use successfully in my IAM Policy Auditor. Here is starter code that you can just use:

{{< highlight java  >}}
package in.sidgod.stash;

import com.atlassian.stash.rest.client.api.StashClient;
import com.atlassian.stash.rest.client.api.entity.Page;
import com.atlassian.stash.rest.client.api.entity.Project;
import com.atlassian.stash.rest.client.httpclient.HttpClientConfig;
import com.atlassian.stash.rest.client.httpclient.HttpClientStashClientFactoryImpl;

import java.net.MalformedURLException;
import java.net.URI;

public class StashJavaClient {

  public static void main(String[] args) {
    String stashUsername = "<stash user name>";
    String stashPassword = "<stash password / token>";
    String stashUrl = "stash server url";

    try {
      HttpClientStashClientFactoryImpl stashClientFactory = new HttpClientStashClientFactoryImpl();
      StashClient stashClient = stashClientFactory.getStashClient(new HttpClientConfig(URI.create(stashUrl).toURL(), stashUsername, stashPassword));

      // Get accessible projects and print them to console
      Page<Project> projectPage = stashClient.getAccessibleProjects(0, 100);
      projectPage.getValues().forEach(System.out::println);
    } catch (MalformedURLException e) {
      e.printStackTrace();
    }
  }

}

{{< / highlight >}}

I was able to use this to complete last leg of my "cool-off" project successfully! Hope this'll help more developers like me to start on using right library for Stash Java client!
