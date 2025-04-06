# Generated by Django 4.2.4 on 2025-02-15 07:26

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('order', '0013_order_product_amount_order_vat'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='product_amount_bf_tax',
            field=models.FloatField(blank=True, help_text='Total cost exclude shipping cost & before tax', null=True),
        ),
    ]
