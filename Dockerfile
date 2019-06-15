FROM buildpack-deps:stretch

ENV DEBIAN_FRONTEND noninteractive

ARG WINE_VERSION=wine
ARG PYTHON_VERSION=2.7.16
ARG PYINSTALLER_VERSION=3.3

# we need wine for this all to work, so we'll use the PPA
RUN set -x \
    && dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends wine wine32 xvfb xauth cabextract winbind \
    && apt-get clean \
    && wget -nv -O /usr/local/bin/winetricks 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' \
    && chmod +x /usr/local/bin/winetricks

# wine settings
ENV WINEPREFIX /vc2008express/
ENV WINEARCH   win32
ENV WINEDEBUG  fixme-all

# Install VS Express 2008
#
# It's should be possible to automate this build with a command similar to the
# following, but the silent install is not working, we need to run this on a
# real computer to click the buttons.
# So let copy a wine prefix.
#
# WINEPREFIX=/vc2008express WINEARCH=win32 WINEDEBUG=fixme-all xvfb-run winetricks -q vc2008express
# tar -zcvf vc2008express.tar.gz vc2008express
# split -d -b 99M vc2008express.tar.gz vc2008express.tar.gz.part
#
COPY vc2008express.tar.gz.part00 /vc2008express.tar.gz.part00
COPY vc2008express.tar.gz.part01 /vc2008express.tar.gz.part01
COPY vc2008express.tar.gz.part02 /vc2008express.tar.gz.part02
COPY vc2008express.tar.gz.part03 /vc2008express.tar.gz.part03
RUN cat vc2008express.tar.gz.part* | tar -zxvf - \
  && chown root:root /vc2008express \
  && rm vc2008express.tar.gz.part*

# PYPI repository location
ENV PYPI_URL=https://pypi.python.org/
# PYPI index location
ENV PYPI_INDEX_URL=https://pypi.python.org/simple

# Install python inside wine
RUN set -x \
    && wget -nv https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION.msi \
    && wine msiexec /qn /a python-$PYTHON_VERSION.msi \
    && rm python-$PYTHON_VERSION.msi \
    && sed -i 's/_windows_cert_stores = .*/_windows_cert_stores = ("ROOT",)/' "$WINEPREFIX/drive_c/Python27/Lib/ssl.py" \
    && echo 'wine '\''C:\Python27\python.exe'\'' "$@"' > /usr/bin/python \
    && echo 'wine '\''C:\Python27\Scripts\easy_install.exe'\'' "$@"' > /usr/bin/easy_install \
    && echo 'wine '\''C:\Python27\Scripts\pip.exe'\'' "$@"' > /usr/bin/pip \
    && echo 'wine '\''C:\Python27\Scripts\pyinstaller.exe'\'' "$@"' > /usr/bin/pyinstaller \
    && chmod +x /usr/bin/* \
    && echo 'assoc .py=PythonScript' | wine cmd \
    && echo 'ftype PythonScript=c:\Python27\python.exe "%1" %*' | wine cmd \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && rm -rf /tmp/.wine-* \
    && /usr/bin/pip install --upgrade setuptools \
    && /usr/bin/pip install pyinstaller \
    && /usr/bin/pip install py2exe_py2

# Define environment variables like "vcvarsall.bat"
ENV DevEnvDir="C:\Program Files\Microsoft Visual Studio 9.0\Common7\IDE"
ENV Framework35Version="v3.5"
ENV FrameworkDir="C:\windows\Microsoft.NET\Framework"
ENV FrameworkVersion="v2.0.50727"
ENV INCLUDE="C:\Program Files\Microsoft Visual Studio 9.0\VC\INCLUDE;C:\Program Files\Microsoft Visual Studio 9.0\VC\PlatformSDK\include;C:\Program Files\Microsoft SDKs\Windows\v6.0A\Include;"
ENV LIB="C:\Program Files\Microsoft Visual Studio 9.0\VC\LIB;C:\Program Files\Microsoft Visual Studio 9.0\VC\PlatformSDK\lib;C:\Program Files\Microsoft SDKs\Windows\v6.0A\Lib;"
ENV LIBPATH="C:\windows\Microsoft.NET\Framework\v3.5;C:\windows\Microsoft.NET\Framework\v2.0.50727;C:\Program Files\Microsoft Visual Studio 9.0\VC\LIB;C:\Program Files\Microsoft SDKs\Windows\v6.0A\Lib;"
ENV VCINSTALLDIR="C:\Program Files\Microsoft Visual Studio 9.0\VC"
ENV VSINSTALLDIR="C:\Program Files\Microsoft Visual Studio 9.0"
ENV WindowsSdkDir="C:\Program Files\Microsoft Visual Studio 9.0\VC\PlatformSDK"
ENV WINEPATH="C:\Program Files\Microsoft Visual Studio 9.0\Common7\IDE;C:\Program Files\Microsoft Visual Studio 9.0\VC\BIN;C:\Program Files\Microsoft Visual Studio 9.0\Common7\Tools;C:\windows\Microsoft.NET\Framework\v3.5;C:\windows\Microsoft.NET\Framework\v2.0.50727;C:\Program Files\Microsoft Visual Studio 9.0\VC\VCPackages;C:\Program Files\Microsoft Visual Studio 9.0\VC\PlatformSDK\bin;C:\Python27\;C:\Python27\Scripts;C:\windows\system32;C:\windows;C:\windows\system32\wbem"

WORKDIR $WINEPREFIX/drive_c
