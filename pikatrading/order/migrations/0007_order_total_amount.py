# Generated by Django 4.2.4 on 2024-03-16 09:34

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('order', '0006_order_kbank_token_id'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='total_amount',
            field=models.IntegerField(blank=True, null=True),
        ),
    ]
