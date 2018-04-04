---
title: New beginning … IoT Garden
author: Sid
type: post
date: 2017-06-12
url: /iot/new-beginning-iot-garden/
categories:
  - IoT
tags:
  - Arduino
  - AWS
  - esp8266
  - IoT
  - Raspberry Pi

---
### The Background

I&#8217;ve been away from the writing scene for far too long. I thought to myself now if I don&#8217;t start on this now, I never will! So here it is me trying to get out of my default &#8220;procrastination mode&#8221; and write something up useful (maybe!).

I have couple of things to write about but let me start by writing about something I am recently working on as hobby project. I had a technical event in my company and there I was facilitator for a workshop on IoT. While carrying it out, something inside me got very excited and had me dig up all my IoT stuff &#8211; old boards, electronic components etc, even new things were ordered on Amazon! Now I know that &#8220;thing&#8221; inside me that got excited was probably my inert electronics and telecommunication engineer 😉

So here is what I am going to try doing in short &#8211; Create a smart garden controlled by IoT devices.

Another reason why I think it would be awesome for me to do it now is that rainy season if upon us (in India) so I get to actually put my experiment to test. This experiment in single line would be as follows:

> I want to optimize daily usage of water in my home garden

Meanwhile this also lets me use this experiment to provide data for a (almost) real life machine learning exercise &#8211; I want to predict how much water do I have to use given past data and future climate predictions!

### The Experiment

From what I can think of now, this experiment of mine is going to involve following things:

  1. Assume some fixed water being use on watering garden daily
  2. Measure temperature, humidity and soil moisture for single pot
  3. Read these measurements daily / hourly
  4. Send these readings on Cloud provider
  5. Analyze data, choose and implement machine learning model, fir model on data
  6. Predict water needed based on predicted weather and model trained in step 5

Now this might sound like too much work for such a simple thing but it lets me use everything that I want to learn 🙂

Now, so far I already have a Raspberry Pi 2, Arduino Uno, ESP8266 and sensors for Temperature, Moisture and Soil Moisture. It seems like all I need to do is figure out how to put all these pieces together and make it work! I do have two options to put together:

  1. Attach sensors to Arduino, send data over serial port to Raspberry Pi, Raspberry Pi then takes care of sending data over to cloud provider &#8211; AWS IoT Platform.
  2. Attach sensors to ESP8266, send data over to cloud. I however know for sure, due to limited support for SSL, I&#8217;ll not be able to send data over to saw AWS IoT platform in its current form of ESP8266.

One important aspect here that should be considered is that all data will be sent over WiFi network @ my home. I&#8217;m not so sure as to whether ESP8266 has that larger range but I&#8217;ll have to try and find that out.

Next, I&#8217;ll try to try out both approach and see which one works using sensors that I already have &#8230;