.include "config.mk"

BUILD   := _build
LAYOUTS := _layouts
POSTS   := _posts
OUTPUT  := _site

SCRIPTS := ${BUILD}/posts.py ${BUILD}/index.py ${BUILD}/archives.py ${BUILD}/tags.py ${BUILD}/atom.py

ASSETS_DIR := assets/posts

all: posts archives tags index atom cname assets assets-posts 404

posts: ${SCRIPTS} ${LAYOUTS}/default.m4 ${LAYOUTS}/post.m4 ${POSTS}/*.md
	python3 ${BUILD}/posts.py \
	  --posts ${POSTS} \
	  --layouts ${LAYOUTS} \
	  --output ${OUTPUT} \
	  --url http://${SITE_URL} \
	  --title "${SITE_TITLE}" \
	  --assets-dir ${ASSETS_DIR}

archives: ${SCRIPTS} ${LAYOUTS}/archive.m4 ${LAYOUTS}/default.m4
	python3 ${BUILD}/archives.py \
	  --data _data/posts.json \
	  --layouts ${LAYOUTS} \
	  --output ${OUTPUT} \
	  --url http://${SITE_URL} \
	  --title "${SITE_TITLE}"

tags: ${SCRIPTS} ${LAYOUTS}/archive.m4 ${LAYOUTS}/default.m4
	python3 ${BUILD}/tags.py \
	  --data _data/posts.json \
	  --layouts ${LAYOUTS} \
	  --output ${OUTPUT} \
	  --url http://${SITE_URL} \
	  --title "${SITE_TITLE}"

index: ${SCRIPTS} ${LAYOUTS}/post.m4 ${LAYOUTS}/default.m4
	python3 ${BUILD}/index.py \
	  --data _data/posts.json \
	  --layouts ${LAYOUTS} \
	  --output ${OUTPUT} \
	  --url http://${SITE_URL} \
	  --title "${SITE_TITLE}"

atom: ${SCRIPTS}
	python3 ${BUILD}/atom.py \
	  --data _data/posts.json \
	  --output ${OUTPUT} \
	  --url http://${SITE_URL} \
	  --title "${SITE_TITLE}"

cname:
	printf '%s\n' '${SITE_URL}' > ${OUTPUT}/CNAME

assets:
	mkdir -p ${OUTPUT}/assets/css
	cp assets/css/milligram.min.css ${OUTPUT}/assets/css/
	cp assets/css/custom.css ${OUTPUT}/assets/css/

assets-posts:
	mkdir -p ${OUTPUT}/assets/posts
	cp -r ${ASSETS_DIR}/* ${OUTPUT}/assets/posts/

404:
	cp 404.html ${OUTPUT}/

clean:
	rm -rf ${OUTPUT}/* _data

serve: all
	@echo "Serving at http://localhost:8000"
	@python3 -m http.server 8000 --directory ${OUTPUT}

test: serve

deploy: all
	cd ${OUTPUT} && \
	git init && \
	git add . && \
	git commit -m "Site updated at ${.TARGET}" && \
	git remote add origin git@github.com:zloidemon/zloidemon.github.com.git && \
	git push origin master --force

.PHONY: all posts archives tags index atom cname assets assets-posts 404 clean deploy serve test
