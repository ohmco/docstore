# Contributing to Docstore

Thank you for your interest in contributing to this Paperless-ngx deployment configuration!

## How to Contribute

### Reporting Issues

If you encounter problems:

1. Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Search existing [GitHub Issues](https://github.com/ohmco/docstore/issues)
3. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Your environment (OS, Docker version, etc.)
   - Relevant logs (redact sensitive information)

### Suggesting Enhancements

We welcome suggestions for:

- New features or scripts
- Documentation improvements
- Configuration optimizations
- Security enhancements

Please open an issue to discuss your idea before implementing.

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Testing Your Changes

Before submitting:

```bash
# Validate Docker Compose syntax
docker compose config

# Test scripts for syntax errors
bash -n setup.sh
bash -n backup.sh
bash -n restore.sh
bash -n maintenance.sh

# Test the deployment (if possible)
./setup.sh
docker compose up -d
docker compose ps
```

### Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing formatting conventions
- Keep scripts POSIX-compliant when possible

### Documentation

When adding features:

- Update relevant documentation files
- Add examples where helpful
- Update QUICK_REFERENCE.md if adding new commands
- Keep documentation clear and concise

## Areas for Contribution

### High Priority

- [ ] Automated testing scripts
- [ ] Additional security hardening
- [ ] Performance optimization guides
- [ ] Multi-architecture support

### Medium Priority

- [ ] Additional backup destinations (S3, etc.)
- [ ] Monitoring and alerting setup
- [ ] Log rotation configuration
- [ ] Alternative database support

### Documentation

- [ ] Video tutorials
- [ ] Platform-specific guides (Ubuntu, Debian, CentOS, etc.)
- [ ] Troubleshooting for specific cloud providers
- [ ] Migration guides from other document systems

## Community

- Be respectful and constructive
- Help others in discussions
- Share your deployment experiences
- Report security issues privately

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project.

## Questions?

Feel free to open an issue for questions about contributing!
