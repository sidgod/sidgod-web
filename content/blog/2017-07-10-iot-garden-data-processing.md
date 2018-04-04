---
title: IoT Garden – Data processing
author: Sid
type: post
date: 2017-07-10
url: /iot/iot-garden-data-processing/
categories:
  - IoT
tags:
  - Amazon CloudWatch
  - AWS
  - AWS IoT
  - AWS Lambda
  - Raspberry Pi

---
In my last post we talked about making sensor data usable by making it available over network for anyone else to consume. In this post, lets take this concept further and see how do we connect this data with cloud IoT providers. Main requirement here is to be able to plot sensor data over time, see how it changes with environment changing around it and then finally use gathered data to predict future values. For now lets only focus on part of visualizing sensor data, in order to achieve this I chose to forward data over MQTT protocol to one of the cloud providers.

<span style="text-decoration: underline;">The Transport Protocol &#8211; MQTT</span>

IoT space is an non standardized domain &#8211; reason I say this is because of diversity of everything associated with this domain &#8211; right from different hardware platforms to software vendors and many transports protocols associated with them. Because of such diversity, everyone invents its own stack for IoT, having said that, some of the popular cloud IaaS vendors have started realizing value for providing IoT support and much more associated with it. These vendors are Amazon AWS, Microsoft Azure etc. For my project, I decided to use MQTT Protocol and Amazon AWS IoT support.

MQTT is Message Queue Telemetry Transport protocol &#8211; its a lightweight publish subscribe message protocol on top of TCP/IP. This is one of the standard protocols in IoT space. It sort of works like a &#8220;topic&#8221; in queuing systems where no. of publishers can publish messages on topic and these messages are then delivered to all available subscribers.

<span style="text-decoration: underline;">Cloud IoT Provider &#8211; AWS IoT</span>

Goal of this phase of project is to extract data made available by Node MCU over network and push it to IoT provider &#8211; AWS IoT in my case. Reason why I chose AWS is that I&#8217;m already familier with most common services it offers and it provides rest of cloud software stack that I need &#8211; namely Serverless Compute, Metrics and Visualization for the same.

<span style="text-decoration: underline;">Data Processing / Forwarding</span>

In order to read data from Node MCU and forward it to AWS IoT, I chose writing code in python since it just seems really doing it in python. On my Raspberry Pi, that&#8217;s sitting in my same Wifi network, I wrote python code to read data and forward it to AWS IoT using their SDK.

To start with, you need to register you Raspberry Pi on AWS IoT as an &#8220;IoT Thing&#8221;, to achieve this I followed processed laid out in AWS documentation at http://docs.aws.amazon.com/iot/latest/developerguide/iot-sdk-setup.html as it is.

Once you have registered RPI to AWS IoT, you&#8217;ll have to download connection kit from &#8220;thing&#8221; information page. This contains all certificates we need to use to push messages over MQTT to AWS IoT. Code to do this is pretty easy as follows:



Code does a very simple thing &#8211; read JSON data from Node MCU, forward the same over MQTT to topic &#8220;garden/data&#8221; on AWS IoT.

<span style="text-decoration: underline;">Scheduling Data Processing / Forwarding</span>

However code here does it just once, I needed sample taken quite a few times a day say every 10 minutes for example. Way to achieve this on Raspbian OS or any other linux / unix flavour for that matter is to schedule a job with service called &#8220;cron&#8221;

This service lets you schedule a code to run at specific frequency. You can find information about cron service and how to use it on WikiPedia to start with &#8211; <https://en.wikipedia.org/wiki/Cron>

In my case I just scheduled one cron job that runs my python script every 10 minutes with following cron expression:

> \*/10 \* \* \* * /home/pi/python-api/garden-reader.sh

Script mentioned here only calls my python script directly. This way every 10 minutes, one json dump read from Node MCU gets dumped on AWS IoT topic over MQTT.

Now we have almost laid out pipeline from sensors to Node MCU to Raspberry Pi to AWS IoT, data has finally arrived on Cloud Environment where we&#8217;ll try to work on it, load it as metric and try to visualize the same in next post &#8230;