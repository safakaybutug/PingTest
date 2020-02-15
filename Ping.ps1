#Mail Body içeriği için html tablo tasarımı.
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
#ping atılacak ip listesini dahil eder. 
$COMPUTER = (Get-Content C:\computers.txt)
#Mail gönderecek hesap adresi.
$User = "sender mail address" 
#Mail şifresini powershellde kullanabileceği formata çevirir.
$PWord = ConvertTo-SecureString -String "mail pass" -AsPlainText -Force
#Kullanıcı adını ve şifreyi "credential" değişkenine atar.
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$end = 0
#Yukarıdaki "end" değişkeni 0 ise  "while" döngüsü dönsün diyoruz "end" değişkeni sabit olduğu için ping işlemi sürekli devam edecek. 
while($end -eq 0){
    $offline = @()
    $offlines = 'Ulaşılamayan IP Adresleri : ' 
        #Listeyi ForEach döngüsüne sokuyoruz.
        $computer | ForEach-Object {  
                        #Test connection ile ping atıyoruz eğer ping varsa hosta "ip is online" yazacak.                      
                       if (test-Connection -ComputerName $_ -Count 1 -quiet)  
                        {
                             Write-Host "$_ is online"
                         } else 
                            { 
                             #Bazen ping kayıplarına denk gelinebiliyor ilk ping başarısız olursa 4 tane daha attırıyoruz. 
                            if (test-Connection -ComputerName $_ -Count 4 -quiet)  
                                {
                                    Write-Host "$_ is exactly online"
                                } else
                                    {   #4 ping de başarısız olursa hosta "ip is not online" yazacak.
                                        write-host "$_ is not online!" 
                                        #"offline" değerini psobject oluşturup time ve statusu belirtiyoruz.
                                        $offline += New-Object -TypeName PsObject -Property @{
                                        "Device IP" = $_
                                        Status = "Ping Request Timed Out"
                                        Time = get-date
                                        }
                                      $offlines += $_ + ' '   #'Ulaşılamayan IP Adresleri : ' ile ip leri "offlines" değeriyle birleştirir.                                  
                                    }
                            }
                        }
                    Clear-Host #hostu temizler.
                    Start-Sleep 5 #5 saniye bekler.
                    #mail içeriğini htmle çevirir.
                    $Body = $offline | ConvertTo-Html -Head $Header | Out-String
                    #Erişilemeyen ip adresi oluşursa mail gönderecek.    
                    if($offline){
                        Send-MailMessage -From $User -to "to address" -Subject $offlines -Body $Body -Encoding utf8 -BodyAsHtml -smtpserver 'smtp server address' -port '587' -Credential $Credential 
                                }
                }
                               