FROM buildpack-deps:stretch

ENV PYTHON2_URL=https://www.python.org/ftp/python/2.7.16/python-2.7.16.msi
ENV PYTHON3_URL=https://www.python.org/ftp/python/3.4.4/python-3.4.4.msi

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends wine wine32 \
    && wget "$PYTHON2_URL" \
    && wine msiexec /i "$(basename $PYTHON2_URL)" /L*v log.txt /passive  \
    && rm "$(basename $PYTHON2_URL)"  \
    && rm -rf /var/lib/apt/lists/*

