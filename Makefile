all: associations.yml index.html L001.rdf

associations.yml: associations.rb Gemfile Gemfile.lock
	bundle exec ./associations.rb

index.html: associations.yml index.haml yaml2html.rb Gemfile Gemfile.lock
	bundle exec ./yaml2html.rb < associations.yml

%.rdf: associations.yml yaml2rdf.rb Gemfile Gemfile.lock
	bundle exec ./yaml2rdf.rb < associations.yml

.PHONY: clean
clean:
	rm -v *.rdf associations.yml index.html
