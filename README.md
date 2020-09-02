# millioneyes

![](https://github.com/mzeier/millioneyes/blob/master/lego-board-trooper.png?raw=true)

## Introduction

This was essentially a science project to see if I could duplicate what commercial services do an mimic a "million eyes" of offsite website checks.

Using any number of Amazon regions, we launch the smallest instance we can and run [telegraf](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/http).

Telegraf can report to a number of end points. The example code reports to [Wavefront](https://www.wavefront.com/) (largely because I worked there when I first hacked on this).

* [Slide Presenation](https://docs.google.com/presentation/d/1HRfNlBURy_n3u1CBJofkNYr2z306yVL647KyruNLsIY/edit?usp=sharing)

## The code

* `terraform`: sample code that launches a single instance in an arbitary number of regions.
* `ansible`: playbooks that, among other things, installs and configures telegraf.
* `wavefront`: sample [Wavefront](https://www.wavefront.com/) dashboard
