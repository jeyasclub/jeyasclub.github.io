const SUPABASE_URL = 'https://ingeqwcpfuugcyafbecl.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_X2cELb4JGEOZ102xgjdHXw_UwNBG-wM';
const SITE_URL = 'https://www.jeyasclub.com';
const DEFAULT_IMAGE = `${SITE_URL}/assets/cover.png`;
const OG_IMAGE_WIDTH = 768;
const OG_IMAGE_HEIGHT = 402;

export default {
  async fetch(request) {
    const requestUrl = new URL(request.url);

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
