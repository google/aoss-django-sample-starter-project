from django.http import HttpResponse
from loguru import logger

def hello(request):
    logger.info("Application Started")

    return HttpResponse("Hello, World!")