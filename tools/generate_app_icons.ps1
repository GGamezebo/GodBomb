# Single app icon: opaque black canvas, rounded plate, simple clock dial + bomb.
Add-Type -AssemblyName System.Drawing

function New-IconBitmap([int]$Width, [int]$Height) {
    $fmt = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    $bmp = New-Object System.Drawing.Bitmap($Width, $Height, $fmt)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Black)
    return @{ Bmp = $bmp; G = $g }
}

function Add-RoundedRectPath([System.Drawing.Drawing2D.GraphicsPath]$Path, [float]$X, [float]$Y, [float]$W, [float]$H, [float]$R) {
    $d = $R * 2.0
    $Path.AddArc($X, $Y, $d, $d, 180, 90)
    $Path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $Path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $Path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $Path.CloseFigure()
}

function Fill-RoundedRect($G, [float]$X, [float]$Y, [float]$W, [float]$H, [float]$R, [System.Drawing.Color]$Color) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-RoundedRectPath $path $X $Y $W $H $R
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $G.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Draw-ClockDial($G, [float]$Cx, [float]$Cy, [float]$Radius) {
    $orange = [System.Drawing.Color]::FromArgb(255, 232, 120, 48)
    $penWidth = [Math]::Max(2.0, $Radius * 0.045)
    $pen = New-Object System.Drawing.Pen($orange, $penWidth)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $G.DrawEllipse($pen, $Cx - $Radius, $Cy - $Radius, $Radius * 2.0, $Radius * 2.0)

    $tickWidth = [Math]::Max(1.5, $Radius * 0.03)
    $tickPen = New-Object System.Drawing.Pen($orange, $tickWidth)
    $tickPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $tickPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    for ($i = 0; $i -lt 12; $i++) {
        $angle = ($i * 30.0 - 90.0) * [Math]::PI / 180.0
        $isMajor = (($i % 3) -eq 0)
        if ($isMajor) { $innerMul = 0.78 } else { $innerMul = 0.84 }
        $inner = $Radius * $innerMul
        $outer = $Radius * 0.96
        $x1 = $Cx + [Math]::Cos($angle) * $inner
        $y1 = $Cy + [Math]::Sin($angle) * $inner
        $x2 = $Cx + [Math]::Cos($angle) * $outer
        $y2 = $Cy + [Math]::Sin($angle) * $outer
        $G.DrawLine($tickPen, $x1, $y1, $x2, $y2)
    }
    $pen.Dispose()
    $tickPen.Dispose()
}

function Draw-Bomb($G, [float]$Cx, [float]$Cy, [float]$Radius) {
    $red = [System.Drawing.Color]::FromArgb(255, 224, 32, 32)
    $brush = New-Object System.Drawing.SolidBrush($red)
    $G.FillEllipse($brush, $Cx - $Radius, $Cy - $Radius, $Radius * 2.0, $Radius * 2.0)
    $brush.Dispose()

    $eyeW = $Radius * 0.34
    $eyeH = $Radius * 0.42
    $eyeY = $Cy - $Radius * 0.08
    $eyeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $G.FillEllipse($eyeBrush, $Cx - $Radius * 0.42 - $eyeW * 0.5, $eyeY - $eyeH * 0.5, $eyeW, $eyeH)
    $G.FillEllipse($eyeBrush, $Cx + $Radius * 0.42 - $eyeW * 0.5, $eyeY - $eyeH * 0.5, $eyeW, $eyeH)
    $eyeBrush.Dispose()

    $pupilBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 20, 20, 20))
    $pupilR = $Radius * 0.11
    $G.FillEllipse($pupilBrush, $Cx - $Radius * 0.42 - $pupilR, $eyeY - $pupilR + $Radius * 0.03, $pupilR * 2.0, $pupilR * 2.0)
    $G.FillEllipse($pupilBrush, $Cx + $Radius * 0.42 - $pupilR, $eyeY - $pupilR + $Radius * 0.03, $pupilR * 2.0, $pupilR * 2.0)
    $pupilBrush.Dispose()

    $fuseWidth = [Math]::Max(2.0, $Radius * 0.12)
    $fusePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 120, 72, 40), $fuseWidth)
    $fusePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $fusePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $fuseX = $Cx + $Radius * 0.15
    $fuseY = $Cy - $Radius * 0.82
    $G.DrawLine($fusePen, $Cx + $Radius * 0.1, $Cy - $Radius * 0.72, $fuseX, $fuseY)
    $fusePen.Dispose()

    $flameBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 168, 48))
    $G.FillEllipse($flameBrush, $fuseX - $Radius * 0.12, $fuseY - $Radius * 0.22, $Radius * 0.24, $Radius * 0.28)
    $flameBrush.Dispose()
}

function Draw-IconArt($G, [float]$Size) {
    $cx = $Size * 0.5
    $cy = $Size * 0.52
    Draw-ClockDial $G $cx $cy ($Size * 0.31)
    Draw-Bomb $G $cx $cy ($Size * 0.17)
}

function Draw-AppIcon($G, [float]$Size) {
    $plate = [System.Drawing.Color]::FromArgb(255, 18, 18, 18)
    $inset = $Size * 0.08
    $side = $Size - ($inset * 2.0)
    $radius = $Size * 0.18
    Fill-RoundedRect $G $inset $inset $side $side $radius $plate
    Draw-IconArt $G $Size
}

function Save-Png($Bmp, [string]$Path) {
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
    $Bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
}

$assets = Join-Path (Split-Path $PSScriptRoot -Parent) "assets"

$mainSize = 1024
$ctx = New-IconBitmap $mainSize $mainSize
Draw-AppIcon $ctx.G $mainSize
Save-Png $ctx.Bmp (Join-Path $assets "icon.png")
$ctx.G.Dispose(); $ctx.Bmp.Dispose()

$adSize = 432
$ctx = New-IconBitmap $adSize $adSize
$ctx.G.Clear([System.Drawing.Color]::Black)
Save-Png $ctx.Bmp (Join-Path $assets "icon_adaptive_bg.png")
$ctx.G.Dispose(); $ctx.Bmp.Dispose()

foreach ($f in @("icon.png", "icon_adaptive_bg.png")) {
    $p = Join-Path $assets $f
    $img = [System.Drawing.Image]::FromFile($p)
    Write-Output "$f : $($img.Width)x$($img.Height)"
    $img.Dispose()
}

Write-Output "Done."
