function Decrypt-GlpiConfigSettings {
    param($String)
    if ($String -is [System.Security.SecureString]) {
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(
                $string))
    }
    elseif ($String -is [System.String]) {
        $String
    }
}