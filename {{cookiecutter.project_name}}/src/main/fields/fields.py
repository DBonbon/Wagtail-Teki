from collections import OrderedDict

from rest_framework.fields import Field
from wagtail.rich_text import expand_db_html
from wagtail.images.models import SourceImageIOError

#Tags
class TagField(Field):
    def to_representation(self, tags):
        try:
            return [
                {"name": tag.name, "slug": tag.slug, "id": tag.id} for tag in tags.all()
            ]
        except Exception:
            return []

##Costum Rich Text and Custom Image currently not used
class CustomRichTextField(Field):
    def to_representation(self, value):
        return expand_db_html(value).replace("/api", "")

#category
class GameCategoryField(Field):
    def to_representation(self, categories):
        try:
            return [
                {
                    "name": category.game_category.name,
                    "slug": category.game_category.slug,
                    "id": category.game_category.id,
                }
            for category in categories.all()
            ]
        except Exception:
            return []

class GameProductField(Field):
    def to_representation(self, products):
        try:
            return [
                {
                    "name": product.product.name,  # Use "product.product" to access the Product model
                    "slug": product.product.slug,
                    "id": product.product.id,
                }
                for product in products.all()
            ]
        except Exception:
            return []

class ImageRenditionField(Field):
    def __init__(
        self,
        filter_spec=["width-480", "width-768", "width-1024", "width-1200"],
        fallback="width-768",
        *args,
        **kwargs,
    ):
        self.filter_spec = filter_spec
        self.fallback = fallback
        super().__init__(*args, **kwargs)

    def to_representation(self, image):
        try:
            # Get the fallback rendition (with full URL)
            fallback_rendition = image.get_rendition(self.fallback)
            full_url = fallback_rendition.full_url
            alt = fallback_rendition.alt

            # Build srcset and WebP srcset for different sizes
            srcset = {}
            srcset_webp = {}

            for filter_spec in self.filter_spec:
                rendition = image.get_rendition(filter_spec)
                rendition_webp = image.get_rendition(f"{filter_spec}|format-webp")

                srcset[filter_spec] = {
                    "src": rendition.url,
                    "full_url": rendition.full_url,
                    "width": rendition.width,
                    "height": rendition.height,
                    "alt": rendition.alt,
                }

                srcset_webp[filter_spec] = {
                    "src": rendition_webp.url,
                    "full_url": rendition_webp.full_url,
                    "width": rendition_webp.width,
                    "height": rendition_webp.height,
                    "alt": rendition_webp.alt,
                }

            # Add focal point information if available
            focal_point = {
                "x": image.focal_point_x,
                "y": image.focal_point_y,
                "width": image.focal_point_width,
                "height": image.focal_point_height,
            } if image.has_focal_point() else None

            return {
                "alt": alt,
                "src": fallback_rendition.url,  # Fallback size (768px)
                "full_url": full_url,  # Use the full_url property for fallback rendition
                "srcset": srcset,  # Return srcset for responsive images
                "srcset_webp": srcset_webp,  # Return WebP srcset
                "focal_point": focal_point,  # Add focal point data if available
            }

        except SourceImageIOError:
            return {
                "alt": "",
                "src": "",  # No valid image
                "full_url": "",  # No full URL
                "srcset": {},
                "srcset_webp": {},
                "focal_point": None,
            }

class AuthorsChildPageField(Field):
    def to_representation(self, child_posts):
        #try:
        return [
            {
                "title": child.title,
                "slug": child.slug,
                "id": child.id,
                'url': child.url,
            }
        for child in child_posts
        ]

        """except Exception:
            return []"""
