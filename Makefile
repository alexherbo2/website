build:
	hugo

serve:
	hugo server --buildDrafts

deploy:
	scripts/deploy

netlify:
	unlink themes/steve-losh
	git clone git://github.com/alexherbo2/hugo-theme-steve-losh themes/steve-losh
	make build

clean:
	rm -Rf build public resources

monogatari-series:
	scripts/monogatari-series-cut
