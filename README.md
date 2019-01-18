# Loebolus
Loebolus aims to make all the public domain Loebs more easily downloadable by re-hosting the PDF's directly, without the need to enter CAPTCHA's.

* Data: <https://github.com/ryanfb/loebolus-data>
* Copyright assessment: <https://github.com/ryanfb/loeb-copyright/>

## SYNOPSIS

The tools used to construct the site are:

 * `associations.rb` - builds an association YAML from the HTML at [Downloebables](http://www.edonnelly.com/loebs.html)
 * `yaml2html.rb` - builds the index HTML using the association YAML and `index.haml`
 * `yaml2rdf.rb` - builds the assocation RDF using the association YAML

To use the tools you'll need to do: `bundle install`
