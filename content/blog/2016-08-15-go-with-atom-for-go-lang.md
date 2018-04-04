---
title: Go with Atom for Go-Lang
author: Sid
type: post
date: 2016-08-15
url: /go/go-with-atom-for-go-lang/
categories:
  - Go
tags:
  - atom
  - atom-go-editor
  - go
  - go-editor
  - go-lang

---
Recently I became docker advocate for out teams here in Pune, if you are thinking what does it actually mean, well I have to ramble about how cool docker is and how can we use it for our advantage till person / team across me says &#8220;Alright ! We get it, docker is awesome, lets use it&#8221; 🙂

One curious thing that I found while my travels through dockerized world of container as service is docker is written in new language around the corner &#8211; Go Lang. Creators of Docker intentionally chose to wrote docker in Go. There are some nice articles that answer typical questions like why and how, but I wanted to personally take a closer look at Go-lang and decide for myself.

As always first step is Initiation and for that I wanted to setup go lang on mac + IDE. Here is roundup of all that worked for me (In short here is how you setup Go Lang and IDE for the same in 10 minutes):

  1. Install GO Lang for Mac, package is available at https://golang.org/dl/
  2. Setup GOPATH &#8211; On Mac, I simply added export GOPATH in my bash_profile like this 
      * export GOPATH=$HOME/sid-projects/go-workdir
  3. Download and Install Atom editor for mac from https://atom.io/download/mac
  4. Open preferences for Atom -> +Install, Install following packages: 
      * go-plus &#8211; This will install everything needed for Atom &#8211; GO integration.
      * autocomplete-go &#8211; For obvious purpose, if not installed already, install this ASAP 😉
      * Platformio Ide Terminal &#8211; This will install terminal so that you&#8217;ll be able to run code directly through Atom editor
      * After each package install, restart Atom.
  5. If any of those packages have dependencies, you&#8217;ll be prompted to take action, it&#8217;s just a matter of clicking through all &#8220;Yes&#8221; buttons.
  6. After final restart of Atom, It&#8217;s time to Point your Atom editor to project location. 
      * File -> Add Project Folder will allow you to point to project directory that you want to use.
  7. Create new file hello.go like this:    [<img class="alignnone size-medium wp-image-15" src="/img/Atom-Go-300x101.png" alt="Atom-Go" width="300" height="101" srcset="/img/Atom-Go-300x101.png 300w, /img/Atom-Go-768x258.png 768w, /img/Atom-Go-1024x345.png 1024w, /img/Atom-Go.png 1260w" sizes="(max-width: 300px) 100vw, 300px" />][1]
  8. IF it fails to auto complete, like in my case, it actually gave me warning that some native modules needed to be rebuilt, once you do that, restart Atom and you&#8217;ll have all the auto complete that you want!

Thanks it folks, It cannot get easier than this, so far I have loved Atom + GO Lang integration, as I progress through learning through GO, I&#8217;ll add more on this topic.

 [1]: /img/Atom-Go.png