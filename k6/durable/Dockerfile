FROM mcr.microsoft.com/azure-functions/powershell:3.0

# install dotnet 3.1 modules
RUN apt-get update && apt-get install -y libcurl3-gnutls && apt-get install -y apt-transport-https
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
RUN dpkg -i /tmp/packages-microsoft-prod.deb
RUN apt-get update && apt-get install -y aspnetcore-runtime-3.1

# install azure-powershell module from PSGallery
#RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted && \
#    pwsh -Command Install-Module -Name Az -Scope AllUsers -Repository PSGallery && \
#    pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FUNCTIONS_WORKER_RUNTIME_VERSION=~7 \
    AzureWebJobsStorage=DefaultEndpointsProtocol=https;AccountName=tmtestsa;AccountKey=gb+JRoMNQoxFBiUnh5qWoFR07pe/7aMw76sP9yTXqzn5S43dL4ShLo+Ca2sIsru0ws8clOLCtBGAXVKd3FRMpw==;EndpointSuffix=core.windows.net \
    WEBSITE_HOSTNAME=localhost


COPY . /home/site/wwwroot