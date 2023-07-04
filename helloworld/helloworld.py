from django.http import HttpResponse
from loguru import logger

def hello(request):
    logger.info("Welcome to AOSS-Django-Sample-Starter-Project!")

    return HttpResponse("Hello, World!")
