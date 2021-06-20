Function Get-FileMetadata {
    <#
        .SYNOPSIS
            Get file metadata from files in a target folder.
        
        .DESCRIPTION
            Retreives file metadata from files in a target path, or file paths, to display information on the target files.
            Useful for understanding application files and identifying metadata stored in them. Enables the administrator to view metadata for application control scenarios.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Install-VisualCRedistributables

        .OUTPUTS
            [System.Array]

        .PARAMETER Path
            A target path in which to scan files for metadata.

        .PARAMETER Include
            Gets only the specified items.

        .EXAMPLE
            Get-FileMetadata -Path "C:\Users\aaron\AppData\Local\GitHubDesktop"

            Description:
            Scans the folder specified in the Path variable and returns the metadata for each file.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = 'Specify a target path, paths or a list of files to scan for metadata.')]
        [Alias('FullName', 'PSPath')]
        [string[]]$Path,

        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False, `
                HelpMessage = 'Gets only the specified items.')]
        [Alias('Filter')]
        [string[]]$Include = @('*.exe', '*.dll', '*.ocx', '*.msi', '*.ps1', '*.vbs', '*.js', '*.cmd', '*.bat')
    )
    Begin {
        # Measure time taken to gather data
        $StopWatch = [system.diagnostics.stopwatch]::StartNew()

        # RegEx to grab CN from certificates
        $FindCN = "(?:.*CN=)(.*?)(?:,\ O.*)"

        Write-Verbose "Beginning metadata trawling."
        $Files = @()
    }
    Process {
        # For each path in $Path, check that the path exists
        ForEach ($Loc in $Path) {
            If (Test-Path -Path $Loc -IsValid) {
                # Get the item to determine whether it's a file or folder
                If ((Get-Item -Path $Loc).PSIsContainer) {
                    # Target is a folder, so trawl the folder for .exe and .dll files in the target and sub-folders
                    Write-Verbose "Getting metadata for files in folder: $Loc"
                    $items = Get-ChildItem -Path $Loc -Recurse -Include $Include
                }
                Else {
                    # Target is a file, so just get metadata for the file
                    Write-Verbose "Getting metadata for file: $Loc"
                    $items = Get-Item -Path $Loc
                }

                # Create an array from what was returned for specific data and sort on file path
                $Files += $items | Select-Object @{Name = "Path"; Expression = {$_.FullName}}, `
                @{Name = "Owner"; Expression = {(Get-Acl -Path $_.FullName).Owner}}, `
                @{Name = "Vendor"; Expression = {$(((Get-AcDigitalSignature -Path $_ -ErrorAction SilentlyContinue).Subject -replace $FindCN, '$1') -replace '"', "")}}, `
                @{Name = "Company"; Expression = {$_.VersionInfo.CompanyName}}, `
                @{Name = "Description"; Expression = {$_.VersionInfo.FileDescription}}, `
                @{Name = "Product"; Expression = {$_.VersionInfo.ProductName}}, `
                @{Name = "ProductVersion"; Expression = {$_.VersionInfo.ProductVersion}}, `
                @{Name = "FileVersion"; Expression = {$_.VersionInfo.FileVersion}}
            }
            Else {
                Write-Error "Path does not exist: $Loc"
            }
        }
    }
    End {

        # Return the array of file paths and metadata
        $StopWatch.Stop()
        Write-Verbose "Metadata trawling complete. Script took $($StopWatch.Elapsed.TotalMilliseconds) ms to complete."
        Return $Files | Sort-Object -Property Path
    }
}

# [Get Extended File Properties.ps1 ](https://github.com/guyrleech/Microsoft/blob/master/Get%20Extended%20File%20Properties.ps1)
Function Get-ExtendedProperties
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true,HelpMessage='File name to retrieve properties of')]
        [ValidateScript({Test-Path -Path $_})]
        [string]$fileName ,
        [AllowNull()]
        [string[]]$properties
    )

    [hashtable]$propertiesToIndex = @{}
    ## need to use absolute paths
    $fileName = Resolve-Path -Path $fileName | Select-Object -ExpandProperty Path
    $shellApp = New-Object -Com shell.application
    $myFolder = $shellApp.Namespace( (Split-Path -Path $fileName -Parent) )
    $myFile = $myFolder.Items().Item( (Split-Path -Path $fileName -Leaf) )

    0..500 | ForEach-Object `
    {
        If( $key = $myFolder.GetDetailsOf( $null , $_ ) )
        {
            Try
            {
                $propertiesToIndex.Add( $key , $_ )
            }
            Catch
            {
            }
        }
    }

    Write-Verbose "Got $($propertiesToIndex.Count) unique property names"

    If( ! $PSBoundParameters[ 'properties' ] -or ! $properties -or ! $properties.Count )
    {
        ForEach( $property in $propertiesToIndex.GetEnumerator() )
        {
            $thisProperty = $myFolder.GetDetailsOf( $myFile , $property.Value )
            If( ! [string]::IsNullOrEmpty( $thisProperty ) )
            {
                [pscustomobject]@{ 
                    'Property' = $property.Name
                    'Value' = $thisProperty
                }
            }
        }
    }
    Else
    {
        ForEach( $property in $properties )
        {
            $index = $propertiesToIndex[ $property ]
            If( $index -ne $null )
            {
                $myFolder.GetDetailsOf( $myFile , $index -as [int] )
            }
            Else
            {
                Write-Warning "No index for property `"$property`""
            }
        }
    }
}

# $f = Get-FileMetadata "H:/image/TIM图片20190902041853.jpg" 
# $f = Get-Item -Path "H:/image/TIM图片20190902041853.jpg" 
$TagLib = "H:\\ElectronProject\\capturescreen\\src\\TagLibSharp.dll"
# [Can't get Taglib# to work with PowerShell 7 ](https://github.com/mono/taglib-sharp/issues/209)
Add-Type -Path $TagLib
[System.Reflection.Assembly]::LoadFile($TagLib)
# [System.Reflection.Assembly]::LoadFile((Resolve-Path ("./taglib-sharp.dll")))
$path_file = "H:\\image\\123.jpg"
$path_file =Resolve-Path $path_file
$song = [TagLib.File]::Create("H:\\image\\123.jpg")
# $song.ImageTag.Comment = "氷菓"
# $song.ImageTag.Comment = $null
$song.Tag.Comment = "氷 菓"
# $song.Tag.Comment = "123"
# $song.Tag.Comment = $null
$song.Save()
# foreach ($tag in $song.Tag)
# {
#     Write-Host "tag:" $tag
# }

# $FilePath = 'H:/image/123.jpg'
# $Folder = Split-Path -Parent -Path $FilePath
# $File = Split-Path -Leaf -Path $FilePath
# $Shell = New-Object -COMObject Shell.Application
# $ShellFolder = $Shell.NameSpace($Folder)
# $ShellFile = $ShellFolder.ParseName($File)
# $ShellFile
# $ShellFile | Add-Member NoteProperty 
# $i = Get-ExtendedProperties 'H:/image/TIM图片20190902041853.jpg'
# $ShellFile.Comments = "qweqwewq" 
# $w = $ShellFolder.GetDetailsOf($ShellFile,24)
# $m = $ShellFile | Get-Member
# Write-Host $ShellFile.ExtendedProperty("System.Title")
# $e =$ShellFile.ExtendedProperty("infotip")
# $ShellFile.ExtendedProperty("infotip").split("`n")
# $ShellFile.ExtendedProperty("infotip").split("`n")[0]
