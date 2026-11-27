"""CI: flutter create এর পরে web (PWA) ঠিক করে — iPhone এ "Add to Home Screen" করলে অ্যাপের মতো খোলে।"""
import json, pathlib, re

root = pathlib.Path(__file__).resolve().parent.parent
web = root / 'web'

m = json.loads((web / 'manifest.json').read_text())
m.update({
    'name': 'গণতি',
    'short_name': 'গণতি',
    'description': 'সহজ দৈনন্দিন হিসাব — আয়, খরচ, দেনা-পাওনা, সঞ্চয়, বাজেট',
    'start_url': '.',
    'display': 'standalone',
    'orientation': 'portrait',
    'background_color': '#2B59FF',
    'theme_color': '#2B59FF',
    'lang': 'bn',
})
(web / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2))

h = (web / 'index.html').read_text()
h = re.sub(r'<title>.*?</title>', '<title>গণতি</title>', h, flags=re.S)
h = re.sub(r'<html[^>]*>', '<html lang="bn">', h, count=1)
h = re.sub(r'<meta name="apple-mobile-web-app-title" content="[^"]*">', '<meta name="apple-mobile-web-app-title" content="গণতি">', h)
extra = ('  <meta name="theme-color" content="#2B59FF">\n'
         '  <meta name="apple-mobile-web-app-status-bar-style" content="default">\n'
         '  <meta name="mobile-web-app-capable" content="yes">\n')
if 'name="theme-color"' not in h:
    h = h.replace('</head>', extra + '</head>', 1)
# অ্যাপ লোড হওয়ার আগে সাদা নয়, নীল পর্দা
h = h.replace('<body>', '<body style="background:#2B59FF">', 1)
(web / 'index.html').write_text(h)
print('web setup done')
