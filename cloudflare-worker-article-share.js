const SUPABASE_URL = 'https://ingeqwcpfuugcyafbecl.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_X2cELb4JGEOZ102xgjdHXw_UwNBG-wM';
const SITE_URL = 'https://www.jeyasclub.com';
const DEFAULT_IMAGE = `${SITE_URL}/assets/cover.png`;
const OG_IMAGE_WIDTH = 768;
const OG_IMAGE_HEIGHT = 402;
const VOCAQUIZ_PRODUCT_SLUG = 'vocabulary-test-result';
const GRAMMAR_TEST_PRODUCT_SLUG = 'unlock-grammar-test-recommendation';
const ENGLISH_SLANG_TEST_PRODUCT_SLUG = 'unlock-english-slang-test';
const SWE_TEST_PRODUCT_SLUG = 'unlock-pembahasan-toefl-structure-written-expressions';
const READING_TEST_PRODUCT_SLUG = 'unlock-reading-test-jeyas-club';
const ENGLISH_HANGOUT_PRODUCT_SLUG = 'english-hangout-club-by-jeyas-club-may-2026-di9e';
const ENGLISH_HANGOUT_COURSE_KEY = 'english-hangout-club';
const TOEFL_VOCAB_PRODUCT_SLUG = '300-toefl-vocabulary';
const TOEFL_VOCAB_COURSE_KEY = '300-toefl-vocabulary';
const TOEFL_VOCAB_R2_KEY = '300_TOEFL_Vocabulary.xlsx';
const TOEFL_VOCAB_DOWNLOAD_NAME = '300_TOEFL_Vocabulary.xlsx';
const ENGLISH_CHALLENGES_PRODUCT_SLUG = 'study-sheet-100-english-challenges';
const ENGLISH_CHALLENGES_COURSE_KEY = 'study-sheet-100-english-challenges';
const ENGLISH_CHALLENGES_R2_KEY = '100_English_Challenges.xlsx';
const ENGLISH_CHALLENGES_DOWNLOAD_NAME = '100_English_Challenges.xlsx';

export default {
  async fetch(request, env) {
    const requestUrl = new URL(request.url);

    if (requestUrl.pathname === '/api/mayar-vocaquiz-webhook') {
      return handleMayarVocaquizWebhook(request, env);
    }

    if (requestUrl.pathname === '/api/download/300-toefl-vocabulary') {
      return handlePrivateCourseDownload(request, env, {
        courseKey: TOEFL_VOCAB_COURSE_KEY,
        r2Key: TOEFL_VOCAB_R2_KEY,
        downloadName: TOEFL_VOCAB_DOWNLOAD_NAME,
      });
    }

    if (requestUrl.pathname === '/api/download/study-sheet-100-english-challenges') {
      return handlePrivateCourseDownload(request, env, {
        courseKey: ENGLISH_CHALLENGES_COURSE_KEY,
        r2Key: ENGLISH_CHALLENGES_R2_KEY,
        downloadName: ENGLISH_CHALLENGES_DOWNLOAD_NAME,
      });
    }

    if (requestUrl.pathname === '/sitemap-articles.xml') {
      return renderArticleSitemap();
    }

    const id = requestUrl.searchParams.get('id');

    if (!id) {
      return Response.redirect(`${SITE_URL}/artikel/`, 302);
    }

    const article = await getArticle(id);

    if (!article) {
      return new Response('Article not found', {
        status: 404,
        headers: {
          'content-type': 'text/plain; charset=utf-8',
          'cache-control': 'no-store',
        },
      });
    }

    if (requestUrl.pathname.includes('/artikel/share-image')) {
      return renderShareImage(article);
    }

    const title = cleanText(article.title || 'Artikel');
    const description = cleanText(
      article.excerpt || stripHtml(article.body || '').slice(0, 155) || 'Baca artikel Jeya\'s Club.'
    );
    const image = `${SITE_URL}/artikel/share-image?id=${encodeURIComponent(id)}&v=${encodeURIComponent(getImageVersion(article.image || DEFAULT_IMAGE))}`;
    const shareUrl = `${SITE_URL}/artikel/share?id=${encodeURIComponent(id)}`;
    const articleUrl = `${SITE_URL}/artikel/read/?id=${encodeURIComponent(id)}`;
    const shouldRedirect = !isCrawler(request.headers.get('user-agent') || '');

    return new Response(renderSharePage({
      title,
      description,
      image,
      shareUrl,
      articleUrl,
      shouldRedirect,
    }), {
      headers: {
        'content-type': 'text/html; charset=utf-8',
        'cache-control': 'public, max-age=300',
      },
    });
  },
};

async function handleMayarVocaquizWebhook(request, env = {}) {
  if (request.method !== 'POST') {
    return jsonResponse({ ok: false, error: 'method_not_allowed' }, 405);
  }

  const configuredSecret = env.MAYAR_WEBHOOK_SECRET || '';
  if (configuredSecret) {
    const requestUrl = new URL(request.url);
    const providedSecret = request.headers.get('x-webhook-secret') || requestUrl.searchParams.get('secret') || '';

    if (providedSecret !== configuredSecret) {
      return jsonResponse({ ok: false, error: 'unauthorized' }, 401);
    }
  }

  let payload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ ok: false, error: 'invalid_json' }, 400);
  }

  const eventName = payload && payload.event;
  const data = payload && payload.data ? payload.data : {};
  const transactionId = data.transactionId || data.id || '';
  const customerEmail = cleanText(data.customerEmail || data.email || '').toLowerCase();
  const productName = cleanText(data.productName || '');
  const productUrl = cleanText(data.productUrl || data.url || '');
  const productId = cleanText(data.productId || '');
  const status = String(data.status || data.transactionStatus || '').toLowerCase();

  if (eventName !== 'payment.received') {
    return jsonResponse({ ok: true, ignored: true, reason: 'unsupported_event' });
  }

  if (status && !['success', 'paid', 'settlement', 'settled', 'completed', 'created', 'true'].includes(status)) {
    return jsonResponse({ ok: true, ignored: true, reason: 'unpaid_status', status });
  }

  const isVocaquiz = isVocaquizPayment({ productName, productUrl, productId }, env);
  const isGrammarTest = isGrammarTestPayment({ productName, productUrl, productId }, env);
  const isEnglishSlangTest = isEnglishSlangTestPayment({ productName, productUrl, productId }, env);
  const isSweTest = isSweTestPayment({ productName, productUrl, productId }, env);
  const isReadingTest = isReadingTestPayment({ productName, productUrl, productId }, env);
  const isEnglishHangout = isEnglishHangoutPayment({ productName, productUrl, productId }, env);
  const isToeflVocab = isToeflVocabPayment({ productName, productUrl, productId }, env);
  const isEnglishChallenges = isEnglishChallengesPayment({ productName, productUrl, productId }, env);

  if (!isVocaquiz && !isGrammarTest && !isEnglishSlangTest && !isSweTest && !isReadingTest && !isEnglishHangout && !isToeflVocab && !isEnglishChallenges) {
    return jsonResponse({ ok: true, ignored: true, reason: 'unmatched_product', productName, productId });
  }

  if (!customerEmail || !customerEmail.includes('@')) {
    return jsonResponse({ ok: false, error: 'missing_customer_email' }, 400);
  }

  const serviceRoleKey = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceRoleKey) {
    return jsonResponse({ ok: false, error: 'missing_supabase_service_role_key' }, 500);
  }

  let rpcName = 'grant_vocaquiz_review_access_by_email';
  let rpcBody = {
    p_email: customerEmail,
    p_transaction_id: transactionId || null,
    p_source: 'mayar',
  };

  if (isGrammarTest) {
    rpcName = 'grant_grammar_test_review_access_by_email';
  }

  if (isEnglishSlangTest) {
    rpcName = 'grant_english_slang_test_review_access_by_email';
  }

  if (isSweTest) {
    rpcName = 'grant_swe_test_review_access_by_email';
  }

  if (isReadingTest) {
    rpcName = 'grant_reading_test_review_access_by_email';
  }

  if (isEnglishHangout) {
    rpcName = 'grant_jeyasclub_course_access_by_email';
    rpcBody = {
      p_email: customerEmail,
      p_course_key: ENGLISH_HANGOUT_COURSE_KEY,
      p_transaction_id: transactionId || null,
      p_source: 'mayar',
    };
  }

  if (isToeflVocab) {
    rpcName = 'grant_jeyasclub_course_access_by_email';
    rpcBody = {
      p_email: customerEmail,
      p_course_key: TOEFL_VOCAB_COURSE_KEY,
      p_transaction_id: transactionId || null,
      p_source: 'mayar',
    };
  }

  if (isEnglishChallenges) {
    rpcName = 'grant_jeyasclub_course_access_by_email';
    rpcBody = {
      p_email: customerEmail,
      p_course_key: ENGLISH_CHALLENGES_COURSE_KEY,
      p_transaction_id: transactionId || null,
      p_source: 'mayar',
    };
  }

  const rpcResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${rpcName}`, {
    method: 'POST',
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify(rpcBody),
  });

  const rpcText = await rpcResponse.text();
  let rpcData = null;
  try {
    rpcData = rpcText ? JSON.parse(rpcText) : null;
  } catch {
    rpcData = rpcText;
  }

  if (!rpcResponse.ok) {
    return jsonResponse({
      ok: false,
      error: 'supabase_rpc_failed',
      status: rpcResponse.status,
      detail: rpcData,
    }, 500);
  }

  return jsonResponse({
    ok: Boolean(rpcData && rpcData.ok),
    product: isEnglishChallenges ? ENGLISH_CHALLENGES_COURSE_KEY : (isToeflVocab ? TOEFL_VOCAB_COURSE_KEY : (isEnglishHangout ? ENGLISH_HANGOUT_COURSE_KEY : (isReadingTest ? 'reading-test-review' : (isSweTest ? 'swe-test-review' : (isEnglishSlangTest ? 'english-slang-test-review' : (isGrammarTest ? 'grammar-test-review' : 'vocaquiz-review')))))),
    result: rpcData,
  });
}

async function handlePrivateCourseDownload(request, env = {}, product = {}) {
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders() });
  }

  if (request.method !== 'GET') {
    return jsonResponse({ ok: false, error: 'method_not_allowed' }, 405);
  }

  if (!env.PRIVATE_DOWNLOADS) {
    return jsonResponse({ ok: false, error: 'missing_private_downloads_bucket' }, 500);
  }

  const serviceRoleKey = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceRoleKey) {
    return jsonResponse({ ok: false, error: 'missing_supabase_service_role_key' }, 500);
  }

  const authHeader = request.headers.get('authorization') || '';
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  if (!token) {
    return jsonResponse({ ok: false, error: 'missing_auth_token' }, 401);
  }

  const userResponse = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
    },
  });

  if (!userResponse.ok) {
    return jsonResponse({ ok: false, error: 'invalid_auth_token' }, 401);
  }

  const user = await userResponse.json();
  if (!user || !user.id) {
    return jsonResponse({ ok: false, error: 'user_not_found' }, 401);
  }

  const accessUrl = new URL(`${SUPABASE_URL}/rest/v1/jeyasclub_course_access`);
  accessUrl.searchParams.set('select', 'id');
  accessUrl.searchParams.set('user_id', `eq.${user.id}`);
  accessUrl.searchParams.set('course_key', `eq.${product.courseKey}`);
  accessUrl.searchParams.set('limit', '1');

  const accessResponse = await fetch(accessUrl.href, {
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
    },
  });

  if (!accessResponse.ok) {
    return jsonResponse({ ok: false, error: 'access_check_failed' }, 500);
  }

  const accessRows = await accessResponse.json();
  if (!Array.isArray(accessRows) || accessRows.length === 0) {
    return jsonResponse({ ok: false, error: 'download_access_denied' }, 403);
  }

  const file = await env.PRIVATE_DOWNLOADS.get(product.r2Key, 'arrayBuffer');
  if (!file) {
    return jsonResponse({ ok: false, error: 'file_not_found' }, 404);
  }

  return new Response(file, {
    headers: {
      ...corsHeaders(),
      'content-type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'content-disposition': `attachment; filename="${product.downloadName}"`,
      'cache-control': 'private, no-store',
    },
  });
}

function isVocaquizPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_VOCAQUIZ_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(VOCAQUIZ_PRODUCT_SLUG)
    || (haystack.includes('vocabulary') && haystack.includes('test') && haystack.includes('result'));
}

function isGrammarTestPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_GRAMMAR_TEST_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(GRAMMAR_TEST_PRODUCT_SLUG)
    || (haystack.includes('grammar') && haystack.includes('test') && haystack.includes('recommendation'))
    || (haystack.includes('grammar') && haystack.includes('test') && haystack.includes('result'));
}

function isEnglishSlangTestPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_ENGLISH_SLANG_TEST_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(ENGLISH_SLANG_TEST_PRODUCT_SLUG)
    || (haystack.includes('english') && haystack.includes('slang') && haystack.includes('test'));
}

function isSweTestPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_SWE_TEST_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(SWE_TEST_PRODUCT_SLUG)
    || (haystack.includes('toefl') && haystack.includes('structure') && haystack.includes('written'));
}

function isReadingTestPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_READING_TEST_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(READING_TEST_PRODUCT_SLUG)
    || (haystack.includes('reading') && haystack.includes('test') && haystack.includes('jeya'));
}

function isEnglishHangoutPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_ENGLISH_HANGOUT_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(ENGLISH_HANGOUT_PRODUCT_SLUG)
    || (haystack.includes('english') && haystack.includes('hangout') && haystack.includes('club'));
}

function isToeflVocabPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_TOEFL_VOCAB_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(TOEFL_VOCAB_PRODUCT_SLUG)
    || (haystack.includes('300') && haystack.includes('toefl') && haystack.includes('vocabulary'));
}

function isEnglishChallengesPayment({ productName, productUrl, productId }, env = {}) {
  const configuredProductId = cleanText(env.MAYAR_ENGLISH_CHALLENGES_PRODUCT_ID || '');
  if (configuredProductId && productId === configuredProductId) return true;

  const haystack = `${productName} ${productUrl}`.toLowerCase();
  return haystack.includes(ENGLISH_CHALLENGES_PRODUCT_SLUG)
    || (haystack.includes('100') && haystack.includes('english') && haystack.includes('challenges'));
}

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(),
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    },
  });
}

function corsHeaders() {
  return {
    'access-control-allow-origin': SITE_URL,
    'access-control-allow-methods': 'GET, POST, OPTIONS',
    'access-control-allow-headers': 'authorization, content-type, x-webhook-secret',
  };
}

async function renderArticleSitemap() {
  const articles = await getPublishedArticlesForSitemap();
  const urls = articles.map(article => {
    const loc = `${SITE_URL}/artikel/share?id=${encodeURIComponent(article.id)}`;
    const lastmod = formatSitemapDate(article.created_at);

    return `  <url>
    <loc>${escapeXml(loc)}</loc>
    ${lastmod ? `<lastmod>${escapeXml(lastmod)}</lastmod>` : ''}
    <changefreq>weekly</changefreq>
    <priority>0.70</priority>
  </url>`;
  }).join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;

  return new Response(xml, {
    headers: {
      'content-type': 'application/xml; charset=utf-8',
      'cache-control': 'public, max-age=300',
    },
  });
}

async function renderShareImage(article) {
  const imageUrl = getShareImageSource(article.image || DEFAULT_IMAGE);
  const imageResponse = await fetch(imageUrl, {
    headers: {
      accept: 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    },
  });

  if (!imageResponse.ok) {
    return Response.redirect(DEFAULT_IMAGE, 302);
  }

  const contentType = imageResponse.headers.get('content-type') || 'image/jpeg';

  return new Response(imageResponse.body, {
    headers: {
      'content-type': contentType,
      'cache-control': 'public, max-age=86400',
    },
  });
}

async function getArticle(id) {
  const apiUrl = new URL(`${SUPABASE_URL}/rest/v1/articles`);
  apiUrl.searchParams.set('select', 'id,title,excerpt,image,body,published');
  apiUrl.searchParams.set('id', `eq.${id}`);
  apiUrl.searchParams.set('published', 'eq.true');
  apiUrl.searchParams.set('limit', '1');

  const response = await fetch(apiUrl.href, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
    },
  });

  if (!response.ok) return null;

  const articles = await response.json();
  return Array.isArray(articles) ? articles[0] : null;
}

async function getPublishedArticlesForSitemap() {
  const apiUrl = new URL(`${SUPABASE_URL}/rest/v1/articles`);
  apiUrl.searchParams.set('select', 'id,created_at');
  apiUrl.searchParams.set('published', 'eq.true');
  apiUrl.searchParams.set('order', 'created_at.desc');
  apiUrl.searchParams.set('limit', '1000');

  const response = await fetch(apiUrl.href, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
    },
  });

  if (!response.ok) return [];

  const articles = await response.json();
  return Array.isArray(articles) ? articles.filter(article => article && article.id) : [];
}

function renderSharePage({ title, description, image, shareUrl, articleUrl, shouldRedirect }) {
  const safeTitle = escapeHtml(title);
  const safeDescription = escapeHtml(description);
  const safeImage = escapeHtml(image);
  const safeShareUrl = escapeHtml(shareUrl);
  const safeArticleUrl = escapeHtml(articleUrl);
  const redirectTags = shouldRedirect
    ? `  <meta http-equiv="refresh" content="0;url=${safeArticleUrl}">
  <script>window.location.replace(${JSON.stringify(articleUrl)});</script>`
    : '';

  return `<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${safeTitle}</title>
  <meta name="description" content="${safeDescription}">
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="Jeya's Club">
  <meta property="og:title" content="${safeTitle}">
  <meta property="og:description" content="${safeDescription}">
  <meta property="og:image" content="${safeImage}">
  <meta property="og:image:secure_url" content="${safeImage}">
  <meta property="og:image:width" content="${OG_IMAGE_WIDTH}">
  <meta property="og:image:height" content="${OG_IMAGE_HEIGHT}">
  <meta property="og:image:alt" content="${safeTitle}">
  <meta property="og:url" content="${safeShareUrl}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${safeTitle}">
  <meta name="twitter:description" content="${safeDescription}">
  <meta name="twitter:image" content="${safeImage}">
  <meta name="twitter:image:src" content="${safeImage}">
  <meta name="twitter:image:alt" content="${safeTitle}">
  <link rel="image_src" href="${safeImage}">
  <link rel="canonical" href="${safeShareUrl}">
${redirectTags}
</head>
<body>
  <main>
    <h1>${safeTitle}</h1>
    <p>${safeDescription}</p>
    <p><a href="${safeArticleUrl}">Baca artikel lengkap</a></p>
  </main>
</body>
</html>`;
}

function absoluteUrl(value) {
  try {
    return new URL(value, SITE_URL).href;
  } catch {
    return DEFAULT_IMAGE;
  }
}

function getShareImageSource(value) {
  try {
    const url = new URL(value || DEFAULT_IMAGE, SITE_URL);

    if (url.hostname === 'ingeqwcpfuugcyafbecl.supabase.co' && url.pathname.includes('/storage/v1/object/public/')) {
      url.pathname = url.pathname.replace('/storage/v1/object/public/', '/storage/v1/render/image/public/');
      url.searchParams.set('width', String(OG_IMAGE_WIDTH));
      url.searchParams.set('height', String(OG_IMAGE_HEIGHT));
      url.searchParams.set('resize', 'cover');
    }

    if (url.hostname === 'images.pexels.com') {
      url.searchParams.set('auto', 'compress');
      url.searchParams.set('cs', 'tinysrgb');
      url.searchParams.set('w', String(OG_IMAGE_WIDTH));
      url.searchParams.set('h', String(OG_IMAGE_HEIGHT));
      url.searchParams.set('fit', 'crop');
    }

    return url.href;
  } catch {
    return DEFAULT_IMAGE;
  }
}

function getImageVersion(value) {
  let hash = 0;
  const text = String(value || DEFAULT_IMAGE);

  for (let index = 0; index < text.length; index += 1) {
    hash = ((hash << 5) - hash) + text.charCodeAt(index);
    hash |= 0;
  }

  return Math.abs(hash).toString(36);
}

function isCrawler(userAgent) {
  return /bot|crawler|spider|google|bing|yandex|duckduckgo|baidu|facebookexternalhit|twitterbot|linkedinbot|whatsapp|telegrambot|slackbot|discordbot/i.test(userAgent);
}

function cleanText(value) {
  return String(value || '').replace(/\s+/g, ' ').trim();
}

function stripHtml(value) {
  return String(value || '').replace(/<[^>]*>/g, ' ');
}

function formatSitemapDate(value) {
  if (!value) return '';
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? '' : date.toISOString();
}

function escapeHtml(value) {
  return String(value || '').replace(/[&<>"']/g, character => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  }[character]));
}

function escapeXml(value) {
  return String(value || '').replace(/[<>&'"]/g, character => ({
    '<': '&lt;',
    '>': '&gt;',
    '&': '&amp;',
    "'": '&apos;',
    '"': '&quot;',
  }[character]));
}
