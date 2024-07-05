# Roda + Falcon Websockets + HTMX

This is an example Roda Web App setup for reading and writing to a Falcon Async Web Server. UI interaction handled by HTMX.


## Start

1. `bundle install`
2. `bundle exec falcon serve --count 1`

## Dev Notes

### 2024-07-05

Acheived streaming AI woot! The default Typhoeus adapter was not working well with our Async calls. Switched to net_http.

### 2024-07-04

Allow chrome to accept self signed certs

https://support.tools/post/chrome-accept-self-signed-certificate-guide/#:~:text=How%20to%20Get%20Chrome%20to%20Accept%20a%20Self-Signed,launches%20the%20Certificate%20Export%20Wizard.%20...%20More%20items
