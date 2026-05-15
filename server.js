const http = require("http");
const fs = require("fs");
const os = require("os");
const path = require("path");

const root = __dirname;
const dataDir = path.join(root, "data");
const sequenceFile = path.join(dataDir, "order-sequence.json");
const port = Number(process.env.PORT || 4173);
const types = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".webmanifest": "application/manifest+json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
};

function sendJson(response, status, data) {
  response.writeHead(status, { "Content-Type": "application/json; charset=utf-8" });
  response.end(JSON.stringify(data));
}

function todayCode(date = new Date()) {
  const year = String(date.getFullYear()).slice(2);
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}${month}${day}`;
}

function readSequence() {
  try {
    return JSON.parse(fs.readFileSync(sequenceFile, "utf8"));
  } catch {
    return {};
  }
}

function nextOrderNumber() {
  fs.mkdirSync(dataDir, { recursive: true });
  const date = todayCode();
  const current = readSequence();
  const sequence = current.date === date ? Number(current.sequence || 0) + 1 : 1;
  fs.writeFileSync(sequenceFile, JSON.stringify({ date, sequence }, null, 2), "utf8");
  return `${date}${String(sequence).padStart(4, "0")}`;
}

function handleApi(request, response, url) {
  if (url.pathname === "/api/order-number" && request.method === "POST") {
    sendJson(response, 200, { orderNumber: nextOrderNumber() });
    return true;
  }

  if (url.pathname === "/api/status") {
    sendJson(response, 200, { ok: true });
    return true;
  }

  return false;
}

function serveStatic(request, response, url) {
  const requestedPath = decodeURIComponent(url.pathname === "/" ? "/index.html" : url.pathname);
  const filePath = path.resolve(path.join(root, requestedPath));

  if (!filePath.startsWith(root)) {
    response.writeHead(403);
    response.end("Forbidden");
    return;
  }

  fs.readFile(filePath, (error, content) => {
    if (error) {
      response.writeHead(404);
      response.end("Not found");
      return;
    }

    response.writeHead(200, { "Content-Type": types[path.extname(filePath)] || "application/octet-stream" });
    response.end(content);
  });
}

function lanAddresses() {
  return Object.values(os.networkInterfaces())
    .flat()
    .filter((item) => item && item.family === "IPv4" && !item.internal)
    .map((item) => item.address);
}

const server = http.createServer((request, response) => {
  const url = new URL(request.url, `http://${request.headers.host}`);
  if (handleApi(request, response, url)) return;
  serveStatic(request, response, url);
});

server.listen(port, "0.0.0.0", () => {
  console.log(`POS prototype running locally at http://127.0.0.1:${port}`);
  lanAddresses().forEach((address) => {
    console.log(`Open on iPad: http://${address}:${port}`);
  });
});
