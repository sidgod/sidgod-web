---
title: Opening Act
author: Sid
type: post
date: 2013-09-23
url: /java-pad-server/opening-act/
categories:
  - Java Pad Server
tags:
  - dev
  - java
  - server
  - socket

---
It has always been really hard for me to think of something really nice as opening act, this time I have deliberately tried not to think of anything for opening act, instead let me directly jump into who I am and what am I doing here without wasting your time !

I am Sid, working professional (!) for an MNC company in security domain. Like 10% other ppl of my experience, I am not too happy with limited things I get to do at workplace. So this is just an effort to get out of work cycle and do something that I would want to learn.

Now coming back to part where I explain what the hell is that I am doing here &#8211; well I am going to try few things on technology, philosophy and other things here which I would love to work on. Now my aim here to popularize new term that I like to use for some software engineers &#8211; &#8220;Experimental Software Engineers&#8221;. Like we have &#8220;Experimental Physicists&#8221; ! This term crossed my mind when I was in office discussing how a certain approach would work against another approach technically. Now instead of just speculating on how some thing would work, why not set up an experiment and try it out ?

So here I am trying to adopt my own philosophy of being an &#8220;Experimental Programmer&#8221;. So as a start, I am going to start with a simple problem and incrementally add complexity to the problem statement and thereby add complexity to solution as well. So lets start by defining problem statement &#8211;

> We will have a system where multiple clients will send data to a plain socket server. Data that clients send to server is nothing by collection of words. Server processes this data by counting unique number of words in each data. Clients can send multiple data lines in each connection to server. Data is sent intermittently not consistently.

Sound simple right ? Now this is very basic problem statement and as I said before, I&#8217;ll make this complex after we get successful &#8220;experiment&#8221; for current problem statement. Lets take a look at what we are looking for in our experiment:

  1. Wait time for each client connection
  2. Overall throughput of data lines / second that can be achieved
  3. CPU, Memory consumption

Now since we have so much to measure, we also need to make sure that we setup our &#8220;experiment&#8221; in such a way that experiment itself is not affected by any other external factors. This means we have to same environment for all of our experiments. For simplicity I have created a simple Ubuntu Server setup on Amazon where I&#8217;ll be running our experiment. Clients can be situated on my laptop / any other public machine which can talk to my Amazon EC server.

Lastly, one thing I would like to mention here is that it&#8217;s not just me who will be working on this, we are a group of individuals who would be working on this project. In case you want to look at the code we are developing, you can visit GitHub account for our org <a href="https://github.com/BappaMorya" target="_blank">here</a>.