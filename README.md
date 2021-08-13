# FortifyToolsInstaller

## Introduction

Build secure software fast with [Fortify](https://www.microfocus.com/en-us/solutions/application-security). Fortify offers end-to-end application security solutions with the flexibility of testing on-premises and on-demand to scale and cover the entire software
development lifecycle.  With Fortify, find security issues early and fix at the speed of DevOps.

The `FortifyToolsInstaller.sh` script in this repository allows for easily installing and optionally running various Fortify tools commonly used in CI/CD pipelines, like ScanCentral Client, FoD Uploader, and FortifyVulnerabilityExporter. See [USAGE.txt](USAGE.txt) for detailed instructions.

## Requirements

The `FortifyToolsInstaller.sh` script is designed to use as little external tools as possible, allowing it to run on most systems and containers that provide the `bash` shell. The script uses the following external software:

* `bash`: Required to run the script
* `curl` or `wget`: Required to download tool installation bundles; the script will automatically select one of these tools based on availability
* `unzip`: Required for most tool installations to extract tool installation bundles
* `chmod`: Optional but highly recommended to update script executable permissions
* `mktemp`: Optional, used to generate temporary filenames for download bundles

## Developers

After making any user-facing changes, make sure to run the following command to update usage documentation:

```
./FortifyToolsInstaller.sh -h 2> USAGE.txt
```

## License

See [LICENSE.TXT](LICENSE.TXT)

