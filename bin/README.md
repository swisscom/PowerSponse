## Why external binaries?

Some of the commands in PowerSponse depend on external binaries. By default
some Sysinternal tools for remote execution of binaries are needed and are
already defined in binary-urls.txt.

The script downloads the binaries/zip files from the URLs defined in
binary-urls.txt and unzips them into the current folder.

## Usage

Use the script to download the required binaries. Use -UrlFile to specifiy the
file with the URLs to download or use a file named "binary-urls.txt".

```
cd <module folder>\bin
.\DownloadBinariesToCurrentDir.ps1 -WhatIf
.\DownloadBinariesToCurrentDir.ps1
```

