---
title: IoT Garden – Data Visualization
author: Sid
type: post
date: 2017-07-17
url: /iot/iot-garden-data-visualization/
categories:
  - IoT
tags:
  - Amazon CloudWatch
  - AWS
  - AWS IoT
  - AWS Lambda
  - MQTT

---
Here comes the last part of &#8220;IoT Garden&#8221; series where I&#8217;ll demonstrate how to quickly visualize data gathered from various sensors. Now for my project I wanted to visualize temperature, humidity and soil moisture collected from my garden. In last post we saw way to bring collected data upto AWS IoT over MQTT Topic called &#8220;garden/data&#8221;. In this post, I&#8217;ll walk you through how different AWS services will help us visualize this data!

<span style="text-decoration: underline;">Amazon CloudWatch Custom Metric</span>

In order to visualize our parameters, simpledt way is to plot them all against time and see them side-by-side to analyze impact of one parameter on another e.g. How does temperature and moisture impact soil moisture. In order to do this, we need to plot and store out data received on &#8220;garden/data&#8221; MQTT topic in a time series manner.

Enter &#8211; Amazon CloudWatch Metrics &#8211; CloudWatch is an AWS service that allows you to do couple of things but here, we&#8217;ll focus on just one of these called &#8220;Custom Metrics&#8221;. A metric will be a measurement against some parameter like temperature. So basically we&#8217;ll have to create 3 custom metric &#8211; temperature, humidity and soil moisture and feed data to those metric over time as we receive data on &#8220;garden/data&#8221; MQTT topic.

Now If we see data arriving over MQTT as a stream, we can process data in stream and keep recording data samples against one of custom metric.

<span style="text-decoration: underline;">Amazon Lambda &#8211; Serverless Compute</span>

Stream computing is precisely what AWS Lambda provides, with this service, you only need to work about how does a &#8220;function&#8221; work on one set of input to produce (optional) output. Since this type of computation is stateless and involves developer to just implement &#8220;function&#8221; to work on single event at a time, such services are also knows as &#8220;Function As a Service (FaaS)). AWS Lambda is one of the great providers of FaaS.

In our case, input is aggregated event that we receive over MQTT, this single event has data about temperature, humidity and soil moisture. Our &#8220;function&#8221; will then read this event and record 3 samples against 3 custom CloudWatch metrics. You can create lambda by following guide &#8211; <http://docs.aws.amazon.com/lambda/latest/dg/building-lambda-apps.html>

Together &#8211; AWS Lambda and Cloud watch will record all incoming samples against time. I again chose python as my language of choice although AWS Lambda offers various other language to choose from. My code in python looks like this:



<span style="text-decoration: underline;">CloudWatch &#8211; Visualization</span>

Now for final part, we need to see graphs for all 3 custom metrics &#8211; this can be done by using yet another service of AWS Cloudwatch &#8211; Dashboards. I created a new Dashboard, used 3 custom metrics and plotted a time series line graph for 3. My CloudWatch dashboard now looks like this:

[<img class="aligncenter size-large wp-image-55" src="/img/Dashboard-1024x640.png" alt="" width="640" height="400" srcset="/img/Dashboard-1024x640.png 1024w, /img/Dashboard-300x188.png 300w, /img/Dashboard-768x480.png 768w, /img/Dashboard-432x270.png 432w" sizes="(max-width: 640px) 100vw, 640px" />][1]

As seen here, we were able to read data from sensors, forward it to Cloud IoT service, process it, store it as time-series data and finally visualize the same. Now MQTT being publish subscribe also adds capabilities such as callbacks so say if these parameters hit certain level or if our machine learning model concludes that we need to start watering the garden, we can do all that with sam setup. But for now, I&#8217;ll conclude this series and hope to write more about followup parts of series about using this data for machine learning soon, till then c&#8217;ya 😉

 [1]: /img/Dashboard.png