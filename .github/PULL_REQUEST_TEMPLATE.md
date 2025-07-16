---
name: Pull Request
about: Submit changes to the Docker Alpine project
title: '[TYPE]: Brief description of changes'
labels: ''
assignees: ''
---

## Summary

**Brief description of what this PR accomplishes:**
<!-- Provide a clear and concise summary of the changes -->

---

## Motivation and Context
- Why is this change required?
- What problem does it solve?
- Reference any related issues (e.g., "Closes #123").

---

## Type of Change
- [ ] 🐛 **Bug fix** (non-breaking change which fixes an issue)
- [ ] ✨ **New feature** (non-breaking change which adds functionality)
- [ ] 💥 **Breaking change** (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 **Documentation** (changes to documentation only)
- [ ] 🔧 **Configuration** (changes to config files, build scripts, or CI/CD)
- [ ] 🧹 **Maintenance** (code cleanup, refactoring, dependency updates)
- [ ] 🔒 **Security** (security improvements or vulnerability fixes)

---

## Changes Made

### Core Components
- [ ] **Alpine Linux packages** - Added/updated/removed packages
- [ ] **S6 Overlay services** - Modified service scripts or configurations
- [ ] **Docker configuration** - Dockerfile, docker-compose, or build changes
- [ ] **Multi-architecture support** - Changes affecting amd64/arm64/arm builds

### Features & Integrations
- [ ] **Monitoring** - Zabbix Agent, health checks, or observability changes
- [ ] **Logging** - Fluent Bit, log rotation, or log management modifications
- [ ] **Security** - OpenDoas, Fail2ban, permission, or access control changes
- [ ] **Communication** - MSMTP, email, or notification system updates
- [ ] **Automation** - Cron jobs, Git operations, or scripting improvements
- [ ] **Development tools** - GoLang, YQ, debugging, or utility additions

### Configuration & Operations
- [ ] **Environment variables** - New or modified configuration options
- [ ] **File permissions** - UID/GID mapping or permission changes
- [ ] **Service lifecycle** - Start/stop/restart behavior modifications
- [ ] **Hook system** - Custom startup scripts or lifecycle hooks

---

## Technical Details

### Root Cause (for bug fixes)
<!-- Describe what was causing the issue -->

### Solution Approach
<!-- Explain how you solved the problem or implemented the feature -->

### Implementation Notes
<!-- Any important technical details, design decisions, or considerations -->

### Dependencies
<!-- List any new dependencies or version updates -->

---

## Testing

### Testing Performed
- [ ] **Container builds** - Verified successful builds for all architectures
- [ ] **Service functionality** - Tested all affected services start/stop correctly
- [ ] **Integration testing** - Verified component interactions work as expected
- [ ] **Regression testing** - Confirmed existing functionality remains intact
- [ ] **Security testing** - Validated security configurations and permissions
- [ ] **Performance testing** - Verified no significant performance degradation

### Test Environment
<!-- Describe your testing setup -->
- **Platform(s):** (e.g., amd64, arm64, arm/v7)
- **Docker version:**
- **Base Alpine version:**
- **Testing method:** (e.g., docker-compose, kubernetes, standalone)

### Test Results
<!-- Provide evidence of successful testing -->
```bash
# Example test commands and results
docker build -t test-alpine .
docker run --rm test-alpine /bin/sh -c "echo 'Test completed successfully'"
```

---

## Documentation

### Documentation Updates
- [ ] **README.md** - Updated if user-facing changes
- [ ] **CHANGELOG.md** - Added entry following Keep a Changelog format
- [ ] **Code comments** - Added/updated inline documentation
- [ ] **Configuration examples** - Updated sample configs or docker-compose files
- [ ] **Security documentation** - Updated SECURITY.md if relevant

### Breaking Changes Documentation
- [ ] **Migration guide** - Provided upgrade instructions
- [ ] **Deprecation notices** - Added appropriate warnings
- [ ] **API changes** - Documented any interface modifications

---

## Compliance & Standards

### Code Quality
- [ ] **Conventional Commits** - Commit messages follow [conventional commits](https://conventionalcommits.org/) format
- [ ] **Shell scripting** - Scripts follow best practices and are shellcheck compliant
- [ ] **Dockerfile best practices** - Follows Docker and Alpine Linux guidelines
- [ ] **S6 Overlay standards** - Service scripts follow s6-overlay conventions

### Security Checklist
- [ ] **No sensitive data** - No passwords, keys, or secrets in code
- [ ] **Principle of least privilege** - Minimal permissions granted
- [ ] **Input validation** - User inputs are properly validated
- [ ] **Security scanning** - No new vulnerabilities introduced
- [ ] **File permissions** - Appropriate file and directory permissions set

### Alpine Linux Specific
- [ ] **Package management** - Uses Alpine package manager (apk) appropriately
- [ ] **Multi-stage builds** - Minimizes final image size
- [ ] **musl libc compatibility** - Code works with musl instead of glibc
- [ ] **BusyBox utilities** - Uses BusyBox-compatible shell commands

---

## Deployment Considerations

### Compatibility
- [ ] **Backward compatibility** - Changes don't break existing deployments
- [ ] **Version compatibility** - Works with supported Alpine Linux versions
- [ ] **Container orchestration** - Compatible with Docker Compose, Kubernetes, etc.

### Performance Impact
- [ ] **Resource usage** - No significant increase in CPU/memory usage
- [ ] **Image size** - Minimal impact on final image size
- [ ] **Startup time** - No degradation in container startup performance

### Operational Impact
- [ ] **Monitoring** - Maintains compatibility with existing monitoring setup
- [ ] **Logging** - Log format and levels remain consistent
- [ ] **Health checks** - Health check endpoints continue to function

---

## Review Checklist

### For Reviewers
Please verify the following before approving:
- [ ] **Code review** - Logic is sound and follows project patterns
- [ ] **Security review** - No security vulnerabilities introduced
- [ ] **Documentation review** - All changes are properly documented
- [ ] **Testing verification** - Adequate testing has been performed
- [ ] **Compliance check** - Follows all project standards and guidelines

### Additional Context
<!-- Any additional information for reviewers -->

---

## Related Issues
- **Closes:** <!-- Link to issues this PR closes (e.g., "Closes #123") -->
- **Related:** <!-- Link to related issues, discussions, or PRs -->

---

## Screenshots/Logs
<!-- If applicable, add screenshots, logs, or command outputs to help explain the changes -->
```bash
# Example output or logs demonstrating the changes
```

---

## Contributor Checklist
<!-- Please check all that apply -->
- [ ] I have read and followed the [Contributing Guidelines](../CONTRIBUTING.md)
- [ ] I have checked that no similar PR already exists
- [ ] I have tested my changes thoroughly
- [ ] I have updated documentation as needed
- [ ] I have added appropriate labels to this PR
- [ ] I have requested review from appropriate maintainers
- [ ] My commit messages follow [conventional commits](https://conventionalcommits.org/) format
- [ ] I understand this PR may be closed if it doesn't meet project standards

---

## Additional Notes
<!-- Any other information that would be helpful for reviewers -->

---

**Thank you for contributing to the Docker Alpine project! 🎉**

*For questions about this PR template or the contribution process, please refer to our [Contributing Guide](../CONTRIBUTING.md) or reach out to the maintainers.*
