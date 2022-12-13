
# Get the current file its directory
$param2=$args[1]
$fileDir=Split-Path -Path $param2

# Create a new directory
New-Item "$fileDir\images" -Type Directory