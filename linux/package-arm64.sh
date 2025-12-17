#!/bin/bash
# Package ARM64 Linux build manually without deleting source files

set -e

VERSION="2.4.1+2001"
BUILD_DIR="build/linux/arm64/release/bundle"
DIST_DIR="dist/${VERSION}"
PKG_NAME="vx-${VERSION}-linux-arm64"

echo "Packaging ARM64 Linux build..."

# Check if ARM64 build exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: ARM64 build not found at $BUILD_DIR"
    echo "Please build first using: make docker_arm64_simple"
    exit 1
fi

# Create dist directory
mkdir -p "$DIST_DIR"

# ============================================
# Create DEB package manually
# ============================================
echo "Creating DEB package..."

DEB_DIR="$DIST_DIR/${PKG_NAME}_deb"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/vx"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/pixmaps"

# Copy application files
cp -r "$BUILD_DIR"/* "$DEB_DIR/usr/share/vx/"

# Create symlink to binary
ln -sf /usr/share/vx/vx "$DEB_DIR/usr/bin/vx"

# Create control file
cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: vx
Version: ${VERSION}
Section: net
Priority: optional
Architecture: arm64
Maintainer: 5vnetworkllc <contactvproxy@proton.me>
Description: An easy-to-use, multi-platform proxy client
 VX is a cross-platform proxy client application.
EOF

# Create postinst script
cat > "$DEB_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e
chmod +x /usr/share/vx/data/flutter_assets/packages/tm_linux/assets/x
echo "Installed VX"
EOF

chmod 755 "$DEB_DIR/DEBIAN/postinst"

# Create desktop file
cat > "$DEB_DIR/usr/share/applications/vx.desktop" << EOF
[Desktop Entry]
Name=VX
Comment=An easy-to-use proxy client
Exec=/usr/bin/vx
Icon=vx
Terminal=false
Type=Application
Categories=Network;
StartupNotify=true
MimeType=x-scheme-handler/vx;
EOF

# Copy icon if exists
if [ -f "assets/dev/icon.png" ]; then
    cp "assets/dev/icon.png" "$DEB_DIR/usr/share/pixmaps/vx.png"
fi

# Build DEB package
dpkg-deb --build "$DEB_DIR" "$DIST_DIR/${PKG_NAME}.deb"
echo "✅ DEB package created: $DIST_DIR/${PKG_NAME}.deb"

# Cleanup
rm -rf "$DEB_DIR"

# ============================================
# Create TAR.GZ package
# ============================================
echo "Creating TAR.GZ package..."

TAR_DIR="$DIST_DIR/${PKG_NAME}_tar"
mkdir -p "$TAR_DIR"
cp -r "$BUILD_DIR" "$TAR_DIR/vx"

cd "$DIST_DIR"
tar -czf "${PKG_NAME}.tar.gz" -C "${PKG_NAME}_tar" vx
cd - > /dev/null

echo "✅ TAR.GZ package created: $DIST_DIR/${PKG_NAME}.tar.gz"

# Cleanup
rm -rf "$TAR_DIR"

# ============================================
# Create RPM package (if rpmbuild is available)
# ============================================
if command -v rpmbuild &> /dev/null; then
    echo "Creating RPM package..."
    
    RPM_BUILD_DIR="$DIST_DIR/${PKG_NAME}_rpm"
    mkdir -p "$RPM_BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    
    # Create tarball for RPM
    tar -czf "$RPM_BUILD_DIR/SOURCES/${PKG_NAME}.tar.gz" -C "build/linux/arm64/release" bundle
    
    # Create spec file
    cat > "$RPM_BUILD_DIR/SPECS/vx.spec" << EOF
Name:           vx
Version:        2.4.1
Release:        2001
Summary:        An easy-to-use, multi-platform proxy client
License:        Commercial
URL:            https://vx.5vnetwork.com
Source0:        ${PKG_NAME}.tar.gz
BuildArch:      aarch64

%description
VX is a cross-platform proxy client application.

%prep
%setup -q -n bundle

%install
mkdir -p %{buildroot}/usr/share/vx
mkdir -p %{buildroot}/usr/bin
cp -r * %{buildroot}/usr/share/vx/
ln -sf /usr/share/vx/vx %{buildroot}/usr/bin/vx

%post
chmod +x /usr/share/vx/data/flutter_assets/packages/tm_linux/assets/x || true
echo "Installed VX"

%files
/usr/share/vx/*
/usr/bin/vx

%changelog
* $(date "+%a %b %d %Y") 5V Network <contactvproxy@proton.me> - 2.4.1-2001
- ARM64 build
EOF
    
    # Build RPM
    rpmbuild --define "_topdir $RPM_BUILD_DIR" -bb "$RPM_BUILD_DIR/SPECS/vx.spec"
    
    # Copy RPM to dist
    find "$RPM_BUILD_DIR/RPMS" -name "*.rpm" -exec cp {} "$DIST_DIR/${PKG_NAME}.rpm" \;
    
    echo "✅ RPM package created: $DIST_DIR/${PKG_NAME}.rpm"
    
    # Cleanup
    rm -rf "$RPM_BUILD_DIR"
else
    echo "⚠️  rpmbuild not found, skipping RPM package"
fi

echo ""
echo "================================================"
echo "ARM64 packaging complete!"
echo "================================================"
echo "Packages created in: $DIST_DIR"
ls -lh "$DIST_DIR"/${PKG_NAME}*
echo ""
echo "To install:"
echo "  DEB: sudo dpkg -i $DIST_DIR/${PKG_NAME}.deb"
echo "  TAR: tar -xzf $DIST_DIR/${PKG_NAME}.tar.gz"
echo "  RPM: sudo rpm -i $DIST_DIR/${PKG_NAME}.rpm"

