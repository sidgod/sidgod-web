.PHONY: serve build clean

# Local development server with drafts and live reload
serve:
	hugo server -D --navigateToChanged

# Production build
build:
	hugo --minify

# Clean generated files
clean:
	rm -rf public/ resources/
