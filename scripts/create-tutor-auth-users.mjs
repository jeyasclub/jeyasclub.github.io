const supabaseUrl = process.env.SUPABASE_URL || "https://ingeqwcpfuugcyafbecl.supabase.co";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const tutorPassword = process.env.TUTOR_DEFAULT_PASSWORD || "123123";

if (!serviceRoleKey) {
  console.error("Missing SUPABASE_SERVICE_ROLE_KEY.");
  console.error("Run with: SUPABASE_SERVICE_ROLE_KEY=... node scripts/create-tutor-auth-users.mjs");
  process.exit(1);
}

const headers = {
  apikey: serviceRoleKey,
  Authorization: `Bearer ${serviceRoleKey}`,
  "Content-Type": "application/json"
};

async function request(path, options = {}) {
  const response = await fetch(`${supabaseUrl}${path}`, {
    ...options,
    headers: { ...headers, ...(options.headers || {}) }
  });
  const text = await response.text();
  let payload = null;
  try {
    payload = text ? JSON.parse(text) : null;
  } catch {
    payload = text;
  }
  if (!response.ok) {
    const message = payload && (payload.message || payload.msg || payload.error_description || payload.error);
    throw new Error(message || `Request failed: ${response.status}`);
  }
  return payload;
}

async function getTutorAccounts() {
  const query = "/rest/v1/class_tutor_login_accounts?select=name,email,password,is_active&is_active=eq.true&order=name.asc";
  return request(query);
}

async function findUserByEmail(email) {
  const users = await request(`/auth/v1/admin/users?per_page=1000`);
  const list = Array.isArray(users && users.users) ? users.users : [];
  return list.find((user) => String(user.email || "").toLowerCase() === email.toLowerCase()) || null;
}

async function createOrUpdateUser(account) {
  const email = account.email.toLowerCase();
  const existing = await findUserByEmail(email);

  if (existing) {
    await request(`/auth/v1/admin/users/${existing.id}`, {
      method: "PUT",
      body: JSON.stringify({
        password: tutorPassword,
        email_confirm: true,
        user_metadata: { role: "class_tutor", tutor_name: account.name }
      })
    });
    return { email, action: "updated" };
  }

  await request("/auth/v1/admin/users", {
    method: "POST",
    body: JSON.stringify({
      email,
      password: tutorPassword,
      email_confirm: true,
      user_metadata: { role: "class_tutor", tutor_name: account.name }
    })
  });
  return { email, action: "created" };
}

const accounts = await getTutorAccounts();

if (!accounts.length) {
  console.log("No active tutors found in class_tutor_login_accounts.");
  process.exit(0);
}

for (const account of accounts) {
  try {
    const result = await createOrUpdateUser(account);
    console.log(`${result.action}: ${result.email}`);
  } catch (error) {
    console.error(`failed: ${account.email} - ${error.message}`);
  }
}
