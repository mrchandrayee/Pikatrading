# Generated by Django 4.2.4 on 2025-03-20 04:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('order', '0022_rename_product_id_order_order_id'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='order_id',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
