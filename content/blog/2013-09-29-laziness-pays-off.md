---
title: Laziness pays off !
author: Sid
type: post
date: 2013-09-29
url: /java-pad-server/laziness-pays-off/
categories:
  - Java Pad Server
tags:
  - cfg
  - config
  - config loader
  - dev
  - java

---
I think software engineers are supposed to be lazy as far as development is concerned. Confused ? Let me explain, software engineers are supposed to write good reusable code so that they won&#8217;t have to write same thing over and over again, hence be lazy ! I know this sounds funny, but recently while working on my own project as described in my previous post, I had a chance of being &#8220;lazy&#8221; so I wanted to share the experience on the same with you all &#8230;

In my almost 6 years of software development experience, I had to work on a lot of tools. Trust me when I say &#8220;a lot&#8221;, I mean it. I had to work on like 7-8 tools for various purposes &#8211; be it for an upgrade of platform or as a regression tool or as a performance driver or as a validation tool. In all those tools one thing what I always hated doing was loading some configuration into some JAVA POJOs. Those who have worked on ground up piece of software will know this is something you have to write for almost everything and it just sucks to write similar thing over and over again ! So when I started working on my recent project, I decided to make sure I will do something about this problem and try to write something generic so that I can be lazy in future. 🙂

If you see what we all as developers need is to read some specific configuration, say from a properties file or an XML and populate the same in memory as JAVA POJO which represents configuration e.g. For my socket server and client, I need configuration such as server host name, server port etc. After I do that, I&#8217;ll need to make server multi-threaded and now I&#8217;ll need no of threads as a configuration. So one thing is sure &#8211; as we work on the problem at hand, configuration we need can also grow.

Now lets take a look at what process we follow to do all of above in scenario say when we want to load configuration from a properties file:

  1. Add property to properties file
  2. Add same property as attribute to Java POJO class along with getter, setter methods following Java Bean standard
  3. Add code which will read from properties file and call respective setter method on Java POJO

This seems okay once, but when you change configuration and add new properties, you have to go back do all 3 steps over and over again. It doesn&#8217;t stop here, you can&#8217;t even use same code across your projects because its too dependent on POJO and property names.

So how about writing something generic which can easily adapt for property additions and can also work across different project so that you can truly reuse it ? What we basically need is to take POJO and property names out of the equation. Way to do this is by making sure that our &#8220;configuration loader&#8221; can work on any given class of POJO and is able to associate property names with attribute names of POJO class. Java gives you some very powerful tools to do this which is called &#8220;reflection&#8221;. Reflection gives us a way to prospect a class and find out all information about it like what methods, fields a class has.

Now instead of directly jumping to most complex situation, lets lay some assumptions such as: Property name in properties file should match field name in POJO. Now new steps to load configuration would be as follows:

  1. Prospect class of POJO and find out all public setter methods having just one argument.
  2. Instantiate POJO object using POJO class
  3. For each property name in properties file, find setter method in POJO class
  4. Convert property value to expected datatype of setter method in POJO class
  5. Set property value on POJO field using setter method

Using these steps, we have made sure that we can work on any combination of properties file and POJO class. We have created a generic facility which can give us POJO sourced from a properties file. This approach is however not without limitations, if you go through new steps you will notice we have following limitations:

  1. POJO class must have default constructor so that we can instantiate object
  2. Property names and field names should match

Obviously there are ways to work around these limitations but you get the basic point &#8211; we have successfully created configuration loader which will let us become lazy !

You can find such implementation on GitHub as part of my pet &#8220;Java Pad Server&#8221; project as follows:

Actual implementation of configuration loader can be found in a class <a href="https://github.com/BappaMorya/java-pad-server/blob/master/src/main/java/in/co/sh00nya/cmn/PropsPojoAdapter.java" target="_blank">here</a>, junit tests for the same can be found <a href="https://github.com/BappaMorya/java-pad-server/blob/master/src/test/java/in/co/sh00nya/cmn/PropsPojoApapterTest.java" target="_blank">here</a>.

Project can be found <a href="https://github.com/BappaMorya/java-pad-server" target="_blank">here</a> on GitHub. Don&#8217;t forget to visit our org <a href="https://github.com/BappaMorya" target="_blank">here</a> for other interesting project.