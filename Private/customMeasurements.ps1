function customMeasurements ($PropHash,$MetHash) {
    if ($PropHash) {
        $dictProperties = New-Object 'system.collections.generic.dictionary[[string],[string]]'
        foreach ($h in $PropHash.GetEnumerator() ) {
            $dictProperties.Add($h.Name, $h.Value)   
        } 
    }
    elseif ($MetHash) {
        $dictProperties = New-Object 'system.collections.generic.dictionary[[string],[double]]'
        foreach ($h in $MetHash.GetEnumerator() ) {
            $dictProperties.Add($h.Name, $h.Value)   
        } 
    }
    else {return $null}
    $dictProperties
}