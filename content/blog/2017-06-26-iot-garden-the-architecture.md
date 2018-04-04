---
title: IoT Garden – The Architecture
author: Sid
type: post
date: 2017-06-26
url: /iot/iot-garden-the-architecture/
categories:
  - IoT
tags:
  - Amazon CloudWatch
  - AWS IoT
  - AWS Lambda
  - DHT11
  - esp8266
  - Node MCU
  - Raspberry Pi
  - Soil Moisture Sensor

---
I can see that my last post was on 12th June so it has taken quite some time for me to finally get Phase 1 of this project to completion. Now, I plan on writing close to 4-5 posts entirely on this phase 1 for Garden IoT. Before we jump right in I&#8217;ll start with 100 ft view of how does this look like and what&#8217;s involved in this project. Following diagram gives good idea about what&#8217;s involved in project, what components are being used and how does data flow between various modules:

&nbsp;

[<img class="aligncenter size-large wp-image-23" src="/img/Garden-IoT-Architecture-1024x375.png" alt="" width="640" height="234" srcset="/img/Garden-IoT-Architecture-1024x375.png 1024w, /img/Garden-IoT-Architecture-300x110.png 300w, /img/Garden-IoT-Architecture-768x282.png 768w, /img/Garden-IoT-Architecture-604x221.png 604w, /img/Garden-IoT-Architecture.png 1369w" sizes="(max-width: 640px) 100vw, 640px" />][1]

There are quite a few things in this diagram, let me start with basics &#8211; I wanted to gather data on temperature, humidity and soil moisture, find trend for all these parameters and finally predict how much water should be dispensed based on past data and weather forecast for the day.

<span style="text-decoration: underline;">Sensors</span>

To gather data on those 3 parameters we need sensors, in this case I&#8217;m using two sensors &#8211;

  1. DHT 11 &#8211; For temperature and humidity
  2. Soil moisture sensor for measuring soil moisture

<span style="text-decoration: underline;">Node MCU</span>

Data from these sensors will be read by ESP8266 / Node MCU chip and made available over Wifi server running within NodeMCU. This whole unit needs to reside in close proximity of my garden.

<span style="text-decoration: underline;">On premise Data Aggregation and Forwarding</span>

Data made available by Node MCU will then be read by Raspberry Pi 2 over Wifi and will be aggregated and then forwarded to AWS IoT. MQTT Protocol will be used to transmit this data to AWS IoT.

<span style="text-decoration: underline;">Cloud Data Processing and Visualization</span>

Data received over MQTT topic will then be forwarded to AWS Lambda. AWS Lambda is a serverless compute service that&#8217;ll break down this data and feed it into Amazon CloudWatch service as custom metric.

Finally Dashboard will show newly added CloudWatch metrics so that we can see visually how different parameters are changing over time.

I was able to get all of it working within last week including software components as well. We&#8217;ll visit all individual components in details from next posts in series.

 [1]: /img/Garden-IoT-Architecture.png