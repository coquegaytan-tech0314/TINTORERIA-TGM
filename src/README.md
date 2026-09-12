# Dashboard source (pre-StatiCrypt)

`dashboard.html` is the **reviewable, unencrypted** operator dashboard.

`../index.html` on `main` must stay the **StatiCrypt password gate**. GitHub Pages serves `index.html`. Merging this file in place of `index.html` would unlock the live floor dashboard.

## Edit

1. Change chrome/styles here only (no lote / tela / kg / machine data).
2. Re-encrypt before merging to `main`:

```bash
export STATICRYPT_PASSWORD='…existing Pages curtain password…'
./scripts/encrypt-dashboard.sh
```

That command reuses `.staticrypt.json` salt, 30-day remember, and the same gate copy. Primary gate button is `#FF2E4D`.

To inspect the current live blob:

```bash
export STATICRYPT_PASSWORD='…'
npx --yes staticrypt --decrypt index.html --password "$STATICRYPT_PASSWORD" --directory /tmp/tgm-decrypted
```
