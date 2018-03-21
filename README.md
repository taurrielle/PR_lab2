# PR lab2

This repository contains laboratory work #2 for Network Programming. 

**Task:** implement a metrics agregator. In order to do that, firstly, a secret key from `https://desolate-ravine-43301.herokuapp.com/` should be requested. In response, a list of URLs (for each device) will be recieved. The secret key expries after `30 seconds` and some devices can take up to `29 seconds` to respond so the requests must be done in parallel. The data that comes from the devices must be parsed according to the returned format (JSON, CSV, XML). Finally, aggregate all responses ordering by sensor type. More details [here](https://github.com/Alexx-G/PR-labs/blob/master/lab2.md#metrics-aggregator).

**Implementation:** was done in `Ruby 2.3.3` using the `typhoeus` gem used to run HTTP requests in parallel. 
