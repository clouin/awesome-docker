# 📦 n8n (Chinese UI Enhanced)

> ✨ A Chinese-enhanced version of the official [n8n](https://github.com/n8n-io/n8n) workflow automation tool.

This image is based on the official `n8nio/n8n` Docker image, with integrated Simplified Chinese UI support provided by [n8n-i18n-chinese](https://github.com/other-blowsnow/n8n-i18n-chinese).

## ✅ Features

- 🌐 **Default UI Language: Simplified Chinese**
- 🔁 **Version-Synced**: UI translations match the official n8n version
- 📦 **Based on Official Image**: Full upstream compatibility

## 🛠 How It Works

This image automatically:

1. Downloads the `editor-ui.tar.gz` matching the `n8n` version from the `n8n-i18n-chinese` release.
2. Extracts and replaces the default `n8n-editor-ui` with Chinese-translated assets.
3. Sets `N8N_DEFAULT_LOCALE=zh-CN` as the default locale.

## 🚀 Usage

```bash
docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n jerryin/n8n
```

### Environment Variables

| Variable             | Default | Description                             |
| -------------------- | ------- | --------------------------------------- |
| `N8N_DEFAULT_LOCALE` | `zh-CN` | Default UI language                     |
| Other n8n variables  | —       | All official n8n env vars are supported |

## 🧱 Image Tags

| Tag      | Description                     |
| -------- | ------------------------------- |
| `latest` | Latest release with zh-CN UI    |
| `1.98.2` | Matches n8n `1.98.2` + zh-CN UI |
| ...      | See all versions on Docker Hub  |

## 📄 License

- [n8n](https://github.com/n8n-io/n8n) is licensed under [Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE).
- Chinese translations provided under respective [open licenses](https://github.com/other-blowsnow/n8n-i18n-chinese/blob/main/LICENSE).

## 🙌 Credits

- 🧠 Original project: [n8n-io/n8n](https://github.com/n8n-io/n8n)
- 🌍 Chinese UI by: [other-blowsnow/n8n-i18n-chinese](https://github.com/other-blowsnow/n8n-i18n-chinese)
