.include "config.mk"
.export AWK

BUILD   := _tools
LAYOUTS := _layouts
POSTS   := _posts
OUTPUT  := _build/site

ASSETS_DIR := assets/posts
DATA    := _build/data

help:
	@echo "Usage: $(MAKE) <target>"
	@echo ""
	@echo "Targets:"
	@echo "  all       Full build (posts, archives, tags, index, atom, cname, assets, 404)"
	@echo "  serve     Build and serve at http://localhost:8000"
	@echo "  deploy    Build and deploy to GitHub Pages"
	@echo "  draft     Create a new post (usage: $(MAKE) draft TITLE=\"Post Title\")"
	@echo "  clean     Remove _build/site/ and _build/data/"

all: posts archives tags index atom cname assets assets-posts 404

posts: ${BUILD}/posts.sh ${BUILD}/frontmatter.awk ${BUILD}/resolve-assets.awk ${LAYOUTS}/default.m4 ${LAYOUTS}/post.m4 ${POSTS}/*.md
	sh ${BUILD}/posts.sh \
	  ${POSTS} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${ASSETS_DIR} \
	  ${DATA} \
	  ${SITE_REPO_HTTP}

archives: ${BUILD}/archives.sh ${LAYOUTS}/archive.m4 ${LAYOUTS}/default.m4 ${DATA}/posts.txt
	sh ${BUILD}/archives.sh \
	  ${DATA} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${SITE_REPO_HTTP}

tags: ${BUILD}/tags.sh ${LAYOUTS}/archive.m4 ${LAYOUTS}/default.m4 ${DATA}/posts.txt
	sh ${BUILD}/tags.sh \
	  ${DATA} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${SITE_REPO_HTTP}

index: ${BUILD}/index.sh ${LAYOUTS}/post.m4 ${LAYOUTS}/default.m4 ${DATA}/posts.txt
	sh ${BUILD}/index.sh \
	  ${DATA} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${SITE_REPO_HTTP}

atom: ${BUILD}/atom.sh ${DATA}/posts.txt
	sh ${BUILD}/atom.sh \
	  ${DATA} \
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

${DATA}/posts.txt: ${BUILD}/posts.sh
	sh ${BUILD}/posts.sh \
	  ${POSTS} \
	  ${LAYOUTS} \
	  ${OUTPUT} \
	  ${SITE_URL} \
	  "${SITE_TITLE}" \
	  ${ASSETS_DIR} \
	  ${DATA} \
	  ${SITE_REPO_HTTP}

clean:
	rm -rf ${OUTPUT} ${DATA}

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
