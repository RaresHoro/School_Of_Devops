// tiny header-echo server
const http = require('http');
const server = http.createServer((req, res) => {
  const chunks = [];
  req.on('data', c => chunks.push(c));
  req.on('end', () => {
    const body = Buffer.concat(chunks).toString();
    const payload = {
      method: req.method,
      url: req.url,
      headers: req.headers,
      body: body,
      time: new Date().toISOString()
    };
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(payload, null, 2));
    console.log('--- request ---\n', payload);
  });
});
server.listen(8080, () => console.log('listening on :8080'));
