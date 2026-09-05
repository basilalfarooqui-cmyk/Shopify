# serve.ps1 — zero-dependency static web server for previewing every site in this
# project locally. No Node, no Python required; uses .NET's HttpListener.
#
#   Start:  powershell -ExecutionPolicy Bypass -File tools\serve.ps1
#   Then:   http://localhost:4321/main-store/
#           http://localhost:4321/niche-sites/smart-ring/
#           http://localhost:4321/category-variations/<category>/design-1/
#
#   Stop:   Ctrl+C  (or close the window)
#
# Optional: -Port 5000 -Root "C:\path\to\folder"

param(
  [int]$Port = 4321,
  [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$Root = (Resolve-Path $Root).Path
$prefix = "http://localhost:$Port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try { $listener.Start() } catch {
  Write-Host "Could not bind $prefix - is something already on port $Port?" -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "  Serving $Root" -ForegroundColor Cyan
Write-Host "  -> $prefix" -ForegroundColor Green
Write-Host "  Ctrl+C to stop." -ForegroundColor DarkGray
Write-Host ""

$mime = @{
  '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'
  '.css'='text/css; charset=utf-8';   '.js'='text/javascript; charset=utf-8'
  '.json'='application/json';         '.svg'='image/svg+xml'
  '.jpg'='image/jpeg';  '.jpeg'='image/jpeg'; '.png'='image/png'
  '.webp'='image/webp'; '.gif'='image/gif';   '.avif'='image/avif'
  '.ico'='image/x-icon';'.woff2'='font/woff2';'.woff'='font/woff'
  '.ttf'='font/ttf';    '.otf'='font/otf';    '.mp4'='video/mp4'
  '.txt'='text/plain; charset=utf-8';  '.md'='text/plain; charset=utf-8'
  '.log'='text/plain; charset=utf-8'
}

while ($listener.IsListening) {
  try { $ctx = $listener.GetContext() } catch { break }
  $res = $ctx.Response
  try {
    $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    $path = if ($rel -eq '') { $Root } else { Join-Path $Root ($rel -replace '/','\') }

    # directory -> index.html, else a simple listing
    if (Test-Path -LiteralPath $path -PathType Container) {
      $idx = Join-Path $path 'index.html'
      if (Test-Path -LiteralPath $idx) {
        $path = $idx
      } else {
        $rows = Get-ChildItem -LiteralPath $path | Sort-Object { -not $_.PSIsContainer }, Name | ForEach-Object {
          $n = $_.Name + $(if ($_.PSIsContainer) { '/' } else { '' })
          "<li><a href=""$n"">$n</a></li>"
        }
        $html = "<!doctype html><meta charset=utf-8><title>/$rel</title>" +
                "<style>body{font:14px/1.7 ui-monospace,Menlo,Consolas,monospace;max-width:760px;margin:48px auto;padding:0 24px;background:#0e0e10;color:#ddd}" +
                "a{color:#8ab4ff;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:15px;color:#888;font-weight:400}ul{list-style:none;padding:0}li{padding:2px 0}</style>" +
                "<h1>/$rel</h1><ul>$($rows -join '')</ul>"
        $buf = [Text.Encoding]::UTF8.GetBytes($html)
        $res.ContentType = 'text/html; charset=utf-8'
        $res.OutputStream.Write($buf, 0, $buf.Length)
        $res.Close(); continue
      }
    }

    if (Test-Path -LiteralPath $path -PathType Leaf) {
      $ext = [IO.Path]::GetExtension($path).ToLower()
      $res.ContentType = $(if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' })
      $res.Headers['Cache-Control'] = 'no-store, no-cache, must-revalidate'
      $res.Headers['Pragma'] = 'no-cache'
      $bytes = [IO.File]::ReadAllBytes($path)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $buf = [Text.Encoding]::UTF8.GetBytes("404 - not found: /$rel")
      $res.ContentType = 'text/plain; charset=utf-8'
      $res.OutputStream.Write($buf, 0, $buf.Length)
    }
  } catch {
    try { $res.StatusCode = 500 } catch {}
  } finally {
    try { $res.Close() } catch {}
  }
}
$listener.Stop()
