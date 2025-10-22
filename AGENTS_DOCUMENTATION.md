# Bazzite OS - AI Coding Agent Documentation

## Overview
Bazzite is a custom Fedora Atomic Linux distribution optimized for gaming and desktop use cases. Built on cloud-native container technology using `bootc`/`rpm-ostree`, it provides an immutable base with extensive gaming optimizations and hardware support.

## Architecture

### Base Technology Stack
- **Base OS**: Fedora Atomic (Kinoite/Silverblue)
- **Container Runtime**: bootc/rpm-ostree for immutable deployments
- **Build System**: Just (command runner) with Containerfile
- **Package Manager**: dnf5 with extensive COPR repository usage
- **Desktop Environments**: KDE Plasma (Kinoite) and GNOME (Silverblue)

### Image Variants
```
bazzite                    # Desktop KDE
bazzite-gnome              # Desktop GNOME  
bazzite-deck               # Steam Deck/HTPC KDE
bazzite-deck-gnome         # Steam Deck/HTPC GNOME
bazzite-nvidia             # Desktop KDE + NVIDIA
bazzite-gnome-nvidia       # Desktop GNOME + NVIDIA
bazzite-deck-nvidia        # Deck KDE + NVIDIA
bazzite-deck-nvidia-gnome  # Deck GNOME + NVIDIA
```

## Build System

### Just Commands
```bash
just build <target> <image>     # Build container image
just build-iso <target> <image> # Build ISO installer
just run <target> <image>       # Run container interactively
just list-images                # List local images
just clean-images               # Cleanup images
just just-check                 # Validate Just syntax
```

### Containerfile Structure
Multi-stage build with three main targets:
1. **bazzite** - Base desktop builds
2. **bazzite-deck** - Steam Deck/HTPC variant  
3. **bazzite-nvidia** - NVIDIA GPU support

### Key Build Arguments
```dockerfile
BASE_IMAGE_NAME="kinoite|silverblue"    # Desktop environment
IMAGE_FLAVOR="main|nvidia|surface|asus" # Hardware variant
KERNEL_FLAVOR="bazzite"                 # Custom kernel
FEDORA_VERSION="41"                     # Fedora version
```

## Repository Structure

```
├── Containerfile              # Main build definition
├── Justfile                   # Build automation
├── build_files/              # Build helper scripts
├── system_files/             # System configurations
│   ├── desktop/              # Desktop-specific configs
│   ├── deck/                 # Steam Deck configs
│   ├── nvidia/               # NVIDIA-specific configs
│   └── overrides/            # Global overrides
├── just_scripts/             # Just command implementations
├── installer/                # ISO creation templates
└── spec_files/              # Custom RPM package specs
```

## Key Components

### Custom Kernel
- **Source**: kernel-bazzite (based on fsync kernel)
- **Features**: HDR support, expanded hardware compatibility
- **Version**: Tracked in build workflows (e.g., 6.16.4-102.bazzite.fc42)

### Package Management
```bash
# Primary COPR repositories
bazzite-org/bazzite           # Core Bazzite packages
bazzite-org/bazzite-multilib  # Multilib support
ublue-os/staging              # Universal Blue staging
ublue-os/packages             # Universal Blue packages
hhd-dev/hhd                   # Handheld daemon

# Key versionlocked packages
ostree, rpm-ostree, plymouth   # Core system
pipewire, wireplumber          # Audio stack
mesa, vulkan-drivers          # Graphics stack
```

### Gaming Stack
- **Steam**: Pre-installed with custom launcher scripts
- **Gamescope**: Compositor for gaming mode
- **MangoHud**: Performance overlay
- **vkBasalt**: Post-processing layer
- **LatencyFleX**: Frame pacing
- **Wine/Proton**: Compatibility layers

### Hardware Support
- **AMD**: Full ROCm/HIP support, Southern Islands GPUs
- **NVIDIA**: Proprietary drivers (NVIDIA variants)
- **Controllers**: xone (Xbox), extensive handheld support
- **Display**: DisplayLink, HDR, variable refresh rate
- **Audio**: PipeWire with custom configurations

## Configuration Management

### System Integration
- **systemd services**: Custom services for hardware management
- **udev rules**: Device-specific configurations
- **dconf overrides**: Desktop environment settings
- **environment files**: System-wide variables

### Key Services
```bash
bazzite-autologin.service      # Deck auto-login
bazzite-hardware-setup.service # Hardware detection
bazzite-flatpak-manager.service # Flatpak management
hhd.service                    # Handheld daemon
wireplumber-workaround.service # Audio fixes
```

## Development Workflow

### Building Images
```bash
# Build desktop KDE image
just build bazzite kinoite

# Build Steam Deck GNOME image  
just build bazzite-deck gnome

# Build NVIDIA variant
just build bazzite-nvidia kde
```

### Testing Changes
```bash
# Validate Just syntax
just just-check

# Run container for testing
just run bazzite kde

# Build and test ISO
just build-iso bazzite kde && just run-iso bazzite kde
```

### Configuration Patterns
1. **Shared configs** in `system_files/*/shared/`
2. **DE-specific** in `system_files/*/kinoite/` or `silverblue/`
3. **Variant-specific** in appropriate subdirectories
4. **Global overrides** in `system_files/overrides/`

## Custom Packages

### Key Custom RPMs
- **bazzite-kernel**: Custom Linux kernel
- **steamdeck-kde-presets**: KDE theming
- **steamdeck-gnome-presets**: GNOME theming
- **gamescope-session-plus**: Enhanced gamescope
- **hhd**: Handheld input daemon

### Package Installation Pattern
```dockerfile
# Enable COPR and install
dnf5 -y copr enable repo/name
dnf5 -y install package-name

# Versionlock critical packages
dnf5 versionlock add critical-package
```

## Extension Guidelines

### Adding New Features
1. **Determine scope**: Desktop vs Deck vs NVIDIA
2. **Add packages** to appropriate Containerfile stage
3. **Create configs** in relevant `system_files/` directory
4. **Add services** if needed
5. **Update Just commands** if new functionality required

### Configuration Files
- **Desktop settings**: `system_files/desktop/*/etc/`
- **User configs**: `system_files/*/usr/share/` or `/etc/skel/`
- **Services**: `system_files/*/usr/lib/systemd/system/`
- **Just commands**: `system_files/*/usr/share/ublue-os/just/`

### Testing Extensions
```bash
# Build with changes
just build bazzite kde

# Test in container
just run bazzite kde

# Verify services
systemctl status new-service

# Test functionality
# ... specific tests
```

## Important Notes

### Build Requirements
- **Container runtime**: Podman or Docker
- **Build context**: Requires significant disk space and time
- **Network**: Access to GitHub and COPR repositories
- **Privileges**: Root access for ISO creation

### Security Considerations
- **SELinux**: Enforced by default
- **Secure boot**: Custom key enrollment supported
- **Image signing**: Cosign verification available
- **Immutable base**: Changes via package layering only

### Performance Optimizations
- **ZRAM**: 4GB compressed swap (Deck variant)
- **CPU schedulers**: LAVD/BORE for gaming
- **I/O scheduler**: Kyber for responsiveness
- **Kernel parameters**: Gaming-optimized defaults

## Common Patterns

### Adding COPR Packages
```dockerfile
# In appropriate RUN instruction
dnf5 -y copr enable username/repo
dnf5 -y install package-name
# Remember to disable copr in cleanup
dnf5 -y copr disable username/repo
```

### System Services
```bash
# Enable service
systemctl enable service-name

# Create override
mkdir -p /etc/systemd/system/service.service.d/
echo "[Service]" > override.conf
```

### Desktop Integration
```bash
# KDE: Copy to /usr/share/ applications/
# GNOME: Use gsettings or dconf overrides
# Both: Update /etc/skel/ for new user defaults
```

This documentation provides the essential context for AI agents to understand and extend Bazzite's build system and configuration management.