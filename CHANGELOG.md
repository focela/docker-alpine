# Changelog

## Table of Contents

- [About](#about)
- [Version History](#version-history)
- [Release Information](#release-information)
- [Contributing](#contributing)
- [Additional Resources](#additional-resources)

---

## About

All notable changes to the Docker Alpine project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and the changelog format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## Version History

## [7.10.31] - 2025-09-01

### Added

#### Infrastructure & Core Systems
- **S6 Overlay v3.2.0.3** - Modern init system and process supervision
- **Multi-architecture support** - Native builds for `amd64`, `arm64`, and `arm/v7`
- **Dynamic UID/GID remapping** - Runtime user/group ID adjustment via `01-permissions`
- **Service lifecycle management** - Comprehensive start, stop, and status control

#### Monitoring & Observability
- **Zabbix Agent v7.2.6** - System monitoring with both C and Go implementations
- **Custom UID/GID configuration** - Flexible monitoring agent deployment
- **Health check capabilities** - Database connectivity verification
- **Fluent Bit v3.1.10** - Advanced log shipping and filtering
- **Log rotation & compression** - Automated log management with `logrotate`

#### Development & Automation Tools
- **GoLang v1.24.2** - Runtime support for Go-based applications
- **YQ v4.44.1** - YAML processing (jq equivalent for YAML files)
- **Git integration** - Built-in support for Git-based operations and automation
- **Configuration templating** - Dynamic config generation and override support
- **Hook system** - Custom script execution during container startup

#### Security & Access Control
- **OpenDoas v6.8.2** - Lightweight, secure sudo alternative
- **Fail2ban integration** - Intrusion prevention with firewall configuration
- **Permission normalization** - Automated security for `logrotate.d` and S6 directories
- **BusyBox extras** - Enhanced shell utilities including grep and sudo

#### Communication & Scheduling
- **MSMTP email delivery** - Reliable email transport agent
- **Gmail SMTP support** - Native Gmail integration via `ENABLE_GMAIL_SMTP`
- **SMTP debugging** - Development aid accessible on port 8025 via `DEBUG_SMTP`
- **Cron scheduling** - BusyBox-based task scheduling with custom job auto-detection

#### Developer Experience
- **Debug mode** - Comprehensive debugging and tracing via `DEBUG_MODE`
- **Quiet mode** - Suppressed non-critical output for cleaner logs
- **Package validation** - Container package update checks with version verification
- **Watchdog protection** - Runaway process monitoring and protection
- **Custom cron integration** - Automatic detection of jobs in `/assets/cron-custom/`

### Enhanced

#### Legacy Compatibility
- **Init script improvements** - Enhanced compatibility with legacy systems
- **Zabbix package verification** - Added check script for package updates
- **File permission handling** - Improved normalization across service directories

#### Operational Features
- **Configuration flexibility** - Extended override and templating capabilities
- **Process supervision** - Enhanced S6 Overlay integration for reliable service management
- **Monitoring extensions** - Expanded Zabbix Agent functionality with configuration options

---

## Release Information

### Version Schema
This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 7.10.31)
- **MAJOR** - Incompatible API changes or major feature overhauls
- **MINOR** - New functionality in a backwards compatible manner
- **PATCH** - Backwards compatible bug fixes and minor improvements

### Release Types
- **Added** - New features, components, or capabilities
- **Changed** - Modifications to existing functionality
- **Deprecated** - Features that will be removed in future versions
- **Removed** - Features removed in this version
- **Fixed** - Bug fixes and corrections
- **Security** - Security vulnerability fixes and improvements

### Links
- [Latest Release](https://github.com/focela/docker-alpine/releases/latest)
- [All Releases](https://github.com/focela/docker-alpine/releases)
- [Compare Versions](https://github.com/focela/docker-alpine/compare)

---

## Contributing

When contributing to this project, please:
1. Follow the [conventional commits](https://conventionalcommits.org/) specification
2. Update this changelog for any notable changes
3. Ensure version bumps follow semantic versioning guidelines
4. Add entries under the `[Unreleased]` section until release

For more information, see our [Contributing Guide](CONTRIBUTING.md) or [Security Policy](SECURITY.md).

---

## Additional Resources

### External Resources
- [Keep a Changelog](https://keepachangelog.com/) - Changelog format guidelines
- [Semantic Versioning](https://semver.org/) - Version numbering specification
- [Conventional Commits](https://conventionalcommits.org/) - Commit message format

### Project Resources
- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [License](LICENSE)

---

> **Questions or Concerns?**
>
> If you have questions about this changelog or need assistance, please contact us at [maintainers@focela.com](mailto:maintainers@focela.com).
>
> For general project questions, visit our [Contributing Guide](CONTRIBUTING.md) or open a discussion in our [GitHub Discussions](https://github.com/focela/docker-alpine/discussions).

---

*This changelog is maintained according to [Keep a Changelog](https://keepachangelog.com/) principles.*
