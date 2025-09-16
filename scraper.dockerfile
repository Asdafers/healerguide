FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy

WORKDIR /app

RUN pip install requests beautifulsoup4 playwright

COPY scraper.py /app/scraper.py

CMD ["python", "scraper.py"]