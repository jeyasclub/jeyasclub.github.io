import { readFile } from "node:fs/promises";

const workerSource = await readFile(new URL("../cloudflare-worker-article-share.js", import.meta.url), "utf8");
const workerModule = await import(`data:text/javascript;base64,${Buffer.from(workerSource).toString("base64")}`);
const worker = workerModule.default;

const requestedUrls = [];
globalThis.fetch = async (url) => {
  requestedUrls.push(String(url));
  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
};

const request = new Request("https://www.jeyasclub.com/api/mayar-vocaquiz-webhook", {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({
    event: "payment.received",
    data: {
      transactionId: "accent-test-regression-check",
      customerEmail: "buyer@example.com",
      productName: "Unlock Accent Test",
      productUrl: "https://jeyasclub.myr.id/pl/unlock-accent-test",
      status: "paid",
      amount: 5000,
    },
  }),
});

const response = await worker.fetch(request, {
  SUPABASE_SERVICE_ROLE_KEY: "test-service-role-key",
});
const result = await response.json();

if (!response.ok || !result.ok || result.product !== "accent-test-review") {
  throw new Error(`Unexpected webhook response: ${JSON.stringify(result)}`);
}

if (!requestedUrls.some(url => url.endsWith("/rest/v1/rpc/grant_accent_test_review_access_by_email"))) {
  throw new Error(`Accent Test grant RPC was not called: ${requestedUrls.join(", ")}`);
}

console.log("Accent Test webhook routing OK");
