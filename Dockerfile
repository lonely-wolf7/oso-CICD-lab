# Fix Dockerfile
FROM python:3.10-alpine3.18 AS build

# Install dependencies for building pex
RUN apk --no-cache add libxml2-dev libxslt-dev gcc python3 python3-dev py3-pip musl-dev linux-headers

# Ensure pex is installed and create the wrapper
RUN python3 -m ensurepip --upgrade && python3 -m pip install pex~=2.1.47
RUN mkdir /source
COPY requirements.txt /source/
RUN pex -r /source/requirements.txt -o /source/pex_wrapper

FROM python:3.10-alpine3.18 AS final

# Upgrade packages and prepare work directory
RUN apk upgrade --no-cache
WORKDIR /dsvw
RUN adduser -D dsvw && chown -R dsvw:dsvw /dsvw

# Copy necessary files and ensure permissions
COPY dsvw.py .
RUN sed -i 's/127.0.0.1/0.0.0.0/g' dsvw.py
COPY --from=build /source/pex_wrapper /dsvw/

# Expose port and set user
EXPOSE 65412
USER dsvw

# Update CMD to point to the correct location
CMD ["/dsvw/pex_wrapper", "/dsvw/dsvw.py"]
