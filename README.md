# Ai Platform Demo

This is a demo platform for building Ai powered user interfaces.

## Start

1. Install Ollama and pull in the model weights for **phi3** & **llama3:instruct**
   1a. Serve Ollama in the background at address `http://localhost:11434` 
2. `bundle install`
3. `x/serve`
4. Open your browser to `https://localhost:9292/`

> Note: The first web-socket handshake will error due to browser not liking our self-signed SSL certificate. Ignore warning for now and let the browser access your site.

## Stack

### Web Service

- [Roda](https://roda.jeremyevans.net/index.html): Ruby Minimal Web Framework
- [Falcon](https://github.com/socketry/falcon): Async web server provides web sockets

### LLM

- [Ollama](https://ollama.com/): LLM Service
- [internlm](https://github.com/InternLM/InternLM): Chinese functional calling llm
- [phi3](https://azure.microsoft.com/en-us/blog/introducing-phi-3-redefining-whats-possible-with-slms/): Microsoft LLM
- [llama3:instruct](https://ai.meta.com/blog/meta-llama-3/) Meta LLM

### UI

- [HTMX](https://htmx.org/): Page interactivity w/o javascript
- [Web Awesome](https://shoelace.style/): UI Web Components

## Reference

- [interalm2 | chat format](https://github.com/InternLM/InternLM/blob/main/chat/chat_format.md#function-call--code-interpreter)
- [ollama | api](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Allow chrome to accept self signed certs](https://support.tools/post/chrome-accept-self-signed-certificate-guide/#:~:text=How%20to%20Get%20Chrome%20to%20Accept%20a%20Self-Signed,launches%20the%20Certificate%20Export%20Wizard.%20...%20More%20items)
