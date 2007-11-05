# Add new mime types for use in respond_to blocks:
Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register_alias "application/msword", :doc
