FROM python:3.9-slim

WORKDIR /app

COPY app.py .

RUN pip install flask

CMD ["python", "app.py"]

# docker build -t joelwembo/argocd_blue_green_demo:latest .
# docker push joelwembo/argocd_blue_green_demo:latest
# docker run --rm -p 5000:5000 joelwembo/argocd_blue_green_demo:latest