Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$global:CONFIG = @{
    GamePath = "E:\Neo Empire Earth\Empire Earth\Data\Saved Games"
    Desktop = [System.Environment]::GetFolderPath('Desktop')
    ConfigFile = Join-Path $env:USERPROFILE "neoee-config.json"
}

function Show-GameTypeWindow {
    $gtForm = New-Object System.Windows.Forms.Form
    $gtForm.Text = "Tipo de partida"
    $gtForm.Size = New-Object System.Drawing.Size(720,420)
    $gtForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    $gtForm.BackColor = $global:THEME.Background
    $gtForm.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $leftX = 20
    $cbWidth = 380
    $startY = 10
    $rowHeight = 36

    $cbSize = New-Object System.Windows.Forms.ComboBox
    $cbSize.Location = New-Object System.Drawing.Point -ArgumentList ([int]$leftX, [int]($startY + 0))
    $cbSize.Size = New-Object System.Drawing.Size($cbWidth,30)
    $cbSize.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cbSize.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cbSize.Name = 'cbMapSize'
    $cbSize.Items.AddRange($global:MAP_SIZES)
    $cbSize.SelectedIndex = 0
    $gtForm.Controls.Add($cbSize)

    $cbDiff = New-Object System.Windows.Forms.ComboBox
    $cbDiff.Location = New-Object System.Drawing.Point -ArgumentList ([int]$leftX, [int]($startY + (1 * $rowHeight) + 5))
    $cbDiff.Size = New-Object System.Drawing.Size($cbWidth,30)
    $cbDiff.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cbDiff.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cbDiff.Name = 'cbDifficulty'
    $cbDiff.Items.AddRange($global:DIFFICULTIES)
    $cbDiff.SelectedIndex = 0
    $gtForm.Controls.Add($cbDiff)

    $cbMap = New-Object System.Windows.Forms.ComboBox
    $cbMap.Location = New-Object System.Drawing.Point -ArgumentList ([int]$leftX, [int]($startY + (2 * $rowHeight) + 10))
    $cbMap.Size = New-Object System.Drawing.Size($cbWidth,30)
    $cbMap.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cbMap.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cbMap.Name = 'cbMapType'
    $cbMap.Items.AddRange($global:MAP_TYPES)
    $cbMap.SelectedIndex = 0
    $gtForm.Controls.Add($cbMap)

    $cbGameType = New-Object System.Windows.Forms.ComboBox
    $cbGameType.Location = New-Object System.Drawing.Point -ArgumentList ([int]$leftX, [int]($startY + (3 * $rowHeight) + 15))
    $cbGameType.Size = New-Object System.Drawing.Size($cbWidth,30)
    $cbGameType.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cbGameType.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cbGameType.Name = 'cbGameType'
    $cbGameType.Items.AddRange($global:GAME_TYPES)
    $cbGameType.SelectedIndex = 0
    $gtForm.Controls.Add($cbGameType)

    $btnCopy = New-Object System.Windows.Forms.Button
    $btnCopy.Text = "Copiar configuracion"
    $btnCopy.Size = New-Object System.Drawing.Size(180,38)
    $btnCopy.Location = New-Object System.Drawing.Point -ArgumentList ([int]$leftX, [int]($startY + (4 * $rowHeight) + 20))
    $btnCopy.BackColor = $global:THEME.Primary
    $btnCopy.ForeColor = [System.Drawing.Color]::White
    $btnCopy.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCopy.FlatAppearance.BorderSize = 0
    $btnCopy.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnCopy.Add_Click({
        $global:SelectedMapSize = $cbSize.SelectedItem
        $global:SelectedDifficulty = $cbDiff.SelectedItem
        $global:SelectedMapType = $cbMap.SelectedItem
        $global:SelectedGameType = $cbGameType.SelectedItem

        $obj = [PSCustomObject]@{
            MapSize = $global:SelectedMapSize
            Difficulty = $global:SelectedDifficulty
            MapType = $global:SelectedMapType
            GameType = $global:SelectedGameType
        }
        $text = $obj | ConvertTo-Json -Compress
        try {
            [System.Windows.Forms.Clipboard]::SetText($text)
        } catch {
        }
        $global:CopiedGameConfig = $obj
        [System.Windows.Forms.MessageBox]::Show("Configuracion copiada al portapapeles", "Copiado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $gtForm.Controls.Add($btnCopy)
    $btnRuleta = New-Object System.Windows.Forms.Button
    $btnRuleta.Text = "Ruleta"
    $btnRuleta.Size = New-Object System.Drawing.Size(160,38)
    $btnRuleta.Location = New-Object System.Drawing.Point -ArgumentList ([int]($leftX + $cbWidth + 20), [int]$startY)
    $btnRuleta.BackColor = $global:THEME.Warning
    $btnRuleta.ForeColor = [System.Drawing.Color]::White
    $btnRuleta.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnRuleta.FlatAppearance.BorderSize = 0
    $btnRuleta.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnRuleta.Add_Click({ Show-RuletaWindow })
    $gtForm.Controls.Add($btnRuleta)

    $gtForm.ShowDialog()
}

if (-Not (Test-Path -Path $global:CONFIG.GamePath)) {
    $global:CONFIG.GamePath = "C:\Program Files (x86)\Neo Empire Earth\Empire Earth\Data\Saved Games"
}

$global:EditMode = $false
$global:isDragging = $false
$global:currentControl = $null
$global:offset = New-Object System.Drawing.Point

function LoadConfig {
    if (Test-Path $global:CONFIG.ConfigFile) {
        $savedConfig = Get-Content $global:CONFIG.ConfigFile | ConvertFrom-Json
        
        $config = @{
            ButtonLocations = @{}
            GridViewLocation = @{
                X = $savedConfig.GridViewLocation.X
                Y = $savedConfig.GridViewLocation.Y
            }
            GridViewSize = @{
                Width = $savedConfig.GridViewSize.Width
                Height = $savedConfig.GridViewSize.Height
            }
            ComboLocation = @{
                X = $savedConfig.ComboLocation.X
                Y = $savedConfig.ComboLocation.Y
            }
            WindowSize = @{
                Width = $savedConfig.WindowSize.Width
                Height = $savedConfig.WindowSize.Height
            }
            EditButtonLocation = @{
                X = $savedConfig.EditButtonLocation.X
                Y = $savedConfig.EditButtonLocation.Y
            }
            TitleLocation = if ($savedConfig.TitleLocation) {
                @{
                    X = $savedConfig.TitleLocation.X
                    Y = $savedConfig.TitleLocation.Y
                }
            } else {
                @{X=20; Y=20}
            }
        }

        $savedConfig.ButtonLocations.PSObject.Properties | ForEach-Object {
            $config.ButtonLocations[$_.Name] = @{
                X = $_.Value.X
                Y = $_.Value.Y
            }
        }

        return $config
    }
    
    return @{
        ButtonLocations = @{
            "btnMoveDesktop" = @{X=20; Y=70}
            "btnDeleteAuto" = @{X=20; Y=170}
            "btnOpenDir" = @{X=20; Y=120}
            "btnDeleteAll" = @{X=20; Y=220}
            "btnReload" = @{X=20; Y=270}
            "btnGameType" = @{X=20; Y=320}
        }
        GridViewLocation = @{X=200; Y=70}
        GridViewSize = @{Width=760; Height=450}
        ComboLocation = @{X=200; Y=540}
        WindowSize = @{Width=1100; Height=650}
        EditButtonLocation = @{X=20; Y=370}
        TitleLocation = @{X=20; Y=20}
    }
}

$global:UIConfig = LoadConfig

$global:MAP_SIZES = @(
    'diminuto',
    'pequeno',
    'mediano',
    'grande',
    'enorme',
    'gigante'
)

$global:DIFFICULTIES = @(
    'facil',
    'medio',
    'dificil'
)

$global:MAP_TYPES = @(
    'neo mediterraneo',
    'mediterraneo',
    'llanuras',
    'montanoso',
    'islas pequenas',
    'islas grandes',
    'perfect islands'
)

$global:GAME_TYPES = @(
    '2v2',
    '3v3',
    '2v2v2',
    '3v3v3',
    '4v4',
    '5v5',
    '2v2v2v2',
    '2v1v1v1v1v1v1v1v1'
)

function Show-RuletaWindow {
    $rForm = New-Object System.Windows.Forms.Form
    $rForm.Text = "Ruleta - Generador de presets"
    $rForm.Size = New-Object System.Drawing.Size(820,520)
    $rForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    $rForm.BackColor = $global:THEME.Background
    $rForm.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    $panelWheel = New-Object System.Windows.Forms.Panel
    $panelWheel.Location = New-Object System.Drawing.Point(20,20)
    $panelWheel.Size = New-Object System.Drawing.Size(480,440)
    $panelWheel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $rForm.Controls.Add($panelWheel)

    $lblPresets = New-Object System.Windows.Forms.Label
    $lblPresets.Text = "Presets (una opcion por linea)"
    $lblPresets.Location = New-Object System.Drawing.Point(520,20)
    $lblPresets.AutoSize = $true
    $rForm.Controls.Add($lblPresets)

    $txtPresets = New-Object System.Windows.Forms.TextBox
    $txtPresets.Location = New-Object System.Drawing.Point(520,50)
    $txtPresets.Size = New-Object System.Drawing.Size(270,260)
    $txtPresets.Multiline = $true
    $txtPresets.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $txtPresets.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $txtPresets.Name = 'txtPresets'
    $txtPresets.ReadOnly = $true
    $txtPresets.Text = ("mediano","medio","llanuras","2v2") -join "`r`n"
    $rForm.Controls.Add($txtPresets)

    $lblPresetSource = New-Object System.Windows.Forms.Label
    $lblPresetSource.Text = "Fuente de presets"
    $lblPresetSource.Location = New-Object System.Drawing.Point(520,320)
    $lblPresetSource.AutoSize = $true
    $rForm.Controls.Add($lblPresetSource)

    $cbPresetSource = New-Object System.Windows.Forms.ComboBox
    $cbPresetSource.Location = New-Object System.Drawing.Point(520,345)
    $cbPresetSource.Size = New-Object System.Drawing.Size(180,26)
    $cbPresetSource.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $cbPresetSource.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cbPresetSource.Items.AddRange(@("Map Sizes","Difficulties","Map Types","Game Types","Custom"))
    $cbPresetSource.SelectedIndex = 0
    $rForm.Controls.Add($cbPresetSource)
    
    $btnCustom = New-Object System.Windows.Forms.Button
    $btnCustom.Text = "Custom"
    $cbPresetSource.Width = 180
    $gap = 10
    $btnCustom.Size = New-Object System.Drawing.Size(80,26)
    $btnCustom.Location = New-Object System.Drawing.Point( ($cbPresetSource.Location.X + $cbPresetSource.Width + $gap), $cbPresetSource.Location.Y )
    $btnCustom.BackColor = $global:THEME.Secondary
    $btnCustom.ForeColor = [System.Drawing.Color]::White
    $btnCustom.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCustom.FlatAppearance.BorderSize = 0
    $btnCustom.Cursor = [System.Windows.Forms.Cursors]::Hand
    $rForm.Controls.Add($btnCustom)

    $btnGenerate = New-Object System.Windows.Forms.Button
    $btnGenerate.Text = "Generar ruleta desde presets"
    $btnGenerate.Size = New-Object System.Drawing.Size(270,36)
    $btnGenerate.Location = New-Object System.Drawing.Point(520,380)
    $btnGenerate.BackColor = $global:THEME.Primary
    $btnGenerate.ForeColor = [System.Drawing.Color]::White
    $btnGenerate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnGenerate.FlatAppearance.BorderSize = 0
    $btnGenerate.Cursor = [System.Windows.Forms.Cursors]::Hand
    $rForm.Controls.Add($btnGenerate)

    $btnStart = New-Object System.Windows.Forms.Button
    $btnStart.Text = "Iniciar Ruleta"
    $btnStart.Size = New-Object System.Drawing.Size(270,36)
    $btnStart.Location = New-Object System.Drawing.Point(520,425)
    $btnStart.BackColor = $global:THEME.Success
    $btnStart.ForeColor = [System.Drawing.Color]::White
    $btnStart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnStart.FlatAppearance.BorderSize = 0
    $btnStart.Cursor = [System.Windows.Forms.Cursors]::Hand
    $rForm.Controls.Add($btnStart)

    $currentSlots = @()
    $ballSize = 16
    $ball = New-Object System.Windows.Forms.Panel
    $ball.Size = New-Object System.Drawing.Size($ballSize, $ballSize)
    $ball.BackColor = [System.Drawing.Color]::Red
    $ball.Visible = $false
    $panelWheel.Controls.Add($ball)
    try {
        $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $gp.AddEllipse(0,0,$ballSize,$ballSize)
        $ball.Region = New-Object System.Drawing.Region($gp)
    } catch {
    }
    $panelWheel.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

        $w = $panelWheel.ClientSize.Width
        $h = $panelWheel.ClientSize.Height
        $centerX = [int]($w / 2)
        $centerY = [int]($h / 2)
        $radius = [int](([Math]::Min($w,$h) / 2) - 20)

        if ($currentSlots.Count -eq 0) {
            $font = New-Object System.Drawing.Font("Segoe UI", 12)
            $sf = New-Object System.Drawing.StringFormat
            $sf.Alignment = [System.Drawing.StringAlignment]::Center
            $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
            $rectF = [System.Drawing.RectangleF]::new([float]0, [float]0, [float]$w, [float]$h)
            $g.DrawString("No hay slots. Genera la ruleta.", $font, [System.Drawing.Brushes]::Black, $rectF, $sf)
            return
        }

        $segments = $currentSlots.Count
        $angleStep = 360.0 / $segments

        for ($i=0; $i -lt $segments; $i++) {
            $startAngle = $i * $angleStep
            $sweep = $angleStep
            $color = if ($i % 2 -eq 0) { [System.Drawing.Color]::FromArgb(255, 240,240,240) } else { [System.Drawing.Color]::FromArgb(255, 220,220,220) }
            $brush = New-Object System.Drawing.SolidBrush($color)

            $rect = [System.Drawing.Rectangle]::new($centerX - $radius, $centerY - $radius, $radius*2, $radius*2)
            $g.FillPie($brush, $rect, $startAngle, $sweep)
            $g.DrawPie([System.Drawing.Pens]::Black, $rect, $startAngle, $sweep)
            $midAngle = ($startAngle + $sweep/2)
            $rad = [Math]::PI * $midAngle / 180
            $textRadius = $radius * 0.62
            $xText = $centerX + [Math]::Cos($rad) * $textRadius
            $yText = $centerY + [Math]::Sin($rad) * $textRadius
            $label = $currentSlots[$i]
            $font = New-Object System.Drawing.Font("Segoe UI", 9)
            $g.TranslateTransform($xText, $yText)
            $g.RotateTransform($midAngle)
            $g.DrawString($label, $font, [System.Drawing.Brushes]::Black, -($font.Size * 4), -6)
            $g.ResetTransform()
            $brush.Dispose()
        }
        $g.FillEllipse([System.Drawing.Brushes]::White, $centerX - 30, $centerY - 30, 60, 60)
        $g.DrawEllipse([System.Drawing.Pens]::Black, $centerX - 30, $centerY - 30, 60, 60)
    })

    $btnGenerate.Add_Click({
        $lines = $txtPresets.Lines | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $txtPresets.Text = ($lines -join "`r`n")
        $currentSlots = @()
        foreach ($ln in $lines) { $currentSlots += $ln }
        $panelWheel.Invalidate()
    })
    $cbPresetSource.Add_SelectedIndexChanged({
        switch ($cbPresetSource.SelectedItem) {
            'Map Sizes'   { 
                $txtPresets.Text = ($global:MAP_SIZES -join "`r`n")
                $currentSlots = @($global:MAP_SIZES)
            }
            'Difficulties' { 
                $txtPresets.Text = ($global:DIFFICULTIES -join "`r`n")
                $currentSlots = @($global:DIFFICULTIES)
            }
            'Map Types'   { 
                $txtPresets.Text = ($global:MAP_TYPES -join "`r`n")
                $currentSlots = @($global:MAP_TYPES)
            }
            'Game Types'  { 
                $txtPresets.Text = ($global:GAME_TYPES -join "`r`n")
                $currentSlots = @($global:GAME_TYPES)
            }
            'Custom'      { 
                $lines = $txtPresets.Lines | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
                $currentSlots = @()
                foreach ($ln in $lines) { $currentSlots += $ln }
            }
        }
        $panelWheel.Invalidate()
    })
    $txtPresets.Text = ($global:MAP_SIZES -join "`r`n")
    $currentSlots = @($global:MAP_SIZES)
    $panelWheel.Invalidate()
    $btnCustom.Add_Click({
        $editForm = New-Object System.Windows.Forms.Form
        $editForm.Text = "Editar preset personalizado"
        $editForm.Size = New-Object System.Drawing.Size(420,420)
        $editForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent

        $tbEdit = New-Object System.Windows.Forms.TextBox
        $tbEdit.Multiline = $true
        $tbEdit.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $tbEdit.Size = New-Object System.Drawing.Size(380,320)
        $tbEdit.Location = New-Object System.Drawing.Point(10,10)
        $tbEdit.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $tbEdit.Text = $txtPresets.Text
        $editForm.Controls.Add($tbEdit)

        $btnOk = New-Object System.Windows.Forms.Button
        $btnOk.Text = "Aceptar"
        $btnOk.Location = New-Object System.Drawing.Point(220,345)
        $btnOk.Size = New-Object System.Drawing.Size(80,30)
        $editForm.Controls.Add($btnOk)

        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "Cancelar"
        $btnCancel.Location = New-Object System.Drawing.Point(310,345)
        $btnCancel.Size = New-Object System.Drawing.Size(80,30)
        $editForm.Controls.Add($btnCancel)

        $btnOk.Add_Click({
            $lines = $tbEdit.Lines | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
            $txtPresets.Text = ($lines -join "`r`n")
            $cbPresetSource.SelectedItem = 'Custom'
            $currentSlots = @()
            foreach ($ln in $lines) { $currentSlots += $ln }
            $panelWheel.Invalidate()
            $editForm.Close()
        })

        $btnCancel.Add_Click({ $editForm.Close() })

        $editForm.ShowDialog()
    })
    $btnStart.Add_Click({
        $linesNow = $txtPresets.Lines | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $currentSlots = @()
        foreach ($ln in $linesNow) { $currentSlots += $ln }

        if ($currentSlots.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Primero genera la ruleta con al menos una casilla.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $btnStart.Enabled = $false
        $steps = Get-Random -Minimum 80 -Maximum 150
        $rotations = Get-Random -Minimum 3 -Maximum 7
        $segments = $currentSlots.Count
        $angleStep = 360.0 / $segments
        $targetIndex = Get-Random -Minimum 0 -Maximum ($segments - 1)
        $finalAngle = ($targetIndex + 0.5) * $angleStep + ($rotations * 360)

        $centerX = [int]($panelWheel.ClientSize.Width / 2)
        $centerY = [int]($panelWheel.ClientSize.Height / 2)
        $radius = [int](([Math]::Min($panelWheel.ClientSize.Width,$panelWheel.ClientSize.Height) / 2) - 40)

        for ($i=0; $i -le $steps; $i++) {
            $t = [double]$i / $steps
            $ease = 1 - [Math]::Pow(1 - $t, 3)
            $angle = $ease * $finalAngle
            $angleRad = [Math]::PI * $angle / 180
            $x = $centerX + [Math]::Cos($angleRad) * $radius
            $y = $centerY + [Math]::Sin($angleRad) * $radius
            $ball.Left = [int]($x - $ballSize/2)
            $ball.Top = [int]($y - $ballSize/2)
            $ball.BringToFront()
            $ball.Visible = $true
            Start-Sleep -Milliseconds 12
            $panelWheel.Refresh()
        }

        $landedAngle = $finalAngle % 360
        $landedIndex = [int]([Math]::Floor($landedAngle / $angleStep)) % $segments
        $resultLabel = $currentSlots[$landedIndex]
        [System.Windows.Forms.MessageBox]::Show("La ruleta selecciono: $resultLabel", "Resultado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        $btnStart.Enabled = $true
        $ball.Visible = $false
    })

    $rForm.ShowDialog()
}

$global:THEME = @{
    Primary = [System.Drawing.Color]::FromArgb(255, 25, 91, 255)
    Secondary = [System.Drawing.Color]::FromArgb(255, 75, 85, 99)
    Background = [System.Drawing.Color]::FromArgb(255, 240, 240, 240)
    Success = [System.Drawing.Color]::FromArgb(255, 34, 197, 94)
    Warning = [System.Drawing.Color]::FromArgb(255, 234, 179, 8)
    Danger = [System.Drawing.Color]::FromArgb(255, 239, 68, 68)
}

function MakeDraggable {
    param (
        [System.Windows.Forms.Control]$Control,
        [string]$ControlName
    )

    if (-not $Control.Name) {
        $Control.Name = $ControlName
    }
    
    $Control.Add_MouseDown({
        param($pSender, $e)
        if ($global:EditMode -and $e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            $global:isDragging = $true
            $global:currentControl = $pSender
            $global:offset = New-Object System.Drawing.Point(
                ($e.X),
                ($e.Y)
            )
        }
    })

    $Control.Add_MouseMove({
        param($pSender, $e)
        if ($global:isDragging -and $global:EditMode -and $global:currentControl -eq $pSender) {
            $newX = $pSender.Left + $e.X - $global:offset.X
            $newY = $pSender.Top + $e.Y - $global:offset.Y
            $pSender.Location = New-Object System.Drawing.Point($newX, $newY)

            if ($pSender -is [System.Windows.Forms.Button]) {
                if ($pSender.Name -eq 'btnEditMode') {
                    $global:UIConfig.EditButtonLocation = @{ X = $newX; Y = $newY }
                } else {
                    $global:UIConfig.ButtonLocations[$pSender.Name] = @{ X = $newX; Y = $newY }
                }
            } elseif ($pSender -is [System.Windows.Forms.DataGridView]) {
                $global:UIConfig.GridViewLocation = @{ X = $newX; Y = $newY }
            } elseif ($pSender -is [System.Windows.Forms.ComboBox]) {
                $global:UIConfig.ComboLocation = @{ X = $newX; Y = $newY }
            } elseif ($pSender -is [System.Windows.Forms.Label] -and $pSender.Name -eq "title") {
                $global:UIConfig.TitleLocation = @{ X = $newX; Y = $newY }
            }
        }
    })

    $Control.Add_MouseUp({
        param($pSender, $e)
        if ($global:isDragging -and $global:currentControl -eq $pSender) {
            $global:isDragging = $false
            $global:currentControl = $null
        }
    })

    $Control.Add_MouseLeave({
        param($pSender, $e)
        if ($global:isDragging -and $global:currentControl -eq $pSender) {
            $global:isDragging = $false
            $global:currentControl = $null
        }
    })
}

function Save-Config {
    $global:UIConfig | ConvertTo-Json | Set-Content $global:CONFIG.ConfigFile
}

function New-StyledButton {
    param (
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width = 160,
        [int]$Height = 40,
        [System.Drawing.Color]$Color = $global:THEME.Primary
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Size = New-Object System.Drawing.Size($Width, $Height)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.BackColor = $Color
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $button.FlatAppearance.BorderSize = 0
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    return $button
}

function New-StyledDataGridView {
    param (
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )
    
    $dgv = New-Object System.Windows.Forms.DataGridView
    $dgv.Location = New-Object System.Drawing.Point($X, $Y)
    $dgv.Size = New-Object System.Drawing.Size($Width, $Height)
    $dgv.BackgroundColor = $global:THEME.Background
    $dgv.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $dgv.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
    $dgv.AllowUserToAddRows = $false
    $dgv.AllowUserToDeleteRows = $false
    $dgv.ReadOnly = $true
    $dgv.MultiSelect = $true
    $dgv.RowHeadersVisible = $false
    $dgv.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
    $dgv.ColumnHeadersHeight = 40
    $dgv.EnableHeadersVisualStyles = $false
    $dgv.RowTemplate.Height = 35
    $dgv.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    return $dgv
}

function Update-FileList {
    param (
        [System.Windows.Forms.DataGridView]$GridView
    )
    
    $GridView.Rows.Clear()
    Get-ChildItem -Path $global:CONFIG.GamePath -File | ForEach-Object {
        $GridView.Rows.Add($_.Name, $_.LastWriteTime)
    }
}

function Move-FromDesktop {
    $file = Get-ChildItem -Path $global:CONFIG.Desktop -Filter *.ees | Select-Object -First 1
    if ($file) {
        $destinationPath = Join-Path -Path $global:CONFIG.GamePath -ChildPath $file.Name

        if (Test-Path $destinationPath) {
            Remove-Item -Path $destinationPath -Force
        }

        Move-Item -Path $file.FullName -Destination $global:CONFIG.GamePath -ErrorAction Stop
        Update-FileList -GridView $fileList
        [System.Windows.Forms.MessageBox]::Show(
            "Archivo movido correctamente",
            "exito",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } else {
        [System.Windows.Forms.MessageBox]::Show(
            "No se encontraron archivos .ees en el escritorio",
            "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }
}

function Remove-AutoSaves {
    $archivos = Get-ChildItem -Path $global:CONFIG.GamePath -Filter "AutoSave*" -File
    $num = $archivos.Count

    if ($num -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "No se encontraron archivos autoguardados",
            "Informacion",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        return
    }

    $result = [System.Windows.Forms.MessageBox]::Show(
        "Estas seguro de eliminar $num archivos de autoguardados?",
        "Confirmar eliminacion",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        $archivos | ForEach-Object {
            Remove-Item -Path $_.FullName -Force
        }

        Update-FileList -GridView $fileList

        [System.Windows.Forms.MessageBox]::Show(
            "Se eliminaron $num archivos autoguardados",
            "Completado",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
}


function ToggleEditMode {
    $global:EditMode = -not $global:EditMode
    $btnEditMode.Text = if ($global:EditMode) { "Salir del modo edicion" } else { "Entrar en modo edicion" }
    $btnEditMode.BackColor = if ($global:EditMode) { $global:THEME.Warning } else { $global:THEME.Primary }
    
    $form.Controls | ForEach-Object {
        if ($_ -is [System.Windows.Forms.Button]) {
            $_.Cursor = if ($global:EditMode) { [System.Windows.Forms.Cursors]::SizeAll } else { [System.Windows.Forms.Cursors]::Hand }
        }
        elseif ($_ -is [System.Windows.Forms.DataGridView] -or $_ -is [System.Windows.Forms.ComboBox] -or ($_ -is [System.Windows.Forms.Label] -and $_.Name -eq "title")) {
            $_.Cursor = if ($global:EditMode) { [System.Windows.Forms.Cursors]::SizeAll } else { [System.Windows.Forms.Cursors]::Default }
        }
    }
}

function Show-MainWindow {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "NeoEE"
    $form.Size = New-Object System.Drawing.Size($global:UIConfig.WindowSize.Width, $global:UIConfig.WindowSize.Height)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.BackColor = $global:THEME.Background
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    $form.Add_SizeChanged({
        $global:UIConfig.WindowSize = @{
            Width = $form.Size.Width
            Height = $form.Size.Height
        }
    })

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Guardados NeoEE"
    $title.Location = New-Object System.Drawing.Point(
        $global:UIConfig.TitleLocation.X,
        $global:UIConfig.TitleLocation.Y
    )
    $title.AutoSize = $true
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = $global:THEME.Primary
    $title.Name = "title"
    MakeDraggable -Control $title -ControlName "title"

    $btnEditMode = New-StyledButton -Text "Entrar en modo edicion" `
        -X $global:UIConfig.EditButtonLocation.X `
        -Y $global:UIConfig.EditButtonLocation.Y `
        -Color $global:THEME.Primary
    $btnEditMode.Add_Click({ ToggleEditMode })
    MakeDraggable -Control $btnEditMode -ControlName "btnEditMode"

    if (-not $global:UIConfig.ButtonLocations.ContainsKey('btnGameType')) {
        $global:UIConfig.ButtonLocations['btnGameType'] = @{ X = 20; Y = 320 }
    }

    $btnGameType = New-StyledButton -Text "Tipo de partida" `
        -X $global:UIConfig.ButtonLocations.btnGameType.X `
        -Y $global:UIConfig.ButtonLocations.btnGameType.Y `
        -Color $global:THEME.Warning
    $btnGameType.Add_Click({ if (-not $global:EditMode) { Show-GameTypeWindow } })
    MakeDraggable -Control $btnGameType -ControlName "btnGameType"

    $btnDeleteAuto = New-StyledButton -Text "Eliminar autoguardados" `
        -X $global:UIConfig.ButtonLocations.btnDeleteAuto.X `
        -Y $global:UIConfig.ButtonLocations.btnDeleteAuto.Y
    $btnDeleteAuto.Add_Click({ 
        if (-not $global:EditMode) { Remove-AutoSaves }
    })
    MakeDraggable -Control $btnDeleteAuto -ControlName "btnDeleteAuto"
    
    $btnOpenDir = New-StyledButton -Text "Abrir directorio" `
        -X $global:UIConfig.ButtonLocations.btnOpenDir.X `
        -Y $global:UIConfig.ButtonLocations.btnOpenDir.Y
    $btnOpenDir.Add_Click({ 
        if (-not $global:EditMode) { Start-Process explorer.exe -ArgumentList $global:CONFIG.GamePath }
    })
    MakeDraggable -Control $btnOpenDir -ControlName "btnOpenDir"
    
    $btnMoveDesktop = New-StyledButton -Text "Mover del escritorio" `
        -X $global:UIConfig.ButtonLocations.btnMoveDesktop.X `
        -Y $global:UIConfig.ButtonLocations.btnMoveDesktop.Y
    $btnMoveDesktop.Add_Click({ 
        if (-not $global:EditMode) { Move-FromDesktop }
    })
    MakeDraggable -Control $btnMoveDesktop -ControlName "btnMoveDesktop"
    
    $btnDeleteAll = New-StyledButton -Text "Borrar todo" `
        -X $global:UIConfig.ButtonLocations.btnDeleteAll.X `
        -Y $global:UIConfig.ButtonLocations.btnDeleteAll.Y `
        -Color $global:THEME.Danger
    $btnDeleteAll.Add_Click({
        if (-not $global:EditMode) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Estas seguro que quieres borrar todos los archivos?",
                "Confirmar eliminacion",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                Get-ChildItem -Path $global:CONFIG.GamePath -File | Remove-Item -Force
                Update-FileList -GridView $fileList
                [System.Windows.Forms.MessageBox]::Show("Todos los archivos han sido eliminados", "Completado")
            }
        }
    })
    MakeDraggable -Control $btnDeleteAll -ControlName "btnDeleteAll"
    
    $btnReload = New-StyledButton -Text "Recargar lista" `
        -X $global:UIConfig.ButtonLocations.btnReload.X `
        -Y $global:UIConfig.ButtonLocations.btnReload.Y `
        -Color $global:THEME.Success
    $btnReload.Add_Click({ 
        if (-not $global:EditMode) { Update-FileList -GridView $fileList }
    })
    MakeDraggable -Control $btnReload -ControlName "btnReload"

    $fileList = New-StyledDataGridView `
        -X $global:UIConfig.GridViewLocation.X `
        -Y $global:UIConfig.GridViewLocation.Y `
        -Width $global:UIConfig.GridViewSize.Width `
        -Height $global:UIConfig.GridViewSize.Height
    $fileList.Columns.Add("FileName", "Archivo")
    $fileList.Columns.Add("LastModified", "Ultima modificacion")
    MakeDraggable -Control $fileList -ControlName "fileList"

    Update-FileList -GridView $fileList

    $comboActions = New-Object System.Windows.Forms.ComboBox
    $comboActions.Location = New-Object System.Drawing.Point(
        $global:UIConfig.ComboLocation.X,
        $global:UIConfig.ComboLocation.Y
    )
    $comboActions.Size = New-Object System.Drawing.Size(180, 30)
    $comboActions.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $comboActions.Items.AddRange(@("Eliminar", "Mover al Escritorio"))
    $comboActions.SelectedIndex = 0
    $comboActions.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    MakeDraggable -Control $comboActions -ControlName "comboActions"
    
    $btnApply = New-StyledButton -Text "Aplicar" -X ($comboActions.Location.X + 190) -Y $comboActions.Location.Y -Width 120
    $btnApply.Add_Click({
        if (-not $global:EditMode) {
            if ($fileList.SelectedRows.Count -eq 0) {
                [System.Windows.Forms.MessageBox]::Show("Selecciona al menos un archivo", "Aviso")
                return
            }
            
            $selectedFiles = @($fileList.SelectedRows | ForEach-Object { $_.Cells[0].Value })
            
            $confirmMessage = if ($comboActions.SelectedItem -eq "Eliminar") {
                "Estas seguro de eliminar los archivos seleccionados?"
            } else {
                "Estas seguro de mover los archivos al escritorio?"
            }
            
            $result = [System.Windows.Forms.MessageBox]::Show(
                $confirmMessage,
                "Confirmar accion",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )
            
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                foreach ($fileName in $selectedFiles) {
                    $filePath = Join-Path $global:CONFIG.GamePath $fileName
                    
                    if ($comboActions.SelectedItem -eq "Eliminar") {
                        Remove-Item -Path $filePath -Force
                    } else {
                        $destPath = Join-Path $global:CONFIG.Desktop $fileName
                        if (Test-Path $destPath) {
                            Remove-Item -Path $destPath -Force
                        }
                        Move-Item -Path $filePath -Destination $global:CONFIG.Desktop -Force
                    }
                }
                
                Update-FileList -GridView $fileList
                [System.Windows.Forms.MessageBox]::Show("Operacion completada", "exito")
            }
        }
    })
    MakeDraggable -Control $btnApply -ControlName "btnApply"

    $form.Add_FormClosing({
        Save-Config
    })

    $form.Controls.AddRange(@(
        $title,
        $btnDeleteAuto,
        $btnOpenDir,
        $btnMoveDesktop,
        $btnDeleteAll,
        $btnReload,
        $fileList,
        $comboActions,
        $btnApply,
        $btnGameType,
        $btnEditMode
    ))

    $btnDeleteAuto.Name = "btnDeleteAuto"
    $btnOpenDir.Name = "btnOpenDir"
    $btnMoveDesktop.Name = "btnMoveDesktop"
    $btnDeleteAll.Name = "btnDeleteAll"
    $btnReload.Name = "btnReload"
    $btnEditMode.Name = "btnEditMode"
    $btnGameType.Name = "btnGameType"
    $btnApply.Name = "btnApply"
    $fileList.Name = "fileList"
    $comboActions.Name = "comboActions"

    $form.Add_MouseMove({
        param($pSender, $e)
        if ($global:isDragging -and $global:EditMode -and $global:currentControl) {
            $newX = $e.X - $global:offset.X
            $newY = $e.Y - $global:offset.Y
            $global:currentControl.Location = New-Object System.Drawing.Point($newX, $newY)

            if ($global:currentControl -is [System.Windows.Forms.Button]) {
                if (-not $global:UIConfig.ButtonLocations) {
                    $global:UIConfig.ButtonLocations = @{}
                }
                $global:UIConfig.ButtonLocations[$global:currentControl.Name] = @{
                    X = $newX
                    Y = $newY
                }
            } elseif ($global:currentControl -is [System.Windows.Forms.DataGridView]) {
                $global:UIConfig.GridViewLocation = @{
                    X = $newX
                    Y = $newY
                }
            } elseif ($global:currentControl -is [System.Windows.Forms.ComboBox]) {
                $global:UIConfig.ComboLocation = @{
                    X = $newX
                    Y = $newY
                }
            }
        }
    })

    $form.Add_MouseUp({
        if ($global:isDragging) {
            $global:isDragging = $false
            $global:currentControl = $null
        }
    })

    $form.ShowDialog()
}

[System.Windows.Forms.Application]::EnableVisualStyles()
Show-MainWindow
