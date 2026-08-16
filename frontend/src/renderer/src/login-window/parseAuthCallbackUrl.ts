export interface ParsedAuthCallback {
  code?: string
  accessToken?: string
  refreshToken?: string
  type?: string
  errorDescription?: string
}

/**
 * disco://auth/callback links can carry either a PKCE `code` query param or implicit-flow
 * tokens in the URL hash, depending on the Supabase project's configured auth flow — handle
 * both. `type` (recovery/signup/magiclink/...) can likewise show up in either location.
 */
export function parseAuthCallbackUrl(rawUrl: string): ParsedAuthCallback {
  const url = new URL(rawUrl)
  const search = url.searchParams
  const hashParams = new URLSearchParams(url.hash.replace(/^#/, ''))

  return {
    code: search.get('code') ?? undefined,
    accessToken: hashParams.get('access_token') ?? undefined,
    refreshToken: hashParams.get('refresh_token') ?? undefined,
    type: search.get('type') ?? hashParams.get('type') ?? undefined,
    errorDescription:
      search.get('error_description') ?? hashParams.get('error_description') ?? undefined
  }
}
