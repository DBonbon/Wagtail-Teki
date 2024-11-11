from django import forms
from wagtail import blocks
from wagtail.rich_text import expand_db_html

from main.pages.base import BasePage

from wagtail.images.api.fields import ImageRenditionField
from wagtail.images.blocks import ImageChooserBlock
from wagtail.snippets.blocks import SnippetChooserBlock

from wagtail.blocks import (
    BooleanBlock,
    CharBlock,
    ChoiceBlock,
    DateTimeBlock,
    FieldBlock,
    IntegerBlock,
    ListBlock,
    PageChooserBlock,
    RawHTMLBlock,
    RichTextBlock,
    StreamBlock,
    StructBlock,
    StructValue,
    TextBlock,
    URLBlock,
)

class CustomRichTextBlock(blocks.RichTextBlock):
    def get_api_representation(self, value, context=None):
        return expand_db_html(value.source)

class CustomImageChooserBlock(ImageChooserBlock):
    def get_api_representation(self, value, context=None):
        if value:
            return {
                "id": value.id,
                "title": value.title,
                "full_url": value.get_rendition("original").full_url,  # Use full URL for original
                "original": {**value.get_rendition("original").attrs_dict, "full_url": value.get_rendition("original").full_url},  # Added full_url to original
                "thumbnail": {**value.get_rendition("fill-120x120").attrs_dict, "full_url": value.get_rendition("fill-120x120").full_url},  # Added full_url to thumbnail
                "srcset": {
                    "small": {**value.get_rendition("width-480").attrs_dict, "full_url": value.get_rendition("width-480").full_url},  # Added full_url to small
                    "medium": {**value.get_rendition("width-768").attrs_dict, "full_url": value.get_rendition("width-768").full_url},  # Added full_url to medium
                    "large": {**value.get_rendition("width-1024").attrs_dict, "full_url": value.get_rendition("width-1024").full_url},  # Added full_url to large
                    "extra_large": {**value.get_rendition("width-1200").attrs_dict, "full_url": value.get_rendition("width-1200").full_url},  # Added full_url to extra_large
                },
                "srcset_webp": {
                    "small": {**value.get_rendition("width-480|format-webp").attrs_dict, "full_url": value.get_rendition("width-480|format-webp").full_url},  # Added full_url to webp small
                    "medium": {**value.get_rendition("width-768|format-webp").attrs_dict, "full_url": value.get_rendition("width-768|format-webp").full_url},  # Added full_url to webp medium
                    "large": {**value.get_rendition("width-1024|format-webp").attrs_dict, "full_url": value.get_rendition("width-1024|format-webp").full_url},  # Added full_url to webp large
                    "extra_large": {**value.get_rendition("width-1200|format-webp").attrs_dict, "full_url": value.get_rendition("width-1200|format-webp").full_url},  # Added full_url to webp extra_large
                },
                "focal_point": {
                    "x": value.focal_point_x,
                    "y": value.focal_point_y,
                    "width": value.focal_point_width,
                    "height": value.focal_point_height,
                } if value.has_focal_point() else None
            }

class CardBlock(blocks.StructBlock):
    """Basic game block that contains exactly 4 cards"""
    image = CustomImageChooserBlock(required=False, null=True, blank=True, label="image")
    card_title = blocks.CharBlock(label="Card Title", required=True)
    card_hint = blocks.CharBlock(label="Card Hint", required=False, help_text="another text string can be used as hint, En translation, etc'")

    class Meta:
        min_num = 4
        max_num = 4

class ImageText(StructBlock):
    reverse = BooleanBlock(required=False)
    text = RichTextBlock()
    image = CustomImageChooserBlock()

class BodyBlock(StreamBlock):
    h1 = CharBlock()
    h2 = CharBlock()
    paragraph = RichTextBlock()
    image_text = ImageText()
    image_carousel = ListBlock(CustomImageChooserBlock())
    thumbnail_gallery = ListBlock(CustomImageChooserBlock())
