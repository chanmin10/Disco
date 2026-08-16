// Must be explicitly passed to Supabase auth calls that send an email — without it, Supabase
// falls back to the project's default Site URL instead of this custom protocol, regardless of
// whether disco://auth/callback is already in the project's redirect allow-list.
export const AUTH_CALLBACK_URL = 'disco://auth/callback'
