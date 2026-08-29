# Use Case and Test Environment

## Background

`cellnet` was created while operating a **Ubiquiti UniFi U5G Max Outdoor** with a Hypecon multi-network eSIM in Brazil.

The Hypecon eSIM used during development can register on more than one host mobile network. TIM and Vivo were both observed and tested. Claro may also be available in some Brazilian states depending on regional and service/network conditions.

This matters because a multi-network eSIM changes the usual assumption that a SIM corresponds to a single mobile operator.

In this environment:

```text
one eSIM
  -> multiple possible host networks
  -> different cells, RF conditions, load and routing
  -> different real-world performance
```

## Limitation addressed

At the time the project was created, the UniFi UI for the U5G Max Outdoor did not expose an explicit control to select which available host network the modem should use.

Automatic selection is convenient, but the automatically selected network may not be the best network for performance.

`cellnet` provides a controlled CLI for inspecting and selecting the host PLMN through the modem's QMI interface.

## Networks used during development

```text
TIM   PLMN 72403
Vivo  PLMN 72410
```

Claro availability is treated as regional/conditional and is not assumed to be universal.

## Why signal strength is not enough

During testing, the network with the strongest radio metrics was not always the network with the highest throughput or lowest latency.

Factors that can matter include:

- 5G NR SNR/SINR;
- LTE anchor quality;
- cell congestion;
- scheduler behavior;
- LTE Carrier Aggregation;
- 5G NR capacity;
- mobile-core routing;
- roaming/MVNO path;
- peering;
- selected speed-test server.

For this reason, `cellnet` combines RF inspection with controlled performance testing.

## Objective of the project

The project is intended to:

1. expose useful modem diagnostics already available through QMI;
2. make host-network selection practical on a multi-network eSIM;
3. compare available operators in the same physical installation;
4. help determine which network performs best at a given place and time;
5. do this without modifying modem firmware or forcing persistent RAT/band settings.

## Test platform

```text
Hardware:            Ubiquiti UniFi U5G Max Outdoor
SIM/eSIM:            Hypecon multi-network eSIM
Host networks:       TIM and Vivo observed/tested
Additional network:  Claro may be regionally available
Cellular mode:       LTE + 5G NSA
QMI device:          /dev/wwan0qmi0
Cellular interface:  wwan0
qmicli:              1.38.x
Shell:                BusyBox / POSIX sh
```

## Project scope

`cellnet` is not a replacement for UniFi Network or the U5G Max Outdoor management interface.

It is an additional diagnostic and network-selection layer for users who need access to modem capabilities that are not currently exposed in the UI.
