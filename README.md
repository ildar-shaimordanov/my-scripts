# CommaFeed Windows runner

`commafeed` is the platform-independent Java-based self-hosted RSS reader. 
It is located at https://github.com/Athou/commafeed. 

`commafeed-win` is the trivial extension for controlling `commafeed` from 
the command line under Windows. Literally, this extension mimics Unix-like 
startup scripts having a minimal set of options and hiding all the needful 
commands within. 

## Installation

1. Download and unzip the latest release of this extension from the page 
   https://github.com/ildar-shaimordanov/commafeed-win/releases/latest. 

1. Download `commafeed.jar`, the latest release of the application from 
   the page https://github.com/Athou/commafeed/releases/latest, and put it 
   into the same directory where this extension lives now. 

1. Use the script `commafeed.bat` to start, stop and check the status.

## Usage

* `start` - starts the application in the background with the settings 
configured in the file `config-win.yml`. The additional option `console` 
allows to output log entries to the same console window. 

* `stop` - forcefully terminates the application. 

* `status` - show the statis of the application. If the application is 
  running, the full command line and process ID will be displayed. 
  Otherwise, the diagnostic message will be displayed. 

## Copyright and license

Under MIT License
