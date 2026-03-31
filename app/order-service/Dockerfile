FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.12-slim
RUN useradd -m -u 1000 appuser
WORKDIR /app
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .
USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH
EXPOSE 5002
CMD ["gunicorn", "--bind", "0.0.0.0:5002", "--workers", "2", "main:app"]

