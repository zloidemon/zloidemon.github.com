.include "config.mk"

BUILD   := _build
LAYOUTS := _layouts
POSTS   := _posts
OUTPUT  := _site

ASSETS_DIR := assets/posts

help:
	@echo "Usage: $(MAKE) <target>"
	@echo ""
	@echo "Targets:"
	@echo "  all       Full build (posts, archives, tags, index, atom, cname, assets, 404)"
	@echo "  serve     Build and serve at http://localhost:8000"
	@echo "  deploy    Build and deploy to GitHub Pages"
	@echo "  draft     Create a new post (usage: $(MAKE) draft TITLE=\"Post Title\")"
	@echo "  clean     Remove _site/ and _data/"

all: posts archives tags index atom cname assets assets-posts 404

posts: ${BUILD}/posts.sh ${BUILD}/frontmatter.awk ${BUILD}/resolve-assets.awk ${LAYOUTS}/default.m4 ${LAYOUTS}/post.m4 ${POSTS}/*.md
	sh ${BUILD}/posts.sh \
	  ${POSTS} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${ASSETS_DIR}

archives: ${BUILD}/archives.sh ${LAYOUTS}/archive.m4 ${LAYOUTS}/default.m4 _data/posts.txt
	sh ${BUILD}/archives.sh \
	  _data \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}"

tags: ${BUILD}/tags.sh ${LAYOUTS}/archive.m4 ${LAYOUTS}/default.m4 _data/posts.txt
	sh ${BUILD}/tags.sh \
	  _data \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}"

index: ${BUILD}/index.sh ${LAYOUTS}/post.m4 ${LAYOUTS}/default.m4 _data/posts.txt
	sh ${BUILD}/index.sh \
	  _data \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}"

atom: ${BUILD}/atom.sh _data/posts.txt
	sh ${BUILD}/atom.sh \
	  _data \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${LAYOUTS}

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

draft:
	${BUILD}/draft.sh "${TITLE}" "${POSTS}" "${LAYOUTS}"

_data/posts.txt: ${BUILD}/posts.sh
	sh ${BUILD}/posts.sh \
	  ${POSTS} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${ASSETS_DIR}

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
	git remote add origin ${SITE_REPO} && \
	git push origin master --force

.PHONY: help all posts archives tags index atom cname assets assets-posts 404 clean serve test draft deploy
