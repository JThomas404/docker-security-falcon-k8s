FROM python:3.11.12-slim AS builder

WORKDIR /app

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.11.12-slim AS build-image

ENV PATH="/opt/venv/bin:$PATH"

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app

COPY ./app /app

RUN addgroup --system --gid 1001 pygroup && \
    adduser --system --uid 1001 --gid 1001 pyuser && \
    chown -R pyuser:pygroup /app

USER pyuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]