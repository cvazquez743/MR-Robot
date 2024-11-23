Add-Type -AssemblyName System.Windows.Forms

# Retrieve the computer's serial number
$serialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

if (-not $serialNumber) {
    Write-Host "Unable to retrieve the serial number. Script exiting." -ForegroundColor Red
    exit
}

# Create the input form for location selection
$form = New-Object System.Windows.Forms.Form
$form.Text = "Computer Location Input"
$form.Width = 400
$form.Height = 200
$form.StartPosition = "CenterScreen"

# Add a label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select the location for the computer:"
$label.AutoSize = $true
$label.Top = 20
$label.Left = 10
$form.Controls.Add($label)

# Add a dropdown (combobox)
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Width = 360
$comboBox.Top = 50
$comboBox.Left = 10
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBox.Items.AddRange(@("CHI", "LEO", "MIA", "NAS", "COL"))
$form.Controls.Add($comboBox)

# Add an OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Width = 100
$okButton.Top = 100
$okButton.Left = 150
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)

# Show the form and process the result
$result = $form.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $comboBox.SelectedItem) {
    $location = $comboBox.SelectedItem
} else {
    Write-Host "Location not selected. Script exiting." -ForegroundColor Red
    exit
}

# Construct the new computer name using serial number and location
$newComputerName = "$location-$serialNumber"

# Prompt for domain credentials
$domainName = "corp.genuinecable.com"
$domainCredential = Get-Credential -Message "Enter domain credentials to join $domainName (e.g., 'GCG\Administrator')"

# Rename and join the computer to the domain
try {
    Add-Computer -NewName $newComputerName -DomainName $domainName -Credential $domainCredential -Restart -Force
    Write-Host "The computer has been renamed to $newComputerName and joined to the domain $domainName. It will restart now." -ForegroundColor Green
} catch {
    Write-Host "Failed to rename or join the computer to the domain. Error: $_" -ForegroundColor Red
    exit
}


