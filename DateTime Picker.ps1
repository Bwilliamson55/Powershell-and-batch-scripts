Add-Type -AssemblyName System.Windows.Forms

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font(“Consolas”, 13)
$mainForm.Text = ” Pick Time Frame”
$mainForm.Font = $font
$mainForm.ForeColor = “White”
$mainForm.BackColor = “DarkOliveGreen”
$mainForm.Width = 350
$mainForm.Height = 250

# DatePicker Label
$datePickerLabel = New-Object System.Windows.Forms.Label
$datePickerLabel.Text = “Start-Date”
$datePickerLabel.Location = “15, 10”
$datePickerLabel.Height = 22
$datePickerLabel.Width = 110
$mainForm.Controls.Add($datePickerLabel)

# EndDatePicker Label
$enddatePickerLabel = New-Object System.Windows.Forms.Label
$enddatePickerLabel.Text = “End-Date”
$enddatePickerLabel.Location = “15, 80”
$enddatePickerLabel.Height = 22
$enddatePickerLabel.Width = 110
$mainForm.Controls.Add($enddatePickerLabel)

# MinTimePicker Label
$minTimePickerLabel = New-Object System.Windows.Forms.Label
$minTimePickerLabel.Text = “Start-Time”
$minTimePickerLabel.Location = “15, 45”
$minTimePickerLabel.Height = 22
$minTimePickerLabel.Width = 110
$mainForm.Controls.Add($minTimePickerLabel)

# MaxTimePicker Label
$maxTimePickerLabel = New-Object System.Windows.Forms.Label
$maxTimePickerLabel.Text = “End-Time”
$maxTimePickerLabel.Location = “15, 115”
$maxTimePickerLabel.Height = 22
$maxTimePickerLabel.Width = 90
$mainForm.Controls.Add($maxTimePickerLabel)

# StartDatePicker
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = “130, 7”
$datePicker.Width = “150”
$datePicker.Format = [windows.forms.datetimepickerFormat]::custom
$datePicker.CustomFormat = “MM/dd/yyyy”
$mainForm.Controls.Add($datePicker)

# StartTimePicker
$minTimePicker = New-Object System.Windows.Forms.DateTimePicker
$minTimePicker.Location = “130, 42”
$minTimePicker.Width = “150”
$minTimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$minTimePicker.CustomFormat = “HH:mm:ss”
$minTimePicker.ShowUpDown = $TRUE
$mainForm.Controls.Add($minTimePicker)


#EndDatePicker
$enddatePicker = New-Object System.Windows.Forms.DateTimePicker
$enddatePicker.Location = “130, 77”
$enddatePicker.Width = “150”
$enddatePicker.Format = [windows.forms.datetimepickerFormat]::custom
$enddatePicker.CustomFormat = “MM/dd/yyyy”
$mainForm.Controls.Add($enddatePicker)


# endTimePicker
$maxTimePicker = New-Object System.Windows.Forms.DateTimePicker
$maxTimePicker.Location = “130, 112”
$maxTimePicker.Width = “150”
$maxTimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$maxTimePicker.CustomFormat = “HH:mm:ss”
$maxTimePicker.ShowUpDown = $TRUE
$mainForm.Controls.Add($maxTimePicker)

# OK Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = “15, 160”
$okButton.ForeColor = “Black”
$okButton.BackColor = “White”
$okButton.Text = “OK”
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

[void] $mainForm.ShowDialog()

#TEMP
$datestart = $datePicker.value.ToShortDateString()
$timestart = $minTimePicker.Value.ToShortTimeString()

$start = $datestart + " " + $timestart
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("The time you picked was $start",0,"Heads up",0x1)
