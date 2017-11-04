Forix
=====

DISCLAIMER: I have no idea what I'm doing - I'm just doing this to learn Ruby.

**Forix is a mini currency exchange service powered by Sinatra/Ruby.**

Conversion rates are pulled from api.fixer.io (updated daily). The idea is to sync with this remote
server from time to time and place the forix service inside your app network so it can be accessed
with micro-latency (as any micro-service requires;).

The conversion rates are stored in the worker memory so it's super fast, but at the same
time it doesn't allow multiple worker processes.


# Install and run

 1. Install docker & docker-compose
 2. `docker-compose up`

# Usage

Use the URL pattern:

```
http://localhost:9292/convert?amount=:numeric_amount&from=:currency_from&to=:currency_to
```

For example:

```
http://localhost:9292/convert?amount=134&from=EUR&to=GBP
```

A correct response is `200 OK` and has the shape:

```
{"original_amount":134.0,"original_currency":"EUR","converted_amount":119.16,"converted_currency":"GBP"}
```

If the requested currency is not found or the request is invalid, a `400 Bad Request` is returned like:

```
{"error":"Currency not found: BTC"}
```

The exchange rates are synced at application start, and can be refreshed any time using:

```
http://localhost:9292/sync
```
