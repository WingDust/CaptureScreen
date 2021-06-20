
param(
    [string[]]$raw=$(throw "Parameter missing: -raw as string[]")
    )
# "raw=$raw"
$raw = $raw | ConvertFrom-Json
# 全局变量
$script:signal = "原位置"
$script:full
$script:result = new-object bool[] 2
function getlocation {
    param (
        $i
    )
    $info = $i[0].ExtendedProperty("infotip").split("`n")
    $location = $info | Where-Object {$_ -match $signal}
    $script:full = Join-Path -path $location.split(":",2)[1].trim() -ChildPath $i.Name -ErrorAction stop
    # return $script:full
}

$sh = new-object -comobject "Shell.Application"
$recyclebin = $sh.Namespace(0xA)
$r1 =$recyclebin.Items() | Where-Object {$_.Name -eq $raw[0]} | Sort-Object ModifyDate -Descending
$r2 =$recyclebin.Items() | Where-Object {$_.Name -eq $raw[1]} | Sort-Object ModifyDate -Descending
getlocation($r1[0])
Move-Item -Path $r1[0].Path -Destination ("{0}" -f $full)
if ($?) {
    $result[0]=$True
}
getlocation($r2[0])
Move-Item -Path $r2[0].Path -Destination ("{0}" -f $full)
if ($?) {
    $result[1]=$True
}
if ($result[0] -eq $True -and $result[1] -eq $True) {
    "done"
}