build:
	hugo

serve:
	hugo server --buildDrafts

deploy:
	scripts/deploy

clean:
	rm --force --recursive build public resources

monogatari-series:
	scripts/monogatari-series-cut
