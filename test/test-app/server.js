'use strict';

const util = require('util');
const http = require('http');
const qs = require('querystring');
const os = require('os');

const port = process.env.PORT || process.env.port || process.env.OPENSHIFT_NODEJS_PORT || 8080;
const ip = process.env.OPENSHIFT_NODEJS_IP || '0.0.0.0';

let nodeEnv = process.env.NODE_ENV || 'unknown';

const server = http.createServer((req, res) => {
  const query = require('url').parse(req.url, true).query;

  let body = '';

  req.on('data', data => {
    body += data;
  });

  req.on('end', () => {
    const formattedBody = qs.parse(body);

    res.writeHead(200, { 'Content-Type': 'text/plain' });

    let out = `This is a node.js echo service
Host: ${req.headers.host}

node.js Production Mode: ${nodeEnv == 'production' ? 'yes' : 'no'}

HTTP/${req.httpVersion}
Request headers:
${util.inspect(req.headers, null)}
Request query:
${util.inspect(query, null)}
Request body:
${util.inspect(formattedBody, null)}
Host: ${os.hostname()}
OS Type: ${os.type()}
OS Platform: ${os.platform()}
OS Arch: ${os.arch()}
OS Release: ${os.release()}
OS Uptime: ${os.uptime()}
OS Free memory: ${os.freemem() / 1024 / 1024}mb
OS Total memory: ${os.totalmem() / 1024 / 1024}mb
OS CPU count: ${os.cpus().length}
OS CPU model: ${os.cpus()[0].model}
OS CPU speed: ${os.cpus()[0].speed}mhz
`;

		res.end(out);
  });
});

server.listen(port);

console.log(`Server running on ${ip}:${port}`);
