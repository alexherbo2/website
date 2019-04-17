build:
	hugo

serve:
	hugo server --buildDrafts

deploy:
	scripts/deploy

clean:
	rm -Rf build public resources

monogatari-series:
	scripts/monogatari-series-cut
