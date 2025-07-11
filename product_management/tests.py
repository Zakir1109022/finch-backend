from django.apps import apps
from django.test import SimpleTestCase

from product_management.apps import ProductManagementConfig


class ProductManagementConfigTests(SimpleTestCase):
    def test_app_config_name(self):
        self.assertEqual(ProductManagementConfig.name, 'product_management')

    def test_app_config_verbose_name(self):
        self.assertEqual(ProductManagementConfig.verbose_name.strip(), 'Product Management')

    def test_app_config_is_registered(self):
        app_config = apps.get_app_config('product_management')
        self.assertIsInstance(app_config, ProductManagementConfig)
