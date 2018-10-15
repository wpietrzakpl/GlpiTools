Function Encrypt-GlpiConfigSettings {
    param($string)
    if ($string -is [System.Security.SecureString]) {
        $string
    }
    elseif ($string -is [System.String] -and $String -notlike '') {
        ConvertTo-SecureString -String $string -AsPlainText -Force
    }
}