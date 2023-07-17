$target_host = Read-Host -Prompt "Enter the target_host you want to test"
$logFile = "nettest.log"

Add-Content $logFile "$(Get-Date)"
Add-Content $logFile (Test-NetConnection $target_host)

if (!(Test-NetConnection $target_host).PingSucceeded) {
    $traceRoute = Test-NetConnection $target_host -TraceRoute
    Add-Content $logFile $traceRoute

    foreach ($ip in $traceRoute.TraceRoute) {
        try {
            $dnsName = (Resolve-DnsName -Type PTR -Name $ip -ErrorAction Stop).NameHost
            Add-Content $logFile "$ip : $dnsName"
        }
        catch {
            Add-Content $logFile "$ip : Unable to resolve"
        }
    }
}
