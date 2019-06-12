FROM buildpack-deps:stretch

ENV DEBIAN_FRONTEND noninteractive

ARG WINE_VERSION=wine
ARG PYTHON_VERSION=2.7.16
ARG PYINSTALLER_VERSION=3.3

# we need wine for this all to work, so we'll use the PPA
RUN set -x \
    && dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends wine wine32 \ 
    && apt-get clean \
    && wget  -O /usr/local/bin/winetricks 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' \
    && chmod +x /usr/local/bin/winetricks

# wine settings
ENV WINEPREFIX /opt/wine
ENV WINEARCH   win32
ENV WINEDEBUG  fixme-all

# PYPI repository location
ENV PYPI_URL=https://pypi.python.org/
# PYPI index location
ENV PYPI_INDEX_URL=https://pypi.python.org/simple

# Install python inside wine
RUN set -x \
    && wget -nv https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION.msi \
    && wine msiexec /qn /a python-$PYTHON_VERSION.msi \
    && rm python-$PYTHON_VERSION.msi \
    && wget -nv https://download.microsoft.com/download/7/9/6/796EF2E4-801B-4FC4-AB28-B59FBF6D907B/VCForPython27.msi \
    && wine msiexec /qn /a VCForPython27.msi \
    && rm VCForPython27.msi \    
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
    && /usr/bin/pip install --upgrade setuptools

RUN set -x \
    && /usr/bin/pip install pyinstaller==$PYINSTALLER_VERSION \
    && /usr/bin/pip install py2exe_py2

ENV VCINSTALLDIR="C:/Program Files/Common Files/Microsoft/Visual C++ for Python/9.0/VC"

WORKDIR $WINEPREFIX/drive_c
