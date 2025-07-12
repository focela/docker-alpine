# Security Policy

## Overview

This document outlines security policies, vulnerability reporting procedures, and best practices for the Docker Alpine container infrastructure. This project includes built-in security features including firewall (iptables), intrusion prevention (fail2ban), monitoring (Zabbix), and secure logging capabilities.

## Supported Versions

We maintain security support for the following versions:

| Version/Tag          | Support Status | Security Updates | Alpine Base |
|---------------------|----------------|------------------|-------------|
| `latest`            | ✅ Supported   | Continuous       | Latest      |
| Current release tags| ✅ Supported   | Regular updates  | Latest      |
| Older release tags  | ⚠️ Limited     | Critical only    | Various     |
| Development tags    | ❌ Unsupported | No updates       | Various     |

> **Important:** Always use specific release tags in production. The `latest` tag should only be used for development and testing.

## Vulnerability Reporting

### Security Contact

If you discover a security vulnerability, please report it responsibly:

**Email:** [security@focela.com](mailto:security@focela.com)

### Reporting Guidelines

**Do NOT:**
- Create public GitHub issues for security vulnerabilities
- Discuss vulnerabilities in public forums or chat rooms
- Share exploit code publicly before coordinated disclosure

**DO include:**
- **Vulnerability Description:** Clear explanation of the security issue
- **Component Affected:** Which container service/feature is impacted (monitoring, firewall, logging, etc.)
- **Reproduction Steps:** Detailed steps to reproduce the vulnerability
- **Attack Scenario:** How this could be exploited in practice
- **Impact Assessment:** Potential damage and affected systems
- **Environment Details:** Container configuration, Alpine version, enabled features
- **Suggested Mitigation:** If you have recommendations for fixes

### Response Timeline

Our security response process:

- **Initial Response:** Acknowledgment within 72 hours
- **Triage:** Severity assessment within 5 business days
- **Investigation:** Full analysis and reproduction
- **Resolution:**
   - **Critical:** 24-48 hours
   - **High:** 1-2 weeks
   - **Medium:** 2-4 weeks
   - **Low:** Next regular release
- **Disclosure:** Coordinated disclosure after fix is available

## Built-in Security Features

This container includes several security components that require proper configuration:

### Firewall Protection
- **iptables rules management** via `CONTAINER_ENABLE_FIREWALL`
- **fail2ban intrusion prevention** via `CONTAINER_ENABLE_FAIL2BAN`
- **Automatic IP blocking** for suspicious activities
- **Configurable jail settings** for different services

### Monitoring & Alerting
- **Zabbix agent integration** for security monitoring
- **Real-time intrusion detection alerts**
- **System health monitoring** with security implications
- **Auto-discovery of security events**

### Secure Logging
- **Fluent-bit log shipping** with tamper-resistant logging
- **Logrotate management** to prevent log-based attacks
- **Centralized log collection** for security analysis
- **Audit trail preservation**

### Access Control
- **User/group management** via permissions system
- **Configurable user privileges**
- **Container isolation** through proper user mapping

## Security Configuration Guide

### Essential Security Settings

#### Firewall Configuration
```bash
# Enable firewall protection
CONTAINER_ENABLE_FIREWALL=TRUE
CONTAINER_ENABLE_FAIL2BAN=TRUE

# Configure fail2ban settings
FAIL2BAN_STARTUP_DELAY=15
FAIL2BAN_MAX_RETRY=5
FAIL2BAN_TIME_BAN=10m
FAIL2BAN_IGNORE_IP="127.0.0.1/8 ::1 YOUR_TRUSTED_NETWORKS"
```

#### Monitoring Security
```bash
# Enable secure monitoring
CONTAINER_ENABLE_MONITORING=TRUE
ZABBIX_ENABLE_AUTOREGISTER=TRUE

# Restrict agent access
ZABBIX_SERVER="YOUR_ZABBIX_SERVER_IP"
# Avoid using 0.0.0.0/0 in production
```

#### Logging Security
```bash
# Enable secure logging
CONTAINER_ENABLE_LOGROTATE=TRUE
CONTAINER_ENABLE_LOGSHIPPING=TRUE

# Configure log retention
LOGROTATE_RETAIN_DAYS=90
SCHEDULING_LOG_LEVEL=8
```

### Environment Variable Security

**Critical Security Variables:**
- Never expose database credentials in plain text
- Use Docker secrets or external secret management
- Rotate authentication tokens regularly
- Validate all input parameters

**Docker Secrets Support:**
```bash
# Use _FILE suffix for sensitive variables
DB_PASSWORD_FILE=/run/secrets/db_password
ZABBIX_SERVER_PSK_FILE=/run/secrets/zabbix_psk
```

### Network Security

#### Port Exposure
```bash
# Minimize exposed ports
# Only expose necessary services:
# - 10050: Zabbix agent (if monitoring externally)
# - 2020: Fluent-bit HTTP (if using external metrics)
# - Custom application ports only
```

#### Service Isolation
- Use dedicated networks for different services
- Implement proper inter-container communication
- Configure firewall rules for container-to-container access

## Security Best Practices

### Deployment Security

1. **Image Verification**
   ```bash
   # Always verify image signatures (when available)
   docker pull focela/docker-alpine:latest
   # Verify checksums and signatures
   ```

2. **Runtime Security**
   ```bash
   # Run with minimal privileges
   docker run --user 1000:1000 \
     --read-only \
     --tmpfs /tmp \
     --tmpfs /var/run \
     focela/docker-alpine:latest
   ```

3. **Resource Limits**
   ```bash
   # Apply resource constraints
   docker run --memory="512m" \
     --cpus="1.0" \
     --pids-limit 100 \
     focela/docker-alpine:latest
   ```

### Configuration Security

1. **Secrets Management**
   - Use Docker secrets, Kubernetes secrets, or external vaults
   - Never embed credentials in environment variables
   - Rotate secrets regularly
   - Audit secret access

2. **Feature Minimization**
   ```bash
   # Disable unused features
   CONTAINER_ENABLE_FAIL2BAN=FALSE  # If not needed
   CONTAINER_ENABLE_MONITORING=FALSE  # If not needed
   CONTAINER_ENABLE_LOGSHIPPING=FALSE  # If not needed
   ```

3. **Validation & Sanitization**
   - Validate all configuration inputs
   - Use safe defaults for all variables
   - Implement input sanitization for user-provided values

### Operational Security

1. **Monitoring**
   - Enable comprehensive logging and monitoring
   - Set up alerts for security events
   - Monitor resource usage for anomalies
   - Review access logs regularly

2. **Updates & Maintenance**
   - Keep base Alpine packages updated
   - Monitor security advisories for Alpine Linux
   - Update container images regularly
   - Patch underlying host systems

3. **Backup & Recovery**
   - Secure backup of configuration
   - Test disaster recovery procedures
   - Encrypt sensitive backup data
   - Store backups in secure locations

### Alpine Linux Specific Security

1. **Package Management**
   - Regularly update Alpine packages
   - Monitor Alpine security advisories
   - Use minimal package installations
   - Verify package signatures

2. **musl libc Considerations**
   - Understand musl vs glibc security differences
   - Monitor musl-specific security issues
   - Test thoroughly on Alpine-based systems

## Incident Response

### Security Incident Detection
- Monitor fail2ban logs for intrusion attempts
- Watch Zabbix alerts for anomalous behavior
- Review application logs for suspicious activities
- Check system resource usage patterns

### Response Procedures
1. **Immediate Actions**
   - Isolate affected containers
   - Preserve evidence (logs, configurations)
   - Assess impact scope
   - Implement emergency mitigations

2. **Investigation**
   - Analyze logs and monitoring data
   - Determine attack vectors
   - Assess data exposure
   - Document findings

3. **Recovery**
   - Apply security patches
   - Update configurations
   - Restore from clean backups if necessary
   - Implement additional controls

## Security Resources

### Documentation
- [Alpine Linux Security](https://security.alpinelinux.org/)
- [s6-overlay Security Considerations](https://github.com/just-containers/s6-overlay)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### Security Tools Integration
- **Vulnerability Scanning:** Integrate with tools like Trivy, Clair, or Snyk
- **Runtime Security:** Consider tools like Falco for runtime monitoring
- **Compliance:** Implement CIS Docker Benchmark compliance

### Reporting Security Issues in Dependencies
- **Alpine Packages:** Report to Alpine Linux security team
- **Base Images:** Follow Docker Hub/Alpine security procedures
- **Third-party Components:** Report to respective maintainers

---

**Remember:** Security is a shared responsibility. While we provide security features and guidance, proper configuration and operational security depend on your deployment practices.
