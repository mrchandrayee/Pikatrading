import os
from .base import *
from enum import Enum
from datetime import timedelta

# SECURITY WARNING: don't run with debug turned on in production!


## CAPTAIN KERORO BY PASS ##

CAPTIAN_KERORO_BYPASS = 0 # Use power of captian to get through winning victory

DEBUG = False
#When DEBUG is False and a view raises an exception, all information will be sent by email to the people listed in the ADMINS setting
ADMINS = [
    ('Zian', 'xxx@gmail.com'),
]
ALLOWED_HOSTS = ['*','pikatrading.com','www.pikatrading.com']
CSRF_TRUSTED_ORIGINS = ["https://pikatrading.com", "https://www.pikatrading.com"]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_DB'),
        'USER': os.environ.get('POSTGRES_USER'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
        'HOST': 'db',
        'PORT': 5432,

    }
}

# Security
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
SECURE_SSL_REDIRECT = True


#CELERY
CELERY_BROKER_URL = 'amqp://guest:guest@rabbitmq:5672//'
CELERY_RESULT_BACKEND = 'rpc://'
CELERY_BEAT_SCHEDULE = {
    'remove-unpaid-orders': {
        'task': 'order.tasks.remove_unpaid_orders',
        'schedule': timedelta(minutes=2),  # Run every minute
    },
}

#KBANK VARIABLE
KBANK_MID = {
    'creditcard' : '45100550000001',# FOR VISA / MasterCard
    'creditcard-jut' : '45100550000001', # FOR JCB / Union Pay/TPN
    'smartpay' : '45100550000001',# FOR INSTALLMENT
    'qr' : '45100550000001', # FOR THAI QRCODE
    'wechat' : '45100550000001', # FOE WECHAT
    'alipay' : '45100550000001' # FOE ALIPAY
}
KBANK_SKEY = 'xx'
KBANK_PKEY = 'xx'
KBANK_EMBEDED_URL = 'xx'
KBANK_ORDER_URL = 'xx'
KBANK_CHARGE_URL = 'xx'
KANK_INQUIRE_QR_TRANSACTION = 'xx'
KANK_INQUIRE_CD_TRANSACTION = 'xx'

## LINE MESSAGE ## API

LINE_ACCESS_TOKEN = "xx"
LINE_PUSH_URL = "https://api.line.me/v2/bot/message/push"
LINE_SENT_TO_USER_ID  = 'xx'# To group ID PIKA NOTIFICATION
