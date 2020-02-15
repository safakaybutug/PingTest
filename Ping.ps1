$Header = @"
<style>
* {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  margin: 0;
  padding: 0;
}
table {
  width: 80%;
  border-collapse: collapse;
}
td, th {
  border: 1px solid #ddd;
  padding: 8px;
}
tr:nth-child(even){background-color: #f2f2f2;}
tr:hover {background-color: #ddd; transition: all .1s;}
th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #4CAF50;
  color: white;
}
</style>
"@

$COMPUTER = (Get-Content C:\computers.txt)
$User = "sender mail address" 
$PWord = ConvertTo-SecureString -String "mail pass" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$end = 0

while($end -eq 0){
    $offline = @()
    $offlinestr = 'Ulaşılamayan IP Adresleri : ' 
    
   
        $computer | ForEach-Object {                        
                       if (test-Connection -ComputerName $_ -Count 1 -quiet)  
                        {
                             Write-Host "$_ is online"
                         } else 
                            { 
                            if (test-Connection -ComputerName $_ -Count 4 -quiet)  
                                {
                                    Write-Host "$_ is exactly online"
                                } else
                                    {
                                        write-host "$_ is not online!" 
                                        $offline += New-Object -TypeName PsObject -Property @{
                                        "Device IP" = $_
                                        Status = "Ping Request Timed Out"
                                        Time = get-date
                                        }
                                      $offlinestr += $_ + ' '                                      
                                    }
                            }
                        }
                    Clear-Host
                    Start-Sleep 5
                    
                    $Body = $offline | ConvertTo-Html -Head $Header | Out-String
                        
                    if($offline){
                        Send-MailMessage -From $User -to "to address" -Subject $offlinestr -Body $Body -Encoding utf8 -BodyAsHtml -smtpserver 'smtp server address' -port '587' -Credential $Credential 
                                }
                }
                               