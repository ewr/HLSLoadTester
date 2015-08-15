# HLSLoadTester

During the course of 
[StreamMachine](https://github.com/StreamMachine/StreamMachine) development, 
I often want a simple load tester that I can point at a server and simulate 
listener load. Because HTTP Live Streaming traffic doesn't exactly behave 
like normal traffic, the best course seems to be to use an actual player 
framework.

This is a WIP OS X GUI tool that creates arbitrary numbers of AVPlayer 
instances and points them at a streaming audio server.

# Usage

Clone the repo. Open in up in XCode (Swift 2.0, so XCode 7). Change the `Dev` 
URL in `AudioPlayer.swift`. Build and Run.

# TODO

* __Implement Seeking:__ There's a toggle button to control whether players 
  should engage in seeking. The intent is to have X% of player traffic seek 
  some arbitrary distance in the playlist.

* __Better UI Feedback:__ Right now the UI is only updated when a player 
  instance completes, and only gives the amount of time spent playing.

* __Implement Bandwidth Limiting:__ Tell X% of traffic to use a lower 
  bandwidth HLS variant. Switch peak bitrate flag during playback.
