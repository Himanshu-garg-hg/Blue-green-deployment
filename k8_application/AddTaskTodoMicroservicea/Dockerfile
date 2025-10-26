# Use the official Python image as the base image
FROM python:3.9

# Set the working directory in the container
WORKDIR /app

# Copy the application files into the container
COPY . .

# Install necessary packages (include curl and gnupg before fetching Microsoft key)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		unixodbc \
		unixodbc-dev \
		curl \
		gnupg \
		ca-certificates \
		apt-transport-https \
	&& rm -rf /var/lib/apt/lists/*

# Add Microsoft package signing key using gpg --dearmor (avoid apt-key which may be missing/deprecated)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg

# Add the Microsoft package repository
RUN curl -fsSL https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update \
	&& ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt

# Start the FastAPI application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
#CMD uvicorn app:app --host 0.0.0.0 --port 8000