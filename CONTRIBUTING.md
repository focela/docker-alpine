# Contributing to Docker Alpine

Thank you for your interest in contributing to the Docker Alpine project! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Guidelines](#contribution-guidelines)
- [Pull Request Process](#pull-request-process)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Release Process](#release-process)
- [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

**Our Pledge:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Our Standards:**
- Professional and courteous behavior
- Constructive and respectful feedback
- Collaboration and knowledge sharing
- Respect for diverse backgrounds and experiences

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Docker** (latest stable version)
- **Git** (2.20+)
- **GitHub account** with SSH key configured
- **Basic knowledge** of Docker, Alpine Linux, and shell scripting

### First Steps

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone git@github.com:YOUR_USERNAME/docker-alpine.git
   cd docker-alpine
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream git@github.com:focela/docker-alpine.git
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

---

## Development Setup

### Local Development Environment

```bash
# Build the image locally for testing
docker build -t docker-alpine:test .

# Run the container for testing
docker run -it --rm docker-alpine:test

# Test with specific Alpine version
docker build --build-arg ALPINE_VERSION=3.19 -t docker-alpine:3.19-test .
```

### Development Tools

- **GitHub Actions** - Automated CI/CD pipeline
- **Docker Build** - Local image building and testing
- **Shell scripting** - Bash script development and testing
- **YAML validation** - GitHub Actions workflow validation

### Development Workflow

```bash
# Build and test locally before committing
docker build -t test-image .

# Run container to verify functionality
docker run -d --name test-container test-image

# Check container status
docker exec test-container s6-svstat /var/run/s6/services/*

# Clean up test resources
docker stop test-container && docker rm test-container
```

---

## Contribution Guidelines

### What We're Looking For

We welcome contributions in these areas:

#### **Core Features**
- **Alpine version support** - New Alpine Linux versions
- **Architecture support** - Additional CPU architectures
- **Security improvements** - Vulnerability fixes and hardening
- **Performance optimizations** - Build time and image size improvements

#### **Infrastructure**
- **CI/CD improvements** - GitHub Actions workflow enhancements
- **Documentation** - README, guides, and examples
- **Workflow optimization** - Build process improvements
- **Multi-platform support** - Architecture compatibility

#### **Bug Fixes**
- **Security vulnerabilities** - CVE fixes and patches
- **Compatibility issues** - Platform-specific problems
- **Build failures** - Docker build and runtime errors
- **Documentation errors** - Typos and outdated information

### What We're NOT Looking For

- **Breaking changes** without proper discussion
- **Major refactoring** without prior agreement
- **New dependencies** without justification
- **Style-only changes** without functional improvements

---

## Pull Request Process

### Before Submitting

1. **Check existing issues** - Avoid duplicate work
2. **Discuss major changes** - Open an issue first for significant changes
3. **Test locally** - Ensure your changes work as expected
4. **Update documentation** - Include relevant documentation changes
5. **Follow coding standards** - Adhere to project style guidelines

### Pull Request Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] CI/CD improvement

## Testing
- [ ] Local testing completed
- [ ] Docker build successful
- [ ] Container runs without errors
- [ ] All tests pass

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Changes tested locally
- [ ] No breaking changes introduced

## Related Issues
Closes #(issue number)
```

### Review Process

1. **Automated checks** - CI/CD validation must pass
2. **Code review** - At least one maintainer approval required
3. **Testing validation** - Changes must pass all tests
4. **Documentation review** - Documentation updates reviewed
5. **Final approval** - Maintainer approval for merge

---

## Code Standards

### General Principles

- **Readability** - Code should be self-documenting
- **Consistency** - Follow established patterns
- **Simplicity** - Prefer simple solutions over complex ones
- **Maintainability** - Consider long-term maintenance

### Shell Scripting

```bash
#!/bin/bash
# Use bash for consistency across platforms
# Always quote variables: "$variable"
# Use [[ ]] for conditional tests
# Prefer functions over inline scripts

# Good example
if [[ -f "$file" ]]; then
    process_file "$file"
fi

# Bad example
if [ -f $file ]; then
    process_file $file
fi
```

### Dockerfile Standards

```dockerfile
# Use specific base image tags
FROM alpine:3.19

# Group RUN commands to reduce layers
RUN apk add --no-cache \
    package1 \
    package2 \
    package3

# Use ARG for build-time variables
ARG ALPINE_VERSION
ENV ALPINE_VERSION=$ALPINE_VERSION

# Set proper labels
LABEL maintainer="Focela Team <maintainers@focela.com>"
LABEL version="1.0.0"
```

### YAML Standards

```yaml
# Use 2 spaces for indentation
# Quote strings with special characters
# Use consistent naming conventions

name: "Build Alpine Image"
on:
  push:
    branches: [main, develop]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: "Checkout"
        uses: actions/checkout@v4
```

---

## Testing

### Testing Requirements

All contributions must include appropriate testing:

#### **Local Testing**
- **Docker builds** - Verify successful image creation
- **Container startup** - Test container initialization
- **Service verification** - Check S6 services status
- **Basic functionality** - Test core features work

#### **CI/CD Testing**
- **GitHub Actions** - Automated workflow validation
- **Multi-platform builds** - Test on different architectures
- **Workflow syntax** - Validate YAML configuration

#### **Manual Testing**
```bash
# Test build process
docker build -t test-image .

# Test container startup
docker run -d --name test-container test-image

# Verify services
docker exec test-container s6-svstat /var/run/s6/services/*

# Clean up
docker stop test-container && docker rm test-container
```

---

## Documentation

### Documentation Standards

- **Clear and concise** - Easy to understand
- **Examples included** - Practical usage examples
- **Regular updates** - Keep documentation current
- **Multiple formats** - Markdown, inline comments, README

### Required Documentation

#### **New Features**
- **README updates** - Feature description and usage
- **CHANGELOG entries** - Version and change details
- **Inline comments** - Code documentation
- **Examples** - Usage examples and demos

#### **API Changes**
- **Interface documentation** - Clear API specifications
- **Migration guides** - Upgrade instructions
- **Breaking changes** - Detailed change descriptions
- **Deprecation notices** - Clear deprecation timeline

---

## Release Process

### Version Management

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** - Incompatible API changes
- **MINOR** - New functionality (backwards compatible)
- **PATCH** - Bug fixes (backwards compatible)

### Release Checklist

- [ ] **Code review** completed
- [ ] **Local testing** completed (Docker build & run)
- [ ] **Documentation** updated
- [ ] **CHANGELOG** updated with version
- [ ] **Git tag** created
- [ ] **GitHub Actions** triggered automatically
- [ ] **Docker images** built and pushed by CI/CD

### Creating a Release

```bash
# Update version in CHANGELOG.md
# Commit changes
git add CHANGELOG.md
git commit -m "chore: bump version to 7.10.32"

# Create and push tag
git tag -a v7.10.32 -m "Release version 7.10.32"
git push origin v7.10.32

# GitHub Actions will automatically build and push images
```

---

## Community

### Getting Help

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - General questions and discussions
- **Security Issues** - [maintainers@focela.com](mailto:maintainers@focela.com)
- **GitHub Issues** - Technical discussions and support

### Recognition

We believe in recognizing contributors:

- **Contributor list** - Listed in project documentation
- **Release notes** - Credit for significant contributions
- **Hall of fame** - Special recognition for major contributions
- **Community spotlight** - Featured contributor stories

### Stay Connected

- **Watch repository** - Get notifications for updates
- **Star project** - Show your support
- **Follow releases** - Stay updated with new versions
- **Join discussions** - Participate in community conversations

---

## Additional Resources

### Development Tools
- [Docker Documentation](https://docs.docker.com/)
- [Alpine Linux Wiki](https://wiki.alpinelinux.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Shell Scripting Guide](https://www.shellscript.sh/)

### Contributing Guides
- [Open Source Guide](https://opensource.guide/)
- [First Timers Only](https://www.firsttimersonly.com/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

### Project Resources
- [Security Policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [License](LICENSE)
- [CHANGELOG](CHANGELOG.md)

---

> **Ready to contribute?**
>
> Start by checking our [open issues](https://github.com/focela/docker-alpine/issues) or [discussions](https://github.com/focela/docker-alpine/discussions) to find something to work on.
>
> **Questions?** Open a [GitHub Discussion](https://github.com/focela/docker-alpine/discussions) or contact us at [maintainers@focela.com](mailto:maintainers@focela.com).

---

## Additional Resources

### External Resources
- [Open Source Guide](https://opensource.guide/) - Open source best practices
- [First Timers Only](https://www.firsttimersonly.com/) - Beginner-friendly contributions
- [GitHub Flow](https://guides.github.com/introduction/flow/) - GitHub workflow

### Project Resources
- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [License](LICENSE)

---

> **Questions or Concerns?**
>
> If you have questions about contributing or need assistance, please contact us at [maintainers@focela.com](mailto:maintainers@focela.com).
>
> For general project questions, visit our [Contributing Guide](CONTRIBUTING.md) or open a discussion in our [GitHub Discussions](https://github.com/focela/docker-alpine/discussions).

---

*This contributing guide is maintained according to best practices from major open-source projects including Docker, Kubernetes, and Alpine Linux.*
