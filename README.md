# FortifyToolsInstaller

## Introduction

Build secure software fast with [Fortify](https://www.microfocus.com/en-us/solutions/application-security). Fortify offers end-to-end application security solutions with the flexibility of testing on-premises and on-demand to scale and cover the entire software
development lifecycle.  With Fortify, find security issues early and fix at the speed of DevOps.

The `FortifyToolsInstaller.sh` script in this repository allows for easily installing and optionally running various Fortify tools commonly used in CI/CD pipelines, like ScanCentral Client, FoD Uploader, and FortifyVulnerabilityExporter. See [USAGE.txt](USAGE.txt) for detailed instructions.

**Note** `FortifyToolsInstaller.sh` is currently in early beta status; functionality may change at any time.

## Developers

After making any user-facing changes, make sure to run the following command to update usage documentation:

```
./FortifyToolsInstaller.sh -h 2> USAGE.txt
```

## License

See [LICENSE.TXT](LICENSE.TXT)

