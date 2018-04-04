---
title: IoT Garden – Data Acquisition
author: Sid
type: post
date: 2017-07-03
url: /iot/iot-garden-data-acquisition/
categories:
  - IoT
tags:
  - DHT11
  - esp8266
  - Node MCU
  - Soil Moisture Sensor

---
In this post, we&#8217;ll concentrate on getting data from sensors and making it available for anyone else to consume. In my case, I used sensors with Node MCU board from Amica.

<span style="text-decoration: underline;">Node MCU</span>

Node MCU is a low cost micro-controller chip with built in Wifi. This unit basically runs on ESP8266 chip which has built in Wifi. Total storage available on chip is 4 MB so your compiled code can be as large as 4 MB. This simple board has 16 General Purpose I/O (GPIO) pins and one 10 bit ADC to read analog data. So basically this small unit packs a lot of punch if you ask me. Except for just one Analog input pin, this board is a solid one. In my case I needed one GPIO pin to read data from DHT 11 sensor and one analog pin to read data from soil moisture sensor.

[<img class="aligncenter wp-image-31 size-medium" src="/img/esp-12E-amica-300x164.jpg" alt="" width="300" height="164" srcset="/img/esp-12E-amica-300x164.jpg 300w, /img/esp-12E-amica-768x419.jpg 768w, /img/esp-12E-amica-1024x558.jpg 1024w, /img/esp-12E-amica-495x270.jpg 495w" sizes="(max-width: 300px) 100vw, 300px" />][1]

Node MCU can be programmed by LUA scripts as supported out of box, however developers have also added support to use and code NodeMCU using Arduino IDE. Since I was familiar with Arduino IDE, I found this very convenient to use. If you want to setup Node MCU support on Arduino IDE, I suggest you follow steps provided on their GitHub page &#8211; <https://github.com/esp8266/Arduino#installing-with-boards-manager>

In order to load program onto Node MCU, just like Arduino, you have to connect Node MCU board to your computer and transfer code over serial port. Now I am using Mac Book for all my trials so I downloaded and installed USB to Serial driver from SILabs from here &#8211; <http://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers>

Once these drivers are setup and you connect Node MCU with your Computer / Laptop, you&#8217;ll be able to try out ESP 8266 examples available out of box. Since now Arduino IDE and Node MCU is setup, lets move on to sensors used &#8211;

<span style="text-decoration: underline;">DHT 11</span>

DHT 11 is a basic ultra low cost temperature and humidity sensor. This sensor&#8217;s technology ensures high reliability and log-term stability. Sensor itself provides a digital output directly on one of its pins. Sensor&#8217;s operating power supply range is from 2.2 V &#8211; 5V.

[<img class="aligncenter wp-image-34 size-medium" src="/img/dht11-300x274.png" alt="" width="300" height="274" srcset="/img/dht11-300x274.png 300w, /img/dht11-295x270.png 295w, /img/dht11.png 516w" sizes="(max-width: 300px) 100vw, 300px" />][2]

You just have to connect DATA pin of this sensor to any GPIO pin on Node MCU board, you also need library installed on Arduino IDE. Now there are many versions of this library and I had some difficult time to choose which one to go with since it was to work with Node MCU. Let me save you trouble &#8211; I used version 1.3.0 of library <https://github.com/adafruit/DHT-sensor-library/releases>. You can download 1.3.0 version from link above and install it in Arduino IDE.

This single library allows you to read both temperature and humidity from DHT 11 as well as DHT 22 sensors.

<span style="text-decoration: underline;">Soil Moisture Sensor</span>

For measuring soil moisture, I bought sensor from RoboIndia &#8211; <https://roboindia.com/store/soil-moisture-sensor>

[<img class="aligncenter size-medium wp-image-35" src="/img/moisture_sensor_sensor-500x500-300x300.jpg" alt="" width="300" height="300" srcset="/img/moisture_sensor_sensor-500x500-300x300.jpg 300w, /img/moisture_sensor_sensor-500x500-150x150.jpg 150w, /img/moisture_sensor_sensor-500x500-270x270.jpg 270w, /img/moisture_sensor_sensor-500x500.jpg 500w" sizes="(max-width: 300px) 100vw, 300px" />][3]

This sensor provided analog value from 0 &#8211; 1023. Instruction to use were very simple &#8211; there are no instructions 🙂 I just pugged it in and started reading analog values from Node MCU. Being analog sensor, there is a need to make sure it works fine so as part of basic calibration, I tested sensor values for completely dry condition (value of less than 10) to complete moisture by dipping sensor into water (Value was 1023).

Now that we know our sensors, lets go to part where they start talking to Node MCU. Following diagram shows how sensors are connected to Node MCU:

[<img class="aligncenter size-large wp-image-36" src="/img/IMG_3696-1024x768.jpg" alt="" width="640" height="480" srcset="/img/IMG_3696-1024x768.jpg 1024w, /img/IMG_3696-300x225.jpg 300w, /img/IMG_3696-768x576.jpg 768w, /img/IMG_3696-360x270.jpg 360w" sizes="(max-width: 640px) 100vw, 640px" />][4]

Interconnections are pretty simple:

Data Pin of DHT11 -> D1 (GOIP 5) Pin on Node MCU

VCC, GND of DHT 11 -> Vin and GND of Node MCU

Analog 0 Pin of Soil Moisture Sensor -> A0 Pin of Node MCU

With this interconnections and DHT library now I was ready to write code and make sensor and Node MCU talk to each other as follows:

We read data from DHT 11 using library, we read data from soil moisture sensor as analog input (value is just an integer between 0 and 1023). We make data available over HTTP Server as json content. All of this code is just over 100 lines of code, I&#8217;ve shared it all on GitHub &#8211;

<a href="https://github.com/sidgod/garden-data-collector" target="_blank" rel="noopener">https://github.com/sidgod/garden-data-collector</a>

Once this code is compiled and pushed into Node MCU over USB->UART, you can access sensor values on browser like this:

[<img class="aligncenter wp-image-43" src="/img/garden-data-300x127.png" alt="" width="600" height="255" srcset="/img/garden-data-300x127.png 300w, /img/garden-data-768x326.png 768w, /img/garden-data-604x257.png 604w, /img/garden-data.png 1012w" sizes="(max-width: 600px) 100vw, 600px" />][5]

This is where first part of work is done. Now we are able to read data from sensors and make it available over Wifi for anyone else to consume. Next we tackle how to read this data and forward it to AWS &#8230;

 [1]: /img/esp-12E-amica.jpg
 [2]: /img/dht11.png
 [3]: /img/moisture_sensor_sensor-500x500.jpg
 [4]: /img/IMG_3696.jpg
 [5]: /img/garden-data.png