FROM python:3.11.12-slim

WORKDIR /app

RUN addgroup --system pygroup && adduser --system --ingroup pygroup pyuser

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /app/app

RUN chown -R pyuser:pygroup /app

USER pyuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
