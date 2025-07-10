# Contributing to Docker Alpine

Thank you for your interest in contributing to the Docker Alpine project! This guide will help you understand our development process and coding standards.

## Table of Contents

- [Project Overview](#project-overview)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [File Structure](#file-structure)
- [Commit Message Standards](#commit-message-standards)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)

## Project Overview

This project provides a comprehensive Alpine Linux container infrastructure framework built on s6-overlay, featuring:

- **Container initialization scripts** for system setup and configuration
- **Service management** with automatic dependency handling and s6-overlay integration
- **Monitoring integration** with Zabbix templates and auto-discovery capabilities
- **Log shipping** with Fluent-bit and automatic logrotate configuration discovery
- **Security features** including firewall (iptables) and intrusion prevention (fail2ban)
- **Flexible configuration** through environment variables and structured defaults system

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Basic understanding of s6-overlay service management
- Familiarity with Alpine Linux and container ecosystems
- Knowledge of Bash scripting and JSON configuration

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/focela/docker-alpine.git
   cd docker-alpine
   ```

2. **Understand the structure**
   ```
   .
   ├── install/
   │   ├── assets/
   │   │   ├── defaults/          # Environment variable defaults (00-container, 02-permissions, etc.)
   │   │   └── functions/         # Reusable bash functions library (00-container)
   │   └── etc/
   │       ├── cont-init.d/       # Container initialization scripts
   │       ├── fluent-bit/        # Fluent-bit configuration and parsers
   │       └── services.available/ # s6-overlay service definitions with run scripts
   └── zabbix_templates/          # Zabbix monitoring templates
       ├── zabbix_agent_container.xml
       └── zabbix_fail2ban.json
   ```

3. **Test your changes**
   - Build test containers with your modifications
   - Verify service startup sequence and functionality
   - Check log output and monitoring integration
   - Test with various environment variable configurations

## Code Style Guidelines

### Bash Scripts

All bash scripts must follow these standards:

#### File Structure
```bash
#!/command/with-contenv bash
#-----------------------------------------------------------------------------
# Script Purpose
#
# Purpose: Brief description of what this script does
# Context: Runs in s6-overlay environment with with-contenv wrapper
# Note: Additional context or relationship to other components
#-----------------------------------------------------------------------------



#-----------------------------------------------------------------------------
# SECTION NAME
#-----------------------------------------------------------------------------
# Brief explanation of what this section accomplishes
code_here
```

#### Formatting Rules
- **Shebang**: Always use `#!/command/with-contenv bash` for s6-overlay compatibility
- **Indentation**: 2 spaces (no tabs)
- **Line length**: Maximum 120 characters
- **Variable expansion**: Use `${VAR:-default}` format for safe expansion
- **Naming**: Use `snake_case` for variables, lowercase for functions
- **Comments**: Above code blocks, never inline

#### Required Elements
- **Script description block** after shebang with exactly 3 blank lines before code
- **Section headers** for logical grouping of functionality
- **Explanatory comments** for complex operations only
- **Proper file ending** with exactly one trailing newline
- **Function calls**: Use container functions like `print_debug`, `liftoff`, `prepare_service`

#### S6-Overlay Integration
- **Initialization scripts**: Must call `liftoff` when complete
- **Service scripts**: Must handle service lifecycle properly
- **Dependencies**: Use `check_container_initialized` and `check_service_initialized`

### JSON Configuration Files

#### Zabbix Templates
- **Indentation**: 2 spaces consistently
- **No trailing commas** (strict JSON compliance for import compatibility)
- **Preserve UUIDs** and exact field names for Zabbix import functionality
- **Consistent formatting** for deeply nested structures

#### Fluent-bit Configuration
- **Follow Fluent-bit syntax requirements**
- **Maintain parser definitions compatibility**
- **Group related configurations logically**

### Environment Variables

- Use `CONTAINER_` prefix for framework-specific variables
- Use `ENABLE_` prefix for feature toggles
- Follow existing naming patterns in `install/assets/defaults/`
- Provide sensible defaults for all variables

## File Structure

### Component Organization

The project follows a numbered prefix system for initialization order:

| Prefix | Component | Purpose |
|--------|-----------|---------|
| `00-` | Container core | Basic container setup and functions |
| `01-` | Timezone | System timezone configuration |
| `02-` | Permissions | User/group management |
| `03-` | Monitoring | Zabbix agent and monitoring |
| `04-` | Scheduling | Cron and logrotate |
| `05-` | Logging | Fluent-bit log shipping |
| `06-` | Messaging | SMTP configuration |
| `07-` | Firewall | iptables and fail2ban |
| `99-` | Finalization | Final container setup |

### Adding New Components

#### Defaults Files (`install/assets/defaults/`)
- **Naming**: `##-component` (e.g., `08-newfeature`)
- **Purpose**: Sets default environment variables for a specific feature
- **Integration**: Must be sourced by other scripts using `get_defaults`
- **Format**: Bash variable assignments with `${VAR:-default}` pattern

#### Functions Library (`install/assets/functions/`)
- **Current structure**: Uses `00-container` as the main library
- **New functions**: Add to existing file or create component-specific files
- **Dependencies**: Functions must work with s6-overlay environment

#### Initialization Scripts (`install/etc/cont-init.d/`)
- **Naming**: Match defaults number prefix: `##-component`
- **Purpose**: Handles one-time container initialization
- **Requirements**: Must call `liftoff` when complete
- **Dependencies**: Use container functions for consistency

#### Service Definitions (`install/etc/services.available/`)
- **Structure**: `##-component/run` (executable script)
- **Purpose**: Contains the main service execution logic
- **Requirements**: Must handle service lifecycle, dependencies, and restart behavior
- **Integration**: Should use `prepare_service` and dependency checks

#### Monitoring Templates (`zabbix_templates/`)
- **Naming**: Descriptive names with appropriate extension
- **Formats**: XML for Zabbix 3.x/4.x, JSON for Zabbix 5.x/6.x+
- **Purpose**: Provide monitoring capabilities for container services

### Naming Conventions

| Component Type | Pattern | Example |
|----------------|---------|---------|
| Defaults | `##-component` | `03-monitoring` |
| Init Scripts | `##-component` | `03-monitoring` |
| Services | `##-component/run` | `03-monitoring/run` |
| Templates | `descriptive_name.ext` | `zabbix_agent_container.xml` |
| Fluent-bit | `component.conf` | `parsers.conf` |

## Commit Message Standards

We strictly follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: New features or functionality
- **fix**: Bug fixes
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic changes)
- **refactor**: Code refactoring without behavior changes
- **test**: Adding or modifying tests
- **chore**: Maintenance tasks

### Scopes
- **defaults**: Environment variable defaults
- **functions**: Bash function library
- **cont-init**: Container initialization scripts
- **services**: Service definitions
- **zabbix**: Zabbix monitoring templates
- **logging**: Logging and log shipping configuration
- **fluent-bit**: Fluent-bit specific configuration

### Examples
```bash
# Good examples
feat(services): add monitoring service definition
fix(cont-init): resolve timezone configuration issue
docs(readme): update installation instructions
feat(zabbix): add Fail2Ban monitoring template
feat(defaults): add logging configuration defaults

# Bad examples
fix stuff
updated monitoring
Add new feature
Fixed bug
```

## Pull Request Process

### Before Submitting

1. **Test thoroughly**
   - Build and test containers with your changes
   - Verify all services start correctly in proper order
   - Check monitoring and logging functionality
   - Test with various environment variable combinations

2. **Follow code style**
   - Run through the style guidelines checklist
   - Ensure proper documentation headers
   - Verify commit message format compliance
   - Check for consistent indentation and formatting

3. **Update documentation**
   - Update relevant README sections
   - Add or modify inline documentation
   - Update this CONTRIBUTING.md if process changes
   - Document new environment variables

### Pull Request Template

When submitting a PR, please use this template:

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] New feature (feat)
- [ ] Bug fix (fix)
- [ ] Documentation update (docs)
- [ ] Code refactoring (refactor)
- [ ] Chore/maintenance

## Component(s) Affected
- [ ] Container initialization
- [ ] Service definitions
- [ ] Monitoring templates
- [ ] Logging configuration
- [ ] Documentation

## Testing
- [ ] Built and tested containers locally
- [ ] Verified service startup sequence
- [ ] Checked log output and monitoring
- [ ] Tested with different configurations
- [ ] Verified backward compatibility

## Checklist
- [ ] Code follows style guidelines
- [ ] Proper bash script headers added
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Conventional commit messages used
- [ ] No breaking changes introduced
```

## Testing Guidelines

### Container Testing

1. **Build test containers**
   ```bash
   # Build with your changes
   docker build -t test-alpine .
   
   # Test with various configurations
   docker run -e CONTAINER_ENABLE_MONITORING=TRUE test-alpine
   docker run -e CONTAINER_ENABLE_LOGROTATE=TRUE test-alpine
   ```

2. **Service verification**
   - All services should start without errors
   - Check `/tmp/.container/` for initialization markers
   - Verify service dependencies are handled correctly
   - Test service restart and failure recovery

3. **Monitoring integration**
   - Test Zabbix agent connectivity
   - Verify auto-registration functionality
   - Check custom monitoring items and discovery rules
   - Validate template import/export

### Configuration Testing

1. **Environment variable testing**
   - Test default values work correctly
   - Test custom configurations override defaults
   - Verify error handling for invalid values
   - Check backward compatibility

2. **Service integration**
   - Test inter-service dependencies
   - Verify startup order and timing
   - Check service restart behavior
   - Test graceful shutdown handling

### Fluent-bit Testing

1. **Log processing**
   - Verify log file discovery
   - Test parser functionality
   - Check output formatting
   - Validate log shipping

## Documentation Standards

### Inline Documentation

- **Purpose over implementation**: Explain why, not just what
- **Keep it concise**: One line comments preferred
- **Update with changes**: Documentation should match current behavior
- **Complex logic**: Always document non-obvious bash constructs

### README Updates

When adding new features:
- Update feature list with clear descriptions
- Add configuration examples with real environment variables
- Include troubleshooting information
- Update environment variable reference table
- Add monitoring and logging details

### Code Comments

```bash
# Good: Explains the purpose and reasoning
# Wait for log files to be populated before starting fail2ban to prevent startup errors
sleep ${FAIL2BAN_STARTUP_DELAY}

# Good: Explains complex logic
# Extract autoregister metadata from configuration files for host metadata setup
autoregister_metadata=$(grep -h "# Autoregister=" "${ZABBIX_CONFIG_PATH}"/"${ZABBIX_CONFIG_FILE}".d/*.conf | cut -d = -f2 | xargs | tr " " ":" | sed 's/^/:/' | sed 's/$/:/')

# Bad: States the obvious
# Sleep for the delay time
sleep ${FAIL2BAN_STARTUP_DELAY}
```

## Getting Help

- **Issues**: Use GitHub issues for bug reports and feature requests
- **Discussions**: Use GitHub discussions for questions and implementation ideas
- **Code Review**: Maintainers will review PRs and provide constructive feedback
- **Documentation**: Check existing code for patterns and examples

## Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). Please read and follow it when contributing.

---

Thank you for contributing to making Alpine container infrastructure better! 🚀
