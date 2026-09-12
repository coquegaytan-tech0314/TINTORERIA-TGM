# Dashboard source (pre-StatiCrypt)

`dashboard.html` is the **reviewable, unencrypted** operator dashboard for PR review and chrome edits.

`../index.html` on `main` / GitHub Pages **must stay the StatiCrypt gate**. Never copy this file over `index.html` on `main`. That would publish the floor dashboard unlocked.

## Edit

1. Change chrome/styles here only (no lote / tela / kg / machine data).
2. Do **not** put curtain passwords, sample secrets, or credentials in this file.
3. Before merging to `main`, re-encrypt (password from the environment only):

```bash
export STATICRYPT_PASSWORD
./scripts/encrypt-dashboard.sh
```

The script reads `STATICRYPT_PASSWORD` from the environment, reuses `.staticrypt.json` salt, keeps 30-day remember, and writes a gated `index.html`. Primary gate button is `#FF2E4D`.
