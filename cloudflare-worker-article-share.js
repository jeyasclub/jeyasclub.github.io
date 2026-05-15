const SUPABASE_URL = 'https://ingeqwcpfuugcyafbecl.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_X2cELb4JGEOZ102xgjdHXw_UwNBG-wM';
const SITE_URL = 'https://www.jeyasclub.com';
const DEFAULT_IMAGE = `${SITE_URL}/assets/cover.png`;

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
    const image = `${SITE_URL}/artikel/share-image?id=${encodeURIComponent(id)}`;
    const shareUrl = `${SITE_URL}/artikel/share?id=${encodeURIComponent(id)}`;
    const articleUrl = `${SITE_URL}/artikel/read/?id=${encodeURIComponent(id)}`;

    return new Response(renderSharePage({
      title,
      description,
      image,
      shareUrl,
      articleUrl,
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
    const loc = `${SITE_URL}/artikel/read/?id=${encodeURIComponent(article.id)}`;
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
  const imageUrl = absoluteUrl(article.image || DEFAULT_IMAGE);
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

function renderSharePage({ title, description, image, shareUrl, articleUrl }) {
  const safeTitle = escapeHtml(title);
  const safeDescription = escapeHtml(description);
  const safeImage = escapeHtml(image);
  const safeShareUrl = escapeHtml(shareUrl);
  const safeArticleUrl = escapeHtml(articleUrl);

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
  <meta property="og:image:alt" content="${safeTitle}">
  <meta property="og:url" content="${safeShareUrl}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${safeTitle}">
  <meta name="twitter:description" content="${safeDescription}">
  <meta name="twitter:image" content="${safeImage}">
  <meta name="twitter:image:alt" content="${safeTitle}">
  <link rel="canonical" href="${safeArticleUrl}">
  <meta http-equiv="refresh" content="0;url=${safeArticleUrl}">
  <script>window.location.replace(${JSON.stringify(articleUrl)});</script>
</head>
<body>
  <a href="${safeArticleUrl}">Baca artikel</a>
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
