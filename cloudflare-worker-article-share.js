const SUPABASE_URL = 'https://ingeqwcpfuugcyafbecl.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_X2cELb4JGEOZ102xgjdHXw_UwNBG-wM';
const SITE_URL = 'https://www.jeyasclub.com';
const DEFAULT_IMAGE = `${SITE_URL}/assets/optimized/banner-thumbnail.jpg`;

export default {
  async fetch(request) {
    const requestUrl = new URL(request.url);
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

    const title = cleanText(article.title || 'Artikel');
    const description = cleanText(
      article.excerpt || stripHtml(article.body || '').slice(0, 155) || 'Baca artikel Jeya\'s Club.'
    );
    const image = absoluteUrl(article.image || DEFAULT_IMAGE);
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

function escapeHtml(value) {
  return String(value || '').replace(/[&<>"']/g, character => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  }[character]));
}
