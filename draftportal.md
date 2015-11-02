##Draft portal

This portal was created using as base the following project located at [this](https://github.com/Vizzuality/Data.GBIF) GitHub repository.

##Structure
	assets  → contains images and files that are not processed by nanoc/sass
	content → contains css and erb files that are processed by nanoc/sass
	layouts → contains the main structure of the pages and several snippets of code that appear several times in the site (partials)
	output  → contains the result of the compilation and is what we upload to gbif.heroku.com

All the gems and ruby code used in the project are installed in this folder:
~/.rvm/gems/ruby-1.9.2-head@gbif/gems

In the project folder we have the following files:
	• config.rb: configuration file for compass
	• Rules: compilation rules for compass and nanoc
	• config.yaml: main configuration file for nanoc
	• Rakefile: custom tasks to compile the website
	• Gemfile: list of gems and versions used

## Folders in the this webapp that contain vizzuality files
src/webapp/css
All css and sass files taken from the output/css and content/css

src/webapp/external
These are example content files used for the mockups, mainly spcies images. We need to figure out how to deal with external images first, but this folder can ultimately be removed. For demo puposes keep it. It holds the folder and all their files from assets/img/photos, assets/img/logos, assets/img/slideshow

src/webapp/fonts
All fonts used in the design. Unclear if there are needed for the final layout. But we should keep them anyway. Taken from assets/fonts

src/webapp/img
All the static images used in the design. Taken from assets/img, but ignoring the folders copied to above paths already (e.g. photos). Also add the assets/favicon folder.

src/webapp/js
The javascript being used, incl jQuery libs. Taken from content/js

src/webapp/favicon.ico
Copied (again) from assets/favicon/favicon_32x32.ico

src/webapp/WEB-INF/pages
This is the bulk of the manual work. All files must be modified, see "Migrating html to freemarker templates"

== CSS
The css is generated via SASS source files and static Compass file includes.
The Compass files to update are: xyz


== Migrating html to freemarker templates
 - default decorator has been reworked quite a bit for menu, infoband, tabs and other variables. It also uses some i18n resources already. Best to update existing decorator instead of creating a new one from scratch
 - for each page use only pieces inside the content div
 - infoband content should go into <content tag="infoband">, see below
 - tabs content should go into <content tag="tabs">, see below
 - replace all links with correct ones, not using any suffix and proper urls in their singular form, e.g. occurrence, not occurrences. Use ids as url parameters, not query params.
 - we need to create good includes in the WEB-INF/inc folder that can be reused in various places. Good candidates for individual includes are the partials in the ruby app. Definite examples for includes are the map module and the taxonomic explorer. This hasnt been done at all!
